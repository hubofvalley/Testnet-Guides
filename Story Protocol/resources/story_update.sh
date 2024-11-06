#!/bin/bash

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

# Menu for selecting the version
echo "Choose the version to update to:"
echo "a. v0.12.1 (Upgrade height: 322000)"
echo "Note: There are currently no versions available after v0.12.1."
read -p "Enter the letter corresponding to the version: " choice

case $choice in
    a)
        update_version "v0.12.1" "https://github.com/piplabs/story/releases/download/v0.12.1" 322000
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
