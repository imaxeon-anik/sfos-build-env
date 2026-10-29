#!/usr/bin/env bash
set -euo pipefail

usage() {
    printf 'Usage: bash scripts/build.sh SOURCE_REPO [ARCH] [OUTPUT_DIR]\n' >&2
    printf 'Environment: SFDK, SFOS_TARGET, SFOS_ALLOW_UNVERIFIED_TARGET=1\n' >&2
    exit 2
}

[[ $# -ge 1 && $# -le 3 ]] || usage
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/versions/sailfish-5.1.0.11.env"
SOURCE="$(cd "$1" && pwd -P)"
ARCH="${2:-$SFOS_DEFAULT_ARCH}"
case "$ARCH" in aarch64|armv7hl|i486) ;; *) usage ;; esac
TARGET="${SFOS_TARGET:-SailfishOS-$SFOS_RELEASE-$ARCH}"
[[ "$TARGET" =~ ^[A-Za-z0-9._-]+$ && "$TARGET" == *"-$ARCH" ]] || { printf 'Invalid target or architecture mismatch\n' >&2; exit 2; }
if [[ "$TARGET" != "SailfishOS-$SFOS_RELEASE-aarch64" && "${SFOS_ALLOW_UNVERIFIED_TARGET:-0}" != 1 ]]; then
    printf 'This target is unverified. Set SFOS_ALLOW_UNVERIFIED_TARGET=1 to opt in.\n' >&2
    exit 2
fi

REPO_ROOT="$(git -C "$SOURCE" rev-parse --show-toplevel)"
[[ "$(cd "$REPO_ROOT" && pwd -P)" == "$SOURCE" ]] || { printf 'SOURCE_REPO must be a repository root\n' >&2; exit 2; }
[[ -z "$(git -C "$SOURCE" status --porcelain --untracked-files=normal)" ]] || { printf 'Commit or remove pending/untracked changes before building. Ignored files are not staged.\n' >&2; exit 2; }
[[ ! -f "$SOURCE/.gitmodules" ]] || { printf 'Submodules are not supported by this staging method yet.\n' >&2; exit 2; }
if git -C "$SOURCE" grep -q 'filter=lfs' HEAD -- '*.gitattributes'; then
    printf 'Git LFS repositories are not supported by this staging method yet.\n' >&2
    exit 2
fi

SDK="${SFDK:-$HOME/SailfishOS/bin/sfdk}"
if [[ "$SDK" != */* ]]; then SDK="$(command -v "$SDK")"; fi
[[ "$SDK" == /* && -x "$SDK" ]] || { printf 'Set SFDK to an executable absolute path\n' >&2; exit 2; }
REVISION="$(git -C "$SOURCE" rev-parse HEAD)"
OUTPUT="${3:-$PWD/out}"
mkdir -p "$OUTPUT"
OUTPUT="$(cd "$OUTPUT" && pwd)"
RUN="$(mktemp -d "$OUTPUT/build-$ARCH-XXXXXXXX")"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/sfos-build-XXXXXXXX")"
trap 'rm -rf "$WORK"' EXIT
printf 'Output: %s\n' "$RUN"
mkdir -p "$WORK/source" "$RUN/RPMS"
git -C "$SOURCE" archive --format=tar HEAD | tar -xf - -C "$WORK/source"
[[ ! -e "$WORK/source/RPMS" && ! -L "$WORK/source/RPMS" ]] || { printf 'Source must not contain a tracked RPMS path\n' >&2; exit 2; }
if [[ -n "$(find "$WORK/source" -name '*.rpm' -print -quit)" ]]; then
    printf 'Source must not contain tracked RPM artifacts\n' >&2
    exit 2
fi

{
    printf 'source_commit=%s\ntarget=%s\narchitecture=%s\n' "$REVISION" "$TARGET" "$ARCH"
    printf 'sdk_baseline=%s\n' "$SFOS_SDK_VERSION"
    printf 'recipe_commit=%s\n' "$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || printf uncommitted)"
    printf 'actual_sdk_version:\n'
    "$SDK" --version
} > "$RUN/build-info.txt"

(
    cd "$WORK/source"
    "$SDK" -c "target=$TARGET" build
) 2>&1 | tee "$RUN/build.log"

[[ -d "$WORK/source/RPMS" && ! -L "$WORK/source/RPMS" ]] || { printf 'Build did not produce a regular RPMS directory\n' >&2; exit 1; }
COUNT=0
while IFS= read -r -d '' PACKAGE; do
    NAME="$(basename "$PACKAGE")"
    [[ ! -e "$RUN/RPMS/$NAME" ]] || { printf 'Duplicate RPM name: %s\n' "$NAME" >&2; exit 1; }
    cp "$PACKAGE" "$RUN/RPMS/$NAME"
    COUNT=$((COUNT + 1))
done < <(find "$WORK/source/RPMS" -type f \( -name "*.$ARCH.rpm" -o -name '*.noarch.rpm' \) -print0)
[[ "$COUNT" -gt 0 ]] || { printf 'No RPMs for the requested architecture were generated\n' >&2; exit 1; }
(
    cd "$RUN/RPMS"
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum ./*.rpm
    else
        shasum -a 256 ./*.rpm
    fi
) > "$RUN/SHA256SUMS"
printf 'Built %s package(s): %s\n' "$COUNT" "$RUN"