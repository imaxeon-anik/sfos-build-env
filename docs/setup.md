# SDK setup

## Reference configuration

- x86_64 Linux SDK host; Ubuntu 24.04 was used for the existing development VM.
- Sailfish SDK 3.13.5.
- SailfishOS 5.1.0.11 aarch64 target; Qt 5.6.3 / C++11 application baseline.
- Git, Bash, tar and standard filesystem/checksum utilities.

This is a reference, not a fully locked provisioning manifest. The original SSD is currently
unavailable for inventory; installer digests, exact dependency snapshots and engine configuration
must be recorded from a verified clean installation before automated provisioning is advertised.

## Install from upstream

1. Follow the official SDK installation instructions at https://docs.sailfishos.org/Tools/Sailfish_SDK/.
2. Obtain the required installer from Sailfish's official distribution. Verify any upstream
   checksum/signature and read the license terms. Do not use an unverified third-party VM image.
3. Install the SDK and configure its build engine using the supported installer workflow.
4. Install the target `SailfishOS-5.1.0.11-aarch64` through the SDK's target-management interface.
   Verify the exact target name with the installed `sfdk` help/target listing for that SDK version.
   Stop if the requested release is unavailable; do not silently substitute a newer target.
5. Set `SFDK` to the installed executable and run `bash scripts/doctor.sh`.
6. Build a clean committed app using `scripts/build.sh`. Inspect the output package and log.

If the build engine cannot access the temporary source directory, set `TMPDIR` to an existing
directory inside a path shared with the engine. Place the output directory there too if needed.

## Verification gate

Before labeling an environment release verified:

- Provision from a clean host, not a copy of a developer home directory.
- Record installer checksums, SDK version, target repositories and package versions.
- Build two independent apps and verify RPM names, architecture and payloads.
- Run each app's own tests. Ordinary host Qt tests do not prove Sailfish API compatibility.
- Repeat the setup from the documentation on another host.
- Test phone-only behavior separately: Sailjail, Secrets, UI, gestures and upgrade retention.

## Existing SSD VM

You may clone this repository inside your existing VM and run it there. VM startup remains a
host-specific concern and is not hardcoded into the shared scripts. Never detach its storage
while running or start the same VM disk on two hosts simultaneously. Do not copy SSH configs,
credentials, histories, private sources or user settings into this repository.