## 0gchain Storage Node Deployment Guide

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
   ```bash
   echo 'export ZGS_LOG_DIR="$HOME/0g-storage-node/run/log"' >> ~/.bash_profile
   echo 'export ZGS_LOG_CONFIG_FILE="$HOME/0g-storage-node/run/log_config"' >> ~/.bash_profile
   echo 'export LOG_CONTRACT_ADDRESS="0xb8F03061969da6Ad38f0a4a9f8a86bE71dA3c8E7"' >> ~/.bash_profile
   echo 'export MINE_CONTRACT="0x96D90AAcb2D5Ab5C69c1c351B0a0F105aae490bE"' >> ~/.bash_profile
   
   source ~/.bash_profile
   
   echo -e "ZGS_LOG_DIR: $ZGS_LOG_DIR\nZGS_LOG_CONFIG_FILE: $ZGS_LOG_CONFIG_FILE\nLOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS\nMINE_CONTRACT: $MINE_CONTRACT\n\n\033[33m\033[0m"
   ```

### 4. download binary
   ```bash
   cd $HOME
   git clone https://github.com/0glabs/0g-storage-node.git
   cd $HOME/0g-storage-node
   git fetch
   git checkout tags/v0.3.0
   git submodule update --init
   sudo apt install cargo
   cargo build --release
   ```

### 5. wallet setup
obtain yout wallet's private key by using this command in your validator node :

   ```bash
   0gchaind keys unsafe-export-eth-key $WALLET_NAME
   ```

store your private key in variable:

   ```bash
   read -sp "Enter your private key: " PRIVATE_KEY && echo
   ```

### 6. update node configuration (use your own JSON RPC endpoint)

   ```bash
   sed -i 's|miner_key = ""|miner_key = "'"$PRIVATE_KEY"'"|' $HOME/0g-storage-node/run/config.toml
   ```

   PLEASE INPUT YOUR OWN JSON-RPC ENDPOINT (VALIDATOR_NODE_IP:8545)
   ```bash
   sed -i 's|# log_config_file = "log_config"|log_config_file = "'"$ZGS_LOG_CONFIG_FILE"'"|' $HOME/0g-storage-node/run/config.toml
   sed -i 's|# log_directory = "log"|log_directory = "'"$ZGS_LOG_DIR"'"|' $HOME/0g-storage-node/run/config.toml
   sed -i 's|mine_contract_address = ".*"|mine_contract_address = "'"$MINE_CONTRACT"'"|' $HOME/0g-storage-node/run/config.toml
   sed -i 's|log_contract_address = ".*"|log_contract_address = "'"$LOG_CONTRACT_ADDRESS"'"|' $HOME/0g-storage-node/run/config.toml
   sed -i 's|blockchain_rpc_endpoint = "<your-own-JSON-RPC-endpoint>"|' $HOME/0g-storage-node/run/config.toml
   sed -i 's|# network_dir = "network"|network_dir = "network"|' $HOME/0g-storage-node/run/config.toml
   sed -i 's|# network_libp2p_port = 1234|network_libp2p_port = 1234|' $HOME/0g-storage-node/run/config.toml
   sed -i 's|network_boot_nodes = \["/ip4/54.219.26.22/udp/1234/p2p/16Uiu2HAmPxGNWu9eVAQPJww79J32pTJLKGcpjRMb4Qb8xxKkyuG1","/ip4/52.52.127.117/udp/1234/p2p/16Uiu2HAm93Hd5azfhkGBbkx1zero3nYHvfjQYM2NtiW4R3r5bE2g"\]|network_boot_nodes = \["/ip4/54.219.26.22/udp/1234/p2p/16Uiu2HAmTVDGNhkHD98zDnJxQWu3i1FL1aFYeh9wiQTNu4pDCgps","/ip4/52.52.127.117/udp/1234/p2p/16Uiu2HAkzRjxK2gorngB1Xq84qDrT4hSVznYDHj6BkbaE4SGx9oS"\]|' $HOME/0g-storage-node/run/config.toml
   sed -i 's|# db_dir = "db"|db_dir = "db"|' $HOME/0g-storage-node/run/config.toml
   ```

### 7. create service
   ```bash
   sudo tee /etc/systemd/system/zgs.service > /dev/null <<EOF
   [Unit]
   Description=ZGS Node
   After=network.target
   
   [Service]
   User=root
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
   sudo systemctl restart zgs && \
   sudo systemctl status zgs
   ```

### 9. show logs by date
   ```bash
   ls -lt $ZGS_LOG_DIR
   ```
