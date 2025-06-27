#!/bin/bash

# Check if OS is Ubuntu
source /etc/os-release
if [ "$ID" != "ubuntu" ]; then
    echo "This script is intended for Ubuntu only. Exiting."
    exit 1
fi

# Define variables
geth_file_name=geth-linux-amd64

# Function to update to a specific version
update_version() {
    local version=$1
    local download_url=$2

    source /etc/os-release
    if [ "$VERSION_ID" = "22.04" ]; then
        echo "Building from source for Ubuntu 22.04"
        sudo systemctl stop story story-geth
        mkdir -p $HOME/story-geth
        cd $HOME/story-geth || { echo "Failed to enter $HOME/story-geth"; exit 1; }
        if ! wget -O "${version}.tar.gz" "https://github.com/piplabs/story-geth/archive/refs/tags/${version}.tar.gz"; then
            echo "Failed to download source. Exiting."
            exit 1
        fi
        if ! tar -xzf "${version}.tar.gz"; then
            echo "Failed to extract source. Exiting."
            exit 1
        fi
        cd "story-geth-${version#v}" || { echo "Failed to enter source directory"; exit 1; }
        if ! make geth; then
            echo "Build failed. Exiting."
            exit 1
        fi
        if ! cp build/bin/geth "$HOME/go/bin/"; then
            echo "Failed to copy binary. Exiting."
            exit 1
        fi
        sudo chown -R "$USER:$USER" "$HOME/go/bin/geth"
        sudo chmod +x "$HOME/go/bin/geth"
    elif dpkg --compare-versions "$VERSION_ID" "gt" "22.04"; then
        echo "Using pre-built binary for Ubuntu $VERSION_ID"
        sudo systemctl stop story story-geth
        mkdir -p "$HOME/story-geth-$version"
        if ! wget -P "$HOME/story-geth-$version" "$download_url/$geth_file_name" -O "$HOME/story-geth-$version/geth"; then
            echo "Failed to download the binary. Exiting."
            exit 1
        fi
        sudo mv "$HOME/story-geth-$version/geth" "$HOME/go/bin/geth"
        sudo chown -R "$USER:$USER" "$HOME/go/bin/geth"
        sudo chmod +x "$HOME/go/bin/geth"
    else
        echo "Unsupported Ubuntu version. Only Ubuntu 22.04 and newer are supported. Exiting."
        exit 1
    fi

    sudo systemctl daemon-reload
    sudo systemctl restart story-geth && sleep 5 && sudo systemctl restart story
}

# Menu for selecting the version
echo "Choose the version to update to:"
echo "a. v1.1.0 (Cosmas)"
# Uncomment and add more versions as needed
# echo "b. v0.11.0"

read -p "Enter the letter corresponding to the version: " choice

case $choice in
    a)
        update_version "v1.1.0" "https://github.com/piplabs/story-geth/releases/download/v1.1.0"
        ;;
    # Uncomment and add more versions as needed
    # b)
    #     update_version "v0.11.0" "https://github.com/piplabs/story-geth/releases/download/v0.11.0"
    #     ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac