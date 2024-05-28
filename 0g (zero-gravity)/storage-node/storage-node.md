## 0gchain Node Deployment Guide

### 1. Install dependencies for building from source
   ```bash
    sudo apt update && \
    sudo apt install curl git jq build-essential gcc unzip wget lz4 openssl -y
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
   ```bash
    echo 'export ZGS_CONFIG_FILE="$HOME/0g-storage-node/run/config.toml"' >> ~/.bash_profile
    echo 'export ZGS_LOG_DIR="$HOME/0g-storage-node/run/log"' >> ~/.bash_profile
    echo 'export ZGS_LOG_CONFIG_FILE="$HOME/0g-storage-node/run/log_config"' >> ~/.bash_profile

    source ~/.bash_profile
   ```

### 4. download binary
   ```bash
    cd $HOME
    git clone https://github.com/0glabs/0g-storage-node.git
    cd 0g-storage-node
    git checkout tags/v1.0.0-testnet
    git submodule update --init
    cargo build --release
    sudo mv $HOME/0g-storage-node/target/release/zgs_node /usr/local/bin
   ```

### 5. wallet setup
obtain yout wallet's private key by using this command :

   ```bash
    0gchaind keys unsafe-export-eth-key $WALLET_NAME
   ```

store your private key in variable:

   ```bash
   read -sp "Enter your private key: " PRIVATE_KEY && echo
   ```

### 6. update node configuration
   ```bash
    if grep -q '# miner_id' $ZGS_CONFIG_FILE; then
        MINER_ID=$(openssl rand -hex 32)
        sed -i "/# miner_id/c\miner_id = \"$MINER_ID\"" $ZGS_CONFIG_FILE
    fi

    if grep -q '# miner_key' $ZGS_CONFIG_FILE; then
        sed -i "/# miner_key/c\miner_key = \"$PRIVATE_KEY\"" $ZGS_CONFIG_FILE
    fi

    sed -i "s|^log_config_file =.*$|log_config_file = \"$ZGS_LOG_CONFIG_FILE\"|" $ZGS_CONFIG_FILE

    if ! grep -q "^log_directory =" "$ZGS_CONFIG_FILE"; then
        echo "log_directory = \"$ZGS_LOG_DIR\"" >> "$ZGS_CONFIG_FILE"
    fi
   ```

### 7. create service
   ```bash
   sudo tee /etc/systemd/system/zgs.service > /dev/null <<EOF
[Unit]
Description=0G Storage Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=zgs_node --config $ZGS_CONFIG_FILE
Restart=on-failure
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
