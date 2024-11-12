#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RESET='\033[0m'

LOGO="
 __      __     _  _                        __    _____  _                      
 \ \    / /    | || |                      / _|  / ____|| |                     
  \ \  / /__ _ | || |  ___  _   _    ___  | |_  | (___  | |_  ___   _ __  _   _ 
  _\ \/ // __ || || | / _ \| | | |  / _ \ |  _|  \___ \ | __|/ _ \ | '__|| | | |
 | |\  /| (_| || || ||  __/| |_| | | (_) || |    ____) || |_| (_) || |   | |_| |
 | |_\/  \__,_||_||_| \___| \__, |  \___/ |_|   |_____/  \__|\___/ |_|    \__, |
 | '_ \ | | | |              __/ |                                         __/ |
 | |_) || |_| |             |___/                                         |___/
 |____/  \__, |                                                                 
          __/ |                                                                 
         |___/                                                                  
 __                                   
/__ __ __ __   _|   \  / __ | |  _    
\_| | (_| | | (_|    \/ (_| | | (/_ \/
                                    /
"

INTRO="
Valley Of Story by Grand Valley

${GREEN}Story Validator Node System Requirements${RESET}
${YELLOW}| Category  | Requirements     |
| --------- | ---------------- |
| CPU       | 8+ cores         |
| RAM       | 32+ GB           |
| Storage   | 500+ GB NVMe SSD |
| Bandwidth | 100+ MBit/s      |${RESET}

- consensus client service file name: ${CYAN}story.service${RESET}
- geth service file name: ${CYAN}story-geth.service${RESET}
- current chain: ${CYAN}odyssey${RESET}
- current story node version: ${CYAN}v0.12.0${RESET}
- current story-geth node version: ${CYAN}v0.10.0${RESET}
"

ENDPOINTS="${GREEN}
Grand Valley Story Protocol public endpoints:${RESET}
- cosmos-rpc: ${BLUE}https://lightnode-rpc-story.grandvalleys.com${RESET}
- evm-rpc: ${BLUE}https://lightnode-json-rpc-story.grandvalleys.com${RESET}
- cosmos rest-api: ${BLUE}https://lightnode-api-story.grandvalleys.com${RESET}
- cosmos ws: ${BLUE}wss://lightnode-rpc-story.grandvalleys.com/websocket${RESET}
- evm ws: ${BLUE}wss://lightnode-wss-story.grandvalleys.com${RESET}

${GREEN}Connect with Story Protocol:${RESET}
- Official Website: ${BLUE}https://www.story.foundation${RESET}
- X: ${BLUE}https://x.com/StoryProtocol${RESET}
- Official Docs: ${BLUE}https://docs.story.foundation${RESET}

${GREEN}Connect with Grand Valley:${RESET}
- X: ${BLUE}https://x.com/bacvalley${RESET}
- GitHub: ${BLUE}https://github.com/hubofvalley${RESET}
- Email: ${BLUE}letsbuidltogether@grandvalleys.com${RESET}
"

# Display LOGO and wait for user input to continue
echo -e "$LOGO"
echo -e "\n${YELLOW}Press Enter to continue...${RESET}"
read -r

# Display INTRO section and wait for user input to continue
echo -e "$INTRO"
echo -e "$ENDPOINTS"
echo -e "\n${YELLOW}Press Enter to continue${RESET}"
read -r
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile
echo "export STORY_CHAIN_ID="odyssey"" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Function to update to a specific version
function update_geth() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/Story%20Protocol/resources/story-geth_update.sh)
    menu
}

# Validator Node Functions
function deploy_validator_node() {
    echo -e "${CYAN}Deploying Validator Node...${RESET}"
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/Story%20Protocol/resources/story_validator_node_install_odyssey.sh)
    menu
}

function create_validator() {
    # Check if bc is installed, if not, install it
    if ! command -v bc &> /dev/null; then
        echo "bc is not installed. Installing bc..."
        sudo apt-get update
        sudo apt-get install bc
    fi

    read -p "Enter your private key (or press Enter to use local private key): " PRIVATE_KEY
    if [ -z "$PRIVATE_KEY" ]; then
        PRIVATE_KEY=$(grep -oP '(?<=PRIVATE_KEY=).*' $HOME/.story/story/config/private_key.txt)
    fi

    read -p "Enter the moniker for your validator: " MONIKER

    read -p "Enter the amount to be staked in IP (e.g., 1024 for 1024 IP, minimum requirement is 1024 IP): " STAKE_IP

    # Convert IP to the required format (assuming 1 IP = 10^18 units)
    MIN_STAKE=1024
    if [ "$STAKE_IP" -lt "$MIN_STAKE" ]; then
        echo "The stake amount is below the minimum requirement of 1024 IP."
        menu
        return
    fi

    # Convert the stake from IP to the required unit format
    STAKE=$(echo "$STAKE_IP * 10^18" | bc)

    story validator create --stake "$STAKE" --moniker "$MONIKER" --private-key "$PRIVATE_KEY" --chain-id 1516
    menu
}

function query_validator_pub_key() {
    story validator export | grep -oP 'Compressed Public Key \(hex\): \K[0-9a-fA-F]+'
    menu
}

function query_balance() {
    echo -e "${CYAN}Select an option:${RESET}"
    echo "1. Query balance of your own EVM address"
    echo "2. Query balance of another EVM address"
    echo "3. Back"
    read -p "Enter your choice (1, 2, or 3): " choice

    case $choice in
        1)
            echo -e "${GREEN}Querying balance of your own EVM address...${RESET}"
            geth --exec "eth.getBalance('$(story validator export | grep -oP '(?<=EVM Address: ).*')')" attach $HOME/.story/geth/odyssey/geth.ipc
            ;;
        2)
            read -p "Enter the EVM address to query: " evm_address
            echo -e "${GREEN}Querying balance of $evm_address...${RESET}"
            geth --exec "eth.getBalance('$evm_address')" attach $HOME/.story/geth/odyssey/geth.ipc
            ;;
        3)
            menu
            ;;
        *)
            echo -e "${RED}Invalid choice. Please enter 1, 2, or 3.${RESET}"
            query_balance
            ;;
    esac
    menu
}

function stake_tokens() {
    # Check if bc is installed, if not, install it
    if ! command -v bc &> /dev/null; then
        echo "bc is not installed. Installing bc..."
        sudo apt-get update
        sudo apt-get install bc
    fi

    echo "Choose an option to delegate tokens:"
    echo "1. Delegate to Grand Valley"
    echo "2. Delegate to self"
    echo "3. Delegate to another validator"
    echo "4. Back"
    read -p "Enter your choice (1/2/3/4): " CHOICE

    case $CHOICE in
        1)
            VALIDATOR_PUBKEY="036a75cfa84cf485e5b4a6844fa9f2ff03f410f7c8c0148f4e4c9e535df9caba22"
            ;;
        2)
            VALIDATOR_PUBKEY=$(story validator export | grep -oP 'Compressed Public Key \(hex\): \K[0-9a-fA-F]+')
            ;;
        3)
            read -p "Enter validator pubkey: " VALIDATOR_PUBKEY
            ;;
        4)
            menu
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            stake_tokens
            ;;
    esac

    echo "Choose the RPC to use:"
    echo "1. Use default RPC"
    echo "2. Use Grand Valley's RPC"
    read -p "Enter your choice (1/2): " RPC_CHOICE

    read -p "Enter the amount to stake in IP (e.g., 1024 for 1024 IP, minimum requirement is 1024 IP): " AMOUNT_IP

    # Convert IP to the required format (assuming 1 IP = 10^18 units)
    AMOUNT=$(echo "$AMOUNT_IP * 10^18" | bc)

    read -p "Enter private key (leave blank to use local private key): " PRIVATE_KEY

    if [ -n "$PRIVATE_KEY" ]; then
        PRIVATE_KEY_FLAG="--private-key $PRIVATE_KEY"
    else
        PRIVATE_KEY_FLAG="--private-key $(grep -oP '(?<=PRIVATE_KEY=).*' $HOME/.story/story/config/private_key.txt)"
    fi

    if [ "$RPC_CHOICE" == "2" ]; then
        story validator stake --validator-pubkey $VALIDATOR_PUBKEY --stake $AMOUNT $PRIVATE_KEY_FLAG --rpc https://lightnode-json-rpc-story.grandvalleys.com:443 --chain-id 1516
    elif [ "$RPC_CHOICE" == "1" ]; then
        story validator stake --validator-pubkey $VALIDATOR_PUBKEY --stake $AMOUNT $PRIVATE_KEY_FLAG --chain-id 1516
    else
        echo "Invalid choice. Please select a valid option."
        stake_tokens
    fi

    menu
}

function unstake_tokens() {
    # Check if bc is installed, if not, install it
    if ! command -v bc &> /dev/null; then
        echo "bc is not installed. Installing bc..."
        sudo apt-get update
        sudo apt-get install bc
    fi

    echo "Choose an option to unstake tokens:"
    echo "1. Unstake from self"
    echo "2. Unstake from another validator"
    echo "3. Back"
    read -p "Enter your choice (1/2/3): " CHOICE

    case $CHOICE in
        1)
            VALIDATOR_PUBKEY=$(story validator export | grep -oP 'Compressed Public Key \(hex\): \K[0-9a-fA-F]+')
            ;;
        2)
            read -p "Enter validator pubkey: " VALIDATOR_PUBKEY
            ;;
        3)
            menu
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            unstake_tokens
            ;;
    esac

    echo "Choose the RPC to use:"
    echo "1. Use default RPC"
    echo "2. Use Grand Valley's RPC"
    read -p "Enter your choice (1/2): " RPC_CHOICE

    read -p "Enter the amount to unstake in IP (e.g., 1024 for 1024 IP, minimum requirement is 1024 IP): " AMOUNT_IP

    # Convert IP to the required format (assuming 1 IP = 10^18 units)
    AMOUNT=$(echo "$AMOUNT_IP * 10^18" | bc)

    read -p "Enter private key (leave blank to use local private key): " PRIVATE_KEY

    if [ -n "$PRIVATE_KEY" ]; then
        PRIVATE_KEY_FLAG="--private-key $PRIVATE_KEY"
    else
        PRIVATE_KEY_FLAG="--private-key $(grep -oP '(?<=PRIVATE_KEY=).*' $HOME/.story/story/config/private_key.txt)"
    fi

    if [ "$RPC_CHOICE" == "2" ]; then
        story validator unstake --validator-pubkey $VALIDATOR_PUBKEY --unstake $AMOUNT $PRIVATE_KEY_FLAG --rpc https://lightnode-json-rpc-story.grandvalleys.com:443 --chain-id 1516
    elif [ "$RPC_CHOICE" == "1" ]; then
        story validator unstake --validator-pubkey $VALIDATOR_PUBKEY --unstake $AMOUNT $PRIVATE_KEY_FLAG --chain-id 1516
    else
        echo "Invalid choice. Please select a valid option."
        unstake_tokens
    fi

    menu
}

function export_evm_key() {
    echo -e "${CYAN}Query all of your current EVM key addresses including your EVM private key${RESET}"
    story validator export --evm-key-path $HOME/.story/story/config/private_key.txt --export-evm-key
    cat $HOME/.story/story/config/private_key.txt
    echo
    menu
}

function delete_validator_node() {
    sudo systemctl stop story story-geth
    sudo systemctl disable story story-geth
    sudo rm -rf /etc/systemd/system/story.service
    sudo rm -rf /etc/systemd/system/story-geth.service
    sudo rm -rf $HOME/.story
    sed -i "/STORY_/d" $HOME/.bash_profile
    echo -e "${RED}Story Validator node deleted successfully.${RESET}"
    menu
}

function stop_validator_node() {
    sudo systemctl stop story story-geth
    echo "Consensus client and Geth service stopped."
    menu
}

function restart_validator_node() {
    sudo systemctl daemon-reload
    sudo rm -f $HOME/.story/story/data/upgrade-info.json
    sudo systemctl restart story story-geth
    echo "Consensus client and Geth service restarted."
    menu
}

function show_consensus_client_logs() {
    sudo journalctl -u story -fn 100
    menu
}

function show_geth_logs() {
    sudo journalctl -u story-geth -fn 100
    menu
}

function show_node_status() {
    port=$(grep -oP 'laddr = "tcp://(0.0.0.0|127.0.0.1):\K[0-9]+57' "$HOME/.story/story/config/config.toml") && curl "http://127.0.0.1:$port/status" | jq
    story status
    menu
}

function backup_validator_key() {
    cp $HOME/.story/story/config/priv_validator_key.json $HOME/priv_validator_key.json
    menu
}

function add_peers() {
    echo "Select an option:"
    echo "1. Add peers manually"
    echo "2. Use Grand Valley's peers"
    echo "3. Back"
    read -p "Enter your choice (1, 2, or 3): " choice

    case $choice in
        1)
            read -p "Enter peers (comma-separated): " peers
            echo "You have entered the following peers: $peers"
            read -p "Do you want to proceed? (yes/no): " confirm
            if [[ $confirm == "yes" ]]; then
                sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.story/story/config/config.toml
                echo "Peers added manually."
            else
                echo "Operation cancelled. Returning to menu."
                menu
            fi
            ;;
        2)
            peers=$(curl -sS https://lightnode-rpc-story.grandvalleys.com/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
            echo "Grand Valley's peers: $peers"
            read -p "Do you want to proceed? (yes/no): " confirm
            if [[ $confirm == "yes" ]]; then
                sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.story/story/config/config.toml
                echo "Grand Valley's peers added."
            else
                echo "Operation cancelled. Returning to menu."
                menu
            fi
            ;;
        3)
            menu
            ;;
        *)
            echo "Invalid choice. Please enter 1, 2, or 3."
            add_peers
            ;;
    esac
    echo "Now you can restart your consensus client"
    menu
}

function manage_consensus_client() {
    echo "Choose an option:"
    echo "1. Migrate to Cosmovisor only"
    echo "2. Update Consensus Client Version (includes Cosmovisor migration and deployment)"
    echo "3. Back"
    read -p "Enter your choice (1/2/3): " choice

    case $choice in
        1)
            migrate_to_cosmovisor
            ;;
        2)
            bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/Story%20Protocol/resources/story_update.sh)
            menu
            ;;
        3)
            menu
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            update_consensus_client
            ;;
    esac
}

# Function to migrate to Cosmovisor

function migrate_to_cosmovisor() {
    echo "The service file for your current validator node will be updated to match Grand Valley's current configuration."
    echo "Press Enter to continue..."
    read -r
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/Story%20Protocol/resources/cosmovisor_migration.sh)
    menu
}

# New functions for stopping and restarting individual services
function stop_consensus_client() {
    sudo systemctl stop story
    echo "Consensus client service stopped."
    menu
}

function stop_geth() {
    sudo systemctl stop story-geth
    echo "Geth service stopped."
    menu
}

function restart_consensus_client() {
    sudo systemctl daemon-reload
    sudo rm -f $HOME/.story/story/data/upgrade-info.json
    sudo systemctl restart story
    echo "Consensus client service restarted."
    menu
}

function restart_geth() {
    sudo systemctl daemon-reload
    sudo systemctl restart story-geth
    echo "Geth service restarted."
    menu
}

function show_all_logs() {
    echo "Displaying both Consensus Client and Geth Logs:"
    sudo journalctl -u story -u story-geth -fn 100
    menu
}

function install_story_app() {
    echo -e "${YELLOW}This option is only for those who want to execute the transactions without running the node.${RESET}"
    mkdir -p story-v0.12.1
    wget -O story-v0.12.1/story https://github.com/piplabs/story/releases/download/v0.12.1/story-linux-amd64
    cp story-v0.12.1/story $HOME/go/bin/story
    sudo chown -R $USER:$USER $HOME/go/bin/story
    sudo chmod +x $HOME/go/bin/story
    echo "story app installed successfully."
    menu
}

function apply_snapshot() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/Story%20Protocol/resources/apply_snapshot.sh)
    menu
}

function show_endpoints() {
    echo -e "$ENDPOINTS"
    echo -e "\n${YELLOW}Press Enter to continue${RESET}"
    read -r
    menu
}

# Menu function
function menu() {
    echo -e "${CYAN}Story Validator Node = Consensus Client Service + Execution Client Service (geth/story-geth)${RESET}"
    echo "Menu:"
    echo -e "${GREEN}1. Node Interactions:${RESET}"
    echo "   a. Deploy/re-Deploy Validator Node (includes Cosmovisor deployment)"
    echo "   b. Manage Consensus Client (Migrate to Cosmovisor or Update Version)"
    echo "   c. Apply Snapshot"
    echo "   d. Add Peers"
    echo "   e. Update Geth Version"
    echo "   f. Show Validator Node Status"
    echo "   g. Show Consensus Client & Geth Logs Together"
    echo "   h. Stop Validator Node"
    echo "   i. Stop Consensus Client Only"
    echo "   j. Stop Geth Only"
    echo "   k. Restart Validator Node"
    echo "   l. Restart Consensus Client Only"
    echo "   m. Restart Geth Only"
    echo "   n. Delete Validator Node (BACKUP YOUR SEEDS PHRASE/EVM-PRIVATE KEY AND priv_validator_key.json BEFORE YOU DO THIS)"
    echo "   o. Install Story App only (v0.12.1)(for executing transactions without running the node)"
    echo -e "${GREEN}2. Validator/Key Interactions:${RESET}"
    echo "   a. Create Validator"
    echo "   b. Query Validator Public Key"
    echo "   c. Query Balance"
    echo "   d. Stake Tokens"
    echo "   e. Unstake Tokens"
    echo "   f. Export EVM Key"
    echo "   g. Backup Validator Key (store it to $HOME directory)"
    echo -e "${GREEN}3. Show Grand Valley's Endpoints${RESET}"
    echo -e "${RED}4. Exit${RESET}"

    echo -e "${GREEN}Let's Buidl Story Together - Grand Valley${RESET}"
    read -p "Choose an option (e.g., 1a or 1 then a): " OPTION

    if [[ $OPTION =~ ^[1-2][a-o]$ ]]; then
        MAIN_OPTION=${OPTION:0:1}
        SUB_OPTION=${OPTION:1:1}
    else
        MAIN_OPTION=$OPTION
        if [[ $MAIN_OPTION =~ ^[1-2]$ ]]; then
            read -p "Choose a sub-option: " SUB_OPTION
        fi
    fi

    case $MAIN_OPTION in
        1)
            case $SUB_OPTION in
                a) deploy_validator_node ;;
                b) manage_consensus_client ;;
                c) apply_snapshot ;;
                d) add_peers ;;
                e) update_geth ;;
                f) show_node_status ;;
                g) show_all_logs ;;
                h) stop_validator_node ;;
                i) stop_consensus_client ;;
                j) stop_geth ;;
                k) restart_validator_node ;;
                l) restart_consensus_client ;;
                m) restart_geth ;;
                n) delete_validator_node ;;
                o) install_story_app ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        2)
            case $SUB_OPTION in
                a) create_validator ;;
                b) query_validator_pub_key ;;
                c) query_balance ;;
                d) stake_tokens ;;
                e) unstake_tokens ;;
                f) export_evm_key ;;
                g) backup_validator_key ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        3) show_endpoints ;;
        4) exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
}

# Start menu
menu
