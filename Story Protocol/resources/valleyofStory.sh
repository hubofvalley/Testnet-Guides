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
Valley of Story by Grand Valley

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
- current story node version: ${CYAN}v0.12.0 - v0.12.1 - v0.13.0${RESET}
- current story-geth node version: ${CYAN}v0.11.0${RESET}
"

PRIVACY_SAFETY_STATEMENT="
${YELLOW}Privacy and Safety Statement${RESET}

${GREEN}No User Data Stored Externally${RESET}
- This script does not store any user data externally. All operations are performed locally on your machine.

${GREEN}No Phishing Links${RESET}
- This script does not contain any phishing links. All URLs and commands are provided for legitimate purposes related to Namada validator node operations.

${GREEN}Security Best Practices${RESET}
- Always verify the integrity of the script and its source.
- Ensure you are running the script in a secure environment.
- Be cautious when entering sensitive information such as wallet names and addresses.

${GREEN}Disclaimer${RESET}
- The authors of this script are not responsible for any misuse or damage caused by the use of this script.
- Use this script at your own risk.

${GREEN}Contact${RESET}
- If you have any concerns or questions, please contact us at letsbuidltogether@grandvalleys.com.
"

ENDPOINTS="${GREEN}
Grand Valley Story Protocol public endpoints:${RESET}
- cosmos-rpc: \e]8;;https://lightnode-rpc-story.grandvalleys.com\a${BLUE}https://lightnode-rpc-story.grandvalleys.com\e]8;;\a${RESET}
- evm-rpc: ${BLUE}https://lightnode-json-rpc-story.grandvalleys.com${RESET}
- cosmos rest-api: ${BLUE}https://lightnode-api-story.grandvalleys.com${RESET}
- cosmos ws: ${BLUE}wss://lightnode-rpc-story.grandvalleys.com/websocket${RESET}
- evm ws: ${BLUE}wss://lightnode-wss-story.grandvalleys.com${RESET}

${GREEN}Connect with Story Protocol:${RESET}
- Official Website: \e]8;;https://www.story.foundation\a${BLUE}https://www.story.foundation\e]8;;\a${RESET}
- X: \e]8;;https://x.com/StoryProtocol\a${BLUE}https://x.com/StoryProtocol\e]8;;\a${RESET}
- Official Docs: \e]8;;https://docs.story.foundation\a${BLUE}https://docs.story.foundation\e]8;;\a${RESET}

${GREEN}Connect with Grand Valley:${RESET}
- X: \e]8;;https://x.com/bacvalley\a${BLUE}https://x.com/bacvalley\e]8;;\a${RESET}
- GitHub: \e]8;;https://github.com/hubofvalley\a${BLUE}https://github.com/hubofvalley\e]8;;\a${RESET}
- Email: \e]8;;mailto:letsbuidltogether@grandvalleys.com\a${BLUE}letsbuidltogether@grandvalleys.com\e]8;;\a${RESET}
"

# Display LOGO and wait for user input to continue
echo -e "$LOGO"
echo -e "$PRIVACY_SAFETY_STATEMENT"
echo -e "\n${YELLOW}Press Enter to continue...${RESET}"
read -r

# Display INTRO section and wait for user input to continue
echo -e "$INTRO"
echo -e "$ENDPOINTS"
echo -e "\n${YELLOW}Press Enter to continue${RESET}"
read -r
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile
echo "export STORY_CHAIN_ID="odyssey"" >> ~/.bash_profile
echo "export DAEMON_NAME=story" >> ~/.bash_profile
echo "export DAEMON_HOME=$(find "$HOME/.story" -type d -name "story" -print -quit)" >> ~/.bash_profile
echo "export DAEMON_DATA_BACKUP_DIR=$(find "$HOME/.story/story/cosmovisor" -type d -name "backup" -print -quit)" >> ~/.bash_profile
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
    echo -e "\n${YELLOW}That's your Validator Public Key or Compressed Public Key (hex) address. Press Enter to go back to main menu...${RESET}"
    read -r
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
            geth --exec "(parseFloat(eth.getBalance('$(story validator export | grep -oP '(?<=EVM Address: ).*')') / 1e18).toFixed(2)) + ' IP'" attach $HOME/.story/geth/odyssey/geth.ipc
            ;;
        2)
            read -p "Enter the EVM address to query: " evm_address
            echo -e "${GREEN}Querying balance of $evm_address...${RESET}"
            geth --exec "(parseFloat(eth.getBalance('$evm_address') / 1e18).toFixed(2)) + ' IP'" attach ~/.story/geth/odyssey/geth.ipc
            ;;
        3)
            menu
            ;;
        *)
            echo -e "${RED}Invalid choice. Please enter 1, 2, or 3.${RESET}"
            query_balance
            ;;
    esac
    echo -e "\n${YELLOW}Press Enter to go back to main menu...${RESET}"
    read -r
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
    echo -e "\n${YELLOW}Press Enter to continue${RESET}"
    read -r
    menu
}

function delete_validator_node() {
    sudo systemctl stop story story-geth
    sudo systemctl disable story story-geth
    sudo rm -rf /etc/systemd/system/story.service
    sudo rm -rf /etc/systemd/system/story-geth.service
    sudo rm -r $HOME/go/bin/story
    sudo rm -r $HOME/go/bin/story-geth $HOME/go/bin/geth
    sudo rm -rf $HOME/.story
    sed -i "/STORY_/d" $HOME/.bash_profile
    echo -e "\n${RED}Story Validator node deleted successfully.${RESET}"
    menu
}

function stop_validator_node() {
    sudo systemctl stop story story-geth
    echo "Consensus client and Geth service stopped."
    menu
}

function restart_validator_node() {
    sudo systemctl daemon-reload
    sudo systemctl restart story story-geth
    echo -e "\n${GREEN}Consensus client and Geth service restarted.${RESET}"
    menu
}

function show_node_status() {
    port=$(grep -oP 'laddr = "tcp://(0.0.0.0|127.0.0.1):\K[0-9]+57' "$HOME/.story/story/config/config.toml") && curl "http://127.0.0.1:$port/status" | jq
    story status
    geth_block_height=$(geth --exec "eth.blockNumber" attach $HOME/.story/geth/odyssey/geth.ipc)
    echo "Geth block height: $geth_block_height"
    echo -e "\n${YELLOW}Press Enter to go back to main menu${RESET}"
    read -r
    menu
}

function backup_validator_key() {
    cp $HOME/.story/story/config/priv_validator_key.json $HOME/priv_validator_key.json
    echo -e "\n${YELLOW}Your priv_vaidator_key.json file has been copied to $HOME${RESET}"
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
    echo -e "\n${YELLOW}Now you can restart your consensus client${RESET}"
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
    echo -e "${YELLOW}Press Enter to continue${RESET}"
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

function show_consensus_client_logs() {
    echo "Displaying Consensus Client Logs:"
    sudo journalctl -u story -fn 100
    menu
}

function show_geth_logs() {
    echo "Displaying Geth Logs:"
    sudo journalctl -u story-geth -fn 100
    menu
}

function install_story_app() {
    echo -e "${YELLOW}This option is only for those who want to execute the transactions without running the node.${RESET}"
    mkdir -p story-v0.13.2
    wget -O story-v0.13.2/story https://github.com/piplabs/story/releases/download/v0.13.2/story-linux-amd64
    cp story-v0.13.2/story $HOME/go/bin/story
    sudo chown -R $USER:$USER $HOME/go/bin/story
    sudo chmod +x $HOME/go/bin/story
    echo -e "${YELLOW}story app installed successfully${RESET}"
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

function show_guidelines() {
    echo -e "${CYAN}Guidelines on How to Use the Valley of Story${RESET}"
    echo -e "${YELLOW}This tool is designed to help you manage your Story Validator Node. Below are the guidelines on how to use it effectively:${RESET}"
    echo -e "${GREEN}1. Navigating the Menu${RESET}"
    echo "   - The menu is divided into several sections: Node Interactions, Validator/Key Interactions, Node Management, Show Grand Valley's Endpoints, and Guidelines."
    echo "   - To select an option, you can either:"
    echo "     a. Enter the corresponding number followed by the letter (e.g., 1a for Deploy/re-Deploy Validator Node)."
    echo "     b. Enter the number, press Enter, and then enter the letter (e.g., 1 then a)."
    echo "   - For sub-options, you will be prompted to enter the letter corresponding to your choice."
    echo -e "${GREEN}2. Entering Choices${RESET}"
    echo "   - For any prompt that has choices, you only need to enter the numbering (1, 2, 3, etc.) or the letter (a, b, c, etc.)."
    echo "   - For yes/no prompts, enter 'yes' for yes and 'no' for no."
    echo "   - For y/n prompts, enter 'y' for yes and 'n' for no."
    echo -e "${GREEN}3. Running Commands${RESET}"
    echo "   - After selecting an option, the script will execute the corresponding commands."
    echo "   - Ensure you have the necessary permissions and dependencies installed for the commands to run successfully."
    echo -e "${GREEN}4. Exiting the Script${RESET}"
    echo "   - To exit the script, select option 6 from the main menu."
    echo "   - Remember to run 'source ~/.bash_profile' after exiting to apply any changes made to environment variables."
    echo -e "${GREEN}5. Additional Tips${RESET}"
    echo "   - Always backup your keys and important data before performing operations like deleting the node."
    echo "   - Regularly update your node to the latest version to ensure compatibility and security."
    echo -e "${GREEN}6. Option Descriptions and Guides${RESET}"
    echo -e "${GREEN}Node Interactions:${RESET}"
    echo "   a. Deploy/re-Deploy Validator Node: Deploys or re-deploys the validator node, including Cosmovisor deployment."
    echo "      - Guide: This option will download and install the necessary components to set up your validator node. Ensure you have the required system specifications."
    echo "   b. Manage Consensus Client: Allows you to migrate to Cosmovisor or update the consensus client version."
    echo "      - Guide: Use this option to update your consensus client to the latest version or migrate to Cosmovisor for better management."
    echo "   c. Apply Snapshot: Applies a snapshot to the node."
    echo "      - Guide: This option will apply a snapshot to your node, which can significantly speed up the syncing process."
    echo "   d. Add Peers: Adds peers to the node, either manually or using Grand Valley's peers."
    echo "      - Guide: Use this option to add peers to your node. You can either enter peers manually or use Grand Valley's peers for better connectivity."
    echo "   e. Update Geth Version: Updates the Geth version."
    echo "      - Guide: This option will update your Geth client to the latest version. Ensure you have a stable internet connection."
    echo "   f. Show Validator Node Status: Displays the status of the validator node."
    echo "      - Guide: Use this option to check the current status of your validator node. It will display relevant information about your node's health."
    echo "   g. Show Consensus Client & Geth Logs Together: Displays logs for both the consensus client and Geth."
    echo "      - Guide: This option will show the logs for both the consensus client and Geth, helping you diagnose any issues."
    echo "   h. Show Consensus Client Logs: Displays logs for the consensus client."
    echo "      - Guide: Use this option to view the logs specifically for the consensus client."
    echo "   i. Show Geth Logs: Displays logs for Geth."
    echo "      - Guide: This option will show the logs specifically for Geth."
    echo -e "${GREEN}Validator/Key Interactions:${RESET}"
    echo "   a. Create Validator: Creates a new validator."
    echo "      - Guide: This option will guide you through creating a new validator. You will need to provide details such as the moniker and staking amount."
    echo "   b. Query Validator Public Key: Queries the validator public key."
    echo "      - Guide: Use this option to retrieve the public key of your validator. This key is essential for staking and other operations."
    echo "   c. Query Balance: Queries the balance of an EVM address."
    echo "      - Guide: This option will show the balance of a specified EVM address. You can choose to query your own address or another address."
    echo "   d. Stake Tokens: Stakes tokens to a validator."
    echo "      - Guide: Use this option to stake tokens to a validator. You can choose to stake to Grand Valley, yourself, or another validator."
    echo "   e. Unstake Tokens: Unstakes tokens from a validator."
    echo "      - Guide: This option will help you unstake tokens from a validator. You can choose to unstake from yourself or another validator."
    echo "   f. Export EVM Key: Exports the EVM key."
    echo "      - Guide: Use this option to export your EVM key. This key is crucial for managing your EVM address."
    echo -e "${GREEN}Node Management:${RESET}"
    echo "   a. Stop Validator Node: Stops the validator node."
    echo "      - Guide: Use this option to stop your validator node. This will halt both the consensus client and Geth services."
    echo "   b. Stop Consensus Client Only: Stops the consensus client."
    echo "      - Guide: This option will stop only the consensus client service."
    echo "   c. Stop Geth Only: Stops Geth."
    echo "      - Guide: Use this option to stop only the Geth service."
    echo "   d. Restart Validator Node: Restarts the validator node."
    echo "      - Guide: This option will restart your validator node, including both the consensus client and Geth services."
    echo "   e. Restart Consensus Client Only: Restarts the consensus client."
    echo "      - Guide: Use this option to restart only the consensus client service."
    echo "   f. Restart Geth Only: Restarts Geth."
    echo "      - Guide: This option will restart only the Geth service."
    echo "   g. Backup Validator Key: Backs up the validator key to the $HOME directory."
    echo "      - Guide: This option will backup your validator key to your home directory. Ensure you keep this key secure."
    echo "   h. Delete Validator Node: Deletes the validator node. Ensure you backup your seeds phrase/EVM-private key and priv_validator_key.json before doing this."
    echo "      - Guide: Use this option to delete your validator node. Make sure to backup all important data before proceeding."
    echo -e "${GREEN}Install Story App only: Installs the Story app (v0.13.1) for executing transactions without running the node.${RESET}"
    echo "      - Guide: Use this option to install the Story app if you only need to execute transactions without running a full node."
    echo -e "${GREEN}Show Grand Valley's Endpoints:${RESET}"
    echo "   Displays Grand Valley's public endpoints."
    echo "      - Guide: This option will show you the public endpoints provided by Grand Valley. These endpoints can be used for various operations."
    echo -e "${GREEN}Show Guidelines:${RESET}"
    echo "   Displays these guidelines."
    echo "      - Guide: Use this option to view the guidelines on how to use the tool effectively."
    echo -e "\n${YELLOW}Press Enter to go back to main menu${RESET}"
    read -r
    menu
}

# Menu function
function menu() {
    echo -e "${CYAN}Valley of Story${RESET}"
    echo -e "${CYAN}Story Validator Node = Consensus Client Service + Execution Client Service (geth/story-geth)${RESET}"
    echo "Main Menu:"
    echo -e "${GREEN}1. Node Interactions:${RESET}"
    echo "   a. Deploy/re-Deploy Validator Node (includes Cosmovisor deployment)"
    echo "   b. Manage Consensus Client (Migrate to Cosmovisor or Update Version)"
    echo "   c. Apply Snapshot"
    echo "   d. Add Peers"
    echo "   e. Update Geth Version"
    echo "   f. Show Validator Node Status"
    echo "   g. Show Consensus Client & Geth Logs Together"
    echo "   h. Show Consensus Client Logs "
    echo "   i. Show Geth Logs"
    echo -e "${GREEN}2. Validator/Key Interactions:${RESET}"
    echo "   a. Create Validator"
    echo "   b. Query Validator Public Key"
    echo "   c. Query Balance"
    echo "   d. Stake Tokens"
    echo "   e. Unstake Tokens"
    echo "   f. Export EVM Key"
    echo -e "${GREEN}3. Node Management:${RESET}"
    echo "   a. Restart Validator Node"
    echo "   b. Restart Consensus Client Only"
    echo "   c. Restart Geth Only"
    echo "   d. Stop Validator Node"
    echo "   e. Stop Consensus Client Only"
    echo "   f. Stop Geth Only"
    echo "   g. Backup Validator Key (store it to $HOME directory)"
    echo "   h. Delete Validator Node (BACKUP YOUR SEEDS PHRASE/EVM-PRIVATE KEY AND priv_validator_key.json BEFORE YOU DO THIS)"
    echo -e "${GREEN}4. Install the Story App (v0.13.1) only to execute transactions without running a node${RESET}"
    echo -e "${GREEN}5. Show Grand Valley's Endpoints${RESET}"
    echo -e "${YELLOW}6. Show Guidelines${RESET}"
    echo -e "${RED}7. Exit${RESET}"

    echo -e "\n${YELLOW}Please run the following command to apply the changes after exiting the script:${RESET}"
    echo -e "${GREEN}source ~/.bash_profile${RESET}"
    echo -e "${YELLOW}This ensures the environment variables are set in your current bash session.${RESET}"
    echo -e "${GREEN}Let's Buidl Story Together - Grand Valley${RESET}"
    read -p "Choose an option (e.g., 1a or 1 then a): " OPTION

    if [[ $OPTION =~ ^[1-6][a-z]$ ]]; then
        MAIN_OPTION=${OPTION:0:1}
        SUB_OPTION=${OPTION:1:1}
    else
        MAIN_OPTION=$OPTION
        if [[ $MAIN_OPTION =~ ^[1-3]$ ]]; then
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
                h) show_consensus_client_logs ;;
                i) show_geth_logs ;;
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
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        3)
            case $SUB_OPTION in
                a) restart_validator_node ;;
                b) restart_consensus_client ;;
                c) restart_geth ;;
                d) stop_validator_node ;;
                e) stop_consensus_client ;;
                f) stop_geth ;;
                g) backup_validator_key ;;
                h) delete_validator_node ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        4) install_story_app ;;
        5) show_endpoints ;;
        6) show_guidelines ;;
        7) exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
}

# Start menu
menu
