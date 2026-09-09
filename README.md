# Testnet Guides

This repository is the original Grand Valley testnet guide collection. Current network documentation and automation are maintained in one Valley toolkit per network; this collection keeps legacy material and provides the directory of current toolkits.

## Current Grand Valley testnet toolkit coverage

Grand Valley currently maintains public tooling and documentation for these testnet targets:

| Network | Current target | Coverage | Canonical toolkit | Guide |
|---|---|---|---|---|
| 0G (ZeroGravity) | Galileo (`0G-testnet-galileo`, EVM `16602`) | Validator, storage node, and Storage KV tooling | [Valley-of-0G-Testnet](https://github.com/hubofvalley/Valley-of-0G-Testnet) | [0G guide](https://github.com/hubofvalley/Valley-of-0G-Testnet/tree/main/docs) |
| Story Protocol | Aeneid (`1315`) | Consensus/EVM validator tooling | [Valley-of-Story-Testnet](https://github.com/hubofvalley/Valley-of-Story-Testnet) | [Story guide](https://github.com/hubofvalley/Valley-of-Story-Testnet/tree/main/docs) |
| Tempo | Moderato (`42431`) | EVM node tooling | [Valley-of-Tempo-Testnet](https://github.com/hubofvalley/Valley-of-Tempo-Testnet) | [Tempo guide](https://github.com/hubofvalley/Valley-of-Tempo-Testnet/tree/main/docs) |
| Limonata | `limonata_10777-1` (EVM `10777`) | Validator and node tooling | [Valley-of-Limonata-Testnet](https://github.com/hubofvalley/Valley-of-Limonata-Testnet) | [Limonata guide](https://github.com/hubofvalley/Valley-of-Limonata-Testnet/tree/main/docs) |
| Gno.land | Pearl (`pearl-1`) | Full-node and validator-candidate workflow | [Valley-of-Gnoland-Testnet](https://github.com/hubofvalley/Valley-of-Gnoland-Testnet) | [Gno.land guide](https://github.com/hubofvalley/Valley-of-Gnoland-Testnet/tree/main/docs) |
| Worrell | `worrell-testnet-1` | Full-node and validator tooling | [Valley-of-Worrel-Testnet](https://github.com/hubofvalley/Valley-of-Worrel-Testnet) | [Worrell guide](https://github.com/hubofvalley/Valley-of-Worrel-Testnet/tree/main/docs) |

This is an inventory of maintained Grand Valley toolkit and documentation coverage. It does **not** by itself claim that Grand Valley currently occupies the active validator set on every listed network. In particular, Gno.land registration is a validator-candidate workflow and is not automatic active-set admission.

## How to use the current toolkits

Use the canonical toolkit repository for the network you need. Each toolkit contains its reviewed launcher, manual guide, version information, safety notes, and network-specific features.

All launcher scripts should be reviewed before execution and run as the normal OS user that owns the node. Do not expose validator keys, mnemonics, private RPC services, or internal infrastructure details.

## Legacy material

The folders in this repository include earlier or historical guides for Anoma, Fogo, Gensyn, Initia, KiteAI, Monad, NEAR StakeWars III, Nexus, Optimum, Sacas Network, Seismic, Stride, and Vana. They remain for reference and should not be treated as the current maintained-toolkit inventory.

`SUMMARY.md` indexes the in-repository guide collection; the maintained-toolkit inventory above is the authoritative current list.

## Grand Valley

- GitHub: [@hubofvalley](https://github.com/hubofvalley)
- X: [@bacvalley](https://x.com/bacvalley)
- Email: letsbuidltogether@grandvalleys.com

**Let's Buidl Together - Grand Valley**
