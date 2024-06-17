## 0gchain Storage Node Deployment Guide
guide's current binaries version: ``v0.3.1``

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
   PLEASE INPUT YOUR OWN JSON-RPC ENDPOINT (VALIDATOR_NODE_IP:8545) OR YOU CAN OUR ENDPOINTS PLEASE CHECK [README](https://github.com/hubofvalley/Testnet-Guides/blob/main/0g%20(zero-gravity)/README.md)
   ```bash
   ENR_ADDRESS=$(wget -qO- eth0.me)
   echo "export ENR_ADDRESS=${ENR_ADDRESS}" >> ~/.bash_profile
   echo 'export ZGS_LOG_DIR="$HOME/0g-storage-node/run/log"' >> ~/.bash_profile
   echo 'export ZGS_LOG_SYNC_BLOCK="334797"' >> ~/.bash_profile
   echo 'export LOG_CONTRACT_ADDRESS="0xb8F03061969da6Ad38f0a4a9f8a86bE71dA3c8E7"' >> ~/.bash_profile
   echo 'export MINE_CONTRACT="0x96D90AAcb2D5Ab5C69c1c351B0a0F105aae490bE"' >> ~/.bash_profile
   echo 'export BLOCKCHAIN_RPC_ENDPOINT="<your json rpc endpoint>"' >> ~/.bash_profile
   
   source ~/.bash_profile
   
   echo -e "\n\033[31mCHECK YOUR STORAGE NODE VARIABLES\033[0m\n\nLOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS\nMINE_CONTRACT: $MINE_CONTRACT\nZGS_LOG_SYNC_BLOCK: $ZGS_LOG_SYNC_BLOCK\nBLOCKCHAIN_RPC_ENDPOINT: $BLOCKCHAIN_RPC_ENDPOINT\n\n"
   ```

### 4. download binary
   ```bash
   cd $HOME
   git clone https://github.com/0glabs/0g-storage-node.git
   cd $HOME/0g-storage-node
   git fetch
   git checkout tags/v0.3.1
   git submodule update --init
   sudo apt install cargo
   cargo build --release
   ```

### 5. wallet private key check
obtain yout wallet's private key by using this command in your validator node :
   ```bash
   0gchaind keys unsafe-export-eth-key $WALLET_NAME
   ```

store your private key in variable:
   ```bash
   read -sp "Enter your private key: " PRIVATE_KEY && echo
   ```

### 6. update node configuration
   ```bash
   sed -i '
   s|^miner_key = ""|miner_key = "'"$PRIVATE_KEY"'"|
   s|^\s*#\?\s*network_dir\s*=.*|network_dir = "network"|
   s|^\s*#\?\s*network_enr_address\s*=.*|network_enr_address = "'"$ENR_ADDRESS"'"|
   s|^\s*#\?\s*network_enr_tcp_port\s*=.*|network_enr_tcp_port = 1234|
   s|^\s*#\?\s*network_enr_udp_port\s*=.*|network_enr_udp_port = 1234|
   s|^\s*#\?\s*network_libp2p_port\s*=.*|network_libp2p_port = 1234|
   s|^\s*#\?\s*network_discovery_port\s*=.*|network_discovery_port = 1234|
   s|^\s*#\?\s*rpc_enabled\s*=.*|rpc_enabled = true|
   s|^\s*#\?\s*db_dir\s*=.*|db_dir = "db"|
   s|^\s*#\?\s*log_config_file\s*=.*|log_config_file = "log_config"|
   s|^\s*#\?\s*log_directory\s*=.*|log_directory = "log"|
   s|^\s*#\?\s*network_boot_nodes\s*=.*|network_boot_nodes = \["/ip4/54.219.26.22/udp/1234/p2p/16Uiu2HAmTVDGNhkHD98zDnJxQWu3i1FL1aFYeh9wiQTNu4pDCgps","/ip4/52.52.127.117/udp/1234/p2p/16Uiu2HAkzRjxK2gorngB1Xq84qDrT4hSVznYDHj6BkbaE4SGx9oS"\]|
   s|^\s*#\?\s*log_contract_address\s*=.*|log_contract_address = "'"$LOG_CONTRACT_ADDRESS"'"|
   s|^\s*#\?\s*mine_contract_address\s*=.*|mine_contract_address = "'"$MINE_CONTRACT"'"|
   s|^\s*#\?\s*log_sync_start_block_number\s*=.*|log_sync_start_block_number = '"$ZGS_LOG_SYNC_BLOCK"'|
   s|^\s*#\?\s*blockchain_rpc_endpoint\s*=.*|blockchain_rpc_endpoint = "'"$BLOCKCHAIN_RPC_ENDPOINT"'"|
   ' $HOME/0g-storage-node/run/config.toml
   ```

### 7. create service
   ```bash
   sudo tee /etc/systemd/system/zgs.service > /dev/null <<EOF
   [Unit]
   Description=ZGS Node
   After=network.target
   
   [Service]
   User=$USER
   WorkingDirectory=$HOME/0g-storage-node/run
   ExecStart=$HOME/0g-storage-node/target/release/zgs_node --config $HOME/0g-storage-node/run/config.toml
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
   sudo systemctl enable zgs && \
   sudo systemctl start zgs && \
   sudo systemctl status zgs
   ```

### 9. show logs by date
   - check the logs file
   ```bash
   ls -lt $ZGS_LOG_DIR
   ```
   - logs command
   ```bash
   tail -f ~/0g-storage-node/run/log/zgs.log.$(TZ=UTC date +%Y-%m-%d)
   ```
   - tx_seq logs command
   ```bash
   tail -f ~/0g-storage-node/run/log/zgs.log.$(TZ=UTC date +%Y-%m-%d) | grep tx_seq
   ```
   MAKE SURE YOUR LOGS HAS THE INCREASING TX_SEQ VALUE
   ![image](https://github.com/hubofvalley/Testnet-Guides/assets/100946299/ad8980bc-fd05-4321-b6bb-aa711503d415)

   WAIT UNTIL IT SYNCED TO THE LATEST TX_SEQ NUMBER ON THE [OG STORAGE SCAN](https://storagescan-newton.0g.ai/)
   ![image](https://github.com/hubofvalley/Testnet-Guides/assets/100946299/1f531de9-a183-43bb-8ef0-016cffaf93af)


   - show INFO logs command(including the number of connected peers)
   ```bash
   tail -f ~/0g-storage-node/run/log/zgs.log.$(TZ=UTC date +%Y-%m-%d) | grep INFO
   ```



### delete storage node
   ```bash
   sudo systemctl stop zgs
   sudo systemctl disable zgs
   sudo rm /etc/systemd/system/zgs.service
   rm -rf $HOME/0g-storage-node
   ```

### upgrade the storage node (IF UR STORAGE NODE STILL IN v0.3.0 VERSION)

1. backup your db directory
   ```bash
   cp /$HOME/0g-storage-node/run/db /$HOME/
   ```

2. delete the node
   ```bash
   sudo systemctl stop zgs
   sudo systemctl disable zgs
   sudo rm /etc/systemd/system/zgs.service
   rm -rf $HOME/0g-storage-node
   ```

3. download latest binary
   ```bash
   cd $HOME
   git clone https://github.com/0glabs/0g-storage-node.git
   cd $HOME/0g-storage-node
   git fetch
   git checkout tags/v0.3.1
   git submodule update --init
   sudo apt install cargo
   cargo build --release
   ```

4. move db directory to binaries
   ```bash
   cd $HOME
   mv /$HOME/db /$HOME/0g-storage-node/run/
   ```

THEN REPEAT STEP 5 TO 8
