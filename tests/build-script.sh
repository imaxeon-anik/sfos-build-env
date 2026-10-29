#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/sfos-test-XXXXXXXX")"
trap 'rm -rf "$WORK"' EXIT
git init -q "$WORK/app"
git -C "$WORK/app" config user.name 'Build script test'
git -C "$WORK/app" config user.email 'test@example.invalid'
printf 'fixture\n' > "$WORK/app/project.pro"
git -C "$WORK/app" add project.pro
git -C "$WORK/app" commit -qm fixture
chmod +x "$ROOT/tests/mock-sfdk.sh"
SFDK="$ROOT/tests/mock-sfdk.sh" bash "$ROOT/scripts/build.sh" "$WORK/app" aarch64 "$WORK/output"
[[ "$(find "$WORK/output" -name '*.rpm' | wc -l | tr -d ' ')" == 1 ]]
[[ -f "$WORK/app/project.pro" && ! -e "$WORK/app/RPMS" ]]
printf 'uncommitted\n' >> "$WORK/app/project.pro"
if SFDK="$ROOT/tests/mock-sfdk.sh" bash "$ROOT/scripts/build.sh" "$WORK/app" aarch64 "$WORK/dirty"; then
    printf 'FAIL: dirty tree accepted\n' >&2; exit 1
fi
git -C "$WORK/app" add project.pro
git -C "$WORK/app" commit -qm change
if MOCK_FAIL=1 SFDK="$ROOT/tests/mock-sfdk.sh" bash "$ROOT/scripts/build.sh" "$WORK/app" aarch64 "$WORK/failed"; then
    printf 'FAIL: SDK failure hidden\n' >&2; exit 1
fi
if MOCK_EMPTY=1 SFDK="$ROOT/tests/mock-sfdk.sh" bash "$ROOT/scripts/build.sh" "$WORK/app" aarch64 "$WORK/empty"; then
    printf 'FAIL: empty output accepted\n' >&2; exit 1
fi
if SFDK="$ROOT/tests/mock-sfdk.sh" bash "$ROOT/scripts/build.sh" "$WORK/app" i486 "$WORK/unverified"; then
    printf 'FAIL: unverified target accepted without opt-in\n' >&2; exit 1
fi
printf 'PASS: staging, artifacts, dirty tree, failed build, empty output, and target opt-in\n'