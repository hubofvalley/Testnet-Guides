# Seismic Contract Deployment & Interaction Guide

This guide walks you through deploying and interacting with encrypted smart contracts on the Seismic devnet, based directly on [ThanhTuan1695's practical walkthrough](https://github.com/ThanhTuan1695/Nodes/tree/main/Seismic).

---

## Requirements

- Ubuntu 20.04 or higher
- Rust (via `rustup`)
- `jq`

Install essentials:
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install curl git jq build-essential -y
```

---

## 1. Install Rust
```bash
curl https://sh.rustup.rs -sSf | sh
```
Choose option 1 and wait. Then:
```bash
. "$HOME/.cargo/env"
```

---

## 2. Install Seismic Tooling
```bash
curl -L \
  -H "Accept: application/vnd.github.v3.raw" \
  "https://api.github.com/repos/SeismicSystems/seismic-foundry/contents/sfoundryup/install?ref=seismic" | bash
```
Follow the shell’s suggestion (typically):
```bash
source ~/.bashrc
sfoundryup
```

---

## 3. Clone Devnet Starter Project
```bash
git clone --recurse-submodules https://github.com/SeismicSystems/try-devnet.git
cd try-devnet/packages/contract/
```

---

## 4. Deploy Contract
```bash
bash script/deploy.sh
```
Follow prompts:
- Step 1: Just hit Enter
- Step 2: Visit [faucet](https://faucet-2.seismicdev.net/), paste the address shown, request tokens
- Wait 15–30 seconds
- Hit Enter again to continue

You'll know it's successful when you see confirmation on-screen.

---

## 5. Interact with the Contract
### Step 1: Install Bun
```bash
curl -fsSL https://bun.sh/install | bash
```
Follow the instructions to update your environment.

### Step 2: Setup CLI and Run
```bash
cd ~/try-devnet/packages/cli/
bun install
bash script/transact.sh
```
Again:
- Step 1: Hit Enter
- Step 2: Use [faucet](https://faucet-2.seismicdev.net/) again with shown address
- Wait, then hit Enter again

You’re done when you see the final confirmation message.

---

## Devnet Info

- **Network Name**: Seismic devnet
- **Currency Symbol**: ETH
- **Chain ID**: 5124
- **RPC (HTTP)**: https://node-2.seismicdev.net/rpc
- **RPC (WebSocket)**: wss://node-2.seismicdev.net/ws
- **Explorer**: https://explorer-2.seismicdev.net
- **Faucet**: https://faucet-2.seismicdev.net

---

Built this using [SeismicSystems/seismic-starter](https://github.com/SeismicSystems/seismic-starter).