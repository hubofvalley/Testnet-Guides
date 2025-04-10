# 0gchain Storage KV Deployment Guide

BEFORE YOU DEPLOY THE STORAGE KV NODE, FIRST YOU MUST DEPLOY YOUR [storage node](https://github.com/hubofvalley/Testnet-Guides/blob/main/0g%20(zero-gravity)/storage-node.md)

- [0gchain Storage KV Deployment Guide](#0gchain-storage-kv-deployment-guide)
    - [**System Requirements**](#system-requirements)
    - [Install via Valley of 0G (Recommended)](#install-via-valley-of-0g-recommended)
      - [Deploy Storage KV](#deploy-storage-kv)
      - [Update Storage KV](#update-storage-kv)
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
    - [🔻 Delete the Node](#-delete-the-node)
    - [Manual Update](#manual-update)

### **System Requirements**

| Category | Requirements                                |
| -------- | ------------------------------------------- |
| CPU      | 8+ cores                                    |
| RAM      | 32+ GB                                      |
| Storage  | Matches the size of kv streams it maintains |

guide's current binary version: `v1.4.0`

(Insert full manual steps here, identical to your previously provided detailed installation instructions)

### Install via Valley of 0G (Recommended)

Valley of 0G provides a faster and simpler way to deploy and manage your Storage KV node.

#### Deploy Storage KV

Open the Valley of 0G CLI:
```bash
bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20\(zero-gravity\)/resources/valleyof0G.sh)
```

From the menu, select:
```
3a → Deploy Storage KV
```

This will:
- install dependencies
- clone the latest repo
- build the binary
- configure and launch your service

---

#### Update Storage KV

If you're upgrading your node to the latest version, use the update menu:

```bash
3c → Update Storage KV
```

The tool will:
- pull the latest tag
- rebuild the node
- restart it cleanly

---

### Manual Installation Guide

This section describes how to manually install and run a 0gchain Storage KV node from source.

---

#### 1. Install Dependencies

```bash
sudo apt-get update -y
sudo apt-get install clang cmake build-essential -y
sudo apt install cargo -y
```

#### 2. Install Go

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

#### 3. Install Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

#### 4. Set Environment Variables

```bash
read -p "Enter json-rpc: " BLOCKCHAIN_RPC_ENDPOINT
echo "Current json-rpc: $BLOCKCHAIN_RPC_ENDPOINT"

read -p "Enter storage kv urls: " ZGS_NODE
echo "Current storage kv urls: $ZGS_NODE"

echo 'export ZGS_LOG_SYNC_BLOCK="595059"' >> ~/.bash_profile
echo "export ZGS_NODE="$ZGS_NODE"" >> ~/.bash_profile
echo 'export LOG_CONTRACT_ADDRESS="0xbD2C3F0E65eDF5582141C35969d66e34629cC768"' >> ~/.bash_profile
echo "export BLOCKCHAIN_RPC_ENDPOINT="$BLOCKCHAIN_RPC_ENDPOINT"" >> ~/.bash_profile

source ~/.bash_profile

echo -e "\n\033[31mCHECK YOUR STORAGE KV VARIABLES\033[0m\n"
echo "ZGS_NODE: $ZGS_NODE"
echo "LOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS"
echo "ZGS_LOG_SYNC_BLOCK: $ZGS_LOG_SYNC_BLOCK"
echo "BLOCKCHAIN_RPC_ENDPOINT: $BLOCKCHAIN_RPC_ENDPOINT"
echo -e "\n\033[3m"lets buidl together" - Grand Valley\033[0m\n"
```

#### 5. Download the Binary

```bash
cd $HOME
git clone -b v1.4.0 https://github.com/0glabs/0g-storage-kv.git
cd 0g-storage-kv
git stash
git fetch --all --tags
git submodule update --init
cargo build --release
```

#### 6. Configure the Node

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

#### 7. Create a Systemd Service

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

#### 8. Start the Node

```bash
sudo systemctl daemon-reload
sudo systemctl enable zgskv
sudo systemctl start zgskv
sudo systemctl status zgskv
```

#### 9. Check Logs

```bash
sudo journalctl -u zgskv -fn 100 -o cat
```

Make sure your `tx_seq` is syncing. You can also check it on the [Storage Scan](https://storagescan-newton.0g.ai/).

### 🔻 Delete the Node

```bash
sudo systemctl stop zgskv
sudo systemctl disable zgskv
sudo rm -rf /etc/systemd/system/zgskv.service
sudo rm -rf $HOME/0g-storage-kv
```

### Manual Update

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