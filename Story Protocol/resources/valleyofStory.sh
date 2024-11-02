#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

LOGO="
${BLUE} __      __     _  _                        __    _____  _                        ${NC}
${BLUE} \ \    / /    | || |                      / _|  / ____|| |                       ${NC}
${BLUE}  \ \  / /__ _ | || |  ___  _   _    ___  | |_  | (___  | |_  ___   _ __  _   _   ${NC}
${BLUE}  _\ \/ // _\` || || | / _ \| | | |  / _ \ |  _|  \___ \ | __|/ _ \ | '__|| | | |  ${NC}
${BLUE} | |\  /| (_| || || ||  __/| |_| | | (_) || |    ____) || |_| (_) || |   | |_| |  ${NC}
${BLUE} | |_\/  \__,_||_||_| \___| \__, |  \___/ |_|   |_____/  \__|\___/ |_|    \__, |  ${NC}
${BLUE} | '_ \ | | | |              __/ |                                         __/ |  ${NC}
${BLUE} | |_) || |_| |             |___/                                         |___/   ${NC}
${BLUE} |_.__/  \__, |                                                                   ${NC}
${BLUE}          __/ |                                                                   ${NC}
${BLUE}         |___/                                                                    ${NC}
${BLUE} __                                    ${NC}
${BLUE}/__ ._ _. ._   _|   \  / _. | |  _     ${NC}
${BLUE}\_| | (_| | | (_|    \/ (_| | | (/_ \/ ${NC}
${BLUE}                                    /  ${NC}
"

INTRO="
${GREEN}Valley Of 0G by Grand Valley${NC}

${YELLOW}Story Validator Node System Requirements${NC}

${GREEN}| Category  | Requirements     |${NC}
${GREEN}| --------- | ---------------- |${NC}
${GREEN}| CPU       | 8+ cores         |${NC}
${GREEN}| RAM       | 32+ GB           |${NC}
${GREEN}| Storage   | 500+ GB NVMe SSD |${NC}
${GREEN}| Bandwidth | 100+ MBit/s      |${NC}

${YELLOW}- consensus client service file name: story.service${NC}
${YELLOW}- geth service file name: story-geth.service${NC}
${YELLOW}- current chain: odyssey${NC}
${YELLOW}- current story node version: v0.12.0${NC}
${YELLOW}- current story-geth node version: v0.10.0${NC}

"

ENDPOINTS="
${GREEN}Grand Valley Story Protocol public endpoints:${NC}
${YELLOW}- cosmos rpc: https://lightnode-rpc-story.grandvalleys.com${NC}
${YELLOW}- json-rpc: https://lightnode-json-rpc-story.grandvalleys.com${NC}
${YELLOW}- cosmos rest-api: https://lightnode-api-story.grandvalleys.com${NC}
${YELLOW}- cosmos ws: wss://lightnode-rpc-story.grandvalleys.com/websocket${NC}
${YELLOW}- evm ws: wss://lightnode-wss-story.grandvalleys.com${NC}

${GREEN}Grand Valley social media:${NC}
${YELLOW}- X: https://x.com/bacvalley${NC}
${YELLOW}- GitHub: https://github.com/hubofvalley${NC}
${YELLOW}- Email: letsbuidltogether@grandvalleys.com${NC}
"

# Display LOGO and wait for user input to continue
echo "$LOGO"
echo -e "\n${YELLOW}Press Enter to continue...${NC}"
read -r

# Display INTRO section and wait for user input to continue
echo "$INTRO"
echo -e "\n${YELLOW}Press Enter to continue${NC}"
read -r

# Display ENDPOINTS section
echo "$ENDPOINTS"

# Validator Node Functions
function deploy_validator_node() {
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
    echo "Select an option:"
    echo "1. Query balance of your own EVM address"
    echo "2. Query balance of another EVM address"
    read -p "Enter your choice (1 or 2): " choice

    case $choice in
        1)
            echo "Querying balance of your own EVM address..."
            geth --exec "eth.getBalance('$(story validator export | grep -oP '(?<=EVM Address: ).*')')" attach $HOME/.story/geth/odyssey/geth.ipc
            ;;
        2)
            read -p "Enter the EVM address to query: " evm_address
            echo "Querying balance of $evm_address..."
            geth --exec "eth.getBalance('$evm_address')" attach $HOME/.story/geth/odyssey/geth.ipc
            ;;
        *)
            echo "Invalid choice. Please enter 1 or 2."
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
    echo "Query all of your current EVM key addresses including your EVM private key"
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
    echo "Story Validator node deleted successfully."
    menu
}

function stop_consensus_client() {
    sudo systemctl stop story
    echo "Consensus client stopped."
    menu
}

function restart_consensus_client() {
    sudo systemctl daemon-reload
    sudo systemctl restart story
    echo "Consensus client restarted."
    menu
}

function stop_geth() {
    sudo systemctl stop story-geth
    echo "Geth service stopped."
    menu
}

function restart_geth() {
    sudo systemctl daemon-reload
    sudo systemctl restart story-geth
    echo "Geth service restarted."
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
            sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.story/story/config/config.toml
            echo "Peers added manually."
            ;;
        2)
            peers=$(curl -sS https://lightnode-rpc-story.grandvalleys.com/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
            sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.story/story/config/config.toml
            echo "Grand Valley's peers added."
            ;;
        *)
            echo "Invalid choice. Please enter 1 or 2."
            ;;
    esac
    echo "Now you can restart your consensus client"
    menu
}

function update_consensus_client() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/Story%20Protocol/resources/story_update.sh)
    menu
}

# Menu
function menu() {
    echo "${GREEN}1. Node Interactions:${NC}"
    echo "${YELLOW}   a. Deploy Validator Node${NC}"
    echo "${YELLOW}   b. Delete Validator Node (DON'T FORGET TO BACKUP YOUR SEEDS PHRASE/EVM-PRIVATE KEY AND priv_validator_key.json BEFORE U DID THIS)${NC}"
    echo "${YELLOW}   c. Stop Consensus Client${NC}"
    echo "${YELLOW}   d. Restart Consensus Client${NC}"
    echo "${YELLOW}   e. Stop Geth Service${NC}"
    echo "${YELLOW}   f. Restart Geth Service${NC}"
    echo "${YELLOW}   g. Show Consensus Client Logs${NC}"
    echo "${YELLOW}   h. Show Geth Logs${NC}"
    echo "${YELLOW}   i. Show Node Status${NC}"
    echo "${YELLOW}   j. Add Peers${NC}"
    echo "${YELLOW}   k. Update Consensus Client${NC}"
    echo "${GREEN}2. Validator/Key Interactions:${NC}"
    echo "${YELLOW}   a. Create Validator${NC}"
    echo "${YELLOW}   b. Query Validator Public Key${NC}"
    echo "${YELLOW}   c. Query Balance${NC}"
    echo "${YELLOW}   d. Stake Tokens${NC}"
    echo "${YELLOW}   e. Unstake Tokens${NC}"
    echo "${YELLOW}   f. Export EVM Key${NC}"
    echo "${YELLOW}   g. Backup Validator Key (store it to $HOME directory)${NC}"
    echo "${GREEN}3. Exit${NC}"

    echo "${BLUE}Let's Buidl Story Together - Grand Valley${NC}"
    read -p "Choose an option: " OPTION

    case $OPTION in
        1)
            read -p "Choose a sub-option: " SUB_OPTION
            case $SUB_OPTION in
                a) deploy_validator_node ;;
                b) delete_validator_node ;;
                c) stop_consensus_client ;;
                d) restart_consensus_client ;;
                e) stop_geth ;;
                f) restart_geth ;;
                g) show_consensus_client_logs ;;
                h) show_geth_logs ;;
                i) show_node_status ;;
                j) add_peers ;;
                k) update_consensus_client ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        2)
            read -p "Choose a sub-option: " SUB_OPTION
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
