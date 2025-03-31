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

    # Download genesis 0g version
    mkdir -p 0g-v0.5.3
    if ! wget -P $HOME/0g-v0.5.3 https://github.com/0glabs/0g-chain/releases/download/v0.5.3/0gchaind-linux-v0.5.3 -O $HOME/0g-v0.5.3/0gchaind; then
        echo "Failed to download the genesis binary. Exiting."
        exit 1
    fi

    # Initialize cosmovisor
    if ! cosmovisor init $HOME/0g-v0.5.3/0gchaind; then
        echo "Failed to initialize cosmovisor. Exiting."
        exit 1
    fi

    cd $HOME/go/bin/
    sudo rm -r 0gchaind
    ln -s $HOME/.0gchain/cosmovisor/current/bin/0gchaind 0gchaind
    sudo chown -R $USER:$USER $HOME/go/bin/0gchaind
    sudo chmod +x $HOME/go/bin/0gchaind
    sudo rm -r $HOME/.0gchain/data/upgrade-info.json
    mkdir -p $HOME/.0gchain/cosmovisor/upgrades
    mkdir -p $HOME/.0gchain/cosmovisor/backup
}

# Function to initialize cosmovisor
init_cosmovisor052() {
    sudo systemctl stop 0gchaind

    # Download genesis 0g version
    mkdir -p 0g-v0.5.3
    wget -P $HOME/0g-v0.5.3 https://github.com/0glabs/0g-chain/releases/download/v0.5.3/0gchaind-linux-v0.5.3 -O $HOME/0g-v0.5.3/0gchaind

    # Initialize cosmovisor
    sudo rm -r $HOME/.0gchain/cosmovisor
    cosmovisor init $HOME/0g-v0.5.3/0gchaind
    cd $HOME/go/bin/
    sudo rm -r 0gchaind
    ln -s $HOME/.0gchain/cosmovisor/current/bin/0gchaind 0gchaind
    sudo chown -R $USER:$USER $HOME/go/bin/0gchaind
    sudo chmod +x $HOME/go/bin/0gchaind
    sudo rm -r $HOME/.0gchain/data/upgrade-info.json
    mkdir -p $HOME/.0gchain/cosmovisor/upgrades
    mkdir -p $HOME/.0gchain/cosmovisor/backup
    sudo systemctl restart 0gchaind
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
input2=$(find "$HOME" -type d -name ".0gchain" -print -quit)
input3=$(find "$HOME/.0gchain/cosmovisor" -type d -name "backup" -print -quit)
binary_file_name=0gchaind-linux-v0.5.3

# Check if cosmovisor is installed
if [ -z "$input1" ]; then
    echo "cosmovisor is not installed. Please install it first."
    exit 1
fi

# Check if 0gchain directory exists
if [ -z "$input2" ]; then
    echo "0gchain directory not found. Please ensure it exists."
    exit 1
fi

# Check if backup directory exists
if [ -z "$input3" ]; then
    echo "Backup directory not found. Please ensure it exists."
    exit 1
fi

# Export environment variables
echo "export DAEMON_NAME=0gchaind" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$input2" >> $HOME/.bash_profile
echo "export DAEMON_DATA_BACKUP_DIR=$input3" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Create or update the systemd service file
sudo tee /etc/systemd/system/0gchaind.service > /dev/null <<EOF
[Unit]
Description=Cosmovisor 0G Node
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME/.0gchain
ExecStart=${input1} run start --log_output_console
StandardOutput=journal
StandardError=journal
Restart=on-failure
LimitNOFILE=65535
Environment="DAEMON_NAME=0gchaind"
Environment="DAEMON_HOME=${input2}"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
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
    mkdir -p $HOME/0g-$version
    if ! wget -P $HOME/0g-$version $download_url/$binary_file_name -O $HOME/0g-$version/0gchaind; then
        echo "Failed to download the binary. Exiting."
        exit 1
    fi

    # Set ownership and permissions
    sudo chown -R $USER:$USER $HOME/.0gchain && \
    sudo chown -R $USER:$USER $HOME/go/bin/0gchaind && \
    sudo chmod +x $HOME/0g-$version/0gchaind && \
    sudo chmod +x $HOME/go/bin/0gchaind && \
    sudo rm -f $HOME/.0gchain/data/upgrade-info.json

    # Add the upgrade to cosmovisor
    if ! cosmovisor add-upgrade $version $HOME/0g-$version/0gchaind --upgrade-height $upgrade_height --force; then
        echo "Failed to add upgrade to cosmovisor. Exiting."
        exit 1
    fi
}

# Menu for selecting the version
echo "Choose the version to update to:"
echo -e "a. ${YELLOW}v0.5.3${RESET} (Upgrade height: 3,781,700)"
read -p "Enter the letter corresponding to the version: " choice

case $choice in
    a)
        update_version "v0.5.3" "https://github.com/0glabs/0g-chain/releases/download/v0.5.3" 3781700
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
