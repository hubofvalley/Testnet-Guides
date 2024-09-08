## 0gchain Storage Node Deployment Guide
guide's current binary version: ``v0.5.0``

### 1. Install dependencies for building from source
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
   PLEASE INPUT YOUR OWN JSON-RPC ENDPOINT (http://VALIDATOR_NODE_IP:8545)
   ```bash
   read -p "Enter json-rpc: " BLOCKCHAIN_RPC_ENDPOINT && echo "Current json-rpc: $BLOCKCHAIN_RPC_ENDPOINT"
   ```

   ```bash
   ENR_ADDRESS=$(wget -qO- eth0.me)
   echo "export ENR_ADDRESS=${ENR_ADDRESS}" >> ~/.bash_profile
   echo 'export ZGS_LOG_DIR="$HOME/0g-storage-node/run/log"' >> ~/.bash_profile
   echo 'export ZGS_LOG_SYNC_BLOCK="595059"' >> ~/.bash_profile
   echo 'export LOG_CONTRACT_ADDRESS="0xbD2C3F0E65eDF5582141C35969d66e34629cC768"' >> ~/.bash_profile
   echo 'export MINE_CONTRACT="0x6815F41019255e00D6F34aAB8397a6Af5b6D806f"' >> ~/.bash_profile
   echo 'export REWARD_CONTRACT="0x51998C4d486F406a788B766d93510980ae1f9360"' >> ~/.bash_profile
   echo "export BLOCKCHAIN_RPC_ENDPOINT=\"$BLOCKCHAIN_RPC_ENDPOINT\"" >> ~/.bash_profile
   
   source ~/.bash_profile
   
   echo -e "\n\033[31mCHECK YOUR STORAGE NODE VARIABLES\033[0m\n\nLOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS\nMINE_CONTRACT: $MINE_CONTRACT\nREWARD_CONTRACT: $REWARD_CONTRACT\nZGS_LOG_SYNC_BLOCK: $ZGS_LOG_SYNC_BLOCK\nBLOCKCHAIN_RPC_ENDPOINT: $BLOCKCHAIN_RPC_ENDPOINT\n\n" "\033[3m\"lets buidl together\" - Grand Valley\033[0m"
   ```

   ALSO CHECK THE JSON-RPC SYNC, MAKE SURE IT'S IN THE LATEST BLOCK
   ```bash
   curl -s -X POST $BLOCKCHAIN_RPC_ENDPOINT -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r '.result' | xargs printf "%d\n"
   ```

### 5. download binary
   ```bash
   cd $HOME
   git clone -b v0.5.0 https://github.com/0glabs/0g-storage-node.git
   cd $HOME/0g-storage-node
   git stash
   git fetch --all --tags
   git checkout 052d2d781b7fb181f1f92b051d8541a05b399b28
   git submodule update --init
   ```
   then build it
   ```bash
   cargo build --release
   ```

### 6. check the storage node version
   ```bash
   "$HOME/0g-storage-node/target/release/zgs_node" --version
   ```

### 7. wallet private key check
obtain yout wallet's private key by using this command in your validator node :
   ```bash
   0gchaind keys unsafe-export-eth-key $WALLET
   ```

store your private key in variable:
   ```bash
   read -p "Enter your private key: " PRIVATE_KEY && echo "private key: $PRIVATE_KEY"
   ```

### 8. update node configuration
   ```bash
   rm -rf $HOME/0g-storage-node/run/config-testnet.toml && cp $HOME/0g-storage-node/run/config-testnet-turbo.toml $HOME/0g-storage-node/run/config-testnet.toml
   ```

   ```bash
   sed -i "
   s|^\s*#\s*miner_key\s*=.*|miner_key = \"$PRIVATE_KEY\"|
   s|^\s*#\s*rpc_listen_address\s*=.*|rpc_listen_address = \"0.0.0.0:5678\"|
   s|^\s*#\?\s*rpc_enabled\s*=.*|rpc_enabled = true|
   s|^\s*#\?\s*log_contract_address\s*=.*|log_contract_address = \"$LOG_CONTRACT_ADDRESS\"|
   s|^\s*#\?\s*mine_contract_address\s*=.*|mine_contract_address = \"$MINE_CONTRACT\"|
   s|^\s*#\?\s*reward_contract_address\s*=.*|reward_contract_address = \"$REWARD_CONTRACT\"|
   s|^\s*#\?\s*log_sync_start_block_number\s*=.*|log_sync_start_block_number = $ZGS_LOG_SYNC_BLOCK|
   s|^\s*#\?\s*blockchain_rpc_endpoint\s*=.*|blockchain_rpc_endpoint = \"$BLOCKCHAIN_RPC_ENDPOINT\"|
   " $HOME/0g-storage-node/run/config-testnet.toml
   ```
   

### 9. create service
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

### 10. start the node
   ```bash
   sudo systemctl daemon-reload && \
   sudo systemctl enable zgs && \
   sudo systemctl restart zgs && \
   sudo systemctl status zgs
   ```

### 11. show logs by date
   - check the logs file
   ```bash
   ls -lt $ZGS_LOG_DIR
   ```
   - full logs command
   ```bash
   tail -f ~/0g-storage-node/run/log/zgs.log.$(TZ=UTC date +%Y-%m-%d)
   ```
   - tx_seq-only logs command
   ```bash
   tail -f ~/0g-storage-node/run/log/zgs.log.$(TZ=UTC date +%Y-%m-%d) | grep tx_seq:
   ```
   MAKE SURE YOUR LOGS HAS THE INCREASING TX_SEQ VALUE
   ![image](https://github.com/hubofvalley/Testnet-Guides/assets/100946299/ad8980bc-fd05-4321-b6bb-aa711503d415)

   WAIT UNTIL IT SYNCED TO THE LATEST TX_SEQ NUMBER ON THE [OG STORAGE SCAN](https://storagescan-newton.0g.ai/)
   ![image](https://github.com/hubofvalley/Testnet-Guides/assets/100946299/1f531de9-a183-43bb-8ef0-016cffaf93af)


   - minimized-logs command
   ```bash
   tail -f ~/0g-storage-node/run/log/zgs.log.$(TZ=UTC date +%Y-%m-%d) | grep -v "discv5\|network\|connect\|16U\|nounce"
   ```

   - check your storage node through rpc
   ```bash
   curl -X POST http://localhost:5678 -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"zgs_getStatus","params":[],"id":1}'  | jq
   ```

### delete storage node
   ```bash
   sudo systemctl stop zgs
   sudo systemctl disable zgs
   sudo rm /etc/systemd/system/zgs.service
   sudo rm -rf $HOME/0g-storage-node
   ```

## update the storage node to v0.5.0
### 1. stop storage node
   ```bash
   sudo systemctl stop zgs
   ```

### 2. update node
   ```bash
   cd $HOME/0g-storage-node
   git stash
   git fetch --all --tags
   git checkout 052d2d781b7fb181f1f92b051d8541a05b399b28 
   git submodule update --init
   ```

### 3. build the latest binary
   ```
   cargo build --release
   ```

### 4. set vars
   PLEASE INPUT YOUR OWN JSON-RPC ENDPOINT (http://VALIDATOR_NODE_IP:8545)
   ```bash
   read -p "Enter json-rpc: " BLOCKCHAIN_RPC_ENDPOINT && echo "Current json-rpc: $BLOCKCHAIN_RPC_ENDPOINT"
   ```

   ```bash
   ENR_ADDRESS=$(wget -qO- eth0.me)
   echo "export ENR_ADDRESS=${ENR_ADDRESS}" >> ~/.bash_profile
   echo 'export ZGS_LOG_DIR="$HOME/0g-storage-node/run/log"' >> ~/.bash_profile
   echo 'export ZGS_LOG_SYNC_BLOCK="595059"' >> ~/.bash_profile
   echo 'export LOG_CONTRACT_ADDRESS="0xbD2C3F0E65eDF5582141C35969d66e34629cC768"' >> ~/.bash_profile
   echo 'export MINE_CONTRACT="0x6815F41019255e00D6F34aAB8397a6Af5b6D806f"' >> ~/.bash_profile
   echo 'export REWARD_CONTRACT="0x51998C4d486F406a788B766d93510980ae1f9360"' >> ~/.bash_profile
   echo "export BLOCKCHAIN_RPC_ENDPOINT=\"$BLOCKCHAIN_RPC_ENDPOINT\"" >> ~/.bash_profile
   
   source ~/.bash_profile
   
   echo -e "\n\033[31mCHECK YOUR STORAGE NODE VARIABLES\033[0m\n\nLOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS\nMINE_CONTRACT: $MINE_CONTRACT\nREWARD_CONTRACT: $REWARD_CONTRACT\nZGS_LOG_SYNC_BLOCK: $ZGS_LOG_SYNC_BLOCK\nBLOCKCHAIN_RPC_ENDPOINT: $BLOCKCHAIN_RPC_ENDPOINT\n\n" "\033[3m\"lets buidl together\" - Grand Valley\033[0m"
   ```

### 5. store your private key in variable:
   ```bash
   read -p "Enter your private key: " PRIVATE_KEY && echo "private key: $PRIVATE_KEY"
   ```

### 6. update node configuration
   ```bash
   rm -rf $HOME/0g-storage-node/run/config-testnet.toml && cp $HOME/0g-storage-node/run/config-testnet-turbo.toml $HOME/0g-storage-node/run/config-testnet.toml
   ```

   ```bash
   sed -i "
   s|^\s*#\s*miner_key\s*=.*|miner_key = \"$PRIVATE_KEY\"|
   s|^\s*#\s*rpc_listen_address\s*=.*|rpc_listen_address = \"0.0.0.0:5678\"|
   s|^\s*#\?\s*rpc_enabled\s*=.*|rpc_enabled = true|
   s|^\s*#\?\s*log_contract_address\s*=.*|log_contract_address = \"$LOG_CONTRACT_ADDRESS\"|
   s|^\s*#\?\s*mine_contract_address\s*=.*|mine_contract_address = \"$MINE_CONTRACT\"|
   s|^\s*#\?\s*reward_contract_address\s*=.*|reward_contract_address = \"$REWARD_CONTRACT\"|
   s|^\s*#\?\s*log_sync_start_block_number\s*=.*|log_sync_start_block_number = $ZGS_LOG_SYNC_BLOCK|
   s|^\s*#\?\s*blockchain_rpc_endpoint\s*=.*|blockchain_rpc_endpoint = \"$BLOCKCHAIN_RPC_ENDPOINT\"|
   " $HOME/0g-storage-node/run/config-testnet.toml
   ```

### 7. restart the node
   ```
   sudo systemctl daemon-reload && \
   sudo systemctl enable zgs && \
   sudo systemctl start zgs && \
   sudo systemctl status zgs
   ```

# [CONTINUE TO STORAGE KV](https://github.com/hubofvalley/Testnet-Guides/blob/main/0g%20(zero-gravity)/storage-kv/storage-kv.md)
