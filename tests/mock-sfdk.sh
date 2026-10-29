#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == --version ]]; then
    printf 'Mock sfdk for orchestration tests only\n'; exit 0
fi
[[ "$#" == 3 && "$1" == -c && "$2" == target=SailfishOS-5.1.0.11-aarch64 && "$3" == build ]]
[[ -f project.pro ]]
[[ "${MOCK_FAIL:-0}" == 0 ]] || exit 42
mkdir RPMS
if [[ "${MOCK_EMPTY:-0}" == 0 ]]; then
    printf 'Not a real RPM; test fixture only\n' > RPMS/harbour-fixture-1.0-1.aarch64.rpm
fi