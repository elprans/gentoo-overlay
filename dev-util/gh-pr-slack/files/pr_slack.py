"""Prepare a rich Slack message for a GitHub pull request.

The devm guest port: the message reaches the Mac clipboard, with its HTML and
plain-text forms, through devm's `pbcopy --html`, and devm's `xdg-open` hands
the channel link to the Mac, where Slack Desktop opens it.
"""

from __future__ import annotations

import argparse
import html
import json
import os
import re
import subprocess
import sys
import tempfile
from collections.abc import Sequence
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urlsplit

PR_FIELDS = "number,title,url,additions,deletions"
SMOL_LINE_LIMIT = 10
SLACK_ARCHIVE_HOST = "vercel.slack.com"
SLACK_ENTERPRISE_ARCHIVE_HOST = "vercel.enterprise.slack.com"
SLACK_APP_HOST = "app.slack.com"
VERCEL_SLACK_TEAM_ID = "T0CAQ00TU"
PBCOPY = "/usr/local/bin/pbcopy"
XDG_OPEN = "/usr/local/bin/xdg-open"


class PrSlackError(RuntimeError):
    """An expected, user-facing failure."""


@dataclass(frozen=True)
class PullRequest:
    number: int
    title: str
    url: str
    additions: int
    deletions: int
    repository: str


@dataclass(frozen=True)
class Message:
    html: str
    plain: str


def run(
    args: Sequence[str],
    *,
    input_text: str | None = None,
) -> subprocess.CompletedProcess[str]:
    try:
        return subprocess.run(
            list(args),
            input=input_text,
            text=True,
            capture_output=True,
            check=False,
        )
    except OSError as error:
        raise PrSlackError(f"could not run {args[0]}: {error}") from error


def command_error(command: str, result: subprocess.CompletedProcess[str]) -> str:
    detail = result.stderr.strip() or result.stdout.strip()
    return f"{command} failed{': ' + detail if detail else ''}"


def repository_from_pr_url(url: str) -> str:
    parts = [part for part in urlsplit(url).path.split("/") if part]
    if len(parts) < 4 or parts[2] != "pull":
        raise PrSlackError(f"gh returned an unrecognized pull request URL: {url}")
    return f"{parts[0]}/{parts[1]}"


def resolve_pr(reference: str | None) -> PullRequest:
    args = ["gh", "pr", "view"]
    if reference:
        args.append(reference)
    args.extend(["--json", PR_FIELDS])

    result = run(args)
    if result.returncode != 0:
        target = f" {reference}" if reference else " for the current branch"
        raise PrSlackError(
            f"could not resolve a pull request{target}: "
            f"{command_error('gh pr view', result)}"
        )

    try:
        data = json.loads(result.stdout)
        url = str(data["url"])
        return PullRequest(
            number=int(data["number"]),
            title=str(data["title"]),
            url=url,
            additions=int(data["additions"]),
            deletions=int(data["deletions"]),
            repository=repository_from_pr_url(url),
        )
    except (KeyError, TypeError, ValueError, json.JSONDecodeError) as error:
        raise PrSlackError(f"gh returned invalid pull request metadata: {error}") from error


def configured_channel(override: str | None) -> str:
    if override:
        return override

    result = run(["git", "config", "--local", "--get", "pr-slack.channel"])
    channel = result.stdout.strip()
    if result.returncode != 0 or not channel:
        raise PrSlackError(
            "no Slack channel configured; pass --channel URL or run "
            "`gh pr-slack configure CHANNEL_URL`"
        )
    return channel


def valid_slack_id(value: str, prefixes: str) -> bool:
    return re.fullmatch(f"[{re.escape(prefixes)}][A-Z0-9]+", value) is not None


def channel_deep_link(channel_url: str) -> tuple[str, str]:
    try:
        parsed = urlsplit(channel_url.strip())
    except ValueError as error:
        raise PrSlackError(f"invalid Slack channel URL: {error}") from error

    if parsed.scheme != "https":
        raise PrSlackError("Slack channel URL must use https")

    parts = [part for part in parsed.path.split("/") if part]
    team_id = VERCEL_SLACK_TEAM_ID
    channel_id: str | None = None

    if parsed.hostname in (SLACK_ARCHIVE_HOST, SLACK_ENTERPRISE_ARCHIVE_HOST):
        if len(parts) >= 2 and parts[0] == "archives":
            channel_id = parts[1]
    elif parsed.hostname == SLACK_APP_HOST:
        if len(parts) >= 3 and parts[0] == "client":
            team_id, channel_id = parts[1], parts[2]
            if team_id != VERCEL_SLACK_TEAM_ID:
                raise PrSlackError(
                    f"Slack URL is for workspace {team_id}, not the Vercel workspace"
                )
    else:
        raise PrSlackError(
            "Slack channel URL must be from vercel.slack.com, "
            "vercel.enterprise.slack.com, or app.slack.com"
        )

    if channel_id is None or not valid_slack_id(channel_id, "CG"):
        raise PrSlackError("Slack channel URL does not contain a valid channel ID")
    if not valid_slack_id(team_id, "T"):
        raise PrSlackError("Slack channel URL does not contain a valid workspace ID")

    return f"slack://channel?team={team_id}&id={channel_id}", channel_id


def configure_channel(channel_url: str) -> tuple[str, str]:
    deep_link, channel_id = channel_deep_link(channel_url)
    result = run(["git", "config", "--local", "pr-slack.channel", deep_link])
    if result.returncode != 0:
        raise PrSlackError(command_error("git config", result))
    return deep_link, channel_id


def parse_reviewers(values: Sequence[str]) -> list[str]:
    reviewers: list[str] = []
    for value in values:
        for item in value.split(","):
            handle = item.strip().lstrip("@").strip()
            if not handle:
                raise PrSlackError("reviewer handles cannot be empty")
            if any(character.isspace() and character != " " for character in handle):
                raise PrSlackError(f"invalid reviewer handle: {item.strip()}")
            reviewers.append(handle)
    return reviewers


def format_message(
    pr: PullRequest,
    *,
    reviewers: Sequence[str] = (),
    description: str | None = None,
    smol: bool | None = None,
) -> Message:
    is_smol = pr.additions + pr.deletions <= SMOL_LINE_LIMIT if smol is None else smol

    suffixes = []
    if is_smol:
        suffixes.append(":smol:")
    suffixes.extend(f"@{reviewer}" for reviewer in reviewers)
    suffix = f" {' '.join(suffixes)}" if suffixes else ""

    link_label = f"{pr.title} #{pr.number}"
    plain_main = (
        f":pr: {pr.repository} [{link_label}]({pr.url}) "
        f"+{pr.additions} -{pr.deletions}{suffix}"
    )
    html_main = (
        f":pr: {html.escape(pr.repository)} "
        f'<a href="{html.escape(pr.url, quote=True)}">'
        f"<b>{html.escape(link_label)}</b></a> "
        f"+{pr.additions} -{pr.deletions}{html.escape(suffix)}"
    )

    if description is None:
        return Message(html=f"<p>{html_main}</p>", plain=plain_main)

    normalized_description = description.replace("\r\n", "\n").replace("\r", "\n")
    html_description = html.escape(normalized_description).replace("\n", "<br>")
    return Message(
        html=f"<p>{html_main}</p><p>{html_description}</p>",
        plain=f"{plain_main}\n{normalized_description}",
    )


def copy_to_clipboard(message: Message) -> None:
    with tempfile.NamedTemporaryFile(
        mode="w", encoding="utf-8", prefix="gh-pr-slack-", suffix=".html"
    ) as html_file:
        html_file.write(message.html)
        html_file.flush()
        result = run([PBCOPY, "--html", html_file.name], input_text=message.plain)
    if result.returncode != 0:
        raise PrSlackError(command_error("pbcopy", result))


def open_slack(channel: str) -> None:
    result = run([XDG_OPEN, channel])
    if result.returncode != 0:
        raise PrSlackError(command_error("xdg-open", result))


def parser() -> argparse.ArgumentParser:
    argument_parser = argparse.ArgumentParser(
        prog="gh pr-slack",
        description=(
            "Copy a rich PR summary and open its Slack channel. "
            "Run `gh pr-slack configure CHANNEL_URL` to configure this repository."
        ),
    )
    argument_parser.add_argument(
        "pr",
        nargs="?",
        help="pull request number, URL, or branch (defaults to the current branch)",
    )
    argument_parser.add_argument(
        "-c", "--channel", metavar="URL", help="override pr-slack.channel"
    )
    argument_parser.add_argument(
        "-d", "--description", metavar="TEXT", help="append a description line"
    )
    argument_parser.add_argument(
        "-r",
        "--reviewer",
        action="append",
        default=[],
        metavar="NAME[,NAME...]",
        help="append one or more reviewer names or handles (repeatable)",
    )
    smol_group = argument_parser.add_mutually_exclusive_group()
    smol_group.add_argument(
        "--smol", dest="smol", action="store_true", help="always add :smol:"
    )
    smol_group.add_argument(
        "--no-smol", dest="smol", action="store_false", help="never add :smol:"
    )
    argument_parser.set_defaults(smol=None)
    return argument_parser


def configure_parser() -> argparse.ArgumentParser:
    argument_parser = argparse.ArgumentParser(
        prog="gh pr-slack configure",
        description="Configure a Slack channel for the current repository.",
    )
    argument_parser.add_argument(
        "channel_url",
        metavar="CHANNEL_URL",
        help="copied Vercel Slack channel URL",
    )
    return argument_parser


def execute(argv: Sequence[str] | None = None) -> int:
    arguments = list(argv) if argv is not None else sys.argv[1:]
    if arguments and arguments[0] == "configure":
        args = configure_parser().parse_args(arguments[1:])
        try:
            deep_link, channel_id = configure_channel(args.channel_url)
        except PrSlackError as error:
            print(f"gh pr-slack: {error}", file=sys.stderr)
            return 1
        print(f"Configured Slack channel {channel_id} for this repository ({deep_link}).")
        return 0

    args = parser().parse_args(arguments)
    try:
        reviewers = parse_reviewers(args.reviewer)
        pr = resolve_pr(args.pr)
        channel = configured_channel(args.channel)
        message = format_message(
            pr,
            reviewers=reviewers,
            description=args.description,
            smol=args.smol,
        )
        copy_to_clipboard(message)
        open_slack(channel)
    except PrSlackError as error:
        print(f"gh pr-slack: {error}", file=sys.stderr)
        return 1

    print(message.plain)
    return 0


def main() -> None:
    raise SystemExit(execute())
