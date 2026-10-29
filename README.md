# SFOS Build Environment

Shared build tooling for Sailfish OS applications. No application source, personal VM,
SSH keys, SDK binaries, signing keys, or API credentials are included.

## Status

This first version wraps an **already installed Sailfish SDK**. It does not install the SDK
automatically and does not yet provide a container image. The reference environment is SDK
3.13.5 on x86_64 Linux with target SailfishOS-5.1.0.11-aarch64 (Qt 5.6.3).
That SDK/target combination previously built an application successfully; this new generic
wrapper has passed mock SDK tests, but has **not yet been verified against a real SDK**.
Do not describe these builds as bit-for-bit reproducible: target repository snapshots,
dependency versions and installer checksums have not yet been locked.

## Build any compatible app

Run inside a Linux SDK host or VM, after installing the SDK and target:

```sh
export SFDK="$HOME/SailfishOS/bin/sfdk"
bash scripts/doctor.sh
bash scripts/build.sh /absolute/path/to/app aarch64 /absolute/path/to/output
```

The app must be a clean Git repository with committed RPM packaging that `sfdk build`
can discover from its root. App dependencies remain in its own RPM spec. This recipe
does not require a particular application name, username, SSD mount or SSH alias.
Submodules and Git LFS sources are rejected until staging support is implemented.
For projects requiring extra setup or explicit spec selection, use an app-owned wrapper;
arbitrary build-command inputs are intentionally not exposed through the workflow.

Each build exports a unique directory containing:

- `RPMS/`: packages for the requested architecture and any noarch packages.
- `build.log`: SDK output, retained even when the build fails.
- `build-info.txt`: application commit, recipe commit, target and reported SDK version.
- `SHA256SUMS`: checksums of the exported packages.

Only committed source is staged. Ignored files and the app's `.git` directory are not copied.
The app checkout is not built in place, and old output RPMs are never reused. Temporary source
is deleted on exit. The SDK can still change its own engine state and install build dependencies.

## Targets and hosts

The default target is recorded in [versions/sailfish-5.1.0.11.env](versions/sailfish-5.1.0.11.env).
Other installed targets can be selected with `SFOS_TARGET`; their architecture must match
the command argument. armv7hl and i486 are accepted only with
`SFOS_ALLOW_UNVERIFIED_TARGET=1`. They are not certified by this repository.
The script does not upgrade SDKs or download targets automatically.

On Apple Silicon, use an appropriate Linux SDK VM. A future container image needs separate
validation of build-engine nesting, architecture emulation and redistribution rights.

## GitHub Actions

[The checks workflow](.github/workflows/checks.yml) runs mocked orchestration tests on
GitHub-hosted Ubuntu. It does **not** build a Sailfish RPM.

[The reusable RPM workflow](.github/workflows/build-rpm.yml) runs on a trusted self-hosted
Linux x64 runner labeled `sfos-sdk`. Configure approvals before enabling it. It uploads
artifacts, never installs on a phone, signs packages or publishes releases.
See [CI setup](docs/ci.md) and [the caller example](examples/application-workflow.yml).

## Setup and safety

- [SDK setup](docs/setup.md)
- [CI and access controls](docs/ci.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Security](SECURITY.md)

Validate the scripts without an SDK:

```sh
bash tests/build-script.sh
```

Before distributing build images, review all SDK and target-component licenses. Keeping this
repository private does not waive redistribution restrictions. No license for redistribution
of these scripts has been selected yet.