#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Snapshot URLs
ITR_API_URL="https://server-5.itrocket.net/testnet/og/.current_state.json"
JOSEPHTRAN_PRUNED_SNAPSHOT_URL="https://josephtran.co/light_0gchain_snapshot.lz4"
JOSEPHTRAN_ARCHIVE_SNAPSHOT_URL="https://josephtran.co/0gchain_snapshot.lz4"

# Function to display the menu
show_menu() {
    echo -e "${GREEN}Choose a snapshot provider:${NC}"
    echo "1. ITRocket"
    echo "2. Josephtran (J•Node)"
    echo "3. Exit"
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

# Function to display snapshot details
display_snapshot_details() {
    local api_url=$1
    local snapshot_info=$(curl -s $api_url)
    local snapshot_height=$(echo "$snapshot_info" | jq -r '.snapshot_height')

    echo -e "${GREEN}Snapshot Height:${NC} $snapshot_height"

    # Get the real-time block height
    realtime_block_height=$(curl -s -X POST "https://lightnode-json-rpc-0g.grandvalleys.com" -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r '.result' | xargs printf "%d\n")

    # Calculate the difference
    block_difference=$((realtime_block_height - snapshot_height))

    echo -e "${GREEN}Real-time Block Height:${NC} $realtime_block_height"
    echo -e "${GREEN}Block Difference:${NC} $block_difference"
}

# Function to choose snapshot type for ITRocket
choose_itrocket_snapshot() {
    echo -e "${GREEN}Checking availability of ITRocket snapshot:${NC}"
    echo -n "Pruned Snapshot: "
    check_url $ITR_API_URL

    prompt_back_or_continue

    echo -e "${GREEN}Choose the type of snapshot for ITRocket:${NC}"
    echo "1. Pruned"
    read -p "Enter your choice: " snapshot_type_choice

    case $snapshot_type_choice in
        1)
            SNAPSHOT_API_URL=$ITR_API_URL
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac

    FILE_NAME=$(curl -s $SNAPSHOT_API_URL | jq -r '.snapshot_name')
    SNAPSHOT_URL="https://server-5.itrocket.net/testnet/og/$FILE_NAME"

    display_snapshot_details $ITR_API_URL

    prompt_back_or_continue
}

# Function to choose snapshot type for Josephtran
choose_josephtran_snapshot() {
    echo -e "${GREEN}Choose the type of snapshot for Josephtran:${NC}"
    echo "1. Pruned"
    echo "2. Archive"
    read -p "Enter your choice: " snapshot_type_choice

    case $snapshot_type_choice in
        1)
            SNAPSHOT_URL=$JOSEPHTRAN_PRUNED_SNAPSHOT_URL
            ;;
        2)
            SNAPSHOT_URL=$JOSEPHTRAN_ARCHIVE_SNAPSHOT_URL
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac
}

# Function to decompress snapshots
decompress_snapshot() {
    lz4 -c -d $SNAPSHOT_FILE | tar -xv -C $HOME/.0gchain
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
            provider_name="ITRocket"
            echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

            choose_itrocket_snapshot
            SNAPSHOT_FILE=$FILE_NAME
            ;;
        2)
            provider_name="Josephtran"
            echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

            echo -e "${GREEN}Checking availability of Josephtran snapshots:${NC}"
            echo -n "Pruned Snapshot: "
            check_url $JOSEPHTRAN_PRUNED_SNAPSHOT_URL
            echo -n "Archive Snapshot: "
            check_url $JOSEPHTRAN_ARCHIVE_SNAPSHOT_URL

            prompt_back_or_continue

            choose_josephtran_snapshot
            SNAPSHOT_FILE="0gchain_snapshot.lz4"
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
    sudo rm -f $HOME/.0gchain/data/upgrade-info.json

    cd $HOME

    # Install required dependencies
    sudo apt-get install wget lz4 jq -y

    # Stop your 0gchain nodes
    sudo systemctl stop $SERVICE_FILE_NAME

    # Back up your validator state
    mv $HOME/.0gchain/data/priv_validator_state.json $HOME/.0gchain/priv_validator_state.json.backup

    # Delete previous 0gchain data folders
    sudo rm -rf $HOME/.0gchain/data

    # Download and decompress snapshot
    wget -O $SNAPSHOT_FILE $SNAPSHOT_URL
    decompress_snapshot

    # Change ownership of the .0gchain directory
    sudo chown -R $USER:$USER $HOME/.0gchain

    # Ask the user if they want to delete the downloaded snapshot files
    read -p "Do you want to delete the downloaded snapshot files? (y/n): " delete_choice

    if [[ $delete_choice == "y" || $delete_choice == "Y" ]]; then
        # Delete downloaded snapshot files
        sudo rm -v $SNAPSHOT_FILE
        echo -e "${GREEN}Downloaded snapshot files have been deleted.${NC}"
    else
        echo -e "${GREEN}Downloaded snapshot files have been kept.${NC}"
    fi

    # Restore your validator state
    cp $HOME/.0gchain/priv_validator_state.json.backup $HOME/.0gchain/data/priv_validator_state.json

    # Migrate to Cosmovisor
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20\(zero-gravity\)/resources/cosmovisor_migration.sh)

    # Start your 0gchain nodes
    sudo systemctl restart $SERVICE_FILE_NAME

    echo -e "${GREEN}Snapshot setup completed successfully.${NC}"
}

main_script
