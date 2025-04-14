# 0gchain Storage KV Deployment Guide

> **Before you deploy the Storage KV node, you must first deploy your [storage node](https://github.com/hubofvalley/Testnet-Guides/blob/main/0g%20(zero-gravity)/storage-node.md).**

## Table of Contents

- [0gchain Storage KV Deployment Guide](#0gchain-storage-kv-deployment-guide)
  - [Table of Contents](#table-of-contents)
  - [System Requirements](#system-requirements)
  - [Automatic Installation (Recommended)](#automatic-installation-recommended)
    - [Valley of 0G Main Menu (Storage KV Section)](#valley-of-0g-main-menu-storage-kv-section)
    - [How to Install Automatically](#how-to-install-automatically)
  - [Manual Installation Guide](#manual-installation-guide)
    - [1. Install Dependencies](#1-install-dependencies)
    - [2. Install Go](#2-install-go)
    - [3. Install Rust](#3-install-rust)
    - [4. Set Environment Variables](#4-set-environment-variables)
    - [5. Download the Binary](#5-download-the-binary)
    - [6. Configure the Node](#6-configure-the-node)
    - [7. Create a Systemd Service](#7-create-a-systemd-service)
    - [8. Start the Node](#8-start-the-node)
    - [9. Check Logs](#9-check-logs)
  - [Delete the Node](#delete-the-node)
  - [Manual Update](#manual-update)
- [Lets Buidl 0G Together](#lets-buidl-0g-together)

---

## System Requirements

| Category | Requirements                                |
| -------- | ------------------------------------------- |
| CPU      | 8+ cores                                    |
| RAM      | 32+ GB                                      |
| Storage  | Matches the size of KV streams it maintains |

- Guide's current binary version: `v1.4.0`

---

## Automatic Installation (Recommended)

For the fastest and easiest way to deploy or manage your Storage KV node, use **Valley of 0G**. This tool automates installation, updates, and service management for Storage KV.

### Valley of 0G Main Menu (Storage KV Section)
```
3. Storage KV
    a. Deploy Storage KV
    b. Show Storage KV Logs
    c. Update Storage KV
```

### How to Install Automatically

1. **Run the Valley of 0G installer:**
   ```bash
   bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20(zero-gravity)/resources/valleyof0G.sh)
   ```

2. **At the main menu, select Storage KV options.**
   - To deploy Storage KV, enter:
     ```
     3a
     ```
   - To view logs, enter:
     ```
     3b
     ```
   - To update Storage KV, enter:
     ```
     3c
     ```

3. **Follow the on-screen prompts until your node is running.**

4. **After exiting the script, apply environment changes:**
   ```bash
   source ~/.bash_profile
   ```

> Valley of 0G automates all required steps, including dependency installation, binary build, configuration, and service setup. For advanced management (logs, updates), use the menu options under "Storage KV".

---

## Manual Installation Guide

This section describes how to manually install and run a 0gchain Storage KV node from source.

---

### 1. Install Dependencies

```bash
sudo apt-get update -y
sudo apt-get install clang cmake build-essential -y
sudo apt install cargo -y
```

### 2. Install Go

```bash
cd $HOME
ver="1.22.0"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```

### 3. Install Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### 4. Set Environment Variables

```bash
read -p "Enter json-rpc: " BLOCKCHAIN_RPC_ENDPOINT
echo "Current json-rpc: $BLOCKCHAIN_RPC_ENDPOINT"

read -p "Enter storage kv urls: " ZGS_NODE
echo "Current storage kv urls: $ZGS_NODE"

echo 'export ZGS_LOG_SYNC_BLOCK="595059"' >> ~/.bash_profile
echo "export ZGS_NODE=$ZGS_NODE" >> ~/.bash_profile
echo 'export LOG_CONTRACT_ADDRESS="0xbD2C3F0E65eDF5582141C35969d66e34629cC768"' >> ~/.bash_profile
echo "export BLOCKCHAIN_RPC_ENDPOINT=$BLOCKCHAIN_RPC_ENDPOINT" >> ~/.bash_profile

source ~/.bash_profile

echo -e "\n\033[31mCHECK YOUR STORAGE KV VARIABLES\033[0m\n"
echo "ZGS_NODE: $ZGS_NODE"
echo "LOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS"
echo "ZGS_LOG_SYNC_BLOCK: $ZGS_LOG_SYNC_BLOCK"
echo "BLOCKCHAIN_RPC_ENDPOINT: $BLOCKCHAIN_RPC_ENDPOINT"
echo -e "\n\033[3mLet's Buidl 0G Together - Grand Valley\033[0m\n"
```

### 5. Download the Binary

```bash
cd $HOME
git clone -b v1.4.0 https://github.com/0glabs/0g-storage-kv.git
cd 0g-storage-kv
git stash
git fetch --all --tags
git submodule update --init
cargo build --release
```

### 6. Configure the Node

```bash
cp $HOME/0g-storage-kv/run/config_example.toml $HOME/0g-storage-kv/run/config.toml
```

Update the config:
```bash
sed -i '
s|^\s*#?\s*rpc_enabled\s*=.*|rpc_enabled = true|
s|^\s*#?\s*rpc_listen_address\s*=.*|rpc_listen_address = "0.0.0.0:6789"|
s|^\s*#?\s*db_dir\s*=.*|db_dir = "db"|
s|^\s*#?\s*kv_db_dir\s*=.*|kv_db_dir = "kv.DB"|
s|^\s*#?\s*log_config_file\s*=.*|log_config_file = "log_config"|
s|^\s*#?\s*log_contract_address\s*=.*|log_contract_address = "'"$LOG_CONTRACT_ADDRESS"'"|
s|^\s*#?\s*zgs_node_urls\s*=.*|zgs_node_urls = "'"$ZGS_NODE"'"|
s|^\s*#?\s*log_sync_start_block_number\s*=.*|log_sync_start_block_number = '"$ZGS_LOG_SYNC_BLOCK"'|
s|^\s*#?\s*blockchain_rpc_endpoint\s*=.*|blockchain_rpc_endpoint = "'"$BLOCKCHAIN_RPC_ENDPOINT"'"|
' $HOME/0g-storage-kv/run/config.toml
```

### 7. Create a Systemd Service

```bash
sudo tee /etc/systemd/system/zgskv.service > /dev/null <<EOF
[Unit]
Description=ZGS KV Node
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/0g-storage-kv/run
ExecStart=$HOME/0g-storage-kv/target/release/zgs_kv --config $HOME/0g-storage-kv/run/config.toml
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
StandardOutput=journal
StandardError=journal
SyslogIdentifier=zgs_kv

[Install]
WantedBy=multi-user.target
EOF
```

### 8. Start the Node

```bash
sudo systemctl daemon-reload
sudo systemctl enable zgskv
sudo systemctl start zgskv
sudo systemctl status zgskv
```

### 9. Check Logs

```bash
sudo journalctl -u zgskv -fn 100 -o cat
```

Make sure your `tx_seq` is syncing. You can also check it on the [Storage Scan](https://storagescan-newton.0g.ai/).

---

## Delete the Node

```bash
sudo systemctl stop zgskv
sudo systemctl disable zgskv
sudo rm -rf /etc/systemd/system/zgskv.service
sudo rm -rf $HOME/0g-storage-kv
```

---

## Manual Update

To update manually if you're on an older version:

```bash
cd $HOME/0g-storage-kv
git stash
git fetch --all --tags
git checkout e7c737901d8953d6b73857dc8d7fb1740a416c5d
git submodule update --init
cargo build --release
```

Re-configure and restart if necessary.

---

# Lets Buidl 0G Together