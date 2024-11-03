#!/bin/bash

# Define variables
geth_file_name=geth-linux-amd64

# Function to update to a specific version
update_version() {
    local version=$1
    local download_url=$2

    # Create directory and download the binary
    cd $HOME
    mkdir -p $HOME/$version
    if ! wget -P $HOME/$version $download_url/$geth_file_name -O $HOME/$version/geth; then
        echo "Failed to download the binary. Exiting."
        exit 1
    fi

    # Move the binary to the appropriate directory
    sudo mv $HOME/$version/geth $HOME/go/bin/geth

    # Set ownership and permissions
    sudo chown -R $USER:$USER $HOME/go/bin/geth
    sudo chmod +x $HOME/go/bin/geth

    # Restart the service
    sudo systemctl daemon-reload && \
    sudo systemctl restart story-geth
}

# Inform the user that there is no currently latest version of story-geth
echo "There is currently no latest version of story-geth available."
echo "Please update the script manually with the version number and download link for the update."

# Menu for selecting the version
echo "Choose the version to update to:"
echo "Note: There are currently no versions available."

# Placeholder for future versions
# Uncomment and add new versions here
# echo "a. v0.9.4"
# echo "b. v0.9.5"

# read -p "Enter the letter corresponding to the version: " choice

case $choice in
    # Placeholder for future versions
    # Uncomment and add new versions here
    # a)
    #     update_version "v0.9.4" "https://github.com/piplabs/story-geth/releases/download/v0.9.4"
    #     ;;
    # b)
    #     update_version "v0.9.5" "https://github.com/piplabs/story-geth/releases/download/v0.9.5"
    #     ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
