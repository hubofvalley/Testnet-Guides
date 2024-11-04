#!/bin/bash

# Function to display the menu
show_menu() {
    echo "Choose a snapshot provider:"
    echo "1. Mandragora"
    echo "2. Exit"
}

# Function to choose snapshot type for Mandragora
choose_mandragora_snapshot() {
    echo "Choose the type of snapshot for Mandragora:"
    echo "1. Pruned"
    echo "2. Archive"
    read -p "Enter your choice: " snapshot_type_choice

    case $snapshot_type_choice in
        1)
            GETH_SNAPSHOT_URL="https://snapshots2.mandragora.io/story/geth_snapshot.lz4"
            STORY_SNAPSHOT_URL="https://snapshots2.mandragora.io/story/story_snapshot.lz4"
            ;;
        2)
            GETH_SNAPSHOT_URL="https://snapshots.mandragora.io/geth_snapshot.lz4"
            STORY_SNAPSHOT_URL="https://snapshots.mandragora.io/story_snapshot.lz4"
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# Main script
show_menu
read -p "Enter your choice: " provider_choice

provider_name=""

case $provider_choice in
    1)
        provider_name="Mandragora"
        echo "Grand Valley extends its gratitude to $provider_name for providing snapshot support."
        choose_mandragora_snapshot
        ;;
    2)
        echo "Exiting."
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Remove upgrade-info.json
sudo rm -f $HOME/.story/story/data/upgrade-info.json

cd $HOME

# Install required dependencies
sudo apt-get install wget lz4 -y

# Stop your story-geth and story nodes
sudo systemctl stop story-geth story

# Back up your validator state
sudo cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/priv_validator_state.json.backup

# Delete previous geth chaindata and story data folders
sudo rm -rf $HOME/.story/geth/odyssey/chaindata $HOME/.story/story/data

# Download story-geth and story snapshots in the background
wget -O geth_snapshot.lz4 $GETH_SNAPSHOT_URL &
wget -O story_snapshot.lz4 $STORY_SNAPSHOT_URL &

# Wait for downloads to complete
wait

# Decompress story-geth and story snapshots
lz4 -c -d geth_snapshot.lz4 | tar -xv -C $HOME/.story/geth/odyssey/geth
lz4 -c -d story_snapshot.lz4 | tar -xv -C $HOME/.story/story

# Delete downloaded story-geth and story snapshots
sudo rm -v geth_snapshot.lz4 story_snapshot.lz4

# Restore your validator state
sudo cp $HOME/.story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

# Start your story-geth and story nodes
sudo systemctl restart story-geth story

echo "Snapshot setup completed successfully."
