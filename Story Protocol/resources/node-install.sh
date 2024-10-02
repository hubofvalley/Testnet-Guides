#!/bin/bash

LOGO="
 __                                   
/__ ._ _. ._   _|   \  / _. | |  _    
\_| | (_| | | (_|    \/ (_| | | (/_ \/
                                    /

"

echo "$LOGO"

# Prompt for MONIKER and STORY_PORT
read -p "Enter your moniker: " MONIKER
read -p "Enter your preferred port number: " STORY_PORT

# 1. Install dependencies for building from source
echo "Installing dependencies..."
if sudo apt update -y && sudo apt upgrade -y && sudo apt install -y curl git jq build-essential gcc unzip wget lz4 openssl libssl-dev pkg-config protobuf-compiler clang cmake llvm llvm-dev; then
    echo "Dependencies installed successfully."
else
    echo "Error installing dependencies."
    exit 1
fi

# 2. Install Go
echo "Installing Go..."
cd $HOME && ver="1.22.0"
if wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && rm "go$ver.linux-amd64.tar.gz"; then
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile
    source ~/.bash_profile
    if go version; then
        echo "Go installed successfully."
    else
        echo "Error installing Go."
        exit 1
    fi
else
    echo "Error downloading Go."
    exit 1
fi

# 3. Install Cosmovisor
echo "Installing Cosmovisor..."
if go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest; then
    echo "Cosmovisor installed successfully."
else
    echo "Error installing Cosmovisor."
    exit 1
fi

# 4. Set environment variables
echo "Setting environment variables..."
echo "export MONIKER=\"$MONIKER\"" >> $HOME/.bash_profile
echo "export STORY_CHAIN_ID=\"iliad\"" >> $HOME/.bash_profile
echo "export STORY_PORT=\"$STORY_PORT\"" >> $HOME/.bash_profile
source $HOME/.bash_profile

# 5. Download Geth and Consensus Client binaries
cd $HOME
echo "Downloading Geth binary..."
if wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.3-b224fdf.tar.gz; then
    geth_folder_name=$(tar -tf geth-linux-amd64-0.9.3-b224fdf.tar.gz | head -n 1 | cut -f1 -d"/")
    tar -xvf geth-linux-amd64-0.9.3-b224fdf.tar.gz
    mv $HOME/$geth_folder_name/geth $HOME/go/bin/
    sudo rm -rf $HOME/$geth_folder_name $HOME/geth-linux-amd64-0.9.3-b224fdf.tar.gz
    echo "Geth binary downloaded and installed."
else
    echo "Error downloading Geth binary."
    exit 1
fi

echo "Downloading Consensus Client binary..."
if wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.9.13-b4c7db1.tar.gz; then
    story_folder_name=$(tar -tf story-linux-amd64-0.9.13-b4c7db1.tar.gz | head -n 1 | cut -f1 -d"/")
    tar -xzf story-linux-amd64-0.9.13-b4c7db1.tar.gz
    mv $HOME/$story_folder_name/story $HOME/go/bin/
    sudo rm -rf $HOME/$story_folder_name $HOME/story-linux-amd64-0.9.13-b4c7db1.tar.gz
    echo "Consensus Client binary downloaded and installed."
else
    echo "Error downloading Consensus Client binary."
    exit 1
fi

# 6. Initialize the app
echo "Initializing the app..."
if story init --network $STORY_CHAIN_ID --moniker $MONIKER; then
    echo "App initialized successfully."
else
    echo "Error initializing the app."
    exit 1
fi

# 7. Add peers to the config.toml
echo "Adding peers to the config..."
peers=$(curl -sS https://lightnode-rpc-story.grandvalleys.com/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
if sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.story/story/config/config.toml; then
    echo "Peers added successfully."
else
    echo "Error adding peers."
    exit 1
fi

# 8. Set custom ports in config.toml
echo "Setting custom ports..."
if sed -i.bak -e "s%:26658%:${STORY_PORT}658%g;
s%:26657%:${STORY_PORT}657%g;
s%:26656%:${STORY_PORT}656%g;
s%:26660%:${STORY_PORT}660%g" $HOME/.story/story/config/config.toml; then
    echo "Ports set successfully."
else
    echo "Error setting custom ports."
    exit 1
fi

# 9. Enable indexer (optional)
echo "Enabling indexer..."
if sed -i -e 's/^indexer = "null"/indexer = "kv"/' $HOME/.story/story/config/config.toml; then
    echo "Indexer enabled."
else
    echo "Error enabling indexer."
    exit 1
fi

# 10. Initialize Cosmovisor
echo "Initializing Cosmovisor..."
if cosmovisor init $HOME/go/bin/story; then
    mkdir -p $HOME/.story/story/cosmovisor/upgrades
    mkdir -p $HOME/.story/story/cosmovisor/backup
    echo "Cosmovisor initialized successfully."
else
    echo "Error initializing Cosmovisor."
    exit 1
fi

# 11. Define Cosmovisor paths for the consensus client
echo "Defining Cosmovisor paths..."
input1=$(which cosmovisor)
input2=$(find $HOME -type d -name "story")
input3=$(find $HOME/.story/story/cosmovisor -type d -name "backup")
echo "export DAEMON_NAME=story" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$input2" >> $HOME/.bash_profile
echo "export DAEMON_DATA_BACKUP_DIR=$input3" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo "Cosmovisor path: $input1"
echo "Story home: $input2"
echo "Backup directory: $input3"

# 12. Create systemd service files for the consensus and Geth clients
echo "Creating systemd service files..."

# Consensus service file
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Cosmovisor Story Node
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME/.story/story
ExecStart=$input1 run run
Restart=on-failure
LimitNOFILE=65535
Environment="DAEMON_NAME=story"
Environment="DAEMON_HOME=$input2"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_DATA_BACKUP_DIR=$input3"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# Geth service file
sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF
[Unit]
Description=Story Geth daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which geth) --iliad --syncmode full --http --http.api eth,net,web3,engine --http.vhosts '*' --http.addr 0.0.0.0 --http.port 8545 --ws --ws.api eth,web3,net,txpool --ws.addr 0.0.0.0 --ws.port 8546
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# 13. Start the node
echo "Starting the node..."
sudo systemctl daemon-reload
if sudo systemctl enable story-geth story && sudo systemctl restart story-geth story; then
    echo "Node installation and setup completed successfully!"
else
    echo "Error starting the node services."
    exit 1
fi
