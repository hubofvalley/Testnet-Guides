#!/bin/bash

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
    mkdir -p story-v0.12.0
    if ! wget -O story-v0.12.0/story-linux-amd64 https://github.com/piplabs/story/releases/download/v0.12.0/story-linux-amd64; then
        echo "Failed to download the genesis binary. Exiting."
        exit 1
    fi

    story_file__name=story-linux-amd64
    cp story-v0.12.0/$story_file__name $HOME/go/bin/story
    sudo chown -R $USER:$USER $HOME/go/bin/story
    sudo chmod +x $HOME/go/bin/story

    # Initialize cosmovisor
    if ! cosmovisor init $HOME/go/bin/story; then
        echo "Failed to initialize cosmovisor. Exiting."
        exit 1
    fi

    mkdir -p $HOME/.story/story/cosmovisor/upgrades
    mkdir -p $HOME/.story/story/cosmovisor/backup
}

# Ask the user if cosmovisor is installed
read -p "Do you have cosmovisor installed? (y/n): " cosmovisor_installed

if [ "$cosmovisor_installed" != "y" ]; then
    install_cosmovisor
    init_cosmovisor
fi

# Define variables
input1=$(which cosmovisor)
input2=$(find $HOME -type d -name "story")
input3=$(find $HOME/.story/story/cosmovisor -type d -name "backup")
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
sudo tee /etc/systemd/system/story.service <<EOF
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

    # Move the binary to the appropriate directory
    sudo cp $HOME/story-$version/story $HOME/go/bin/story

    # Set ownership and permissions
    sudo chown -R $USER:$USER $HOME/.story && \
    sudo chown -R $USER:$USER $HOME/go/bin/story && \
    sudo rm -f $HOME/.story/story/data/upgrade-info.json

    # Add the upgrade to cosmovisor
    if ! cosmovisor add-upgrade $version $HOME/go/bin/story --upgrade-height $upgrade_height --force; then
        echo "Failed to add upgrade to cosmovisor. Exiting."
        exit 1
    fi
}

# Function to perform batch update
batch_update_version() {
    local version1="v0.12.1"
    local version2="v0.13.0"
    local download_url1="https://github.com/piplabs/story/releases/download/v0.12.1"
    local download_url2="https://github.com/piplabs/story/releases/download/v0.13.0"
    local upgrade_height1=322000
    local upgrade_height2=858000

    # Create directories and download the binaries
    cd $HOME
    mkdir -p $HOME/story-$version1
    mkdir -p $HOME/story-$version2
    if ! wget -P $HOME/story-$version1 $download_url1/$story_file_name -O $HOME/story-$version1/story; then
        echo "Failed to download the binary for $version1. Exiting."
        exit 1
    fi
    if ! wget -P $HOME/story-$version2 $download_url2/$story_file_name -O $HOME/story-$version2/story; then
        echo "Failed to download the binary for $version2. Exiting."
        exit 1
    fi

    # Set ownership and permissions
    sudo chown -R $USER:$USER $HOME/.story && \
    sudo chown -R $USER:$USER $HOME/story-$version1/story && \
    sudo chown -R $USER:$USER $HOME/story-$version2/story && \
    sudo rm -f $HOME/.story/story/data/upgrade-info.json

    # Add the batch upgrade to cosmovisor
    if ! cosmovisor add-batch-upgrade --upgrade-list $version1:$HOME/story-$version1/story:$upgrade_height1,$version2:$HOME/story-$version2/story:$upgrade_height2; then
        echo "Failed to add batch upgrade to cosmovisor. Exiting."
        exit 1
    fi

    # Move the latest version to the go directory
    sudo cp $HOME/story-$version2/story $HOME/go/bin/story
}

# Menu for selecting the version
echo "Choose the version to update to:"
echo "a. v0.12.1 (Upgrade height: 322000)"
echo "b. v0.13.0 (Upgrade height: 858000)"
echo "c. Batch update (v0.12.1 at block height 322000 and v0.13.0 at block height 858000)"
read -p "Enter the letter corresponding to the version: " choice

case $choice in
    a)
        update_version "v0.12.1" "https://github.com/piplabs/story/releases/download/v0.12.1" 322000
        ;;
    b)
        update_version "v0.13.0" "https://github.com/piplabs/story/releases/download/v0.13.0" 858000
        ;;
    c)
        batch_update_version
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
