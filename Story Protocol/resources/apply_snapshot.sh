#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display the menu
show_menu() {
    echo -e "${GREEN}Choose a snapshot provider:${NC}"
    echo "1. Mandragora"
    echo "2. ITRocket"
    echo "3. Exit"
}

# Function to choose snapshot type for Mandragora
choose_mandragora_snapshot() {
    echo -e "${GREEN}Choose the type of snapshot for Mandragora:${NC}"
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
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac
}

# Function to choose snapshot type for ITRocket
choose_itrocket_snapshot() {
    echo -e "${GREEN}Choose the type of snapshot for ITRocket:${NC}"
    echo "1. Pruned"
    echo "2. Archive"
    read -p "Enter your choice: " snapshot_type_choice

    case $snapshot_type_choice in
        1)
            GETH_SNAPSHOT_URL="https://server-1.itrocket.net/testnet/story/geth_story_2024-11-05_304590_snap.tar.lz4"
            STORY_SNAPSHOT_URL="https://server-1.itrocket.net/testnet/story/story_2024-11-05_304590_snap.tar.lz4"
            ;;
        2)
            GETH_SNAPSHOT_URL="https://server-5.itrocket.net/testnet/story/geth_story_2024-11-05_303734_snap.tar.lz4"
            STORY_SNAPSHOT_URL="https://server-5.itrocket.net/testnet/story/story_2024-11-05_303734_snap.tar.lz4"
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac
}

# Function to decompress snapshots
decompress_snapshots() {
    if [[ $GETH_SNAPSHOT_FILE == *.tar.lz4 ]]; then
        lz4 -c -d $GETH_SNAPSHOT_FILE | tar -xv -C $HOME/.story/geth/odyssey/geth
        lz4 -c -d $STORY_SNAPSHOT_FILE | tar -xv -C $HOME/.story/story
    else
        lz4 -c -d $GETH_SNAPSHOT_FILE | tar -xv -C $HOME/.story/geth/odyssey/geth
        lz4 -c -d $STORY_SNAPSHOT_FILE | tar -xv -C $HOME/.story/story
    fi
}

# Main script
show_menu
read -p "Enter your choice: " provider_choice

provider_name=""

case $provider_choice in
    1)
        provider_name="Mandragora"
        echo -e "${GREEN}Grand Valley extends its gratitude to $provider_name for providing snapshot support.${NC}"
        choose_mandragora_snapshot
        GETH_SNAPSHOT_FILE="geth_snapshot.lz4"
        STORY_SNAPSHOT_FILE="story_snapshot.lz4"
        ;;
    2)
        provider_name="ITRocket"
        echo -e "${GREEN}Grand Valley extends its gratitude to $provider_name for providing snapshot support.${NC}"
        choose_itrocket_snapshot
        GETH_SNAPSHOT_FILE="geth_snapshot.tar.lz4"
        STORY_SNAPSHOT_FILE="story_snapshot.tar.lz4"
        ;;
    3)
        echo -e "${GREEN}Exiting.${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${NC}"
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
wget -O $GETH_SNAPSHOT_FILE $GETH_SNAPSHOT_URL &
wget -O $STORY_SNAPSHOT_FILE $STORY_SNAPSHOT_URL &

# Wait for downloads to complete
wait

# Decompress story-geth and story snapshots
decompress_snapshots

# Delete downloaded story-geth and story snapshots
sudo rm -v $GETH_SNAPSHOT_FILE $STORY_SNAPSHOT_FILE

# Restore your validator state
sudo cp $HOME/.story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

# Start your story-geth and story nodes
sudo systemctl restart story-geth story

echo -e "${GREEN}Snapshot setup completed successfully.${NC}"
