# 0G Testnet Guide

oO> _This guide is continuously updated._

<p align="center">
  <img src="https://github.com/hubofvalley/Testnet-Guides/assets/100946299/fe21ef6a-0979-4ac1-8d92-6d1bcf76c7cc" width="600" height="300">
</p>

## Table of Contents

- [0G Testnet Guide](#0g-testnet-guide)
  - [Table of Contents](#table-of-contents)
- [ZeroGravity](#zerogravity)
  - [What Is 0G?](#what-is-0g)
  - [0G’s Architecture](#0gs-architecture)
  - [0G Solving Target](#0g-solving-target)
  - [Conclusion](#conclusion)
  - [Grand Valley's 0G Testnet Public Endpoints](#grand-valleys-0g-testnet-public-endpoints)
- [Continue to Storage Node](#continue-to-storage-node)
- [Let's Buidl 0G Together](#lets-buidl-0g-together)

---

# ZeroGravity

## What Is 0G?

ZeroGravity (0G) is the first infinitely scalable, decentralized data availability layer featuring a built-in general-purpose storage system. This enables 0G to offer a highly scalable on-chain database suitable for various Web2 and Web3 data needs, including on-chain AI. As a data availability layer, 0G ensures seamless verification of accurate data storage.

![dAIOS](resources/dAIOS.png)

In the sections below, we will delve deeper into this architecture and explore the key use cases it unlocks.

## 0G’s Architecture

0G achieves high scalability by dividing the data availability workflow into two main lanes:

1. **Data Storage Lane**: Achieves horizontal scalability through data partitioning, allowing rapid storage and access of large amounts of data.
2. **Data Publishing Lane**: Ensures data availability using a quorum-based system with an "honest majority" assumption, where the quorum is randomly selected via a Verifiable Random Function (VRF). This method avoids data broadcasting bottlenecks and supports larger data transfers in the Storage Lane.

0G Storage is an on-chain database made up of Storage Nodes that participate in a Proof of Random Access (PoRA) mining process. Nodes are rewarded for correctly responding to random data queries, promoting network participation and scalability.

0G DA (Data Availability) Layer is built on 0G Storage and uses a quorum-based architecture for data availability confirmation. The system relies on an honest majority of nodes, with quorum selection randomized by VRF and GPUs enhancing the erasure coding process for data storage.

## 0G Solving Target

The increasing need for greater Layer 2 (L2) scalability has coincided with the rise of Data Availability Layers (DALs), which are essential for addressing Ethereum's scaling challenges. L2s handle transactions off-chain and settle on Ethereum for security, requiring transaction data to be posted somewhere for validation. By publishing data directly on Ethereum, high fees are distributed among L2 users, enhancing scalability.

DALs offer a more efficient method for publishing and maintaining off-chain data for inspection. However, existing DALs struggle to manage the growing volume of on-chain data, especially for data-intensive applications like on-chain AI, due to limited storage capacity and throughput.

0G offers a solution with a 1,000x performance improvement over Ethereum's danksharding and a 4x improvement over Solana's Firedancer, providing the infrastructure needed for massive Web3 data scalability. Key applications of 0G include:

1. **AI**: 0G Storage can handle large datasets, and 0G DA enables the rapid deployment of AI models on-chain.
2. **L1s / L2s**: These networks can use 0G for data availability and storage, with partners like Polygon, Arbitrum, Fuel, and Manta Network.
3. **Bridges**: Networks can store their state using 0G, facilitating secure cross-chain transfers by storing and communicating user balances.
4. **Rollups-as-a-Service (RaaS)**: 0G provides DA and storage infrastructure for RaaS providers like Caldera and AltLayer.
5. **DeFi**: 0G's scalable DA supports efficient DeFi on specific L2s and L3s, enabling fast settlement and high-frequency trading.
6. **On-chain Gaming**: Gaming requires reliable storage of cryptographic proofs and metadata, such as player assets and actions.
7. **Data Markets**: Web3 data markets can store their data on-chain, feasible on a large scale with 0G.

## Conclusion

0G is a scalable, low-cost, and programmable DA solution essential for bringing vast amounts of data on-chain. Its role as an on-chain data storage solution unlocks numerous use cases, providing the database infrastructure for any on-chain application. 0G efficiently stores and proves the availability of any Web2 or Web3 data, extending benefits beyond confirming L2 transactions.

For more detailed information, visit the [0G DA documentation](https://docs.0g.ai/0g-doc/docs/0g-da).

With Public Testnet, 0G’s docs and code become public. Check them out below:

- [0gchain Website](https://0g.ai/)
- [0gchain X](https://x.com/0G_labs)
- [0gchain Discord](https://discord.com/invite/0glabs)
- [0gchain Docs](https://docs.0g.ai/0g-doc)
- [0gchain Github](https://github.com/0glabs)
- [0gchain Explorer](https://explorer.grandvalleys.com/0g-chain%20testnet)

## Grand Valley's 0G Testnet Public Endpoints

- **Cosmos RPC:** `https://lightnode-rpc-0g.grandvalleys.com`
- **JSON-RPC:** `https://lightnode-json-rpc-0g.grandvalleys.com`
- **Cosmos REST API:** `https://lightnode-api-0g.grandvalleys.com`
- **Peer:** `a97c8615903e795135066842e5739e30d64e2342@peer-0g.grandvalleys.com:28656`

---

# [Continue to Storage Node](https://github.com/hubofvalley/Testnet-Guides/blob/main/0g%20(zero-gravity)/storage-node.md)

---

# Let's Buidl 0G Together
