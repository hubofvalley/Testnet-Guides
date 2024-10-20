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
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y curl git jq build-essential gcc unzip wget lz4 openssl libssl-dev pkg-config protobuf-compiler clang cmake llvm llvm-dev

# 2. Install Go
cd $HOME && ver="1.22.0"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile
source ~/.bash_profile
go version

# 3. Install Cosmovisor
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest

# 4. Set environment variables
echo "export MONIKER=\"$MONIKER\"" >> $HOME/.bash_profile
echo "export STORY_CHAIN_ID=\"iliad\"" >> $HOME/.bash_profile
echo "export STORY_PORT=\"$STORY_PORT\"" >> $HOME/.bash_profile
source $HOME/.bash_profile

# 5. Download Geth and Consensus Client binaries
cd $HOME

# Geth binary
wget https://github.com/piplabs/story-geth/releases/download/v0.9.4/geth-linux-amd64
geth_file_name=geth-linux-amd64
mv $HOME/$geth_file_name $HOME/go/bin/geth
sudo chown -R $USER:$USER $HOME/go/bin/geth
sudo chmod +x $HOME/go/bin/geth
sudo rm -rf $HOME/$geth_file_name

# Consensus client binary
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.9.13-b4c7db1.tar.gz
story_folder_name=$(tar -tf story-linux-amd64-0.9.13-b4c7db1.tar.gz | head -n 1 | cut -f1 -d"/")
tar -xzf story-linux-amd64-0.9.13-b4c7db1.tar.gz
mv $HOME/$story_folder_name/story $HOME/go/bin/
sudo rm -rf $HOME/$story_folder_name $HOME/story-linux-amd64-0.9.13-b4c7db1.tar.gz

# 6. Initialize the app
story init --network $STORY_CHAIN_ID --moniker $MONIKER

# 7. Add peers to the config.toml
peers=$(curl -sS https://lightnode-rpc-story.grandvalleys.com/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.story/story/config/config.toml
echo $peers

# 8. Set custom ports in config.toml
sed -i.bak -e "s%:26658%:${STORY_PORT}658%g;
s%:26657%:${STORY_PORT}657%g;
s%:26656%:${STORY_PORT}656%g;
s%:26660%:${STORY_PORT}660%g" $HOME/.story/story/config/config.toml

# 9. Enable indexer (optional)
sed -i -e 's/^indexer = "null"/indexer = "kv"/' $HOME/.story/story/config/config.toml

# 10. Initialize Cosmovisor
echo "export DAEMON_NAME=story" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$(find $HOME -type d -name "story")" >> $HOME/.bash_profile
source $HOME/.bash_profile
cosmovisor init $HOME/go/bin/story
mkdir -p $HOME/.story/story/cosmovisor/upgrades
mkdir -p $HOME/.story/story/cosmovisor/backup

# 11. Define Cosmovisor paths for the consensus client
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
sudo systemctl daemon-reload
sudo systemctl enable story-geth story
sudo systemctl restart story-geth story

# 14. Confirmation message for installation completion
if systemctl is-active --quiet story && systemctl is-active --quiet story-geth; then
    echo "Node installation and services started successfully!"
else
    echo "Node installation failed. Please check the logs for more information."
fi

# 15. Version update to v0.10.0 (HARDFORK at height 626575)
# Define the path of cosmovisor for being used in the consensus client
input1=$(which cosmovisor)
input2=$(find $HOME -type d -name "story")
input3=$(find $HOME/.story/story/cosmovisor -type d -name "backup")
echo "export DAEMON_NAME=story" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$input2" >> $HOME/.bash_profile
echo "export DAEMON_DATA_BACKUP_DIR=$(find $HOME/.story/story/cosmovisor -type d -name "backup")" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo "input1: $input1"
echo "input2: $input2"
echo "input3: $input3"

# Download the new node binary
cd $HOME && \
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.10.0-9603826.tar.gz

# Extract the new node binary
story_folder_name=$(tar -tf story-linux-amd64-0.10.0-9603826.tar.gz | head -n 1 | cut -f1 -d"/")
tar -xzf story-linux-amd64-0.10.0-9603826.tar.gz

# Set access and delete the existing upgrade file in data dir
sudo chown -R $USER:$USER $HOME/.story && sudo rm $HOME/.story/story/data/upgrade-info.json

# Execute the cosmovisor `add-upgrade` command
# v0.10.0 block height upgrade is 626575
cosmovisor add-upgrade v0.10.0 $HOME/$story_folder_name/story --upgrade-height 626575 --force

# After the instructions are successfully completed, delete the tar file and folder
sudo rm -rf $HOME/$story_folder_name $HOME/story-linux-amd64-0.10.0-9603826.tar.gz

# Confirmation that the node version update to v0.10.0 has been applied
echo "Node auto-update to version v0.10.0 has been successfully applied at height 626575."

# Reminder for the next update
echo "Reminder: You must update the node version to v0.10.1 when the node reaches height 990454."

# show the full logs
echo "sudo journalctl -u story-geth -u story -fn 100"
