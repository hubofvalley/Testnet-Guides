# Namada Testnet Guide

`will always update`

<p align="center">
  <img src="resources/namadagrandvalley.png" width="600" height="300">
</p>

## Table of Contents

- [Namada Testnet Guide](#namada-guide)
  - [Table of Contents](#table-of-contents)
- [Namada](#namada)
  - [What is Namada?](#what-is-namada)
  - [Key Features](#key-features)
    - [Asset-Agnostic Shielded Transfers](#asset-agnostic-shielded-transfers)
    - [Shared Shielded Set](#shared-shielded-set)
    - [Fast ZKP Generation on Edge Devices](#fast-zkp-generation-on-edge-devices)
    - [Low Transaction Latency and Near-Zero Fees](#low-transaction-latency-and-near-zero-fees)
    - [IBC Compatibility](#ibc-compatibility)
    - [Data Protection as a Public Good](#data-protection-as-a-public-good)
  - [Cubic Proof-of-Stake (CPoS)](#cubic-proof-of-stake-cpos)
    - [Innovations for Validators and Delegators](#innovations-for-validators-and-delegators)
  - [Namada Governance](#namada-governance)
    - [Formal On-Chain Mechanism](#formal-on-chain-mechanism)
    - [Public Goods Funding (PGF)](#public-goods-funding-pgf)
  - [Grand Valley's Namada public endpoints](#grand-valleys-namada-public-endpoints)
- [Lets Buidl Namada Together](#lets-buidl-namada-together)

---

# Namada

## What is Namada?

Namada is a proof-of-stake Layer 1 (L1) for interchain asset-agnostic data protection. It natively interoperates with fast-finality chains via the Inter-Blockchain Communication (IBC) protocol. For data protection, Namada deploys an upgraded version of the multi-asset shielded pool (MASP) circuit that allows all assets (fungible and non-fungible) to share a common shielded set – this way, transferring a CryptoKitty is indistinguishable from transferring ETH, DAI, ATOM, OSMO, NAM (Namada's native asset), or any other asset on Namada. The MASP also enables shielded set rewards, a novel feature that funds data protection as a public good.

## Key Features

### Asset-Agnostic Shielded Transfers

- **Zcash-like Data Protection**: Transfer any fungible and non-fungible tokens with Zcash-like data protection, including native and non-native tokens.
- **zk-SNARKs**: Enabled by the deployment of novel zk-SNARKs.

### Shared Shielded Set

- **Indistinguishable Transfers**: A shielded transfer involving a Stargaze NFT is indistinguishable from an ATOM or NAM transfer.
- **Upgraded MASP**: The MASP, an upgraded version of Zcash's Sapling circuit, enables all assets to share the same shielded set, ensuring data protection guarantees are not fragmented among individual assets and are independent of the transaction volume of a particular asset.

### Fast ZKP Generation on Edge Devices

- **Vertical Integration**: Namada is vertically integrated, allowing users to interact at Testnet with the protocol and send shielded transfers via browser applications.

### Low Transaction Latency and Near-Zero Fees

- **Fast-Proof Generation**: Supports Visa-like speed with fast-proof generation and modern BFT consensus.
- **Scalability**: Namada scales via fractal instances, similar to Anoma.

### IBC Compatibility

- **Interoperability**: Interoperates with any fast-finality chain that is IBC compatible.

### Data Protection as a Public Good

- **Incentives**: The Namada protocol incentivizes users that hold shielded assets, thereby contributing to the shared shielded set, via the latest update of the MASP circuit that includes the novel Convert Circuit.
- **Public Good**: The shielded set in Namada is a non-exclusive and anti-rivalrous public good; the more people use shielded transfers, the better the data protection guarantees for each individual.

## Cubic Proof-of-Stake (CPoS)

### Innovations for Validators and Delegators

- **Cubic Slashing**: Penalties for safety faults in Namada are calculated following a cubic slashing algorithm, encouraging validators to deploy more diverse and uncorrelated setups.
- **Improved PoS Guarantees**: The cost of attacking Namada is quantifiable due to the automatic detection mechanism on which accounts contributed to the fault (validators, delegators, etc.).
- **Transaction Fees in Multiple Assets**: Fees can be paid in many tokens and can be updated via a governance vote.

## Namada Governance

### Formal On-Chain Mechanism

- **Stake-Weighted Voting**: Namada's on-chain governance protocol supports text-based proposals with stake-weighted voting.
- **Proposal Format**: Proposals in Namada use a similar format to BIP2.
- **Voting**: Anyone with NAM tokens can vote in governance, and delegators can overwrite their validators' votes.

### Public Goods Funding (PGF)

- **Retroactive and Continuous Funding**: Namada supports both retroactive and continuous public-goods funding.
- **Council**: Managed by a public-goods-funding council composed of trusted community members (elected by governance).
- **Disbursement**: Continuous funding is regularly distributed, while retroactive funding is distributed in lump-sum payments based on past work.
- **Veto Mechanism**: The community has a veto mechanism to check on council members' spending proposals.

For more detailed information, visit the [Namada Documentation](https://docs.namada.net/).

With Public Testnet, Namada's docs and code become public. Check them out below!

- [Namada Website](https://namada.net/)
- [Namada Twitter](https://twitter.com/namada)
- [Namada Discord](https://discord.gg/namada)
- [Namada Docs](https://docs.namada.net/)
- [Namada GitHub](https://github.com/anoma)

## Grand Valley's Namada public endpoints

- cosmos rpc: `https://lightnode-rpc-namada.grandvalleys.com`
- json-rpc: `https://lightnode-json-rpc-namada.grandvalleys.com`
- cosmos ws: `wss://lightnode-rpc-namada.grandvalleys.com/websocket`
- seed: `tcp://65882ea69f4146d8cc83564257252f4711d3e05e@seed-namada.grandvalleys.com:56656`
- peer: `tcp://3879583b9c6b1ac29d38fefb5a14815dd79282d6@peer-namada.grandvalleys.com:38656`
- indexer: `https://indexer-namada.grandvalleys.com`
- masp-indexer: `https://masp-indexer-namada.grandvalleys.com`
- Valley of Namadillo (Namadillo): `https://valley-of-namadillo.grandvalleys.com`

# Lets Buidl Namada Together
