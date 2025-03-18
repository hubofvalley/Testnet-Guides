#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RESET='\033[0m'

LOGO="

 _    _       _  _                          ___       _
| |  | |     | || |                        / __)     | |
| |  | |____ | || |  ____  _   _     ___  | |__       \ \    ____   ____  ____   ___
 \ \/ // _  || || | / _  )| | | |   / _ \ |  __)       \ \  / _  | / ___)/ _  | /___)
 _\  /( ( | || || |( (/ / | |_| |  | |_| || |      _____) )( ( | |( (___( ( | ||___ |
| |\/  \_||_||_||_| \____) \__  |   \___/ |_|     (______/  \_||_| \____)\_||_|(___/
| | _   _   _             (____/
| || \ | | | |
| |_) )| |_| |
|____/  \__  |
       (____/

/__ __ __ __   _|   \  / __ | |  _
\_| | (_| | | (_|    \/ (_| | | (/_ \/
                                    /
"

INTRO="
Valley of Sacas by Grand Valley

${GREEN}Sacas Validator Node System Requirements${RESET}
${YELLOW}| Category  | Requirements                   |
| --------- | ------------------------------ |
| CPU       | 8+ cores                        |
| RAM       | 8+ GB                           |
| Storage   | 200+ GB NVMe SSD                |
| Bandwidth | 100 MBps for Download / Upload  |${RESET}

- guide's current binaries version: ${CYAN}v0.20.0${RESET}
- service file name: ${CYAN}sacasd.service${RESET}
- current chain: ${CYAN}sac_1317-1${RESET}
"

PRIVACY_SAFETY_STATEMENT="
${YELLOW}Privacy and Safety Statement${RESET}

${GREEN}No User Data Stored Externally${RESET}
- This script does not store any user data externally. All operations are performed locally on your machine.

${GREEN}No Phishing Links${RESET}
- This script does not contain any phishing links. All URLs and commands are provided for legitimate purposes related to Sacas validator node operations.

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

ENDPOINTS="
${GREEN}Grand Valley Sacas public endpoints:${RESET}
- cosmos rpc: ${BLUE}https://lightnode-rpc-sacas.grandvalleys.com${RESET}
- json-rpc: ${BLUE}https://lightnode-json-rpc-sacas.grandvalleys.com${RESET}
- cosmos rest-api: ${BLUE}https://lightnode-api-sacas.grandvalleys.com${RESET}
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
echo 'export SACAS_CHAIN_ID="sac_1317-1"' >> $HOME/.bash_profile
source $HOME/.bash_profile

# Validator Node Functions
function deploy_validator_node() {
    echo -e "${CYAN}Deploying Validator Node...${RESET}"
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/Sacas%20Network/resources/sacas_validator_node_install_mainnet.sh)
    menu
}

function create_validator() {
    DEFAULT_WALLET=$WALLET_NAME # Assuming $WALLET_NAME is set elsewhere in your script
    read -p "Enter the name for your validator: " NAME

    read -p "Enter the commission rate: (e.g., 0.05) " COMMISSION_RATE

    read -p "Enter the max commission rate change: (e.g., 0.05) " MAX_COMMISSION_RATE_CHANGE

    read -p "Enter the email for your validator security contact: " EMAIL

    read -p "Enter wallet name/alias (leave empty to use current default wallet --> $DEFAULT_WALLET): " WALLET_NAME

    sacasd tx staking create-validator \
    --amount=1000000usacas \
    --pubkey=$(sacasd tendermint show-validator) \
    --moniker="$NAME" \
    --commission-rate="$COMMISSION_RATE" \
    --commission-max-rate="$MAX_COMMISSION_RATE_CHANGE" \
    --commission-max-change-rate=0.01 \
    --min-self-delegation=1 \
    --from="$WALLET_NAME" \
    --chain-id=$SACAS_CHAIN_ID
    menu
}

function add_seeds() {
    echo "Select an option:"
    echo "1. Add seeds manually"
    echo "2. Use Grand Valley's seed"
    read -p "Enter your choice (1 or 2): " choice

    case $choice in
        1)
            read -p "Enter seeds (comma-separated): " seeds
            echo "You have entered the following seeds: $seeds"
            read -p "Do you want to proceed? (yes/no): " confirm
            if [[ $confirm == "yes" ]]; then
                sed -i -e "s|^seeds *=.*|seeds = \"$seeds\"|" $HOME/.sacasd/config/config.toml
                echo "Seeds added manually."
            else
                echo "Operation cancelled. Returning to menu."
                menu
            fi
            ;;
        2)
            seeds="tcp://65882ea69f4146d8cc83564257252f4711d3e05e@seed-mainnet-sacas.grandvalleys.com:56656"
            echo "Grand Valley's seeds: $seeds"
            read -p "Do you want to proceed? (yes/no): " confirm
            if [[ $confirm == "yes" ]]; then
                sed -i -e "s|^seeds *=.*|seeds = \"$seeds\"|" $HOME/.sacasd/config/config.toml
                echo "Grand Valley's seeds added."
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
    echo "Now you can restart your Sacas node"
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
                sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.sacasd/config/config.toml
                echo "Peers added manually."
            else
                echo "Operation cancelled. Returning to menu."
                menu
            fi
            ;;
        2)
            peers=$(curl -sS https://lightnode-rpc-sacas.grandvalleys.com/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
            echo "Grand Valley's peers: $peers"
            read -p "Do you want to proceed? (yes/no): " confirm
            if [[ $confirm == "yes" ]]; then
                sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.sacasd/config/config.toml
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
    echo "Now you can restart your Sacas node"
    menu
}

function delete_validator_node() {
    sudo systemctl stop sacasd
    sudo systemctl disable sacasd
    sudo rm -rf /etc/systemd/system/sacasd.service
    sudo rm -rf $HOME/sacas
    sudo rm -rf $HOME/.sacasd
    sed -i "/SACAS_/d" $HOME/.bash_profile
    echo -e "${RED}Sacas Validator node deleted successfully.${RESET}"
    menu
}

function stop_validator_node() {
    sudo systemctl stop sacasd
    echo "Sacas validator node service stopped."
    menu
}

function restart_validator_node() {
    sudo systemctl daemon-reload
    sudo systemctl restart sacasd
    echo "Sacas validator node service restarted."
    menu
}

function backup_validator_key() {
    cp $HOME/.sacasd/config/priv_validator_key.json $HOME/priv_validator_key.json
    echo -e "\n${YELLOW}Your priv_validator_key.json file has been copied to $HOME${RESET}"
    menu
}

function show_validator_node_logs() {
    echo "Displaying Sacas Validator Node Logs:"
    sudo journalctl -u sacasd -fn 100
    menu
}

function show_validator_node_status() {
    port=$(grep -oP 'laddr = "tcp://(0.0.0.0|127.0.0.1):\K[0-9]+57' "$HOME/.sacasd/config/config.toml")
    curl -s http://127.0.0.1:$port/status | jq
    echo -e "\n${YELLOW}Press Enter to go back to Valley of Sacas main menu${RESET}"
    read -r
    menu
}

function install_sacas_app() {
    echo -e "${YELLOW}This option is only for those who want to execute the transactions without running the node.${RESET}"
    mkdir -p sacas-v0.20.0
    wget -O sacas-v0.20.0/sacasd https://github.com/sacasnetwork/sacas/releases/download/v0.20.0/sacasd-linux-v0.20.0
    cp sacas-v0.20.0/sacasd $HOME/go/bin/sacasd
    sudo chown -R $USER:$USER $HOME/go/bin/sacasd
    sudo chmod +x $HOME/go/bin/sacasd
    echo -e "${YELLOW}sacas app installed successfully${RESET}"
    menu
}

function apply_snapshot() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/Sacas%20Network/resources/apply_snapshot.sh)
    menu
}

function show_endpoints() {
    echo -e "$ENDPOINTS"
    echo -e "\n${YELLOW}Press Enter to continue${RESET}"
    read -r
    menu
}

function show_guidelines() {
    echo -e "${CYAN}Guidelines on How to Use the Valley of Sacas${RESET}"
    echo -e "${YELLOW}This tool is designed to help you manage your Sacas Validator Node. Below are the guidelines on how to use it effectively:${RESET}"
    echo -e "${GREEN}1. Navigating the Menu${RESET}"
    echo "   - The menu is divided into several sections: Node Interactions, Validator/Key Interactions, Node Management, Install Sacas App, Show Grand Valley's Endpoints, and Guidelines."
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
    echo "   - To exit the script, select option 7 from the main menu."
    echo "   - Remember to run 'source ~/.bash_profile' after exiting to apply any changes made to environment variables."

    echo -e "${GREEN}5. Additional Tips${RESET}"
    echo "   - Always backup your keys and important data before performing operations like deleting the node."
    echo "   - Regularly update your node to the latest version to ensure compatibility and security."

    echo -e "${GREEN}6. Option Descriptions and Guides${RESET}"
    echo -e "${GREEN}Node Interactions:${RESET}"
    echo "   a. Deploy/re-Deploy Validator Node: Deploys or re-deploys the validator node."
    echo "   b. Show Validator Node Status: Displays the status of the validator node."
    echo "   c. Show Validator Node Logs: Displays logs for the validator node."
    echo "   d. Apply Snapshot: Applies a snapshot to the node."
    echo "   e. Add Seeds: Adds seeds to the node."
    echo "   f. Add Peers: Adds peers to the node."

    echo -e "${GREEN}Validator/Key Interactions:${RESET}"
    echo "   a. Create Validator: Creates a new validator for staking SACAS tokens."
    echo "   b. Query Balance: Queries the balance of a wallet."
    echo "   c. Stake Tokens: Stakes tokens to support network security or unstakes them as required."
    echo "   d. Redelegate Tokens: Redelegates tokens to another validator."
    echo "   e. Withdraw Unbonded Tokens: Withdraws unbonded tokens from a validator."
    echo "   f. Claim Rewards: Claims rewards from a validator."
    echo "   g. Transfer Tokens: Transfers tokens between transparent and shielded accounts."

    echo -e "${GREEN}Node Management:${RESET}"
    echo "   a. Restart Validator Node: Restarts the validator node."
    echo "   b. Stop Validator Node: Stops the validator node."
    echo "   c. Backup Validator Key: Backs up the validator key to your $HOME directory."
    echo "   d. Delete Validator Node: Deletes the validator node. Ensure you backup your seeds phrase and priv_validator_key.json before proceeding."

    echo -e "${GREEN}Install Sacas App:${RESET}"
    echo "   - Use this option to install the Sacas app (v0.20.0) for command-line transactions and network interactions without running a node."

    echo -e "${GREEN}Show Grand Valley's Endpoints:${RESET}"
    echo "   - Displays Grand Valley's public endpoints."

    echo -e "${GREEN}Show Guidelines:${RESET}"
    echo "   - Displays these guidelines."

    echo -e "\n${YELLOW}Press Enter to go back to Valley of Sacas main menu${RESET}"
    read -r
    menu
}

# Menu function
function menu() {
    echo -e "${CYAN}Valley of Sacas${RESET}"
    echo -e "${CYAN}Sacas Validator Node = Consensus Client Service + Execution Client Service (sacasd)${RESET}"
    echo "Main Menu:"
    echo -e "${GREEN}1. Node Interactions:${RESET}"
    echo "   a. Deploy/re-Deploy Validator Node"
    echo "   b. Show Validator Node Status"
    echo "   c. Show Validator Node Logs"
    echo "   d. Apply Snapshot"
    echo "   e. Add Seeds"
    echo "   f. Add Peers"
    echo -e "${GREEN}2. Validator/Key Interactions:${RESET}"
    echo "   a. Create Validator"
    echo "   b. Query Balance"
    echo "   c. Stake Tokens"
    echo "   d. Redelegate Tokens"
    echo "   e. Withdraw Unbonded Tokens"
    echo "   f. Claim Rewards"
    echo "   g. Transfer Tokens"
    echo -e "${GREEN}3. Node Management:${RESET}"
    echo "   a. Restart Validator Node"
    echo "   b. Stop Validator Node"
    echo "   c. Backup Validator Key (store it to $HOME directory)"
    echo "   d. Delete Validator Node (BACKUP YOUR SEEDS PHRASE AND priv_validator_key.json BEFORE YOU DO THIS)"
    echo -e "${GREEN}4. Install the Sacas App (v0.20.0) only to execute transactions without running a node${RESET}"
    echo -e "${YELLOW}5. Show Grand Valley's Endpoints${RESET}"
    echo -e "${YELLOW}6. Show Guidelines${RESET}"
    echo -e "${RED}7. Exit${RESET}"

    echo -e "\n${YELLOW}Please run the following command to apply the changes after exiting the script:${RESET}"
    echo -e "${GREEN}source ~/.bash_profile${RESET}"
    echo -e "${YELLOW}This ensures the environment variables are set in your current bash session.${RESET}"
    echo -e "${GREEN}Let's Buidl Sacas Together - Grand Valley${RESET}"
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
                b) show_validator_node_status ;;
                c) show_validator_node_logs ;;
                d) apply_snapshot ;;
                e) add_seeds ;;
                f) add_peers ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        2)
            case $SUB_OPTION in
                a) create_validator ;;
                b) query_balance ;;
                c) stake_tokens ;;
                d) redelegate_tokens ;;
                e) withdraw_unbonded_tokens ;;
                f) claim_rewards ;;
                g) transfer_tokens ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        3)
            case $SUB_OPTION in
                a) restart_validator_node ;;
                b) stop_validator_node ;;
                c) backup_validator_key ;;
                d) delete_validator_node ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        4) install_sacas_app ;;
        5) show_endpoints ;;
        6) show_guidelines ;;
        7) exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
}

# Start menu
menu
