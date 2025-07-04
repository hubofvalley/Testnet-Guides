#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Snapshot API URLs
ITR_API_URL="https://server-3.itrocket.net/testnet/og/.current_state.json"

# Function to display snapshot details
display_snapshot_details() {
    local api_url=$1
    local snapshot_info=$(curl -s $api_url)
    local snapshot_height=$(echo "$snapshot_info" | jq -r '.snapshot_height')

    echo -e "${GREEN}Snapshot Height:${NC} $snapshot_height"

    realtime_block_height=$(curl -s -X POST "https://lightnode-json-rpc-0g.grandvalleys.com" -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r '.result' | xargs printf "%d\n")
    block_difference=$((realtime_block_height - snapshot_height))
    echo -e "${GREEN}Real-time Block Height:${NC} $realtime_block_height"
    echo -e "${GREEN}Block Difference:${NC} $block_difference"
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

# Function to prompt user to back or continue
prompt_back_or_continue() {
    read -p "Press Enter to continue or type 'back' to go back to the menu: " user_choice
    if [[ $user_choice == "back" ]]; then
        main_script
    fi
}

# Function to download and decompress snapshots from ITRocket
extract_itrocket_snapshots() {
    mkdir -p "$EXEC_DIR"
    mkdir -p "$CONS_DIR"

    echo -e "${GREEN}Decompressing Execution Snapshot...${NC}"
    if ! curl "$GETH_URL" | lz4 -dc - | tar -xf - -C "$EXEC_DIR"; then
        echo -e "${RED}Failed to extract execution snapshot. Please check the archive structure or disk space.${NC}"
        exit 1
    fi

    echo -e "${GREEN}Decompressing Consensus Snapshot...${NC}"
    if ! curl "$CONS_URL" | lz4 -dc - | tar -xf - -C "$CONS_DIR"; then
        echo -e "${RED}Failed to extract consensus snapshot. Please check the archive structure or disk space.${NC}"
        exit 1
    fi
}

# Function to apply ITRocket snapshot
choose_itrocket_snapshot() {
    echo -e "${GREEN}ITRocket snapshot selected.${NC}"
    echo -e "Grand Valley extends its gratitude to ${YELLOW}ITRocket${NC} for providing snapshot support."

    echo -e "${GREEN}Checking availability of ITRocket snapshot:${NC}"

    SNAPSHOT_INFO=$(curl -s $ITR_API_URL)
    GETH_FILE=$(echo "$SNAPSHOT_INFO" | jq -r '.snapshot_geth_name')
    CONS_FILE=$(echo "$SNAPSHOT_INFO" | jq -r '.snapshot_name')

    GETH_URL="https://server-3.itrocket.net/testnet/og/$GETH_FILE"
    CONS_URL="https://server-3.itrocket.net/testnet/og/$CONS_FILE"

    echo -n "Execution Client (0g-geth) Snapshot: "
    check_url $GETH_URL
    echo -n "Consensus Client (0gchaind) Snapshot: "
    check_url $CONS_URL

    prompt_back_or_continue

    display_snapshot_details $ITR_API_URL

    read -p "Enter the directory where you want to download the snapshots (default is $HOME): " download_location
    download_location=${download_location:-$HOME}
    read -p "When the snapshot has been applied (decompressed), do you want to delete the downloaded files? (y/n): " delete_choice
    mkdir -p "$download_location"
    cd "$download_location"

    sudo apt install wget lz4 jq -y

    EXEC_DIR="$HOME/.0gchaind/0g-home/geth-home/geth"
    CONS_DIR="$HOME/.0gchaind/0g-home/0gchaind-home"

    sudo systemctl stop 0gchaind 0g-geth || sudo systemctl stop 0gchaind 0ggeth
    sudo systemctl disable 0gchaind 0g-geth || sudo systemctl disable 0gchaind 0ggeth

    if [ -f "$CONS_DIR/data/priv_validator_state.json" ]; then
        cp "$CONS_DIR/data/priv_validator_state.json" "$HOME/.0gchaind/priv_validator_state.json.backup"
    else
        echo -e "${YELLOW}priv_validator_state.json not found. Skipping backup.${NC}"
    fi

    rm -rf "$EXEC_DIR/chaindata" "$CONS_DIR/data"

    extract_itrocket_snapshots

    sudo chown -R $USER:$USER "$HOME/.0gchaind"

    if [[ $delete_choice == "y" || $delete_choice == "Y" ]]; then
        echo -e "${YELLOW}Files were streamed directly and not saved locally.${NC}"
    else
        echo -e "${YELLOW}No local snapshot files to retain; they were streamed during extraction.${NC}"
    fi

    if [ -f "$HOME/.0gchaind/priv_validator_state.json.backup" ]; then
        mkdir -p "$CONS_DIR/data"
        cp "$HOME/.0gchaind/priv_validator_state.json.backup" "$CONS_DIR/data/priv_validator_state.json"
    fi

    sudo systemctl enable 0gchaind 0g-geth || sudo systemctl enable 0gchaind 0ggeth
    sudo systemctl restart 0gchaind 0g-geth || sudo systemctl restart 0gchaind 0ggeth

    echo -e "${GREEN}0G snapshot setup completed successfully.${NC}"
}

main_script() {
    echo -e "${GREEN}Choose a snapshot provider:${NC}"
    echo "1. ITRocket"
    echo "2. Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            choose_itrocket_snapshot
            ;;
        2)
            echo -e "${YELLOW}Exiting.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Exiting.${NC}"
            exit 1
            ;;
    esac
}

main_script

echo "Let's Buidl 0G Together"
