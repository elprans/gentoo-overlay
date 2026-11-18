# codex

Codex 0.170.0 is built by this overlay with six maintained source patches and a locally generated dependency bundle published as a GitHub release asset.

## Packaging

[[dev-util/codex/codex-0.170.0.ebuild]] builds the CLI and code-mode host using the GURU package layout, system ripgrep, and bubblewrap.

As in GURU, V8 152.2.0 comes from OpenAI's prebuilt `librusty_v8` archives and matching Rust bindings for amd64 and arm64. Rust Codex and the code-mode host are compiled locally. The Manifest covers both architectures; Portage fetches only the V8 files selected for the build architecture.

The source baseline is upstream `rust-v0.170.0`. The ebuild applies the ordered text patches from [[dev-util/codex/files]] during `src_prepare`, with paths relative to `codex-rs/` and strip level 1. It then applies the generated protocol bundle patch with `git apply --binary -p1`; GNU patch cannot apply Git binary deltas.

These patches belong to the ebuild. Remove their duplicate copies from `/etc/portage/patches/dev-util/codex/` and the old `schema-exports.gitpatch` post-prepare hook in `/etc/portage/env/dev-util/codex` when switching to this recipe, so patches apply exactly once.

### Patch-only customization

Portage user patches remain a valid way to customize Codex when another repository already supplies a suitable ebuild.

Export patches relative to that recipe's source directory and install them under `/etc/portage/patches/dev-util/codex/`. An ebuild calling `default` in `src_prepare` applies `.patch` and `.diff` files in filename order. The package directory applies across versions, so check every selected source baseline.

For Git binary exports, use a package environment `post_src_prepare` hook that runs `git apply --binary -p1` in `${S}`. Remove both the duplicate patches and that hook when the selected ebuild carries them itself. Rebuild the package from source to install source changes.

## Local features

Six local patches add keyring fallback, cost accounting, sandbox socket access, synchronous follow-ups, system ripgrep, and shipped-binary daemon startup.

The catalog-advertised asynchronous question tool uses [[codex:codex-rs/core/src/tools/handlers/request_user_input_async.rs#RequestUserInputAsyncHandler|the blocking user-input path]]. The TUI shows a question prompt immediately, and the active turn waits for the answers as a tool result instead of retaining hidden queued follow-ups.

Restricted sessions retain configured Unix-socket allowlists when the managed TCP proxy is disabled, without granting general TCP/IP access.

Keyring fallback extends [[codex:codex-rs/model-provider-info/src/lib.rs#ModelProviderInfo#api_key]]. [[codex:codex-rs/cli/src/doctor.rs#provider_specific_auth_check|Doctor's provider auth check]] follows the same precedence: a nonempty environment key wins, then an opt-in OS keyring record under service `Codex Model Providers` and the provider's `env_key` account. It distinguishes missing records from keyring access failures without including secret values or backend error text in reports.

Cost tracking treats upstream `usage_metadata.amount` as authoritative. If Vercel AI Gateway omits it, Codex authenticates `GET /v1/generation?id=...` and retries after 5, 15, and 60 seconds for the settled `total_cost`.

Codex recognizes Gateway by the base URL host `ai-gateway.vercel.sh`. A provider's `vercel_ai_gateway` setting overrides that check, so a proxy that forwards to Gateway under another host, such as a loopback proxy that adds the key, still settles generation costs.

Gateway WebSocket responses expose provider response IDs rather than their billing generation IDs, so this lookup cannot settle their costs. Leaving WebSockets disabled in the provider configuration uses the HTTP path for cost attribution.

Totals use fixed-point USD micros and persist total, post-fork incremental cost, and completeness with token-count rollout events. They flow through [[codex:codex-rs/app-server-protocol/src/protocol/v2/thread.rs#ThreadTokenUsage]] into the footer, title, status line, `/status`, and exit summary without requiring backend usage access.

Stable and experimental protocol exports include the same local cost field; generated TypeScript, JSON schemas, and precomputed bundles stay aligned with the protocol types.

The `/cost` command and status surfaces read project totals from one indexed SQLite aggregate and never scan rollout JSONL synchronously. If SQLite is unavailable, cost fails immediately instead of falling back to rollout parsing.

Upstream `daybreak_enabled` metadata is an optional per-thread Daybreak preference, not an access grant. It shares the metadata update path with local cost state; explicit Daybreak, project, and cost updates require SQLite so persisted state cannot silently diverge.

The cost schema is initialized outside SQLx history by [[codex:codex-rs/state/src/migrations.rs#ensure_local_thread_cost_schema]] after upstream migrations run. An immediate transaction makes its column check and idempotent index/table DDL safe across concurrent startups.

All numbered state migrations remain upstream-owned. Local cost-schema additions evolve through rerunnable startup DDL and never add or rewrite `_sqlx_migrations` rows.

A project is the normalized Git root, or normalized working directory outside Git, and includes persisted active and archived threads. Startup reconciles distinct stored working directories, and live metadata changes update project identity and cost rows immediately after durable token-count appends.

A cursor- and fingerprint-driven background backfill parses lightweight rollout envelopes under the rollout maintenance lock with bounded concurrency and batched SQLite writes. During backfill, `/cost` returns the indexed subtotal immediately and prefixes it with `~` if any matching thread is missing, stale, or incomplete.

Project aggregation counts each root thread's total and each fork's post-fork increment. It preserves ordinal, history-base, timestamp fallback, copied, referenced, reverted, and partial-history semantics; revert switches the selected rollout and cost row atomically, using an incomplete zero row if reconstruction fails.

Dollar displays round fixed-point micros to cents and use Codex's locale-aware integer grouping helper. The exit summary adds `Cost` after token usage, and a thread with no observed charge displays `$0.00` rather than `unavailable`.

## Source checkout

The `codex` external source resolves [[codex:README.md|Codex source documentation]] and source-symbol links through `~/dev/mirrors/codex` on this machine.

[[lat.md/lat.md]] pins the canonical upstream revision. The ignored `lat.md/config.local.yaml` selects the local checkout and its patched commit; keep that override aligned with the checkout's HEAD after rerolling patches. The repo's local `.codex/config.toml` adds the mirror to `sandbox_workspace_write.writable_roots`; restart the Codex session to pick up permission changes.

## Version bumps

Follow [[ebuilds#Patch maintenance]] and semantically reroll the patches in `~/dev/mirrors/codex` against the exact upstream revision selected by the ebuild.

Review upstream changes before editing: remove behavior now supplied upstream, adapt local behavior to current abstractions, and preserve the desired end state. Commit each patch's implementation and associated tests together in the source checkout.

Build and run relevant source tests in the checkout to reuse its Rust cache. Regenerate schemas from the patched protocol types and verify stable and experimental exports. Export reviewed commits with paths relative to `codex-rs/` into the versioned files in [[dev-util/codex/files]], separating binary exports from text patches. Verify that applying all exports to pristine upstream source reproduces the committed source changes.

Refresh [[codex#Dependency bundle]], then generate the Manifest and validate Portage prepare and build phases before installing the rebuilt package. Update the canonical Lat source pin when changing the upstream baseline and the local override when changing the patched checkout commit.

## Dependency bundle

Generate the crates archive locally with `pycargoebuild` from the patched workspace lockfile and publish it to this repository's GitHub releases.

Git dependencies stay in `GIT_CRATES` and are fetched separately. The bundle contains registry crates with Cargo checksum metadata; `pycargoebuild` also refreshes the recipe's crate licenses and Git dependency revisions. Its in-place mode does not update other ebuild logic, so review source preparation and upstream Git patches separately. With `pycargoebuild` 0.17.2, MXC metadata discovery needs its nested `src/Cargo.toml` workspace; if metadata refresh fails after archive creation, fix that discovery and resume with `--use-crate-tarball` to retain the completed bundle.

Use a writable distfiles directory and the CLI package to select the workspace:

```sh
pycargoebuild --write-crate-tarball --no-manifest \
  --distdir /tmp/codex-0.170.0-distfiles \
  --input dev-util/codex/codex-0.170.0.ebuild \
  --crate-tarball-path /tmp/codex-0.170.0-distfiles/codex-0.170.0-deps.tar.xz \
  ~/dev/mirrors/codex/codex-rs/cli
```

[The published release](https://github.com/elprans/gentoo-overlay/releases/tag/codex-0.170.0) follows this repository's existing `granted` and `terraform` convention: tag and title `codex-0.170.0`, targeting `master`, with asset `codex-0.170.0-deps.tar.xz`. Publish the generated archive using `gh release create` (or `gh release upload` for an existing release), verify the uploaded digest, then regenerate the Manifest against that asset.

For a new release, publish the archive and inspect its asset digest before writing the Manifest (substitute the new version for later bumps):

```sh
gh release create codex-0.170.0 --repo elprans/gentoo-overlay \
  --target master --title codex-0.170.0 \
  --notes "Vendored dependency tarball for the codex 0.170.0 ebuild." \
  /tmp/codex-0.170.0-distfiles/codex-0.170.0-deps.tar.xz
gh release view codex-0.170.0 --repo elprans/gentoo-overlay --json assets
DISTDIR=/tmp/codex-0.170.0-distfiles \
  ebuild dev-util/codex/codex-0.170.0.ebuild manifest
```

The ebuild downloads the bundle from `https://github.com/elprans/gentoo-overlay/releases/download/${P}/${P}-deps.tar.xz`. Every version gets its own release asset; generate and publish a matching bundle before using a new URL.
