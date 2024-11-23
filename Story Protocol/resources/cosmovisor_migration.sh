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

    # Initialize cosmovisor with the current story binary
    if ! cosmovisor init $HOME/go/bin/story; then
        echo "Failed to initialize cosmovisor. Exiting."
        exit 1
    fi

    mkdir -p $HOME/.story/story/cosmovisor/upgrades
    mkdir -p $HOME/.story/story/cosmovisor/backup
}

# Install and initialize cosmovisor
install_cosmovisor
init_cosmovisor

# Define variables
input1=$(which cosmovisor)
input2=$(find "$HOME/.story" -type d -name "story" -print -quit)
input3=$(find "$HOME/.story/story/cosmovisor" -type d -name "backup" -print -quit)

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

# Reload and Restart systemd to apply changes
sudo systemctl daemon-reload
sudo systemctl restart story

echo "Cosmovisor migration completed successfully."
