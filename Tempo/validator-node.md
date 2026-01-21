# Table of Contents
- [Table of Contents](#table-of-contents)
- [Installation](#installation)
  - [System Requirements](#system-requirements)
  - [Automatic Installation](#automatic-installation)
    - [Valley of Tempo (Testnet): Tools by Grand Valley](#valley-of-tempo-testnet-tools-by-grand-valley)
      - [Key Features of Valley of Tempo](#key-features-of-valley-of-tempo)
      - [Run the following command to install Valley of Tempo:](#run-the-following-command-to-install-valley-of-tempo)
  - [Manual Installation](#manual-installation)
    - [1. Install Dependencies](#1-install-dependencies)
    - [2. Set Vars (Moniker, Ports, Wallet)](#2-set-vars-moniker-ports-wallet)
    - [3. Open Firewall Ports](#3-open-firewall-ports)
    - [4. Install Tempo and Foundry Binary](#4-install-tempo-and-foundry-binary)
    - [5. Prepare the Data Directory](#5-prepare-the-data-directory)
    - [6. Download Snapshot (Genesis + State)](#6-download-snapshot-genesis--state)
    - [7. Create the Systemd Service](#7-create-the-systemd-service)
    - [8. Start the Node](#8-start-the-node)
  - [Operations Cheat Sheet](#operations-cheat-sheet)
  - [Delete the Node](#delete-the-node)
  - [Upgrade Tempo Manually](#upgrade-tempo-manually)

# Installation

## System Requirements

| Category   | Requirements     |
| ---------- | ---------------- |
| CPU        | 8+ cores         |
| RAM        | 32+ GB           |
| Storage    | 500+ GB NVMe SSD |
| Bandwidth  | 1Gbit/s         |

- Service file name: `tempo.service`
- Current chain: `Tempo Testnet (Moderato)`
- Chain ID: `42431`
- Current tempo binary version: `v1.0.0-rc.1`

## Automatic Installation

### Valley of Tempo (Testnet): Tools by Grand Valley

![Valley of Tempo Image 1](resources/VoT.png)

**Valley of Tempo** by Grand Valley is an all-in-one toolkit for running and operating Tempo nodes. Tempo is a payments-first blockchain incubated by Stripe and Paradigm, built on the Reth (Rust Ethereum) stack to deliver 100,000+ TPS and sub-second finality. This guide keeps the Valley tone while mapping every step to Tempo's high-throughput infra.

#### Key Features of Valley of Tempo

- **Deploy and Manage Tempo Nodes:** Spin up new nodes or remove existing ones. **Important!** Always back up keys before wiping data.
- **Node Control:** Start, stop, or restart services with a single action.
- **Node Status:** Quickly check sync health and service state.
- **Peer & Networking:** Open required ports and peer for stable connectivity.
- **Client Updates:** Keep the Tempo binary current for best performance.
- **Logging:** Tail unified logs for fast troubleshooting.
- **Key Handling:** Export keys from your Tempo wallet directory (back them up securely).
- **Snapshot Sync:** Use the latest snapshot to accelerate initial sync.
- **Tempo CLI Installation:** Install the Tempo app for command-line transactions without running a full node.

#### Run the following command to install Valley of Tempo:

```bash
bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/Tempo/resources/valleyofTempo.sh)
```

This loader script (stored in this repo) fetches and runs the primary installer hosted in the dedicated Valley-of-Tempo-Testnet repository: https://github.com/hubofvalley/Valley-of-Tempo-Testnet.

## Manual Installation

### 1. Install Dependencies

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git jq lz4 build-essential ufw
```

### 2. Set Vars (Moniker, Ports, Wallet)

```bash
read -p "Enter your moniker: " MONIKER && echo "Current moniker: $MONIKER"
read -p "Enter your 2 digits custom port (leave empty to use default: 30): " TEMPO_PORT && echo "Current port number: ${TEMPO_PORT:-30}"

echo "export MONIKER=$MONIKER" >> $HOME/.bash_profile
echo "export TEMPO_CHAIN_ID=moderato" >> $HOME/.bash_profile
echo "export TEMPO_PORT=${TEMPO_PORT:-30}" >> $HOME/.bash_profile
echo "export TEMPO_HOME=$HOME/.tempo" >> $HOME/.bash_profile
echo "export PATH=$HOME/.tempo/bin:\$PATH" >> $HOME/.bash_profile

source $HOME/.bash_profile
```

### 3. Open Firewall Ports

Tempo uses specific ports for peering and RPC. Allow SSH first so you do not lock yourself out.

- 22 (TCP): SSH
- 30303 (TCP/UDP): Tempo P2P
- 8545 (TCP): HTTP RPC
- 9000 (TCP): Metrics

```bash
sudo ufw allow 22/tcp comment "SSH Access"
sudo ufw allow ${TEMPO_PORT}303/tcp comment "Tempo Testnet P2P Peering"
sudo ufw allow ${TEMPO_PORT}303/udp comment "Tempo Testnet P2P Discovery"
sudo ufw allow ${TEMPO_PORT}545/tcp comment "Tempo Testnet HTTP RPC"
sudo ufw --force enable
sudo ufw status verbose
```

### 4. Install Tempo and Foundry Binary

```bash
curl -L https://tempo.xyz/install | bash

touch ~/.bash_profile
if [ -f ~/.bashrc ]; then
  grep -E "tempo|Tempo|\\.tempo" ~/.bashrc >> ~/.bash_profile || true
  sed -i.bak '/tempo\|Tempo\|\.tempo/d' ~/.bashrc
fi

# Install Foundry (store env in .bash_profile just like Tempo)
curl -L https://foundry.paradigm.xyz | bash

if [ -f ~/.bashrc ]; then
  grep -E "foundry|Foundry|\\.foundry" ~/.bashrc >> ~/.bash_profile || true
  sed -i.bak '/foundry\|Foundry\|\.foundry/d' ~/.bashrc
fi

if ! grep -q ".foundry/bin" ~/.bash_profile; then
  echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> ~/.bash_profile
fi

source ~/.bash_profile
~/.foundry/bin/foundryup
source ~/.bash_profile
tempo --version
cast --version
```

### 5. Prepare the Data Directory

```bash
mkdir -p $HOME/.tempo/data
```

### 6. Download Snapshot (Genesis + State)

```bash
tempo download
sudo rm -r $HOME/.local/share/reth
```

This pulls the latest snapshot so you do not need to replay the chain from block 0.

### 7. Create the Systemd Service

```bash
sudo tee /etc/systemd/system/tempo.service > /dev/null <<EOF
[Unit]
Description=Tempo Node (Reth stack)
After=network.target
Wants=network.target

[Service]
Type=simple
User=$USER
Group=$USER
Environment=RUST_LOG=info
WorkingDirectory=$HOME/.tempo
ExecStart=$HOME/.tempo/bin/tempo node \
  --datadir $HOME/.tempo/data \
  --follow wss://rpc.moderato.tempo.xyz \
  --port ${TEMPO_PORT}303 \
  --discovery.addr 0.0.0.0 \
  --discovery.port ${TEMPO_PORT}303 \
  --http \
  --http.addr 0.0.0.0 \
  --http.port ${TEMPO_PORT}545 \
  --http.api eth,net,web3,txpool,trace \
  --ws.addr 127.0.0.1 \
  --ws.port ${TEMPO_PORT}546 \
  --authrpc.addr 127.0.0.1 \
  --authrpc.port ${TEMPO_PORT}551 \
  --metrics $(curl -4 -s ifconfig.me):${TEMPO_PORT}900 \
  --full \
  --prune.block-interval 2500 \
  --prune.sender-recovery.full \
  --prune.receipts.distance 10064 \
  --prune.account-history.distance 10064 \
  --prune.storage-history.distance 10064
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=tempo
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF
```

### 8. Start the Node

```bash
sudo systemctl daemon-reload
sudo systemctl enable tempo
sudo systemctl restart tempo
```

Tail logs to confirm healthy sync:

```bash
sudo journalctl -u tempo -f -o cat
```

You should see rapid `Block added` and `Forkchoice updated` messages as the node catches up.

---

## Operations Cheat Sheet

- **Check status:** `systemctl status tempo`
- **Restart:** `sudo systemctl restart tempo`
- **Stop:** `sudo systemctl stop tempo`
- **Logs (live):** `sudo journalctl -u tempo -f -o cat`
- **Verify binary:** `tempo --version`
- **Data directory:** `$HOME/.tempo/data`

---

## Delete the Node

> **Warning:** This wipes your local Tempo data and service file. Back up any keys before you proceed.

```bash
sudo systemctl stop tempo
sudo systemctl disable tempo
sudo rm /etc/systemd/system/tempo.service
sudo rm -rf $HOME/.tempo
sudo systemctl daemon-reload
```

---

## Upgrade Tempo Manually

If a new Tempo binary is announced:

```bash
curl -L https://tempo.xyz/install | bash

touch ~/.bash_profile
if [ -f ~/.bashrc ]; then
  grep -E "tempo|Tempo|\\.tempo" ~/.bashrc >> ~/.bash_profile || true
  sed -i.bak '/tempo\|Tempo\|\.tempo/d' ~/.bashrc
fi

source ~/.bash_profile
tempo --version
sudo systemctl restart tempo
```
