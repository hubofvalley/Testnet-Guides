# Worrell Testnet Guide

Worrell is a Cosmos SDK proof-of-stake network. This entrypoint keeps the manual facts visible and routes node operations to the canonical Grand Valley toolkit.

## Network details

- Chain ID: `worrell-testnet-1`
- Binary: `worrelld` v0.1.2
- Denom: `uworrell` (6 decimals)
- Node home: `~/.worrell`
- Minimum gas price: `0.025uworrell`
- Recommended testnet host: 2 vCPU, 4 GB RAM, 100 GB SSD, public P2P access

## Valley of Worrell

Valley of Worrell is the Grand Valley interactive installer and operations menu for the Worrell Testnet node.

Run the reviewed public launcher directly:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/hubofvalley/Valley-of-Worrel-Testnet/main/resources/valleyofWorrel.sh)
```

The canonical repository contains the installer, updater, status checks, peer configuration, key/validator helpers, guarded `tx staking delegate` delegation, service management, backup flow, pruning selection, optional Cosmovisor runtime, guarded snapshot application, and manual guides:

- [Valley-of-Worrel-Testnet](https://github.com/hubofvalley/Valley-of-Worrel-Testnet)
- [Usage guide](https://github.com/hubofvalley/Valley-of-Worrel-Testnet/blob/main/docs/usage.md)
- [Manual node guide](https://github.com/hubofvalley/Valley-of-Worrel-Testnet/blob/main/docs/node-guide.md)

## Official sources

- [Worrell node runbook](https://github.com/worrellchain/worrell/blob/main/docs/RUNNING-A-NODE.md)
- [Worrell source](https://github.com/worrellchain/worrell)
- [Worrell network metadata](https://github.com/worrellchain/networks/tree/main/worrell-testnet-1)
- [Validator Telegram](https://t.me/worrellvalidators)

## Safety

Use testnet-only keys. Verify the genesis SHA256, keep `priv_validator_key.json` backed up, keep RPC/API/gRPC private unless protected, and never run two nodes with the same validator signing key. Delegation is an on-chain action: use the Valley `2f` preview, verify the local balance and target validator, and confirm only after checking the exact positive `uworrell` amount.

For the manual workflow and operational checklist, see [validator-node.md](validator-node.md).

`Let's Buidl Worrell Together - Grand Valley`
