BEFORE YOU DEPLOY THE STORAGE KV NODE, FIRST YOU MUST DEPLOY YOUR [STORAGE NODE](https://github.com/hubofvalley/Testnet-Guides/blob/main/0g%20(zero-gravity)/storage-node/storage-node.md)

## 0gchain Storage KV Deployment Guide

### 1. Install dependencies for building from source
   ```bash
   sudo apt-get update
   sudo apt-get install clang cmake build-essential
   ```

### 2. install go
   ```bash
   wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
   sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz
   export PATH=$PATH:/usr/local/go/bin
   ```

### 3. install rustup
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

### 4. set vars
   PLEASE INPUT YOUR STORAGE NODE URL (STORAGE_NODE_IP:5678)
   ```bash
   echo 'export ZGS_LOG_SYNC_BLOCK="334797"' >> ~/.bash_profile
   echo 'export ZGS_NODE="<your storage node url>"' >> ~/.bash_profile
   echo 'export LOG_CONTRACT_ADDRESS="0xb8F03061969da6Ad38f0a4a9f8a86bE71dA3c8E7"' >> ~/.bash_profile
   echo 'export MINE_CONTRACT="0x96D90AAcb2D5Ab5C69c1c351B0a0F105aae490bE"' >> ~/.bash_profile
   echo 'export BLOCKCHAIN_RPC_ENDPOINT="<your json rpc endpoint>"' >> ~/.bash_profile
   
   source ~/.bash_profile
   
   echo -e "\n\033[31mCHECK YOUR VARIABLES\033[0m\n\nZGS_NODE: $ZGS_NODE\nLOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS\nMINE_CONTRACT: $MINE_CONTRACT\nZGS_LOG_SYNC_BLOCK: $ZGS_LOG_SYNC_BLOCK\nBLOCKCHAIN_RPC_ENDPOINT: $BLOCKCHAIN_RPC_ENDPOINT\n\n"
   ```

### 4. download binary
   ```bash
   cd $HOME
   git clone https://github.com/0glabs/0g-storage-kv.git
   cd $HOME/0g-storage-kv
   git submodule update --init
   sudo apt install cargo
   cargo build --release
   ```

### 5. update storage kv configuration

   ```bash
   sed -i '
   s|^\s*#\?\s*rpc_enabled\s*=.*|rpc_enabled = true|
   s|^\s*#\?\s*rpc_listen_address\s*=.*|rpc_listen_address = "0.0.0.0:6789"|
   s|^\s*#\?\s*db_dir\s*=.*|db_dir = "db"|
   s|^\s*#\?\s*kv_db_dir\s*=.*|kv_db_dir = "kv.DB"|
   s|^\s*#\?\s*log_config_file\s*=.*|log_config_file = "log_config"|
   s|^\s*#\?\s*log_contract_address\s*=.*|log_contract_address = "'"$LOG_CONTRACT_ADDRESS"'"|
   s|^\s*#\?\s*zgs_node_urls\s*=.*|zgs_node_urls = "'"$ZGS_NODE"'"|
   s|^\s*#\?\s*mine_contract_address\s*=.*|mine_contract_address = "'"$MINE_CONTRACT"'"|
   s|^\s*#\?\s*log_sync_start_block_number\s*=.*|log_sync_start_block_number = '"$ZGS_LOG_SYNC_BLOCK"'|
   s|^\s*#\?\s*blockchain_rpc_endpoint\s*=.*|blockchain_rpc_endpoint = "'"$BLOCKCHAIN_RPC_ENDPOINT"'"|
   ' $HOME/0g-storage-kv/run/config.toml
   ```

### 7. create service
   ```bash
   sudo tee /etc/systemd/system/zgskv.service > /dev/null <<EOF
   [Unit]
   Description=ZGS KV
   After=network.target
   
   [Service]
   User=$USER
   WorkingDirectory=$HOME/0g-storage-kv/run
   ExecStart=$HOME/0g-storage-kv/target/release/zgs_kv --config $HOME/0g-storage-kv/run/config.toml
   Restart=on-failure
   RestartSec=10
   LimitNOFILE=65535
   
   [Install]
   WantedBy=multi-user.target
   EOF
   ```
### 8. start the node
   ```bash
   sudo systemctl daemon-reload && \
   sudo systemctl enable zgskv && \
   sudo systemctl start zgskv && \
   sudo systemctl status zgskv
   ```
