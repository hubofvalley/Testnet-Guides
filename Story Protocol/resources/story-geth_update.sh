#!/bin/bash

# Define variables
geth_file_name=geth-linux-amd64

# Function to update to a specific version
update_version() {
    local version=$1
    local download_url=$2

    # Create directory and download the binary
    cd $HOME
    mkdir -p $HOME/story-geth-$version
    if ! wget -P $HOME/story-geth-$version $download_url/$geth_file_name -O $HOME/story-geth-$version/geth; then
        echo "Failed to download the binary. Exiting."
        exit 1
    fi

    # Move the binary to the appropriate directory
    sudo mv $HOME/story-geth-$version/geth $HOME/go/bin/geth

    # Set ownership and permissions
    sudo chown -R $USER:$USER $HOME/go/bin/geth
    sudo chmod +x $HOME/go/bin/geth

    # Restart the service
    sudo systemctl daemon-reload && \
    sudo systemctl restart story-geth
}

# Inform the user that there is no currently latest version of story-geth
echo "There is currently no latest version of story-geth available."

# Menu for selecting the version
echo "Choose the version to update to:"
echo "There are currently no versions available."

# Placeholder for future versions
# Uncomment and add new versions here
echo "a. v0.10.1"
echo "a. v0.11.0"
# echo "b. v0.9.5"

read -p "Enter the letter corresponding to the version: " choice

case $choice in
    # Placeholder for future versions
    # Uncomment and add new versions here
    a)
         update_version "v0.10.1" "https://github.com/piplabs/story-geth/releases/download/v0.10.1"
         ;;
    b)
         update_version "v0.11.0" "https://github.com/piplabs/story-geth/releases/download/v0.11.0"
         ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
