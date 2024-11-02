#!/bin/bash

# Define variables
input1=$(which cosmovisor)
input2=$(find $HOME -type d -name "story")
input3=$(find $HOME/.story/story/cosmovisor -type d -name "backup")
story_file_name=story-linux-amd64

# Export environment variables
echo "export DAEMON_NAME=story" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$input2" >> $HOME/.bash_profile
echo "export DAEMON_DATA_BACKUP_DIR=$input3" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Function to update to a specific version
update_version() {
    local version=$1
    local download_url=$2

    # Create directory and download the binary
    mkdir -p $HOME/$version
    cd $HOME/$version && wget $download_url/$story_file_name

    # Move the binary to the appropriate directory
    sudo cp $HOME/$version/$story_file_name $HOME/go/bin/story

    # Set ownership and permissions
    sudo chown -R $USER:$USER $HOME/.story && \
    sudo chown -R $USER:$USER $HOME/go/bin/story && \
    sudo rm $HOME/.story/story/data/upgrade-info.json

    # Add the upgrade to cosmovisor
    cosmovisor add-upgrade $version $HOME/$version/$story_file_name --upgrade-height 322000 --force

    # Restart the service
    sudo systemctl daemon-reload && \
    sudo systemctl restart story
}

# Menu for selecting the version
echo "Choose the version to update to:"
echo "1. v0.12.1"
echo "Note: There are currently no versions available after v0.12.1."
read -p "Enter the number corresponding to the version: " choice

case $choice in
    1)
        update_version "v0.12.1" "https://github.com/piplabs/story/releases/download/v0.12.1"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
