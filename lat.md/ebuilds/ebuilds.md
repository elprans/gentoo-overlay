# Package customizations

Local package customizations can use overlay ebuilds or Portage user patches applied to an ebuild supplied by another repository.

- [[codex]] — Codex ebuild, source patches, and dependency bundle

## Patch maintenance

Maintain patches in a matching source checkout against the exact upstream revision selected by the package's ebuild.

Review upstream changes before rerolling: remove behavior now supplied upstream and adapt remaining changes to current abstractions. Commit related implementation and tests together, validate the patched source, and export patches from those commits.

For packages using Portage user patches, install the exported patches under `/etc/portage/patches/<category>/<package>/`. An ebuild supplied by another repository can provide all packaging behavior while user patches supply the local source changes.

Use the configured Lat external source for source work; [[codex#Version bumps]] describes the Codex workflow.
