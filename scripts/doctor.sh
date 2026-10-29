#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/versions/sailfish-5.1.0.11.env"
for TOOL in git tar find mktemp tee; do
    command -v "$TOOL" >/dev/null || { printf 'Missing tool: %s\n' "$TOOL" >&2; exit 1; }
done
SDK="${SFDK:-$HOME/SailfishOS/bin/sfdk}"
if [[ "$SDK" != */* ]]; then SDK="$(command -v "$SDK")"; fi
[[ -x "$SDK" ]] || { printf 'Sailfish SDK missing. Install it and set SFDK. See docs/setup.md\n' >&2; exit 1; }
printf 'Host: %s / %s\n' "$(uname -s)" "$(uname -m)"
printf 'Expected SDK baseline: %s\nExpected target: SailfishOS-%s-%s\n' "$SFOS_SDK_VERSION" "$SFOS_RELEASE" "$SFOS_DEFAULT_ARCH"
"$SDK" --version
printf 'SDK executable found. This does not verify installed targets, repositories, or build-engine startup.\n'