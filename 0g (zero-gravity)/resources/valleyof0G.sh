#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
ORANGE='\033[38;5;214m'
RESET='\033[0m'

LOGO="
 __      __     _  _                        __    ___    _____ 
 \ \    / /    | || |                      / _|  / _ \  / ____|
  \ \  / /__ _ | || |  ___  _   _    ___  | |_  | | | || |  __ 
  _\ \/ // __ || || | / _ \| | | |  / _ \ |  _| | | | || | |_ |
 | |\  /| (_| || || ||  __/| |_| | | (_) || |   | |_| || |__| |
 | |_\/  \__,_||_||_| \___| \__, |  \___/ |_|    \___/  \_____|
 | '_ \ | | | |              __/ |                             
 | |_) || |_| |             |___/                              
 |____/  \__, |                                                
          __/ |                                                
         |___/                                                 
 __                                   
/__ __ __ __   _|   \  / __ | |  _    
\_| | (_| | | (_|    \/ (_| | | (/_ \/
                                    /
"

INTRO="
Valley of 0G by ${ORANGE}Grand Valley${RESET}

${GREEN}0G Validator Node System Requirements${RESET}
${YELLOW}| Category  | Requirements                   |
| --------- | ------------------------------ |
| CPU       | 8 cores                        |
| RAM       | 64+ GB                         |
| Storage   | 1+ TB NVMe SSD                 |
| Bandwidth | 100 MBps for Download / Upload |${RESET}

validator node current binaries version: ${CYAN}v0.2.5${RESET} will automatically update to the latest version
service file name: ${CYAN}0gchaind.service${RESET}
current chain : ${CYAN}zgtendermint_16600-2${RESET}

------------------------------------------------------------------

${GREEN}Storage Node System Requirements${RESET}
${YELLOW}| Category  | Requirements                   |
| --------- | ------------------------------ |
| CPU       | 8+ cores                       |
| RAM       | 32+ GB                         |
| Storage   | 500GB / 1TB NVMe SSD           |
| Bandwidth | 100 MBps for Download / Upload |${RESET}

storage node current binary version: ${CYAN}v0.8.4${RESET}

------------------------------------------------------------------

${GREEN}Storage KV System Requirements${RESET}
${YELLOW}| Category | Requirements                                |
| -------- | ------------------------------------------- |
| CPU      | 8+ cores                                    |
| RAM      | 32+ GB                                      |
| Storage  | Matches the size of kv streams it maintains |${RESET}

storage kvs current binary version: ${CYAN}v1.2.2${RESET}

------------------------------------------------------------------
"

PRIVACY_SAFETY_STATEMENT="
${YELLOW}Privacy and Safety Statement${RESET}

${GREEN}No User Data Stored Externally${RESET}
- This script does not store any user data externally. All operations are performed locally on your machine.

${GREEN}No Phishing Links${RESET}
- This script does not contain any phishing links. All URLs and commands are provided for legitimate purposes related to 0G validator node operations.

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
Grand Valley 0G public endpoints:${RESET}
- cosmos-rpc: \e]8;;https://lightnode-rpc-0g.grandvalleys.com\a${BLUE}https://lightnode-rpc-0g.grandvalleys.com\e]8;;\a${RESET}
- evm-rpc: ${BLUE}https://lightnode-json-rpc-0g.grandvalleys.com${RESET}
- cosmos rest-api: ${BLUE}https://lightnode-api-0g.grandvalleys.com${RESET}
- peer: ${BLUE}65f62fc8e46ff89f7960bc30e2fc1c0e4a846340@peer-0g.grandvalleys.com:26656${RESET}
- Grand Valley Explorer: ${BLUE}https://explorer.grandvalleys.com${RESET}

${GREEN}Connect with Zero Gravity (0G):${RESET}
- Official Website: \e]8;;https://0g.ai/\a${BLUE}https://0g.ai/\e]8;;\a${RESET}
- X: \e]8;;https://x.com/0G_labs\a${BLUE}https://x.com/0G_labs\e]8;;\a${RESET}
- Official Docs: \e]8;;https://docs.0g.ai/\a${BLUE}https://docs.0g.ai/\e]8;;\a${RESET}

${GREEN}Connect with Grand Valley:${RESET}
- X: \e]8;;https://x.com/bacvalley\a${BLUE}https://x.com/bacvalley\e]8;;\a${RESET}
- GitHub: \e]8;;https://github.com/hubofvalley\a${BLUE}https://github.com/hubofvalley\e]8;;\a${RESET}
- 0G Testnet Guide on GitHub by Grand Valley: ${BLUE}https://github.com/hubofvalley/Testnet-Guides/tree/main/0g%20(zero-gravity)${RESET}
- Email: \e]8;;mailto:letsbuidltogether@grandvalleys.com\a${BLUE}letsbuidltogether@grandvalleys.com\e]8;;\a${RESET}
"

# Function to detect the service file name
function detect_service_file() {
  if [[ -f "/etc/systemd/system/0gchaind.service" ]]; then
    SERVICE_FILE_NAME="0gchaind.service"
  elif [[ -f "/etc/systemd/system/0gd.service" ]]; then
    SERVICE_FILE_NAME="0gd.service"
  else
    SERVICE_FILE_NAME="Not found"
    echo -e "${RED}No valid service file found (0gchaind.service or 0gd.service). Continuing without setting a service file name.${RESET}"
  fi
}

# Display LOGO and wait for user input to continue
echo -e "$LOGO"
echo -e "$PRIVACY_SAFETY_STATEMENT"
echo -e "\n${YELLOW}Press Enter to continue...${RESET}"
read -r

# Display INTRO section and wait for user input to continue
echo -e "$INTRO"
echo -e "$ENDPOINTS"
echo -e "${YELLOW}\nPress Enter to continue${RESET}"
read -r
detect_service_file
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile
echo "export OG_CHAIN_ID="zgtendermint_16600-2"" >> $HOME/.bash_profile
echo "export SERVICE_FILE_NAME=\"$SERVICE_FILE_NAME\"" >> ~/.bash_profile
echo "export DAEMON_NAME=0gchaind" >> ~/.bash_profile
echo "export DAEMON_HOME=$(find $HOME -type d -name ".0gchain" -print -quit)" >> ~/.bash_profile
echo "export DAEMON_DATA_BACKUP_DIR=$(find "$HOME/.0gchain/cosmovisor" -type d -name "backup" -print -quit)" >> ~/.bash_profile
source $HOME/.bash_profile

# Validator Node Functions
function deploy_validator_node() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_validator_node_install.sh)
    menu
}

function migrate_to_cosmovisor() {
    echo "The service file for your current validator node will be updated to match Grand Valley's current configuration."
    echo "Press Enter to continue..."
    read -r
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20\(zero-gravity\)/resources/cosmovisor_migration.sh)
    menu
}

function apply_snapshot() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20\(zero-gravity\)/resources/apply_snapshot.sh)
    menu
}

function install_0gchain_app() {
    cd $HOME
    mkdir -p 0gchain-v0.4.0
    wget -O 0gchain-v0.4.0/0gchaind https://github.com/0glabs/0g-chain/releases/download/v0.4.0/0gchaind-linux-v0.4.0
    cp 0gchain-v0.4.0/0gchaind $HOME/go/bin/0gchaind
    sudo chown -R $USER:$USER $HOME/go/bin/0gchaind
    sudo chmod +x $HOME/go/bin/0gchaind
    echo "0gchain app installed successfully."
    menu
}

function create_validator() {
    read -p "Enter wallet name: " WALLET
    read -p "Enter validator name (moniker): " MONIKER
    read -p "Enter your identity: " IDENTITY
    read -p "Enter your website URL: " WEBSITE
    read -p "Enter your email: " EMAIL

    0gchaind tx staking create-validator \
    --amount=1000000ua0gi \
    --pubkey=$(0gchaind tendermint show-validator) \
    --moniker=$MONIKER \
    --chain-id=$OG_CHAIN_ID \
    --commission-rate=0.10 \
    --commission-max-rate=0.20 \
    --commission-max-change-rate=0.01 \
    --min-self-delegation=1 \
    --from=$WALLET \
    --identity=$IDENTITY \
    --website=$WEBSITE \
    --security-contact=$EMAIL \
    --details="lets buidl 0g together" \
    --gas auto --gas-adjustment 1.4 \
    -y
    menu
}

function query_balance() {
    read -p "Enter wallet address: " WALLET_ADDRESS
    0gchaind query bank balances $WALLET_ADDRESS --chain-id $OG_CHAIN_ID
    echo -e "\n${YELLOW}Press Enter to go back to main menu${RESET}"
    read -r
    menu
}

function send_transaction() {
    read -p "Enter sender wallet name: " SENDER_WALLET
    read -p "Enter recipient wallet address: " RECIPIENT_ADDRESS
    read -p "Enter amount to send: " AMOUNT
    0gchaind tx bank send $SENDER_WALLET $RECIPIENT_ADDRESS ${AMOUNT}ua0gi --chain-id $OG_CHAIN_ID --gas auto --gas-adjustment 1.4 -y
    menu
}

function stake_tokens() {
    DEFAULT_WALLET=$WALLET  # Assuming $WALLET is set elsewhere in your script
    while true; do
        read -p "Enter wallet name (leave empty to use current default wallet --> $DEFAULT_WALLET): " WALLET_NAME
        if [ -z "$WALLET_NAME" ]; then
            WALLET_NAME=$DEFAULT_WALLET
        fi

        # Get wallet address
        WALLET_ADDRESS=$(0gchaind keys list | grep -E 'address:' | sed 's/[^:]*: //')

        if [ -n "$WALLET_ADDRESS" ]; then
            break
        else
            echo "Wallet name not found. Please check the wallet name and try again."
        fi
    done

    echo "Using wallet: $WALLET_NAME ($WALLET_ADDRESS)"

    echo "Choose an option:"
    echo "1. Delegate to Grand Valley"
    echo "2. Self-delegate"
    echo "3. Delegate to another validator"
    read -p "Enter your choice (1, 2, or 3): " CHOICE

    read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE

    case $CHOICE in
        1)
            read -p "Enter amount to stake: " AMOUNT
            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                0gchaind tx staking delegate 0gvaloper1yzwlgyrgcg83u32fclz0sy2yhxsuzpvprrt5r4 ${AMOUNT}ua0gi --from $WALLET_NAME --chain-id $OG_CHAIN_ID --gas auto --gas-adjustment 1.4 --node https://lightnode-rpc-0g.grandvalleys.com:443 -y
            else
                0gchaind tx staking delegate 0gvaloper1yzwlgyrgcg83u32fclz0sy2yhxsuzpvprrt5r4 ${AMOUNT}ua0gi --from $WALLET_NAME --chain-id $OG_CHAIN_ID --gas auto --gas-adjustment 1.4 -y
            fi
            ;;
        2)
            read -p "Enter amount to stake: " AMOUNT
            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                0gchaind tx staking delegate $(0gchaind keys show $WALLET_NAME --bech val -a) ${AMOUNT}ua0gi --from $WALLET_NAME --chain-id $OG_CHAIN_ID --gas auto --gas-adjustment 1.4 --node https://lightnode-rpc-0g.grandvalleys.com:443 -y
            else
                0gchaind tx staking delegate $(0gchaind keys show $WALLET_NAME --bech val -a) ${AMOUNT}ua0gi --from $WALLET_NAME --chain-id $OG_CHAIN_ID --gas auto --gas-adjustment 1.4 -y
            fi
            ;;
        3)
            read -p "Enter validator address: " VALIDATOR_ADDRESS
            read -p "Enter amount to stake: " AMOUNT
            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                0gchaind tx staking delegate $VALIDATOR_ADDRESS ${AMOUNT}ua0gi --from $WALLET_NAME --chain-id $OG_CHAIN_ID --gas auto --gas-adjustment 1.4 --node https://lightnode-rpc-0g.grandvalleys.com:443 -y
            else
                0gchaind tx staking delegate $VALIDATOR_ADDRESS ${AMOUNT}ua0gi --from $WALLET_NAME --chain-id $OG_CHAIN_ID --gas auto --gas-adjustment 1.4 -y
            fi
            ;;
        *)
            echo "Invalid choice. Please enter 1, 2, or 3."
            ;;
    esac

    menu
}

function unstake_tokens() {
    DEFAULT_WALLET=$WALLET  # Assuming $WALLET is set elsewhere in your script
    while true; do
        read -p "Enter wallet name (leave empty to use current default wallet --> $DEFAULT_WALLET): " WALLET_NAME
        if [ -z "$WALLET_NAME" ]; then
            WALLET_NAME=$DEFAULT_WALLET
        fi

        # Get wallet address
        WALLET_ADDRESS=$(0gchaind keys list | grep -E 'address:' | sed 's/[^:]*: //')

        if [ -n "$WALLET_ADDRESS" ]; then
            break
        else
            echo "Wallet name not found. Please check the wallet name and try again."
        fi
    done

    echo "Using wallet: $WALLET_NAME ($WALLET_ADDRESS)"

    read -p "Enter validator address: " VALIDATOR_ADDRESS
    read -p "Enter amount to unstake: " AMOUNT

    read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE

    if [ "$RPC_CHOICE" == "grandvalley" ]; then
        0gchaind tx staking unbond $VALIDATOR_ADDRESS ${AMOUNT}ua0gi --from $WALLET_NAME --chain-id $OG_CHAIN_ID --gas auto --gas-adjustment 1.4 --node https://lightnode-rpc-0g.grandvalleys.com:443 -y
    else
        0gchaind tx staking unbond $VALIDATOR_ADDRESS ${AMOUNT}ua0gi --from $WALLET_NAME --chain-id $OG_CHAIN_ID --gas auto --gas-adjustment 1.4 -y
    fi

    menu
}

function export_evm_private_key() {
    read -p "Enter wallet name: " WALLET_NAME
    0gchaind keys unsafe-export-eth-key $WALLET_NAME
    echo -e "\n${YELLOW}Press Enter to go back to main menu${RESET}"
    read -r
    menu
}

function restore_wallet() {
    read -p "Enter wallet name: " WALLET_NAME
    0gchaind keys add $WALLET_NAME --recover --eth
    menu
}

function create_wallet() {
    read -p "Enter wallet name: " WALLET_NAME
    0gchaind keys add $WALLET_NAME --eth
    menu
}

function delete_validator_node() {
    sudo systemctl stop $SERVICE_FILE_NAME
    sudo systemctl disable $SERVICE_FILE_NAME
    sudo rm -rf /etc/systemd/system/$SERVICE_FILE_NAME
    sudo rm -r 0g-chain
    sudo rm $HOME/go/bin/0gchaind
    sudo rm -rf $HOME/.0gchain
    sed -i "/OG_/d" $HOME/.bash_profile
    echo "Validator node deleted successfully."
    menu
}

function show_validator_logs() {
    sudo journalctl -u $SERVICE_FILE_NAME -fn 100
    menu
}

function show_node_status() {
    0gchaind status | jq
    realtime_block_height=$(curl -s -X POST "https://evmrpc-testnet.0g.ai" -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r '.result' | xargs printf "%d\n")
    node_height=$(0gchaind status | jq -r '.sync_info.latest_block_height')
    echo "Validator node block height: $node_height"
    block_difference=$(( realtime_block_height - node_height ))
    echo "Real-time Block Height: $realtime_block_height"
    echo -e "${YELLOW}Block Difference:${NC} $block_difference"

    # Add explanation for negative values
    if (( block_difference < 0 )); then
        echo -e "${GREEN}Note:${NC} A negative value is normal - this means 0G's official RPC block height is currently behind your node's height"
    fi
    echo -e "\n${YELLOW}Press Enter to go back to main menu${RESET}"
    read -r
    menu
}

function stop_validator_node() {
    sudo systemctl stop $SERVICE_FILE_NAME
    menu
}

function restart_validator_node() {
    sudo systemctl daemon-reload
    sudo systemctl restart $SERVICE_FILE_NAME
    menu
}

function backup_validator_key() {
    cp $HOME/.0gchain/config/priv_validator_key.json $HOME/priv_validator_key.json
    echo -e "\n${YELLOW}Your priv_vaidator_key.json file has been copied to $HOME${RESET}"
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
                sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.0gchain/config/config.toml
                echo "Peers added manually."
            else
                echo "Operation cancelled. Returning to menu."
                menu
            fi
            ;;
        2)
            peers=$(curl -sS https://lightnode-rpc-0g.grandvalleys.com/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
            echo "Grand Valley's peers: $peers"
            read -p "Do you want to proceed? (yes/no): " confirm
            if [[ $confirm == "yes" ]]; then
                sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.0gchain/config/config.toml
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

# Storage Node Functions
function deploy_storage_node() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_storage_node_install.sh)
    menu
}

function update_storage_node() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_storage_node_update.sh)
    menu
}

function delete_storage_node() {
    sudo systemctl stop zgs
    sudo systemctl disable zgs
    sudo rm -rf /etc/systemd/system/zgs.service
    sudo rm -r $HOME/0g-storage-node
    echo "Storage node deleted successfully."
    menu
}

function change_storage_node() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_storage_node_change.sh)
    menu
}

function show_storage_logs() {
    tail -f ~/0g-storage-node/run/log/zgs.log.$(TZ=UTC date +%Y-%m-%d)
    menu
}

function show_storage_status() {
    curl -X POST http://localhost:5678 -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"zgs_getStatus","params":[],"id":1}'  | jq
    echo -e "\n${YELLOW}Press Enter to go back to main menu${RESET}"
    read -r
    menu
}

function stop_storage_node() {
    sudo systemctl stop zgs
    menu
}

function restart_storage_node() {
    sudo systemctl daemon-reload
    sudo systemctl restart zgs
    menu
}

# Storage KV Functions
function deploy_storage_kv() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_storage_kv_install.sh)
    menu
}

function show_storage_kv_logs() {
    sudo journalctl -u zgskv -fn 100
    menu
}

function delete_storage_kv() {
    sudo systemctl stop zgskv
    sudo systemctl disable zgskv
    sudo rm -rf /etc/systemd/system/zgskv.service
    sudo rm -r $HOME/0g-storage-kv
    echo "Storage KV deleted successfully."
    menu
}

function update_storage_kv() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_storage_kv_update.sh)
    menu
}

function stop_storage_kv() {
    sudo systemctl stop zgskv
    menu
}

function restart_storage_kv() {
    sudo systemctl daemon-reload
    sudo systemctl restart zgskv
    menu
}

# Show Grand Valley's Endpoints
function show_endpoints() {
    echo -e "$ENDPOINTS"
    echo -e "\n${YELLOW}Press Enter to go back to main menu${RESET}"
    read -r
    menu
}

# Function to show guidelines
function show_guidelines() {
    echo -e "${CYAN}Guidelines on How to Use the Valley of 0G${RESET}"
    echo -e "${YELLOW}This tool is designed to help you manage your 0G Validator Node. Below are the guidelines on how to use it effectively:${RESET}"
    echo -e "${GREEN}1. Navigating the Menu${RESET}"
    echo "   - The menu is divided into several sections: Node Interactions, Validator/Key Interactions, Node Management, Show Grand Valley's Endpoints, and Guidelines."
    echo "   - To select an option, you can either:"
    echo "     a. Enter the corresponding number followed by the letter (e.g., 1a for Deploy/re-Deploy Validator Node)."
    echo "     b. Enter the number, press Enter, and then enter the letter (e.g., 1 then a)."
    echo "   - For sub-options, you will be prompted to enter the letter corresponding to your choice."
    echo -e "${GREEN}2. Entering Choices${RESET}"
    echo "   - For any prompt that has choices, you only need to enter the numbering (1, 2, 3, etc.) or the letter (a, b, c, etc.)."
    echo "   - For y/n prompts, enter 'y' for yes and 'n' for no."
    echo "   - For yes/no prompts, enter 'yes' for yes and 'no' for no."
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
    echo "   d. Add Peers: Adds peers to the node, either manually or using Grand Valley's peers for better connectivity."
    echo "      - Guide: Use this option to add peers to your node. You can either enter peers manually or use Grand Valley's peers."
    echo "   e. Show Node Status: Displays the current status of your validator node. It will display relevant information about your node's health."
    echo "   f. Show Validator Logs: Displays logs specifically for the validator."
    echo "   g. Create Validator: Creates a new validator."
    echo "      - Guide: This option will guide you through creating a new validator. You will need to provide details such as the moniker and staking amount."
    echo "   h. Create Wallet: Creates a new wallet."
    echo "   i. Restore Wallet: Restores an existing wallet."
    echo "   j. Query Balance: Queries the balance of a specified EVM address."
    echo "   k. Send Transaction: Sends a transaction between two wallets."
    echo "   l. Stake Tokens: Stakes tokens to a validator."
    echo "      - Guide: Use this option to stake tokens to a validator. You can choose to stake to Grand Valley, yourself, or another validator."
    echo "   m. Unstake Tokens: Unstakes tokens from a validator."
    echo "      - Guide: This option will help you unstake tokens from a validator. You can choose to unstake from yourself or another validator."
    echo "   n. Export EVM Private Key: Exports the EVM private key."
    echo "   o. Backup Validator Key: Backs up the validator key to the $HOME directory."
    echo "   p. Install 0gchain App only: Installs the 0gchain app (v0.4.0) for executing transactions without running the node."
    echo -e "${GREEN}Validator/Key Interactions:${RESET}"
    echo "   a. Create Validator"
    echo "   b. Query Validator Public Key"
    echo "   c. Query Balance"
    echo "   d. Stake Tokens"
    echo "   e. Unstake Tokens"
    echo "   f. Export EVM Key"
    echo "   g. Backup Validator Key (store it to $HOME directory)"
    echo -e "${GREEN}Node Management:${RESET}"
    echo "   a. Stop Validator Node: Stops the validator node."
    echo "   b. Restart Validator Node: Restarts the validator node."
    echo "   c. Delete Validator Node: Deletes the validator node. Ensure you backup your seeds phrase/EVM-private key and priv_validator_key.json before doing this."
    echo -e "${GREEN}Show Grand Valley's Endpoints:${RESET}"
    echo "   Displays Grand Valley's public endpoints."
    echo -e "${GREEN}Show Guidelines:${RESET}"
    echo "   Displays these guidelines."
    echo -e "\n${YELLOW}Press Enter to go back to main menu${RESET}"
    read -r
    menu
}

# Menu function
function menu() {
    if [[ -f "/etc/systemd/system/0gchaind.service" ]]; then
    SERVICE_FILE_NAME="0gchaind.service"
    elif [[ -f "/etc/systemd/system/0gd.service" ]]; then
    SERVICE_FILE_NAME="0gd.service"
    else
    SERVICE_FILE_NAME="Not found"
    echo -e "${RED}No valid service file found (0gchaind.service or 0gd.service). Continuing without setting a service file name.${RESET}"
    fi
    realtime_block_height=$(curl -s -X POST "https://evmrpc-testnet.0g.ai" -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r '.result' | xargs printf "%d\n")
    echo -e "${ORANGE}Valley of 0G${RESET}"
    echo "Main Menu:"
    echo -e "${GREEN}1. Validator Node${RESET}"
    echo "    a. Deploy/re-Deploy Validator Node (includes Cosmovisor deployment)"
    echo "    b. Migrate Validator Node to Cosmovisor"
    echo "    c. Apply Snapshot"
    echo "    d. Add Peers"
    echo "    e. Show Node Status"
    echo "    f. Show Validator Logs"
    echo "    g. Create Validator"
    echo "    h. Create Wallet"
    echo "    i. Restore Wallet"
    echo "    j. Query Balance"
    echo "    k. Send Transaction"
    echo "    l. Stake Tokens"
    echo "    m. Unstake Tokens"
    echo "    n. Export EVM Private Key"
    echo "    o. Backup Validator Key (store it to $HOME directory)"
    echo -e "${GREEN}2. Storage Node${RESET}"
    echo "    a. Deploy Storage Node"
    echo "    b. Update Storage Node"
    echo "    c. Change Storage Node"
    echo "    d. Show Storage Node Logs"
    echo "    e. Show Storage Node Status"
    echo -e "${GREEN}3. Storage KV${RESET}"
    echo "    a. Deploy Storage KV"
    echo "    b. Show Storage KV Logs"
    echo "    c. Update Storage KV"
    echo -e "${GREEN}4. Node Management:${RESET}"
    echo "    a. Restart Validator Node"
    echo "    b. Restart Storage Node"
    echo "    c. Restart Storage KV"
    echo "    d. Stop Validator Node"
    echo "    e. Stop Storage Node"
    echo "    f. Stop Storage KV"
    echo "    g. Delete Validator Node (BACKUP YOUR SEEDS PHRASE/EVM-PRIVATE KEY AND priv_validator_key.json BEFORE YOU DO THIS)"
    echo "    h. Delete Storage Node"
    echo "    i. Delete Storage KV"
    echo -e "${GREEN}5. Install the 0gchain App (v0.4.0) only to execute transactions without running a node${RESET}"
    echo -e "${GREEN}6. Show Grand Valley's Endpoints${RESET}"
    echo -e "${YELLOW}7. Show Guidelines${RESET}"
    echo -e "${RED}8. Exit${RESET}"

    echo -e "Latest Block Height: ${GREEN}$realtime_block_height${RESET}"
    echo -e "\n${YELLOW}Please run the following command to apply the changes after exiting the script:${RESET}"
    echo -e "${GREEN}source ~/.bash_profile${RESET}"
    echo -e "${YELLOW}This ensures the environment variables are set in your current bash session.${RESET}"
    echo -e "${GREEN}Let's Buidl 0G Together - Grand Valley${RESET}"
    read -p "Choose an option (e.g., 1a or 1 then a): " OPTION

    if [[ $OPTION =~ ^[1-7][a-z]$ ]]; then
        MAIN_OPTION=${OPTION:0:1}
        SUB_OPTION=${OPTION:1:1}
    else
        MAIN_OPTION=$OPTION
        if [[ $MAIN_OPTION =~ ^[1-4]$ ]]; then
            read -p "Choose a sub-option: " SUB_OPTION
        fi
    fi

    case $MAIN_OPTION in
        1)
            case $SUB_OPTION in
                a) deploy_validator_node ;;
                b) migrate_to_cosmovisor ;;
                c) apply_snapshot ;;
                d) add_peers ;;
                e) show_node_status ;;
                f) show_validator_logs ;;
                g) create_validator ;;
                h) create_wallet ;;
                i) restore_wallet ;;
                j) query_balance ;;
                k) send_transaction ;;
                l) stake_tokens ;;
                m) unstake_tokens ;;
                n) export_evm_private_key ;;
                o) backup_validator_key ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        2)
            case $SUB_OPTION in
                a) deploy_storage_node ;;
                b) update_storage_node ;;
                c) change_storage_node ;;
                d) show_storage_logs ;;
                e) show_storage_status ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        3)
            case $SUB_OPTION in
                a) deploy_storage_kv ;;
                b) show_storage_kv_logs ;;
                c) update_storage_kv ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        4)
            case $SUB_OPTION in
                a) restart_validator_node ;;
                b) restart_storage_node ;;
                c) restart_storage_kv ;;
                d) stop_validator_node ;;
                e) stop_storage_node ;;
                f) stop_storage_kv ;;
                g) delete_validator_node ;;
                h) delete_storage_node ;;
                i) delete_storage_kv ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        5) install_0gchain_app ;;
        6) show_endpoints ;;
        7) show_guidelines ;;
        8) exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
}

# Call the menu function to start the script
menu
