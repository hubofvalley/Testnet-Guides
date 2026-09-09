#!/usr/bin/env bash
set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required to access the private Valley-of-Worrel-Testnet repository." >&2
  exit 1
fi

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

gh repo clone hubofvalley/Valley-of-Worrel-Testnet "$workdir/repo" -- --branch main --depth 1 >/dev/null
bash "$workdir/repo/resources/valleyofWorrel.sh" "$@"
