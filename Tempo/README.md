# Tempo Testnet Guide

> _This guide is continuously updated._

<p align="center">
  <img src="resources/brand-kit/image.png" width="1000" height="600">
</p>

## Table of Contents

- [Tempo Testnet Guide](#tempo-testnet-guide)
  - [Table of Contents](#table-of-contents)
- [Tempo](#tempo)
  - [What Is Tempo?](#what-is-tempo)
  - [Tempo \& Stablecoins](#tempo--stablecoins)
  - [EVM Compatibility](#evm-compatibility)
  - [Tempo Testnet Connection Details](#tempo-testnet-connection-details)
  - [TIP-20 Token Standard](#tip-20-token-standard)
  - [Fees on Tempo](#fees-on-tempo)
  - [Example Use Case](#example-use-case)
  - [Conclusion](#conclusion)
  - [Grand Valley \& Tempo](#grand-valley--tempo)
  - [Lets Buidl Tempo Together](#lets-buidl-tempo-together)

---

# Tempo

## What Is Tempo?

Tempo is a purpose-built **Layer 1 blockchain for payments**, designed to support high-throughput, low-latency, and low-cost transactions, with a strong focus on stablecoin-based financial applications.

Tempo aims to simplify how developers build payment systems by providing a network optimised specifically for monetary flows, rather than general-purpose smart contract execution alone.

Tempo Testnet is publicly available and open for developers to experiment, integrate, and build.

## Tempo & Stablecoins

Stablecoins are a core primitive in the Tempo ecosystem.

Tempo is designed to support:
- Stable-value payments
- Deterministic settlement
- Predictable fee behaviour
- Transparent accounting

By focusing on stablecoin-native design, Tempo targets real-world payment use cases that require reliability, clarity, and scalability.

## EVM Compatibility

Tempo is **EVM-compatible**, allowing developers to use familiar Ethereum tooling such as:
- Standard JSON-RPC methods
- Ethereum wallets
- Existing EVM development frameworks

Tempo targets modern EVM behaviour, making it easier to port or adapt Ethereum-based applications to the Tempo network.

## Tempo Testnet Connection Details

You can connect to Tempo Testnet using standard EVM-compatible tools.

**Network Details (from official Tempo documentation):**

- **Network Name:** Tempo Testnet (Andantino)
- **Chain ID:** `42429`
- **Currency Symbol:** `USD`
- **HTTP RPC:** `https://rpc.testnet.tempo.xyz`
- **WebSocket RPC:** `wss://rpc.testnet.tempo.xyz`
- **Block Explorer:** `https://explore.tempo.xyz`

> **Note:** Tempo does not use a traditional native gas token. Some wallets may display placeholder balances due to wallet assumptions about native assets.

## TIP-20 Token Standard

TIP-20 is Tempo’s native token standard for stablecoins and payment-focused tokens.

TIP-20:
- Extends ERC-20
- Is designed specifically for stablecoin and payment use cases
- Integrates with Tempo’s fee and payment mechanisms

Developers working with payments on Tempo will primarily interact with TIP-20 tokens.

## Fees on Tempo

Tempo’s fee model is designed around stablecoin-denominated payments.

Transaction fees can be paid using supported TIP-20 tokens, subject to liquidity and protocol rules defined by Tempo. This design allows fees to remain predictable and aligned with real-world value.

For precise details, always refer to the official fee specification in the Tempo documentation.

## Example Use Case

Without Tempo, building a stablecoin payment system typically requires:
- Custom smart contracts
- External accounting logic
- Complex fee handling
- Off-chain reconciliation

With Tempo Testnet, a developer can:
1. Connect to the network using standard EVM tools
2. Work with Tempo Accounts and TIP-20 tokens
3. Issue or integrate stable-value assets
4. Execute payments and settlements directly on-chain

All within a single, coherent payment-focused blockchain environment.

## Conclusion

Tempo provides a clean and focused foundation for building payment and stablecoin applications on-chain. By prioritising payments, settlement, and predictable fees, Tempo lowers the complexity required to build reliable financial infrastructure.

For official references and deeper technical details, visit:

- https://tempo.xyz/
- https://tempo.xyz/blog/testnet
- https://docs.tempo.xyz/
- https://docs.tempo.xyz/quickstart/integrate-tempo
- https://docs.tempo.xyz/quickstart/connection-details
- https://docs.tempo.xyz/protocol
- https://docs.tempo.xyz/sdk

## Grand Valley & Tempo

Grand Valley is exploring Tempo Testnet to:
- Study the protocol from an infrastructure and developer perspective
- Build open-source guides and references for the community
- Prepare for deeper ecosystem participation as Tempo evolves

All guides, tools, and references by Grand Valley will be maintained openly on GitHub and gradually integrated into the official Grand Valley website.

## Lets Buidl Tempo Together