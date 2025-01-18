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
    if ! wget -p $HOME/story-v0.12.0 https://github.com/piplabs/story/releases/download/v0.12.0/story-linux-amd64 -O $HOME/story-v0.12.0/story; then
        echo "Failed to download the genesis binary. Exiting."
        exit 1
    fi

    # Initialize cosmovisor
    if ! cosmovisor init $HOME/story-v0.12.0/story; then
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
init_cosmovisor0132() {
    echo "Initializing cosmovisor..."

    # Download genesis story version
    mkdir -p story-v0.13.2
    if ! wget -p $HOME/story-v0.12.0 https://github.com/piplabs/story/releases/download/v0.13.2/story-linux-amd64 -O $HOME/story-v0.13.2/story; then
        echo "Failed to download the genesis binary. Exiting."
        exit 1
    fi

    # Initialize cosmovisor
    if ! cosmovisor init $HOME/story-v0.13.2/story; then
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
input2=$(find "$HOME/.story" -type d -name "story" -print -quit)
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
    sudo chmod +x $HOME/go/bin/story && \
    sudo rm -f $HOME/.story/story/data/upgrade-info.json

    # Add the upgrade to cosmovisor
    if ! cosmovisor add-upgrade $version $HOME/story-$version/story --upgrade-height $upgrade_height --force; then
        echo "Failed to add upgrade to cosmovisor. Exiting."
        exit 1
    fi
}

# Function to perform batch update
batch_update_version() {
    local version1="v0.12.1"
    local version2="v0.13.0"
    local version3="v0.13.2"
    local download_url1="https://github.com/piplabs/story/releases/download/v0.12.1"
    local download_url2="https://github.com/piplabs/story/releases/download/v0.13.0"
    local download_url3="https://github.com/piplabs/story/releases/download/v0.13.2"
    local upgrade_height1=322000
    local upgrade_height2=858000
    #local upgrade_height3=2065886

    # Create directories and download the binaries
    cd $HOME
    mkdir -p $HOME/story-$version1
    mkdir -p $HOME/story-$version2
    #mkdir -p $HOME/story-$version3
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
    #sudo chown -R $USER:$USER $HOME/story-$version3/story && \
    sudo rm -f $HOME/.story/story/data/upgrade-info.json

    # Add the batch upgrade to cosmovisor
    if ! cosmovisor add-batch-upgrade --upgrade-list $version1:$HOME/story-$version1/story:$upgrade_height1,$version2:$HOME/story-$version2/story:$upgrade_height2; then
        echo "Failed to add batch upgrade to cosmovisor. Exiting."
        exit 1
    fi
}

# Menu for selecting the version
echo "Choose the version to update to:"
echo "a. v0.12.1 (Upgrade height: 322,000)"
echo "b. v0.13.0 (Upgrade height: 858,000)"
echo "c. v0.13.2 (Upgrade height: 2,065,886)"
echo "d. Batch update: Upgrade to v0.12.1 at height 322,000, v0.13.0 at height 858,000, and v0.13.2 at height 2,065,886 (RECOMMENDED FOR THOSE AIMING TO ACHIEVE ARCHIVE NODE STATUS)."
read -p "Enter the letter corresponding to the version: " choice

case $choice in
    a)
        update_version "v0.12.1" "https://github.com/piplabs/story/releases/download/v0.12.1" 322000
        ;;
    b)
        update_version "v0.13.0" "https://github.com/piplabs/story/releases/download/v0.13.0" 858000
        ;;
    c)
        init_cosmovisor0132
        ;;
    d)
        batch_update_version
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
