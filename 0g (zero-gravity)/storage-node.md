# 0gchain Storage Node Deployment Guide

## Table of Contents

- [0gchain Storage Node Deployment Guide](#0gchain-storage-node-deployment-guide)
  - [Table of Contents](#table-of-contents)
  - [System Requirements](#system-requirements)
  - [Automatic Installation (Recommended)](#automatic-installation-recommended)
    - [Valley of 0G Main Menu (Storage Node Section)](#valley-of-0g-main-menu-storage-node-section)
    - [How to Install Automatically](#how-to-install-automatically)
    - [Apply a Snapshot](#apply-a-snapshot)
    - [Update the Node](#update-the-node)
  - [Manual Installation Guide](#manual-installation-guide)
    - [1. Install Dependencies for Building from Source](#1-install-dependencies-for-building-from-source)
    - [2. Install Go](#2-install-go)
    - [3. Install Rustup](#3-install-rustup)
    - [4. Set Vars](#4-set-vars)
    - [5. Download Binary](#5-download-binary)
    - [6. Check the Storage Node Version](#6-check-the-storage-node-version)
    - [7. Wallet Private Key Check](#7-wallet-private-key-check)
    - [8. Update Node Configuration](#8-update-node-configuration)
    - [9. Create Service](#9-create-service)
    - [10. Start the Node](#10-start-the-node)
    - [11. Show Logs by Date](#11-show-logs-by-date)
    - [Delete Storage Node](#delete-storage-node)
- [Lets Buidl 0G Together](#lets-buidl-0g-together)

---

![0G's storage infrastructure](resources/storage.png)

## System Requirements

| Category   | Requirements                   |
| ---------- | ----------------------------- |
| CPU        | 8+ cores                      |
| RAM        | 32+ GB                        |
| Storage    | 500GB / 1TB NVMe SSD          |
| Bandwidth  | 100 MBps for Download/Upload  |

- Guide's current binary version: `v1.0.0`

---

## Automatic Installation (Recommended)


### Valley of 0G Main Menu (Storage Node Section)
```
2. Storage Node
    a. Deploy Storage Node
    b. Update Storage Node
    c. Apply Storage Node Snapshot
    d. Change Storage Node
    e. Show Storage Node Logs
    f. Show Storage Node Status
```

### How to Install Automatically

1. **Run the Valley of 0G installer:**
   ```bash
   bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20\(zero-gravity\)/resources/valleyof0G.sh)
   ```

2. **At the main menu, select Storage Node options.**
   - To deploy a storage node, enter:
     ```
     2a
     ```
   - To update, enter:
     ```
     2b
     ```
   - To apply a snapshot, enter:
     ```
     2c
     ```

3. **Follow the on-screen prompts until your node is running.**

4. **After exiting the script, apply environment changes:**
   ```bash
   source ~/.bash_profile
   ```

> Valley of 0G automates all required steps, including binary download, configuration, and service setup. For advanced management (logs, status, etc.), use the menu options under "Storage Node".

---

### Apply a Snapshot

If you want to sync your storage node faster, use the snapshot feature in Vo0G.

1. **Open Valley of 0G** (if you haven't already):
   ```bash
   bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20\(zero-gravity\)/resources/valleyof0G.sh)
   ```

2. **From the main menu, input:**
   ```
   2c
   ```
   This will apply the latest snapshot.

> `data_db` is already excluded from the snapshot file.  
> Existing `data_db` will be automatically removed before syncing.

---

### Update the Node

To update your storage node to the latest version:

1. **Open Valley of 0G:**
   ```bash
   bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20\(zero-gravity\)/resources/valleyof0G.sh)
   ```

2. **From the main menu, input:**
   ```
   2b
   ```
   The tool will:
   - Pull the latest version of the repo
   - Rebuild the binary
   - Restart your node with zero hassle

---

## Manual Installation Guide

### 1. Install Dependencies for Building from Source

```bash
sudo apt-get update -y
sudo apt-get install clang cmake build-essential -y
sudo apt install git -y
sudo apt install libssl-dev -y
sudo apt install pkg-config -y
sudo apt-get install protobuf-compiler -y
sudo apt-get install clang -y
sudo apt-get install llvm llvm-dev -y
```

### 2. Install Go

```bash
cd $HOME && \
ver="1.22.0" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile && \
source ~/.bash_profile && \
go version
```

### 3. Install Rustup

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### 4. Set Vars

```bash
read -p "Enter json-rpc: " BLOCKCHAIN_RPC_ENDPOINT && echo "Current json-rpc: $BLOCKCHAIN_RPC_ENDPOINT"
echo "export ENR_ADDRESS=${ENR_ADDRESS}" >> ~/.bash_profile
echo 'export ZGS_LOG_DIR="$HOME/0g-storage-node/run/log"' >> ~/.bash_profile
echo 'export ZGS_LOG_SYNC_BLOCK="0"' >> ~/.bash_profile
echo "export BLOCKCHAIN_RPC_ENDPOINT=\"$BLOCKCHAIN_RPC_ENDPOINT\"" >> ~/.bash_profile
source ~/.bash_profile

### Boot Nodes Configuration
### The following boot nodes are configured by default:

BOOT_NODES=(
  "/ip4/47.251.88.201/udp/1234/p2p/16Uiu2HAmFGrDV8wKToa1dd8uh6bz8bSY28n33iRP3pvfeBU6ysCw"
  "/ip4/47.76.49.188/udp/1234/p2p/16Uiu2HAmBb7PQzvfZjHBENcF7E7mZaiHSrpBoH7mKTyNijYdqMM6"
)
```

Check sync block via:
```bash
curl -s -X POST $BLOCKCHAIN_RPC_ENDPOINT -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r '.result' | xargs printf "%d\n"
```

### 5. Download Binary

```bash
cd $HOME
git clone -b v1.0.0 https://github.com/0glabs/0g-storage-node.git
cd $HOME/0g-storage-node
git stash
git fetch --all --tags
git submodule update --init
```

Then build it:
```bash
cargo build --release
```

### 6. Check the Storage Node Version

```bash
$HOME/0g-storage-node/target/release/zgs_node --version
```

### 7. Wallet Private Key Check

Get private key via validator node:
```bash
0gchaind keys unsafe-export-eth-key $WALLET
```

Save in variable:
```bash
read -p "Enter your private key: " PRIVATE_KEY && echo "private key: $PRIVATE_KEY"
```

### 8. Update Node Configuration

**Standard Contract**
```bash
rm -rf $HOME/0g-storage-node/run/config-testnet.toml && cp $HOME/0g-storage-node/run/config-testnet-standard.toml $HOME/0g-storage-node/run/config-testnet.toml
```

**Turbo Contract (Default)**
```bash
rm -rf $HOME/0g-storage-node/run/config-testnet.toml && cp $HOME/0g-storage-node/run/config-testnet-turbo.toml $HOME/0g-storage-node/run/config-testnet.toml
```

Then edit:
```bash
sed -i "
s|^\s*#\?\s*network_boot_nodes\s*=.*|network_boot_nodes = [\"${BOOT_NODES[0]}\",\"${BOOT_NODES[1]}\"]|
s|^\s*#\s*miner_key\s*=.*|miner_key = \"$PRIVATE_KEY\"|
s|^\s*#\s*listen_address\s*=.*|listen_address = \"0.0.0.0:5678\"|
s|^\s*#\s*listen_address_admin\s*=.*|listen_address_admin = \"0.0.0.0:5679\"|
s|^\s*#\?\s*rpc_enabled\s*=.*|rpc_enabled = true|
s|^\s*#\?\s*log_sync_start_block_number\s*=.*|log_sync_start_block_number = 0|
s|^\s*#\?\s*blockchain_rpc_endpoint\s*=.*|blockchain_rpc_endpoint = \"$BLOCKCHAIN_RPC_ENDPOINT\"|
s|^\s*#\?\s*log_contract_address\s*=.*|log_contract_address = \"0x56A565685C9992BF5ACafb940ff68922980DBBC5\"|
s|^\s*#\?\s*mine_contract_address\s*=.*|mine_contract_address = \"0xB87E0e5657C25b4e132CB6c34134C0cB8A962AD6\"|
s|^\s*#\?\s*reward_contract_address\s*=.*|reward_contract_address = \"0x233B2768332e4Bae542824c93cc5c8ad5d44517E\"|
" $HOME/0g-storage-node/run/config-testnet.toml
```

### 9. Create Service

```bash
sudo tee /etc/systemd/system/zgs.service > /dev/null <<EOF
[Unit]
Description=ZGS Node
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/0g-storage-node/run
ExecStart=$HOME/0g-storage-node/target/release/zgs_node --config $HOME/0g-storage-node/run/config-testnet.toml
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

### 10. Start the Node

```bash
sudo systemctl daemon-reload && \
sudo systemctl enable zgs && \
sudo systemctl restart zgs && \
sudo systemctl status zgs
```

### 11. Show Logs by Date

```bash
tail -f ~/0g-storage-node/run/log/zgs.log.$(TZ=UTC date +%Y-%m-%d)
```

Minimized logs:
```bash
tail -f ~/0g-storage-node/run/log/zgs.log.$(TZ=UTC date +%Y-%m-%d) | grep -v "discv5\|network\|connect\|16U\|nounce"
```

Check node RPC status:
```bash
curl -X POST http://localhost:5678 -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"zgs_getStatus","params":[],"id":1}'  | jq
```

### Delete Storage Node

```bash
sudo systemctl stop zgs
sudo systemctl disable zgs
sudo rm /etc/systemd/system/zgs.service
sudo rm -rf $HOME/0g-storage-node
```

---

# Lets Buidl 0G Together
