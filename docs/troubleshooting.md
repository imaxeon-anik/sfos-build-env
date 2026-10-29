# Troubleshooting

## SDK not found

Install the SDK first and set `SFDK` to its absolute executable path. The wrapper does not
find your Mac's SSD, start a VM or configure SSH. Run it inside the SDK host.

## Target missing

Install the matching target with the SDK's supported target-management tools. `SFOS_TARGET`
selects an installed target, not a download. Non-baseline targets require explicit opt-in.

## Engine cannot see source

Set `TMPDIR` to an existing directory shared with the engine. The wrapper uses a temporary
checkout to avoid stale artifacts and destructive cleanup in the original app repository.

## App tree is dirty

Commit the app's intended changes first. The wrapper builds that commit, not arbitrary working
files. Prefer an output directory outside the app checkout; otherwise ignore it explicitly.

## Multiple specs or nonstandard build setup

This initial wrapper uses the SDK's default root-level `sfdk build` discovery. Projects requiring
other arguments need an app-owned adapter and focused tests before extending the shared interface.

## Workflow queued forever

Check that the `sfos-sdk` runner is online, Linux x64, and permitted for the calling repository.
Check the `sfos-build` environment's pending approval. Do not remove approvals to bypass a failure.

## Private recipe checkout denied

Check private reusable-workflow access and the explicit read-only token. Never enable broad
write permissions just to fix checkout access. Pin recipe and workflow to the same commit.

## Build succeeds but device fails

Inspect the RPM dependencies and payload. Native QML imports, permissions, hardware access and
on-device migrations need their own validation. A successful compile is not a device test.