BEFORE YOU DEPLOY THE STORAGE KV NODE, FIRST YOU MUST DEPLOY YOUR [storage kv](<https://github.com/hubofvalley/Testnet-Guides/blob/main/0g%20(zero-gravity)/storage-node.md>)

# 0gchain Storage KV Deployment Guide

- [0gchain Storage KV Deployment Guide](#0gchain-storage-kv-deployment-guide)
    - [**System Requirements**](#system-requirements)
    - [1. Install dependencies for building from source](#1-install-dependencies-for-building-from-source)
    - [2. install go](#2-install-go)
    - [3. install rustup](#3-install-rustup)
    - [4. set vars](#4-set-vars)
    - [5. download binary](#5-download-binary)
    - [6. copy a config\_example.toml file](#6-copy-a-config_exampletoml-file)
    - [7. update storage kv configuration](#7-update-storage-kv-configuration)
    - [8. create service](#8-create-service)
    - [9. start the node](#9-start-the-node)
    - [10. check the logs](#10-check-the-logs)
  - [delete the node](#delete-the-node)
  - [update the storage kv (in case you're still in the previous version)](#update-the-storage-kv-in-case-youre-still-in-the-previous-version)
    - [1. stop storage kv](#1-stop-storage-kv)
    - [2. update node](#2-update-node)
    - [3. build the latest binary](#3-build-the-latest-binary)
    - [4. set vars](#4-set-vars-1)
    - [5. update storage kv configuration](#5-update-storage-kv-configuration)
    - [6. restart the node](#6-restart-the-node)
    - [7. show the logs](#7-show-the-logs)
- [CONTINUE TO STORAGE CLI](#continue-to-storage-cli)
- [let's buidl together](#lets-buidl-together)

### **System Requirements**

| Category | Requirements                                |
| -------- | ------------------------------------------- |
| CPU      | 8+ cores                                    |
| RAM      | 32+ GB                                      |
| Storage  | Matches the size of kv streams it maintains |

guide's current binary version: `v1.2.2`

### 1. Install dependencies for building from source

```bash
sudo apt-get update -y
sudo apt-get install clang cmake build-essential -y
```

### 2. install go

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

### 3. install rustup

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### 4. set vars

PLEASE INPUT YOUR storage kv URL (http://STORAGE_NODE_IP:5678) , YOUR JSON RPC ENDPOINT (VALIDATOR_NODE_IP:8545). CURRENTLY USING STANDARD LOG CONTRACT ADDRESS

```bash
read -p "Enter json-rpc: " BLOCKCHAIN_RPC_ENDPOINT && echo "Current json-rpc: $BLOCKCHAIN_RPC_ENDPOINT" &&
read -p "Enter storage kv urls: " ZGS_NODE && echo "Current storage kv urls: $ZGS_NODE"
```

```bash
echo 'export ZGS_LOG_SYNC_BLOCK="595059"' >> ~/.bash_profile
echo "export ZGS_NODE=\"$ZGS_NODE\"" >> ~/.bash_profile
echo 'export LOG_CONTRACT_ADDRESS="0xbD2C3F0E65eDF5582141C35969d66e34629cC768"' >> ~/.bash_profile
echo "export BLOCKCHAIN_RPC_ENDPOINT=\"$BLOCKCHAIN_RPC_ENDPOINT\"" >> ~/.bash_profile

source ~/.bash_profile

echo -e "\n\033[31mCHECK YOUR STORAGE KV VARIABLES\033[0m\n\nZGS_NODE: $ZGS_NODE\nLOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS\nMINE_CONTRACT: $MINE_CONTRACT\nZGS_LOG_SYNC_BLOCK: $ZGS_LOG_SYNC_BLOCK\nBLOCKCHAIN_RPC_ENDPOINT: $BLOCKCHAIN_RPC_ENDPOINT\n\n" "\033[3m\"lets buidl together\" - Grand Valley\033[0m"
```

### 5. download binary

```bash
cd $HOME
git clone -b v1.2.2 https://github.com/0glabs/0g-storage-kv.git
cd $HOME/0g-storage-kv
git stash
git fetch --all --tags
git checkout e7c737901d8953d6b73857dc8d7fb1740a416c5d
git submodule update --init
sudo apt install cargo
```

then build it

```bash
cargo build --release
```

### 6. copy a config_example.toml file

```bash
cp /$HOME/0g-storage-kv/run/config_example.toml /$HOME/0g-storage-kv/run/config.toml
```

### 7. update storage kv configuration

```bash
sed -i '
s|^\s*#\?\s*rpc_enabled\s*=.*|rpc_enabled = true|
s|^\s*#\?\s*rpc_listen_address\s*=.*|rpc_listen_address = "0.0.0.0:6789"|
s|^\s*#\?\s*db_dir\s*=.*|db_dir = "db"|
s|^\s*#\?\s*kv_db_dir\s*=.*|kv_db_dir = "kv.DB"|
s|^\s*#\?\s*log_config_file\s*=.*|log_config_file = "log_config"|
s|^\s*#\?\s*log_contract_address\s*=.*|log_contract_address = "'"$LOG_CONTRACT_ADDRESS"'"|
s|^\s*#\?\s*zgs_node_urls\s*=.*|zgs_node_urls = "'"$ZGS_NODE"'"|
s|^\s*#\?\s*log_sync_start_block_number\s*=.*|log_sync_start_block_number = '"$ZGS_LOG_SYNC_BLOCK"'|
s|^\s*#\?\s*blockchain_rpc_endpoint\s*=.*|blockchain_rpc_endpoint = "'"$BLOCKCHAIN_RPC_ENDPOINT"'"|
' $HOME/0g-storage-kv/run/config.toml
```

### 8. create service

```bash
sudo tee /etc/systemd/system/zgskv.service > /dev/null <<EOF
[Unit]
Description=zgskv KV
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

### 9. start the node

```bash
sudo systemctl daemon-reload && \
sudo systemctl enable zgskv && \
sudo systemctl start zgskv && \
sudo systemctl status zgskv
```

### 10. check the logs

```bash
sudo journalctl -u zgskv -fn 100 -o cat
```

MAKE SURE YOUR LOGS HAS THE SYNCED TX_SEQ(tx sequence) VALUE, CHECK [STORAGE SCAN](https://storagescan-newton.0g.ai/)
![image](https://github.com/hubofvalley/Testnet-Guides/assets/100946299/ce2d8707-190d-4931-8ed1-44c1447fe360)

## delete the node

```bash
sudo systemctl stop zgskv
sudo systemctl disable zgskv
sudo rm -rf /etc/systemd/system/zgskv.service
sudo rm -rf 0g-storage-kv
```

## update the storage kv (in case you're still in the previous version)

### 1. stop storage kv

```bash
sudo systemctl stop zgskv
```

### 2. update node

```bash
cd $HOME/0g-storage-kv
git stash
git fetch --all --tags
git checkout e7c737901d8953d6b73857dc8d7fb1740a416c5d
git submodule update --init
```

### 3. build the latest binary

```bash
cargo build --release
```

### 4. set vars

PLEASE INPUT YOUR storage kv URL (http://STORAGE_NODE_IP:5678) , YOUR JSON RPC ENDPOINT (VALIDATOR_NODE_IP:8545). CURRENTLY USING STANDARD LOG CONTRACT ADDRESS

```bash
read -p "Enter json-rpc: " BLOCKCHAIN_RPC_ENDPOINT && echo "Current json-rpc: $BLOCKCHAIN_RPC_ENDPOINT" &&
read -p "Enter storage kv urls: " ZGS_NODE && echo "Current storage kv urls: $ZGS_NODE"
```

```bash
echo 'export ZGS_LOG_SYNC_BLOCK="595059"' >> ~/.bash_profile
echo "export ZGS_NODE=\"$ZGS_NODE\"" >> ~/.bash_profile
echo 'export LOG_CONTRACT_ADDRESS="0xbD2C3F0E65eDF5582141C35969d66e34629cC768"' >> ~/.bash_profile
echo "export BLOCKCHAIN_RPC_ENDPOINT=\"$BLOCKCHAIN_RPC_ENDPOINT\"" >> ~/.bash_profile

source ~/.bash_profile

echo -e "\n\033[31mCHECK YOUR STORAGE KV VARIABLES\033[0m\n\nZGS_NODE: $ZGS_NODE\nLOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS\nMINE_CONTRACT: $MINE_CONTRACT\nZGS_LOG_SYNC_BLOCK: $ZGS_LOG_SYNC_BLOCK\nBLOCKCHAIN_RPC_ENDPOINT: $BLOCKCHAIN_RPC_ENDPOINT\n\n" "\033[3m\"lets buidl together\" - Grand Valley\033[0m"
```

### 5. update storage kv configuration

```bash
rm -rf $HOME/0g-storage-kv/run/config.toml && cp $HOME/0g-storage-kv/run/config_example.toml $HOME/0g-storage-kv/run/config.toml
```

```bash
sed -i '
s|^\s*#\?\s*rpc_enabled\s*=.*|rpc_enabled = true|
s|^\s*#\?\s*rpc_listen_address\s*=.*|rpc_listen_address = "0.0.0.0:6789"|
s|^\s*#\?\s*db_dir\s*=.*|db_dir = "db"|
s|^\s*#\?\s*kv_db_dir\s*=.*|kv_db_dir = "kv.DB"|
s|^\s*#\?\s*log_config_file\s*=.*|log_config_file = "log_config"|
s|^\s*#\?\s*log_contract_address\s*=.*|log_contract_address = "'"$LOG_CONTRACT_ADDRESS"'"|
s|^\s*#\?\s*zgs_node_urls\s*=.*|zgs_node_urls = "'"$ZGS_NODE"'"|
s|^\s*#\?\s*log_sync_start_block_number\s*=.*|log_sync_start_block_number = '"$ZGS_LOG_SYNC_BLOCK"'|
s|^\s*#\?\s*blockchain_rpc_endpoint\s*=.*|blockchain_rpc_endpoint = "'"$BLOCKCHAIN_RPC_ENDPOINT"'"|
' $HOME/0g-storage-kv/run/config.toml
```

### 6. restart the node

```bash
sudo systemctl daemon-reload && \
sudo systemctl restart zgskv && \
sudo systemctl status zgskv
```

### 7. show the logs

- full logs command

```bash
sudo journalctl -u zgskv -fn 100 -o cat
```

# [CONTINUE TO STORAGE CLI](<https://github.com/hubofvalley/Testnet-Guides/blob/main/0g%20(zero-gravity)/storage-cli.md>)

# let's buidl together
