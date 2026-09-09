#!/usr/bin/env bash
set -euo pipefail

exec bash <(curl -fsSL https://raw.githubusercontent.com/hubofvalley/Valley-of-Worrel-Testnet/main/resources/valleyofWorrel.sh) "$@"
