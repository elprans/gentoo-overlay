from __future__ import annotations

import json
import subprocess
import unittest
from contextlib import redirect_stdout
from io import StringIO
from unittest.mock import patch

import pr_slack


def completed(
    args: list[str],
    *,
    returncode: int = 0,
    stdout: str = "",
    stderr: str = "",
) -> subprocess.CompletedProcess[str]:
    return subprocess.CompletedProcess(args, returncode, stdout, stderr)


class PullRequestTests(unittest.TestCase):
    def metadata(self, **updates: object) -> str:
        data = {
            "number": 42,
            "title": "Fix the thing",
            "url": "https://github.com/vercel/repo/pull/42",
            "additions": 7,
            "deletions": 2,
        }
        data.update(updates)
        return json.dumps(data)

    @patch("pr_slack.run")
    def test_resolves_current_branch_pr(self, run: unittest.mock.Mock) -> None:
        run.return_value = completed([], stdout=self.metadata())

        pr = pr_slack.resolve_pr(None)

        run.assert_called_once_with(
            ["gh", "pr", "view", "--json", pr_slack.PR_FIELDS]
        )
        self.assertEqual(pr.repository, "vercel/repo")
        self.assertEqual(pr.number, 42)

    @patch("pr_slack.run")
    def test_passes_explicit_number_or_url_to_gh(self, run: unittest.mock.Mock) -> None:
        run.return_value = completed([], stdout=self.metadata())

        pr_slack.resolve_pr("123")
        self.assertEqual(run.call_args.args[0][3], "123")

        pr_slack.resolve_pr("https://github.com/vercel/repo/pull/123")
        self.assertEqual(
            run.call_args.args[0][3], "https://github.com/vercel/repo/pull/123"
        )

    @patch("pr_slack.run")
    def test_reports_missing_pr(self, run: unittest.mock.Mock) -> None:
        run.return_value = completed([], returncode=1, stderr="no pull requests found")

        with self.assertRaisesRegex(pr_slack.PrSlackError, "current branch.*no pull"):
            pr_slack.resolve_pr(None)


class FormattingTests(unittest.TestCase):
    def pr(self, **updates: object) -> pr_slack.PullRequest:
        values = {
            "number": 42,
            "title": "Fix <unsafe> & things",
            "url": 'https://github.com/vercel/repo/pull/42?x=1&y="2"',
            "additions": 7,
            "deletions": 2,
            "repository": "vercel/repo",
        }
        values.update(updates)
        return pr_slack.PullRequest(**values)

    def test_formats_rich_and_plain_representations(self) -> None:
        message = pr_slack.format_message(self.pr(), smol=False)

        self.assertEqual(
            message.plain,
            ':pr: vercel/repo [Fix <unsafe> & things #42]('
            'https://github.com/vercel/repo/pull/42?x=1&y="2") +7 -2',
        )
        self.assertIn(
            '<a href="https://github.com/vercel/repo/pull/42?x=1&amp;y=&quot;2&quot;">'
            "<b>Fix &lt;unsafe&gt; &amp; things #42</b></a>",
            message.html,
        )

    def test_smol_threshold_and_overrides(self) -> None:
        self.assertIn(":smol:", pr_slack.format_message(self.pr()).plain)
        self.assertIn(
            ":smol:",
            pr_slack.format_message(self.pr(additions=10, deletions=0)).plain,
        )
        self.assertNotIn(
            ":smol:",
            pr_slack.format_message(self.pr(additions=10, deletions=1)).plain,
        )
        self.assertIn(
            ":smol:",
            pr_slack.format_message(
                self.pr(additions=100, deletions=100), smol=True
            ).plain,
        )
        self.assertNotIn(":smol:", pr_slack.format_message(self.pr(), smol=False).plain)

    def test_description_is_a_second_escaped_line(self) -> None:
        message = pr_slack.format_message(
            self.pr(), description="Please review <carefully>\nThanks", smol=False
        )

        self.assertTrue(message.plain.endswith("\nPlease review <carefully>\nThanks"))
        self.assertTrue(
            message.html.endswith("<p>Please review &lt;carefully&gt;<br>Thanks</p>")
        )

    def test_reviewers_are_plain_handles_on_main_line(self) -> None:
        reviewers = pr_slack.parse_reviewers(["alice,bob", "@carol", "Some Name"])
        message = pr_slack.format_message(self.pr(), reviewers=reviewers, smol=False)

        self.assertEqual(reviewers, ["alice", "bob", "carol", "Some Name"])
        self.assertTrue(message.plain.endswith("@alice @bob @carol @Some Name"))
        self.assertIn("@alice @bob @carol @Some Name</p>", message.html)

    def test_reviewer_rejects_non_space_whitespace(self) -> None:
        with self.assertRaisesRegex(pr_slack.PrSlackError, "invalid reviewer"):
            pr_slack.parse_reviewers(["Some\tName"])


class ChannelTests(unittest.TestCase):
    def test_builds_direct_link_from_vercel_archive_url(self) -> None:
        self.assertEqual(
            pr_slack.channel_deep_link(
                "https://vercel.slack.com/archives/C04KJQUBERY"
            ),
            (
                "slack://channel?team=T0CAQ00TU&id=C04KJQUBERY",
                "C04KJQUBERY",
            ),
        )

    def test_builds_direct_link_from_vercel_message_url(self) -> None:
        self.assertEqual(
            pr_slack.channel_deep_link(
                "https://vercel.slack.com/archives/C04KJQUBERY/p1700000000000000"
                "?thread_ts=1700000000.000000&cid=C04KJQUBERY"
            )[0],
            "slack://channel?team=T0CAQ00TU&id=C04KJQUBERY",
        )

    def test_builds_direct_link_from_vercel_enterprise_url(self) -> None:
        for url in (
            "https://vercel.enterprise.slack.com/archives/C04KJQUBERY",
            (
                "https://vercel.enterprise.slack.com/archives/C04KJQUBERY/"
                "p1700000000000000?thread_ts=1700000000.000000"
            ),
        ):
            with self.subTest(url=url):
                self.assertEqual(
                    pr_slack.channel_deep_link(url),
                    (
                        "slack://channel?team=T0CAQ00TU&id=C04KJQUBERY",
                        "C04KJQUBERY",
                    ),
                )

    def test_builds_direct_link_from_slack_client_url(self) -> None:
        self.assertEqual(
            pr_slack.channel_deep_link(
                "https://app.slack.com/client/T0CAQ00TU/C04KJQUBERY"
            )[0],
            "slack://channel?team=T0CAQ00TU&id=C04KJQUBERY",
        )

    def test_rejects_malformed_or_missing_channel_id(self) -> None:
        for url in (
            "not-a-url",
            "http://vercel.slack.com/archives/C04KJQUBERY",
            "https://vercel.slack.com/archives/",
            "https://vercel.slack.com/archives/not-a-channel",
        ):
            with self.subTest(url=url), self.assertRaises(pr_slack.PrSlackError):
                pr_slack.channel_deep_link(url)

    def test_rejects_other_slack_workspace(self) -> None:
        for url in (
            "https://other.slack.com/archives/C04KJQUBERY",
            "https://other.enterprise.slack.com/archives/C04KJQUBERY",
            "https://app.slack.com/client/T01234567/C04KJQUBERY",
        ):
            with self.subTest(url=url), self.assertRaisesRegex(
                pr_slack.PrSlackError, "workspace|must be"
            ):
                pr_slack.channel_deep_link(url)

    @patch("pr_slack.run")
    def test_configures_channel_for_current_repository(
        self, run: unittest.mock.Mock
    ) -> None:
        run.return_value = completed([])

        deep_link, channel_id = pr_slack.configure_channel(
            "https://vercel.slack.com/archives/C04KJQUBERY"
        )

        self.assertEqual(
            deep_link, "slack://channel?team=T0CAQ00TU&id=C04KJQUBERY"
        )
        self.assertEqual(channel_id, "C04KJQUBERY")
        run.assert_called_once_with(
            ["git", "config", "--local", "pr-slack.channel", deep_link]
        )

    @patch("pr_slack.run")
    def test_reports_configuration_outside_a_repository(
        self, run: unittest.mock.Mock
    ) -> None:
        run.return_value = completed([], returncode=128, stderr="not a git repository")
        with self.assertRaisesRegex(pr_slack.PrSlackError, "not a git repository"):
            pr_slack.configure_channel(
                "https://vercel.slack.com/archives/C04KJQUBERY"
            )

    @patch("pr_slack.run")
    def test_reads_local_git_configuration(self, run: unittest.mock.Mock) -> None:
        run.return_value = completed([], stdout="https://example.slack.com/archives/C1\n")

        self.assertEqual(
            pr_slack.configured_channel(None),
            "https://example.slack.com/archives/C1",
        )
        run.assert_called_once_with(
            ["git", "config", "--local", "--get", "pr-slack.channel"]
        )

    @patch("pr_slack.run")
    def test_override_skips_git_configuration(self, run: unittest.mock.Mock) -> None:
        override = "https://example.slack.com/archives/C2"
        self.assertEqual(pr_slack.configured_channel(override), override)
        run.assert_not_called()

    @patch("pr_slack.run")
    def test_reports_missing_channel(self, run: unittest.mock.Mock) -> None:
        run.return_value = completed([], returncode=1)
        with self.assertRaisesRegex(
            pr_slack.PrSlackError, "gh pr-slack configure CHANNEL_URL"
        ):
            pr_slack.configured_channel(None)


class SideEffectTests(unittest.TestCase):
    @patch("pr_slack.run")
    def test_clipboard_invocation_contains_html_and_plain_payloads(
        self, run: unittest.mock.Mock
    ) -> None:
        copied: dict[str, str] = {}

        def capture(
            args: list[str], *, input_text: str | None = None
        ) -> subprocess.CompletedProcess[str]:
            copied["html"] = pr_slack.Path(args[-1]).read_text()
            copied["plain"] = input_text or ""
            return completed(args)

        run.side_effect = capture
        message = pr_slack.Message(
            '<p>:pr: repo <a href="https://example.com"><b>Title</b></a> @yury</p>',
            ":pr: repo Title @yury",
        )

        pr_slack.copy_to_clipboard(message)

        args = run.call_args.args[0]
        self.assertEqual(args[:2], ["/usr/local/bin/pbcopy", "--html"])
        self.assertEqual(copied, {"html": message.html, "plain": message.plain})
        self.assertFalse(pr_slack.Path(args[-1]).exists())

    @patch("pr_slack.run")
    def test_reports_clipboard_failure(self, run: unittest.mock.Mock) -> None:
        run.return_value = completed(
            [], returncode=1, stderr="host integration tunnel is unavailable"
        )

        with self.assertRaisesRegex(
            pr_slack.PrSlackError,
            "pbcopy failed: host integration tunnel is unavailable",
        ):
            pr_slack.copy_to_clipboard(pr_slack.Message("<p>Hello</p>", "Hello"))

    @patch("pr_slack.run")
    def test_opens_url_in_slack_desktop(self, run: unittest.mock.Mock) -> None:
        run.return_value = completed([])
        channel = "slack://channel?team=T0CAQ00TU&id=C04KJQUBERY"

        pr_slack.open_slack(channel)

        run.assert_called_once_with(["/usr/local/bin/xdg-open", channel])

    @patch("pr_slack.open_slack")
    @patch("pr_slack.copy_to_clipboard", side_effect=pr_slack.PrSlackError("copy failed"))
    @patch("pr_slack.configured_channel", return_value="https://slack.test/C1")
    @patch("pr_slack.resolve_pr")
    def test_does_not_open_slack_when_copy_fails(
        self,
        resolve: unittest.mock.Mock,
        _channel: unittest.mock.Mock,
        _copy: unittest.mock.Mock,
        open_slack: unittest.mock.Mock,
    ) -> None:
        resolve.return_value = pr_slack.PullRequest(
            1, "Title", "https://github.com/o/r/pull/1", 1, 1, "o/r"
        )

        self.assertEqual(pr_slack.execute([]), 1)
        open_slack.assert_not_called()


class CliTests(unittest.TestCase):
    @patch("pr_slack.open_slack")
    @patch("pr_slack.copy_to_clipboard")
    @patch(
        "pr_slack.configured_channel",
        return_value="slack://channel?team=T0CAQ00TU&id=C04KJQUBERY",
    )
    @patch("pr_slack.resolve_pr")
    def test_prints_copied_plain_text_on_success(
        self,
        resolve: unittest.mock.Mock,
        _channel: unittest.mock.Mock,
        _copy: unittest.mock.Mock,
        _open: unittest.mock.Mock,
    ) -> None:
        resolve.return_value = pr_slack.PullRequest(
            89,
            "Clarify lat.md snapshot guidance",
            "https://github.com/vercel-labs/lat.md/pull/89",
            24,
            20,
            "vercel-labs/lat.md",
        )
        output = StringIO()

        with redirect_stdout(output):
            result = pr_slack.execute(["-r", "yury"])

        self.assertEqual(result, 0)
        self.assertEqual(
            output.getvalue(),
            ":pr: vercel-labs/lat.md [Clarify lat.md snapshot guidance #89]"
            "(https://github.com/vercel-labs/lat.md/pull/89) +24 -20 @yury\n",
        )

    @patch("pr_slack.configure_channel")
    def test_configure_command_writes_channel_and_skips_pr_flow(
        self, configure: unittest.mock.Mock
    ) -> None:
        configure.return_value = (
            "slack://channel?team=T0CAQ00TU&id=C04KJQUBERY",
            "C04KJQUBERY",
        )

        channel_url = "https://vercel.slack.com/archives/C04KJQUBERY"
        self.assertEqual(pr_slack.execute(["configure", channel_url]), 0)

        configure.assert_called_once_with(channel_url)

    def test_parses_repeatable_and_comma_separated_reviewers(self) -> None:
        args = pr_slack.parser().parse_args(
            ["12", "-r", "alice,bob", "--reviewer", "carol", "--no-smol"]
        )
        self.assertEqual(args.pr, "12")
        self.assertEqual(args.reviewer, ["alice,bob", "carol"])
        self.assertFalse(args.smol)


if __name__ == "__main__":
    unittest.main()
