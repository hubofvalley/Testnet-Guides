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

    mkdir -p $HOME/.0gchain/cosmovisor/upgrades
    mkdir -p $HOME/.0gchain/cosmovisor/backup
}

# Install and initialize cosmovisor
install_cosmovisor
init_cosmovisor

# Define variables
input1=$(which cosmovisor)
input2=$(find $HOME -type d -name "story")
input3=$(find $HOME/.0gchain/cosmovisor -type d -name "backup")

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

# Define the service file name
SERVICE_FILE_NAME=$1

# Check if the service file name is provided and is either 0gchaind.service or 0gd.service
if [[ -z "$SERVICE_FILE_NAME" || ("$SERVICE_FILE_NAME" != "0gchaind.service" && "$SERVICE_FILE_NAME" != "0gd.service") ]]; then
  echo "Usage: $0 <service_file_name>"
  echo "Service file name must be either 0gchaind.service or 0gd.service"
  exit 1
fi

# Define the service file path
SERVICE_FILE_PATH="/etc/systemd/system/$SERVICE_FILE_NAME"

# Check if the service file exists
if [[ ! -f "$SERVICE_FILE_PATH" ]]; then
  echo "Service file $SERVICE_FILE_PATH does not exist."
  exit 1
fi

# Update the service file
cat <<EOF | sudo tee "$SERVICE_FILE_PATH"
[Unit]
Description=Cosmovisor 0G Node
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME/.0gchain
ExecStart=$input1 run start --log_output_console
StandardOutput=journal
StandardError=journal
Restart=on-failure
LimitNOFILE=65535
Environment="DAEMON_NAME=0gchaind"
Environment="DAEMON_HOME=$input2"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_DATA_BACKUP_DIR=$input3"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# Reload the systemd daemon to apply the changes
sudo systemctl daemon-reload

# Reload and Restart systemd to apply changes
sudo systemctl daemon-reload
sudo systemctl restart "$SERVICE_FILE_NAME"

echo "Cosmovisor migration completed successfully."
