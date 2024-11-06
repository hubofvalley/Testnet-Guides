#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Snapshot URLs
MAND_PRUNED_GETH_SNAPSHOT_URL="https://snapshots2.mandragora.io/story/geth_snapshot.lz4"
MAND_PRUNED_STORY_SNAPSHOT_URL="https://snapshots2.mandragora.io/story/story_snapshot.lz4"
MAND_ARCHIVE_GETH_SNAPSHOT_URL="https://snapshots.mandragora.io/geth_snapshot.lz4"
MAND_ARCHIVE_STORY_SNAPSHOT_URL="https://snapshots.mandragora.io/story_snapshot.lz4"

ITR_PRUNED_GETH_SNAPSHOT_URL="https://server-1.itrocket.net/testnet/story/geth_story_2024-11-05_304590_snap.tar.lz4"
ITR_PRUNED_STORY_SNAPSHOT_URL="https://server-1.itrocket.net/testnet/story/story_2024-11-05_304590_snap.tar.lz4"
ITR_ARCHIVE_GETH_SNAPSHOT_URL="https://server-5.itrocket.net/testnet/story/geth_story_2024-11-05_303734_snap.tar.lz4"
ITR_ARCHIVE_STORY_SNAPSHOT_URL="https://server-5.itrocket.net/testnet/story/story_2024-11-05_303734_snap.tar.lz4"

CROUTON_SNAPSHOT_URL="https://storage.crouton.digital/testnet/story/snapshots/story_latest.tar.lz4"

JOSEPHTRAN_PRUNED_GETH_SNAPSHOT_URL="https://story.josephtran.co/Geth_snapshot.lz4"
JOSEPHTRAN_PRUNED_STORY_SNAPSHOT_URL="https://story.josephtran.co/Story_snapshot.lz4"
JOSEPHTRAN_ARCHIVE_GETH_SNAPSHOT_URL="https://story.josephtran.co/archive_Geth_snapshot.lz4"
JOSEPHTRAN_ARCHIVE_STORY_SNAPSHOT_URL="https://story.josephtran.co/archive_Story_snapshot.lz4"

# Function to display the menu
show_menu() {
    echo -e "${GREEN}Choose a snapshot provider:${NC}"
    echo "1. Mandragora"
    echo "2. ITRocket"
    echo "3. CroutonDigital"
    echo "4. Josephtran"
    echo "5. Exit"
}

# Function to check if a URL is available
check_url() {
    local url=$1
    if curl --output /dev/null --silent --head --fail "$url"; then
        echo -e "${GREEN}Available${NC}"
    else
        echo -e "${RED}Not available at the moment${NC}"
    fi
}

# Function to choose snapshot type for Mandragora
choose_mandragora_snapshot() {
    echo -e "${GREEN}Choose the type of snapshot for Mandragora:${NC}"
    echo "1. Pruned"
    echo "2. Archive"
    read -p "Enter your choice: " snapshot_type_choice

    case $snapshot_type_choice in
        1)
            GETH_SNAPSHOT_URL=$MAND_PRUNED_GETH_SNAPSHOT_URL
            STORY_SNAPSHOT_URL=$MAND_PRUNED_STORY_SNAPSHOT_URL
            ;;
        2)
            GETH_SNAPSHOT_URL=$MAND_ARCHIVE_GETH_SNAPSHOT_URL
            STORY_SNAPSHOT_URL=$MAND_ARCHIVE_STORY_SNAPSHOT_URL
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
            GETH_SNAPSHOT_URL=$ITR_PRUNED_GETH_SNAPSHOT_URL
            STORY_SNAPSHOT_URL=$ITR_PRUNED_STORY_SNAPSHOT_URL
            ;;
        2)
            GETH_SNAPSHOT_URL=$ITR_ARCHIVE_GETH_SNAPSHOT_URL
            STORY_SNAPSHOT_URL=$ITR_ARCHIVE_STORY_SNAPSHOT_URL
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac
}

# Function to choose snapshot type for Josephtran
choose_josephtran_snapshot() {
    echo -e "${GREEN}Choose the type of snapshot for Josephtran:${NC}"
    echo "1. Pruned"
    echo "2. Archive"
    read -p "Enter your choice: " snapshot_type_choice

    case $snapshot_type_choice in
        1)
            GETH_SNAPSHOT_URL=$JOSEPHTRAN_PRUNED_GETH_SNAPSHOT_URL
            STORY_SNAPSHOT_URL=$JOSEPHTRAN_PRUNED_STORY_SNAPSHOT_URL
            ;;
        2)
            GETH_SNAPSHOT_URL=$JOSEPHTRAN_ARCHIVE_GETH_SNAPSHOT_URL
            STORY_SNAPSHOT_URL=$JOSEPHTRAN_ARCHIVE_STORY_SNAPSHOT_URL
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac
}

# Function to decompress snapshots for Mandragora, ITRocket, and Josephtran
decompress_snapshots() {
    lz4 -c -d $GETH_SNAPSHOT_FILE | tar -xv -C $HOME/.story/geth/odyssey/geth
    lz4 -c -d $STORY_SNAPSHOT_FILE | tar -xv -C $HOME/.story/story
}

# Function to decompress snapshot for CroutonDigital
decompress_crouton_snapshot() {
    lz4 -c -d $CROUTON_SNAPSHOT_FILE | tar -xv -C $HOME/.story
}

# Function to prompt user to back or continue
prompt_back_or_continue() {
    read -p "Press Enter to continue or type 'back' to go back to the menu: " user_choice
    if [[ $user_choice == "back" ]]; then
        main_script
    fi
}

# Main script
main_script() {
    show_menu
    read -p "Enter your choice: " provider_choice

    provider_name=""

    case $provider_choice in
        1)
            provider_name="Mandragora"
            echo -e "Grand Valley extends its gratitude to ${GREEN}$provider_name${NC} for providing snapshot support."

            echo -e "${GREEN}Checking availability of Mandragora snapshots:${NC}"
            echo -n "Pruned GETH Snapshot: "
            check_url $MAND_PRUNED_GETH_SNAPSHOT_URL
            echo -n "Pruned STORY Snapshot: "
            check_url $MAND_PRUNED_STORY_SNAPSHOT_URL
            echo -n "Archive GETH Snapshot: "
            check_url $MAND_ARCHIVE_GETH_SNAPSHOT_URL
            echo -n "Archive STORY Snapshot: "
            check_url $MAND_ARCHIVE_STORY_SNAPSHOT_URL

            prompt_back_or_continue

            choose_mandragora_snapshot
            GETH_SNAPSHOT_FILE="geth_snapshot.lz4"
            STORY_SNAPSHOT_FILE="story_snapshot.lz4"
            ;;
        2)
            provider_name="ITRocket"
            echo -e "Grand Valley extends its gratitude to ${GREEN}$provider_name${NC} for providing snapshot support."

            echo -e "${GREEN}Checking availability of ITRocket snapshots:${NC}"
            echo -n "Pruned GETH Snapshot: "
            check_url $ITR_PRUNED_GETH_SNAPSHOT_URL
            echo -n "Pruned STORY Snapshot: "
            check_url $ITR_PRUNED_STORY_SNAPSHOT_URL
            echo -n "Archive GETH Snapshot: "
            check_url $ITR_ARCHIVE_GETH_SNAPSHOT_URL
            echo -n "Archive STORY Snapshot: "
            check_url $ITR_ARCHIVE_STORY_SNAPSHOT_URL

            prompt_back_or_continue

            choose_itrocket_snapshot
            GETH_SNAPSHOT_FILE="geth_snapshot.tar.lz4"
            STORY_SNAPSHOT_FILE="story_snapshot.tar.lz4"
            ;;
        3)
            provider_name="CroutonDigital"
            echo -e "Grand Valley extends its gratitude to ${GREEN}$provider_name${NC} for providing snapshot support."

            echo -e "${GREEN}Checking availability of CroutonDigital snapshot:${NC}"
            echo -n "Archive Snapshot: "
            check_url $CROUTON_SNAPSHOT_URL

            prompt_back_or_continue

            CROUTON_SNAPSHOT_FILE="story_latest.tar.lz4"
            ;;
        4)
            provider_name="Josephtran"
            echo -e "Grand Valley extends its gratitude to ${GREEN}$provider_name${NC} for providing snapshot support."

            echo -e "${GREEN}Checking availability of Josephtran snapshots:${NC}"
            echo -n "Pruned GETH Snapshot: "
            check_url $JOSEPHTRAN_PRUNED_GETH_SNAPSHOT_URL
            echo -n "Pruned STORY Snapshot: "
            check_url $JOSEPHTRAN_PRUNED_STORY_SNAPSHOT_URL
            echo -n "Archive GETH Snapshot: "
            check_url $JOSEPHTRAN_ARCHIVE_GETH_SNAPSHOT_URL
            echo -n "Archive STORY Snapshot: "
            check_url $JOSEPHTRAN_ARCHIVE_STORY_SNAPSHOT_URL

            prompt_back_or_continue

            choose_josephtran_snapshot
            GETH_SNAPSHOT_FILE="Geth_snapshot.lz4"
            STORY_SNAPSHOT_FILE="Story_snapshot.lz4"
            ;;
        5)
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

    # Download and decompress snapshots based on the provider
    if [[ $provider_choice -eq 1 || $provider_choice -eq 2 || $provider_choice -eq 4 ]]; then
        wget -O $GETH_SNAPSHOT_FILE $GETH_SNAPSHOT_URL
        wget -O $STORY_SNAPSHOT_FILE $STORY_SNAPSHOT_URL
        decompress_snapshots
    elif [[ $provider_choice -eq 3 ]]; then
        wget -O $CROUTON_SNAPSHOT_FILE $CROUTON_SNAPSHOT_URL
        decompress_crouton_snapshot
    fi

    # Change ownership of the .story directory
    sudo chown -R $USER:$USER $HOME/.story

    # Ask the user if they want to delete the downloaded snapshot files
    read -p "Do you want to delete the downloaded snapshot files? (y/n): " delete_choice

    if [[ $delete_choice == "y" || $delete_choice == "Y" ]]; then
        # Delete downloaded snapshot files
        if [[ $provider_choice -eq 1 || $provider_choice -eq 2 || $provider_choice -eq 4 ]]; then
            sudo rm -v $GETH_SNAPSHOT_FILE $STORY_SNAPSHOT_FILE
        elif [[ $provider_choice -eq 3 ]]; then
            sudo rm -v $CROUTON_SNAPSHOT_FILE
        fi
        echo -e "${GREEN}Downloaded snapshot files have been deleted.${NC}"
    else
        echo -e "${GREEN}Downloaded snapshot files have been kept.${NC}"
    fi

    # Restore your validator state
    sudo cp $HOME/.story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

    # Start your story-geth and story nodes
    sudo systemctl restart story-geth story

    echo -e "${GREEN}Snapshot setup completed successfully.${NC}"
}

main_script
