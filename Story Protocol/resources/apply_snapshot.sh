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

MAND_PRUNED_API_URL="https://snapshots2.mandragora.io/story/info.json"
MAND_ARCHIVE_API_URL="https://snapshots.mandragora.io/info.json"

ITR_PRUNED_API_URL_1="https://server-1.itrocket.net/testnet/story/.current_state.json"
ITR_ARCHIVE_API_URL_1="https://server-8.itrocket.net/testnet/story/.current_state.json"
ITR_PRUNED_API_URL_2="https://server-3.itrocket.net/testnet/story/.current_state.json"
ITR_ARCHIVE_API_URL_2="https://server-5.itrocket.net/testnet/story/.current_state.json"

CROUTON_SNAPSHOT_URL="https://storage.crouton.digital/testnet/story/snapshots/story_latest.tar.lz4"

JOSEPHTRAN_PRUNED_GETH_SNAPSHOT_URL="https://story.josephtran.co/Geth_snapshot.lz4"
JOSEPHTRAN_PRUNED_STORY_SNAPSHOT_URL="https://story.josephtran.co/Story_snapshot.lz4"
JOSEPHTRAN_ARCHIVE_GETH_SNAPSHOT_URL="https://story.josephtran.co/archive_Geth_snapshot.lz4"
JOSEPHTRAN_ARCHIVE_STORY_SNAPSHOT_URL="https://story.josephtran.co/archive_Story_snapshot.lz4"

ORIGINSTAKE_PRUNED_API_URL="https://snapshot.originstake.com/story_snapshot_metadata.json"
ORIGINSTAKE_ARCHIVE_API_URL="https://snapshot.originstake.com/full/story_full_snapshot_metadata.json"

# Function to display the menu
show_menu() {
    echo -e "${GREEN}Choose a snapshot provider:${NC}"
    echo "1. Mandragora"
    echo "2. ITRocket"
    echo "3. CroutonDigital"
    echo "4. Josephtran (J•Node)"
    echo "5. OriginStake"
    echo "6. Exit"
}

# Function to check if a URL is available
check_url() {
    local url=$1
    if curl --output /dev/null --silent --head --fail "$url"; then
        echo -e "${GREEN}Available${NC}"
    else
        echo -e "${RED}Not available at the moment${NC}"
        return 1
    fi
}

# Function to display snapshot details
display_snapshot_details() {
    local api_url=$1
    local snapshot_info=$(curl -s $api_url)
    local snapshot_height

    if [[ $api_url == *"mandragora"* ]]; then
        snapshot_height=$(echo "$snapshot_info" | grep -oP '"snapshot_height":\s*\K\d+')
    elif [[ $api_url == *"originstake"* ]]; then
        snapshot_height=$(echo "$snapshot_info" | jq -r '.height')
    else
        snapshot_height=$(echo "$snapshot_info" | jq -r '.snapshot_height')
    fi

    echo -e "${GREEN}Snapshot Height:${NC} $snapshot_height"
}

# Function to choose snapshot type for Mandragora
choose_mandragora_snapshot() {
    echo -e "${GREEN}Choose the type of snapshot for Mandragora:${NC}"
    echo "1. Pruned"
    echo "2. Archive"
    read -p "Enter your choice: " snapshot_type_choice

    case $snapshot_type_choice in
        1)
            SNAPSHOT_API_URL=$MAND_PRUNED_API_URL
            ;;
        2)
            SNAPSHOT_API_URL=$MAND_ARCHIVE_API_URL
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac

    display_snapshot_details $SNAPSHOT_API_URL

    prompt_back_or_continue

    GETH_SNAPSHOT_URL=$MAND_PRUNED_GETH_SNAPSHOT_URL
    STORY_SNAPSHOT_URL=$MAND_PRUNED_STORY_SNAPSHOT_URL
}

# Function to choose snapshot type for ITRocket
choose_itrocket_snapshot() {
    echo -e "${GREEN}Choose the type of snapshot for ITRocket:${NC}"
    echo "1. Pruned"
    echo "2. Archive"
    read -p "Enter your choice: " snapshot_type_choice

    case $snapshot_type_choice in
        1)
            echo -e "${GREEN}Checking availability and details of Pruned snapshots:${NC}"
            echo -n "Pruned Snapshot (Server 1): "
            check_url $ITR_PRUNED_API_URL_1
            if [[ $? -eq 0 ]]; then
                display_snapshot_details $ITR_PRUNED_API_URL_1
            fi
            echo -n "Pruned Snapshot (Server 2): "
            check_url $ITR_PRUNED_API_URL_2
            if [[ $? -eq 0 ]]; then
                display_snapshot_details $ITR_PRUNED_API_URL_2
            fi

            echo -e "${GREEN}Choose the server for Pruned snapshot:${NC}"
            echo "1. Server 1"
            echo "2. Server 2"
            read -p "Enter your choice: " server_choice

            case $server_choice in
                1)
                    SNAPSHOT_API_URL=$ITR_PRUNED_API_URL_1
                    ;;
                2)
                    SNAPSHOT_API_URL=$ITR_PRUNED_API_URL_2
                    ;;
                *)
                    echo -e "${RED}Invalid choice. Exiting.${NC}"
                    exit 1
                    ;;
            esac
            ;;
        2)
            echo -e "${GREEN}Checking availability and details of Archive snapshots:${NC}"
            echo -n "Archive Snapshot (Server 1): "
            check_url $ITR_ARCHIVE_API_URL_1
            if [[ $? -eq 0 ]]; then
                display_snapshot_details $ITR_ARCHIVE_API_URL_1
            fi
            echo -n "Archive Snapshot (Server 2): "
            check_url $ITR_ARCHIVE_API_URL_2
            if [[ $? -eq 0 ]]; then
                display_snapshot_details $ITR_ARCHIVE_API_URL_2
            fi

            echo -e "${GREEN}Choose the server for Archive snapshot:${NC}"
            echo "1. Server 1"
            echo "2. Server 2"
            read -p "Enter your choice: " server_choice

            case $server_choice in
                1)
                    SNAPSHOT_API_URL=$ITR_ARCHIVE_API_URL_1
                    ;;
                2)
                    SNAPSHOT_API_URL=$ITR_ARCHIVE_API_URL_2
                    ;;
                *)
                    echo -e "${RED}Invalid choice. Exiting.${NC}"
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac

    prompt_back_or_continue

    FILE_NAME=$(curl -s $SNAPSHOT_API_URL | jq -r '.snapshot_name')
    GETH_FILE_NAME=$(curl -s $SNAPSHOT_API_URL | jq -r '.snapshot_geth_name')
    GETH_SNAPSHOT_URL="https://server-3.itrocket.net/testnet/story/$GETH_FILE_NAME"
    STORY_SNAPSHOT_URL="https://server-3.itrocket.net/testnet/story/$FILE_NAME"
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

    prompt_back_or_continue
}

# Function to choose snapshot type for OriginStake
choose_originstake_snapshot() {
    echo -e "${GREEN}Choose the type of snapshot for OriginStake:${NC}"
    echo "1. Pruned"
    echo "2. Archive"
    read -p "Enter your choice: " snapshot_type_choice

    case $snapshot_type_choice in
        1)
            SNAPSHOT_API_URL=$ORIGINSTAKE_PRUNED_API_URL
            ;;
        2)
            SNAPSHOT_API_URL=$ORIGINSTAKE_ARCHIVE_API_URL
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac

    display_snapshot_details $SNAPSHOT_API_URL

    prompt_back_or_continue

    FILE_NAME=$(curl -s $SNAPSHOT_API_URL | jq -r '.name')
    SNAPSHOT_URL="https://snapshot.originstake.com/$FILE_NAME"
}

# Function to decompress snapshots for Mandragora, ITRocket, and Josephtran
decompress_snapshots() {
    lz4 -c -d $GETH_SNAPSHOT_FILE | tar -xv -C $HOME/.story/geth/odyssey/geth
    lz4 -c -d $STORY_SNAPSHOT_FILE | tar -xv -C $HOME/.story/story
}

# Function to decompress snapshot for CroutonDigital and OriginStake
decompress_crouton_originstake_snapshot() {
    lz4 -c -d $SNAPSHOT_FILE | tar -xv -C $HOME/.story
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
            echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

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
            echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

            echo -e "${GREEN}Checking availability of ITRocket snapshots:${NC}"
            echo -n "Pruned Snapshot (Server 1): "
            check_url $ITR_PRUNED_API_URL_1
            echo -n "Archive Snapshot (Server 1): "
            check_url $ITR_ARCHIVE_API_URL_1
            echo -n "Pruned Snapshot (Server 2): "
            check_url $ITR_PRUNED_API_URL_2
            echo -n "Archive Snapshot (Server 2): "
            check_url $ITR_ARCHIVE_API_URL_2

            prompt_back_or_continue

            choose_itrocket_snapshot
            GETH_SNAPSHOT_FILE=$GETH_FILE_NAME
            STORY_SNAPSHOT_FILE=$FILE_NAME
            ;;
        3)
            provider_name="CroutonDigital"
            echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

            echo -e "${GREEN}Checking availability of CroutonDigital snapshot:${NC}"
            echo -n "Archive Snapshot: "
            check_url $CROUTON_SNAPSHOT_URL

            prompt_back_or_continue

            CROUTON_SNAPSHOT_FILE="story_latest.tar.lz4"
            SNAPSHOT_URL=$CROUTON_SNAPSHOT_URL
            ;;
        4)
            provider_name="Josephtran"
            echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

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
            provider_name="OriginStake"
            echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

            echo -e "${GREEN}Checking availability of OriginStake snapshots:${NC}"
            echo -n "Pruned Snapshot: "
            check_url $ORIGINSTAKE_PRUNED_API_URL
            echo -n "Archive Snapshot: "
            check_url $ORIGINSTAKE_ARCHIVE_API_URL

            prompt_back_or_continue

            choose_originstake_snapshot
            SNAPSHOT_FILE=$FILE_NAME
            SNAPSHOT_URL=$SNAPSHOT_URL
            ;;
        6)
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
    sudo apt-get install wget lz4 jq -y

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
    elif [[ $provider_choice -eq 3 || $provider_choice -eq 5 ]]; then
        wget -O $SNAPSHOT_FILE $SNAPSHOT_URL
        decompress_crouton_originstake_snapshot
    fi

    # Change ownership of the .story directory
    sudo chown -R $USER:$USER $HOME/.story

    # Ask the user if they want to delete the downloaded snapshot files
    read -p "Do you want to delete the downloaded snapshot files? (y/n): " delete_choice

    if [[ $delete_choice == "y" || $delete_choice == "Y" ]]; then
        # Delete downloaded snapshot files
        if [[ $provider_choice -eq 1 || $provider_choice -eq 2 || $provider_choice -eq 4 ]]; then
            sudo rm -v $GETH_SNAPSHOT_FILE $STORY_SNAPSHOT_FILE
        elif [[ $provider_choice -eq 3 || $provider_choice -eq 5 ]]; then
            sudo rm -v $SNAPSHOT_FILE
        fi
        echo -e "${GREEN}Downloaded snapshot files have been deleted.${NC}"
    else
        echo -e "${GREEN}Downloaded snapshot files have been kept.${NC}"
    fi

    # Restore your validator state
    sudo cp $HOME/.story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

    # Update version
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/Story%20Protocol/resources/story_update.sh)

    # Start your story-geth and story nodes
    sudo systemctl restart story-geth story

    echo -e "${GREEN}Snapshot setup completed successfully.${NC}"
}

main_script
