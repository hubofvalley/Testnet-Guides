# Story Protocol Testnet Guide

> _This guide is continuously updated._

<p align="center">
  <img src="https://github.com/user-attachments/assets/2ac53a77-8eec-48be-9106-eb832ae5fee3" width="600" height="300">
</p>

## Table of Contents

- [Story Protocol Testnet Guide](#story-protocol-testnet-guide)
  - [Table of Contents](#table-of-contents)
- [Story Protocol](#story-protocol)
  - [What Is Story?](#what-is-story)
  - [Story’s Architecture](#storys-architecture)
    - [Components](#components)
    - [Modules](#modules)
  - [Programmable IP License (PIL)](#programmable-ip-license-pil)
  - [Story Solving Target](#story-solving-target)
  - [Example Use Case](#example-use-case)
  - [Conclusion](#conclusion)
  - [Grand Valley's Story Protocol Testnet Public Endpoints](#grand-valleys-story-protocol-testnet-public-endpoints)
- [Lets Buidl Story Together](#lets-buidl-story-together)

---

# Story Protocol

## What Is Story?

Story is an innovative initiative designed to revolutionize the management of creative Intellectual Property (IP) by leveraging blockchain technology. By making IP "programmable," Story aims to streamline the processes of protection, licensing, and monetization of creative works. The core of this endeavor is the Story Network, a specialized layer 1 blockchain built to support efficient and scalable IP management.

![image](https://github.com/user-attachments/assets/2ceec88b-8c84-4b48-a31d-e2c888c6b80d)

In the sections below, we will delve deeper into this architecture and explore the key use cases it unlocks.

## Story’s Architecture

Story Network is a purpose-built layer 1 blockchain that combines the advantages of EVM (Ethereum Virtual Machine) and Cosmos SDK. It is fully EVM-compatible and features deep execution layer optimizations to support complex data structures like IP quickly and cost-efficiently. Key features include:

1. **Precompiled Primitives**: Traverse complex data structures like IP graphs within seconds at marginal costs, ensuring that the licensing process is both fast and affordable.
2. **Consensus Layer**: Based on the mature CometBFT stack, this layer ensures fast finality and cheap transactions, further enhancing the efficiency of the network.

The Proof-of-Creativity Protocol is a set of smart contracts natively deployed on Story Network. It allows creators to register their IP as "IP Assets" (IPA) on the protocol.

### Components

- **On-Chain NFT**: Represents the IP, which could be an existing NFT or a new NFT minted to represent off-chain IP.
- **IP Account**: A modified ERC-6551 (Token Bound Account) implementation that manages the IP.

### Modules

- **Licensing Module**: Allows creators to set terms on their IP, such as whether derivative works can use the IP commercially.
- **Royalty Module**: Enables the creation of revenue streams from derivative works.
- **Dispute Module**: Facilitates the resolution of disputes.

## Programmable IP License (PIL)

The PIL is an off-chain legal contract that enforces the terms of IP Assets and License Tokens. It allows the redemption of tokenized IP into the off-chain legal system, outlining real legal terms for how creators can remix, monetize, and create derivatives of their IP.

## Story Solving Target

The increasing need for greater efficiency in IP management has coincided with the rise of blockchain technology, which is essential for addressing the current system's challenges. Traditional methods of protecting and licensing IP are cumbersome and expensive, often requiring the involvement of lawyers. This makes the process inaccessible for many creators, particularly those without substantial resources.

Moreover, the current system relies on one-to-one licensing deals, which are not scalable. This leads to many potential licensing opportunities being missed, stifling creativity and innovation. Additionally, the rapid proliferation of AI-generated media has outpaced the current IP system, which was designed for physical replication. There is an urgent need to automate and optimize the licensing of IP to keep up with the digital age.

Story offers a solution with a specialized layer 1 blockchain that combines the advantages of EVM and Cosmos SDK, providing the infrastructure needed for massive IP data scalability. Key applications of Story include:

1. **Creators**: Register IP as IP Assets and set terms using the Programmable IP License (PIL).
2. **Derivative Works**: License IP automatically through the blockchain, making the process efficient and scalable.
3. **AI-Generated Media**: Efficiently manage AI-generated content by automating the licensing process.
4. **Scalable Licensing**: Ensure all potential opportunities are captured, fostering creativity and collaboration.

## Example Use Case

Without Story, creating a comic with multiple IPs (e.g., Azuki and Pudgy NFTs) would require extensive legal work, making it impractical. With Story, IP holders can register their IP, set terms, and license their work automatically through the blockchain, making the process efficient and scalable.

## Conclusion

By leveraging blockchain technology, Story is poised to revolutionize IP management, making it more efficient, scalable, and accessible for creators worldwide. It provides a scalable, low-cost, and fully programmable IP management solution essential for bringing vast amounts of IP on-chain.

For more detailed information, visit the [Story Documentation](https://docs.story.foundation).

With Public Testnet, Story's docs and code become public. Check them out below:

- [Story Website](https://www.story.foundation/)
- [Story Twitter](https://x.com/StoryProtocol)
- [Story Discord](https://discord.gg/storyprotocol)
- [Story Docs](https://docs.story.foundation/)
- [Story GitHub](https://github.com/storyprotocol)
- [Story Explorer](https://testnet.storyscan.app/)
- [Piplabs Github](https://github.com/piplabs)

## Grand Valley's Story Protocol Testnet Public Endpoints

- **Cosmos RPC:** `https://lightnode-rpc-story.grandvalleys.com`
- **JSON-RPC:** `https://lightnode-json-rpc-story.grandvalleys.com`
- **Cosmos REST API:** `https://lightnode-api-story.grandvalleys.com`
- **Cosmos WS:** `wss://lightnode-rpc-story.grandvalleys.com/websocket`
- **EVM WS:** `wss://lightnode-wss-story.grandvalleys.com`
- **Peer:** `7e311e22cff1a0d39c3758e342fa4c2ee1aea461@peer-story.grandvalleys.com:28656`

# Lets Buidl Story Together