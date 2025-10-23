#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Function to install cosmovisor
install_cosmovisor() {
    echo "Installing cosmovisor..."
    if ! go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest; then
        echo "Failed to install cosmovisor. Exiting."
        exit 1
    fi
}

# Function to initialize cosmovisor
init_cosmovisor() {
    echo "Initializing cosmovisor..."

    # Download genesis story version
    mkdir -p story-v1.1.1
    if ! wget -p $HOME/story-v1.1.1 https://github.com/piplabs/story/releases/download/v1.1.1/story-linux-amd64 -O $HOME/story-v1.1.1/story; then
        echo "Failed to download the genesis binary. Exiting."
        exit 1
    fi

    # Initialize cosmovisor
    if ! cosmovisor init $HOME/story-v1.1.1/story; then
        echo "Failed to initialize cosmovisor. Exiting."
        exit 1
    fi

    cd $HOME/go/bin/
    sudo rm -r story
    ln -s $HOME/.story/story/cosmovisor/current/bin/story story
    sudo chown -R $USER:$USER $HOME/go/bin/story
    sudo chmod +x $HOME/go/bin/story
    sudo rm -r $HOME/.story/story/data/upgrade-info.json
    mkdir -p $HOME/.story/story/cosmovisor/upgrades
    mkdir -p $HOME/.story/story/cosmovisor/backup
}

# Function to initialize cosmovisor
init_cosmovisor110() {
    sudo systemctl stop story story-geth

    # Download genesis story version
    mkdir -p story-v1.2.0
    wget -p $HOME/story-v1.2.0 https://github.com/piplabs/story/releases/download/v1.2.0/story-linux-amd64 -O $HOME/story-v1.2.0/story

    # Initialize cosmovisor
    sudo rm -r $HOME/.story/story/cosmovisor
    cosmovisor init $HOME/story-v1.2.0/story
    cd $HOME/go/bin/
    sudo rm -r story
    ln -s $HOME/.story/story/cosmovisor/current/bin/story story
    sudo chown -R $USER:$USER $HOME/go/bin/story
    sudo chmod +x $HOME/go/bin/story
    sudo rm -r $HOME/.story/story/data/upgrade-info.json
    mkdir -p $HOME/.story/story/cosmovisor/upgrades
    mkdir -p $HOME/.story/story/cosmovisor/backup
    sudo systemctl restart story story-geth
}

# Ask the user if cosmovisor is installed
read -p "Do you have cosmovisor installed? (y/n): " cosmovisor_installed

if [ "$cosmovisor_installed" == "y" ]; then
    echo "Cosmovisor is already installed. Skipping installation and initialization."
else
    install_cosmovisor
    init_cosmovisor
fi

# Define variables
input1=$(which cosmovisor)
input2=$(find "$HOME/.story/story" -type d -name "story" -print -quit)
input3=$(find "$HOME/.story/story/cosmovisor" -type d -name "backup" -print -quit)
story_file_name=story-linux-amd64

# Check if cosmovisor is installed
if [ -z "$input1" ]; then
    echo "cosmovisor is not installed. Please install it first."
    exit 1
fi

# Check if story directory exists
if [ -z "$input2" ]; then
    echo "Story directory not found. Please ensure it exists."
    exit 1
fi

# Check if backup directory exists
if [ -z "$input3" ]; then
    echo "Backup directory not found. Please ensure it exists."
    exit 1
fi

# Export environment variables
echo "export DAEMON_NAME=story" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$input2" >> $HOME/.bash_profile
echo "export DAEMON_DATA_BACKUP_DIR=$input3" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Create or update the systemd service file
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Cosmovisor Story Node
After=network.target

[Service]
User=${USER}
Type=simple
WorkingDirectory=${HOME}/.story/story
ExecStart=${input1} run run
StandardOutput=journal
StandardError=journal
Restart=on-failure
RestartSec=5
LimitNOFILE=65536
LimitNPROC=65536
Environment="DAEMON_NAME=story"
Environment="DAEMON_HOME=${input2}"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_DATA_BACKUP_DIR=${input3}"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to apply changes
sudo systemctl daemon-reload

# Function to update to a specific version
update_version() {
    local version=$1
    local download_url=$2
    local upgrade_height=$3

    # Create directory and download the binary
    cd $HOME
    mkdir -p $HOME/story-$version
    if ! wget -P $HOME/story-$version $download_url/$story_file_name -O $HOME/story-$version/story; then
        echo "Failed to download the binary. Exiting."
        exit 1
    fi

    # Set ownership and permissions
    sudo chown -R $USER:$USER $HOME/.story && \
    sudo chown -R $USER:$USER $HOME/go/bin/story && \
    sudo chmod +x $HOME/story-$version/story && \
    sudo chmod +x $HOME/go/bin/story && \
    sudo rm -f $HOME/.story/story/data/upgrade-info.json

    # Copy the updated binary to the cosmovisor genesis directory
    GENESIS_DIR="$HOME/.story/story/cosmovisor/genesis/bin"
    cp "$HOME/story-$version/story" "$GENESIS_DIR/story"
    sudo chown -R $USER:$USER "$GENESIS_DIR/story"
    sudo chmod +x "$GENESIS_DIR/story"

    # Add the upgrade to cosmovisor
    if ! cosmovisor add-upgrade $version $HOME/story-$version/story --upgrade-height $upgrade_height --force; then
        echo "Failed to add upgrade to cosmovisor. Exiting."
        exit 1
    fi
}

# Function to perform batch update
batch_update_version() {
    local version1="v1.1.0"
    local version2="v1.2.0"
    local version3="v1.3.0"
    local download_url1="https://github.com/piplabs/story/releases/download/v1.1.0"
    local download_url2="https://github.com/piplabs/story/releases/download/v1.2.0"
    local download_url3="https://github.com/piplabs/story/releases/download/v1.3.0"
    local upgrade_height1=640000
    local upgrade_height2=3861111
    local upgrade_height3=5707000

    # Create directories and download the binaries
    cd $HOME
    mkdir -p $HOME/story-$version1
    mkdir -p $HOME/story-$version2
    mkdir -p $HOME/story-$version3
    if ! wget -P $HOME/story-$version1 $download_url1/$story_file_name -O $HOME/story-$version1/story; then
        echo "Failed to download the binary for $version1. Exiting."
        exit 1
    fi
    if ! wget -P $HOME/story-$version2 $download_url2/$story_file_name -O $HOME/story-$version2/story; then
        echo "Failed to download the binary for $version2. Exiting."
        exit 1
    fi
    if ! wget -P $HOME/story-$version3 $download_url3/$story_file_name -O $HOME/story-$version3/story; then
        echo "Failed to download the binary for $version3. Exiting."
        exit 1
    fi

    # Set ownership and permissions
    sudo chown -R $USER:$USER $HOME/.story && \
    sudo chown -R $USER:$USER $HOME/story-$version1/story && \
    sudo chown -R $USER:$USER $HOME/story-$version2/story && \
    sudo chown -R $USER:$USER $HOME/story-$version3/story && \
    sudo chmod +x $HOME/story-$version1/story && \
    sudo chmod +x $HOME/story-$version2/story && \
    sudo chmod +x $HOME/story-$version3/story && \
    sudo rm -f $HOME/.story/story/data/upgrade-info.json

    # Add the batch upgrade to cosmovisor
    if ! cosmovisor add-batch-upgrade --upgrade-list $version1:$HOME/story-$version1/story:$upgrade_height1,$version2:$HOME/story-$version2/story:$upgrade_height2,$version3:$HOME/story-$version3/story:$upgrade_height3; then
        echo "Failed to add batch upgrade to cosmovisor. Exiting."
        exit 1
    fi
}

# Menu for selecting the version
rpc_response=$(curl -s -X POST "https://aeneid.storyrpc.io" -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}')
realtime_block_height=$(echo "$rpc_response" | jq -r '.result' | xargs printf "%d")
echo "Choose the version to update to:"
#read -p "There are currently no new versions available."
echo -e "a. ${YELLOW}v1.1.0${RESET} (${GREEN}Virgil${RESET} Upgrade height: 640,000)"
echo -e "b. ${YELLOW}v1.1.1${RESET} (${GREEN}Additional update for validator CLI interaction${RESET} Upgrade height: 1,398,904)"
echo -e "c. ${YELLOW}v1.2.0${RESET} (${GREEN}Ovid${RESET} Upgrade height: 3,861,111)"
echo -e "d. ${YELLOW}v1.3.0${RESET} (${GREEN}Polybius${RESET} Upgrade height: 5,707,000)"
echo -e "e. ${YELLOW}v1.3.3${RESET} (${GREEN}Latest upgrade, dynamic height (current block + 100)${RESET})"
#echo "f. Batch update: Upgrade to v1.1.0 at height 640,000, v1.1.1 at height 858,000, v1.2.0 at height 3,861,111 and v1.3.0 at height 5,707,000 (RECOMMENDED FOR THOSE AIMING TO ACHIEVE ARCHIVE NODE STATUS)."
read -p "Enter the letter corresponding to the version: " choice

case $choice in
    a)
        update_version "v1.1.0" "https://github.com/piplabs/story/releases/download/v1.1.0" 640000
        ;;
    b)
        update_version "v1.1.1" "https://github.com/piplabs/story/releases/download/v1.1.1" 1398904
        ;;
    c)
        update_version "v1.2.0" "https://github.com/piplabs/story/releases/download/v1.2.0" 3861111
        ;;
    d)
        update_version "v1.3.0" "https://github.com/piplabs/story/releases/download/v1.3.0" 5707000
        ;;
    e)
        update_version "v1.3.3" "https://github.com/piplabs/story/releases/download/v1.3.3" $((realtime_block_height + 100))
        ;;
    #f)
        #batch_update_version
        #;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo "Let's Buidl Story Together"
