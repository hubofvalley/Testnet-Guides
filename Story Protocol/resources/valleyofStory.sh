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

INTRO="${GREEN}
Valley Of 0G by Grand Valley

Story Validator Node System Requirements

${YELLOW}| Category  | Requirements     |
| --------- | ---------------- |
| CPU       | 8+ cores         |
| RAM       | 32+ GB           |
| Storage   | 500+ GB NVMe SSD |
| Bandwidth | 100+ MBit/s      |${RESET}

- consensus client service file name: ${BLUE}story.service${RESET}
- geth service file name: ${BLUE}story-geth.service${RESET}
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

Grand Valley social media:
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
echo -e "\n${YELLOW}Press Enter to continue${RESET}"
read -r

# Display ENDPOINTS section
echo -e "$ENDPOINTS"

# Define variables
geth_file_name=geth-linux-amd64

# Function to update to a specific version
update_geth_version() {
    local version=$1
    local download_url=$2

    # Create directory and download the binary
    cd $HOME
    mkdir -p $HOME/$version
    if ! wget -P $HOME/$version $download_url/$geth_file_name -O $HOME/$version/geth; then
        echo -e "${RED}Failed to download the binary. Exiting.${RESET}"
        exit 1
    fi

    # Move the binary to the appropriate directory
    sudo mv $HOME/$version/geth $HOME/go/bin/geth

    # Set ownership and permissions
    sudo chown -R $USER:$USER $HOME/go/bin/geth
    sudo chmod +x $HOME/go/bin/geth

    # Restart the service
    sudo systemctl daemon-reload && \
    sudo systemctl restart story-geth
}

# Validator Node Functions
function deploy_validator_node() {
    echo -e "${CYAN}Deploying Validator Node...${RESET}"
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/Story%20Protocol/resources/story_validator_node_install_odyssey.sh)
    menu
}

function create_validator() {
    read -p "Enter your private key: " PRIVATE_KEY
    story validator create --stake 1000000000000000000 --private-key $(grep -oP '(?<=PRIVATE_KEY=).*' $HOME/.story/story/config/private_key.txt)
    menu
}

function query_validator_pub_key() {
    story validator export | grep -oP 'Compressed Public Key \(base64\): \K.*'
    menu
}

function query_balance() {
    echo -e "${CYAN}Select an option:${RESET}"
    echo "1. Query balance of your own EVM address"
    echo "2. Query balance of another EVM address"
    read -p "Enter your choice (1 or 2): " choice

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
        *)
            echo -e "${RED}Invalid choice. Please enter 1 or 2.${RESET}"
            ;;
    esac
    menu
}

function stake_tokens() {
    read -p "Stake to self or another validator? (self/other): " TARGET
    if [ "$TARGET" == "self" ]; then
        VALIDATOR_PUBKEY=$(story validator export | grep -oP 'Compressed Public Key \(base64\): \K.*')
    else
        read -p "Enter validator pubkey: " VALIDATOR_PUBKEY
    fi
    read -p "Enter amount to stake: " AMOUNT
    story validator stake --validator-pubkey $VALIDATOR_PUBKEY --stake $AMOUNT --private-key $(grep -oP '(?<=PRIVATE_KEY=).*' $HOME/.story/story/config/private_key.txt) -y
    menu
}

function unstake_tokens() {
    read -p "Unstake from self or another validator? (self/other): " TARGET
    if [ "$TARGET" == "self" ]; then
        VALIDATOR_PUBKEY=$(story validator export | grep -oP 'Compressed Public Key \(base64\): \K.*')
    else
        read -p "Enter validator pubkey: " VALIDATOR_PUBKEY
    fi
    read -p "Enter amount to unstake: " AMOUNT
    story validator unstake --validator-pubkey $VALIDATOR_PUBKEY --stake $AMOUNT --private-key $(grep -oP '(?<=PRIVATE_KEY=).*' $HOME/.story/story/config/private_key.txt) -y
    menu
}

function export_evm_key() {
    echo -e "${CYAN}Query all of your current EVM key addresses including your EVM private key${RESET}"
    story validator export --evm-key-path $HOME/.story/story/config/private_key.txt --export-evm-key
    cat $HOME/.story/story/config/private_key.txt
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

function stop_services() {
    sudo systemctl stop story story-geth
    echo "Consensus client and Geth service stopped."
    menu
}

function restart_services() {
    sudo systemctl daemon-reload
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
    port=$(grep -oP 'laddr = "tcp://0.0.0.0:\K[0-9]+57' "$HOME/.story/story/config/config.toml") && curl "http://127.0.0.1:$port/status" | jq
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
    read -p "Enter your choice (1 or 2): " choice

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
        *)
            echo "Invalid choice. Please enter 1 or 2."
            menu
            ;;
    esac
    echo "Now you can restart your consensus client"
    menu
}

function update_consensus_client() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/Story%20Protocol/resources/story_update.sh)
    menu
}

function update_geth() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/Story%20Protocol/resources/story-geth_update.sh)
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

# Menu
function menu() {
    echo -e "${CYAN}Story Validator Node = Consensus Client Service + Execution Client Service (geth/story-geth)${RESET}"
    echo "Menu:"
    echo -e "${GREEN}1. Node Interactions:${RESET}"
    echo "   a. Deploy Validator Node"
    echo "   b. Delete Validator Node (DON'T FORGET TO BACKUP YOUR SEEDS PHRASE/EVM-PRIVATE KEY AND priv_validator_key.json BEFORE YOU DO THIS)"
    echo "   c. Stop Consensus Client and Geth Service"
    echo "   d. Restart Consensus Client and Geth Service"
    echo "   e. Show Consensus Client Logs"
    echo "   f. Show Geth Logs"
    echo "   g. Show Node Status"
    echo "   h. Add Peers"
    echo "   i. Update Consensus Client Version"
    echo "   j. Update Geth Version"
    echo "   k. Stop Consensus Client Only"
    echo "   l. Stop Geth Only"
    echo "   m. Restart Consensus Client Only"
    echo "   n. Restart Geth Only"
    echo "   o. Show Consensus Client & Geth Logs Together"
    echo -e "${GREEN}2. Validator/Key Interactions:${RESET}"
    echo "   a. Create Validator"
    echo "   b. Query Validator Public Key"
    echo "   c. Query Balance"
    echo "   d. Stake Tokens"
    echo "   e. Unstake Tokens"
    echo "   f. Export EVM Key"
    echo "   g. Backup Validator Key (store it to $HOME directory)"
    echo -e "${RED}3. Exit${RESET}"

    echo "Let's Buidl Story Together - Grand Valley"
    read -p "Choose an option (e.g., 1a or 1 then a): " OPTION

    if [[ $OPTION =~ ^[1-2][a-o]$ ]]; then
        MAIN_OPTION=${OPTION:0:1}
        SUB_OPTION=${OPTION:1:1}
    else
        read -p "Choose a sub-option: " SUB_OPTION
        MAIN_OPTION=$OPTION
    fi

    case $MAIN_OPTION in
        1)
            case $SUB_OPTION in
                a) deploy_validator_node ;;
                b) delete_validator_node ;;
                c) stop_services ;;
                d) restart_services ;;
                e) show_consensus_client_logs ;;
                f) show_geth_logs ;;
                g) show_node_status ;;
                h) add_peers ;;
                i) update_consensus_client ;;
                j) update_geth ;;
                k) stop_consensus_client ;;
                l) stop_geth ;;
                m) restart_consensus_client ;;
                n) restart_geth ;;
                o) show_all_logs ;;
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
        3) exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
}

# Start menu
menu

