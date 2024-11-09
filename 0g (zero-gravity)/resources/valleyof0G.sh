#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
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
Valley Of 0G by Grand Valley

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

storage node current binary version: ${CYAN}v0.6.1${RESET}

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

ENDPOINTS="${GREEN}
Grand Valley 0G public endpoints:${RESET}
- cosmos-rpc: ${BLUE}https://lightnode-rpc-0g.grandvalleys.com${RESET}
- evm-rpc: ${BLUE}https://lightnode-json-rpc-0g.grandvalleys.com${RESET}
- cosmos rest-api: ${BLUE}https://lightnode-api-0g.grandvalleys.com${RESET}

${GREEN}Connect with Zero Gravity (0G):${RESET}
- Official Website: ${BLUE}https://0g.ai/${RESET}
- X: ${BLUE}https://x.com/0G_labs${RESET}
- Official Docs: ${BLUE}https://docs.0g.ai/${RESET}

${GREEN}Connect with Grand Valley:${RESET}
- X: ${BLUE}https://x.com/bacvalley${RESET}
- GitHub: ${BLUE}https://github.com/hubofvalley${RESET}
- Email: ${BLUE}letsbuidltogether@grandvalleys.com${RESET}
"

# Display LOGO and wait for user input to continue
echo -e "$LOGO"
echo -e "${YELLOW}\nPress Enter to continue...${RESET}"
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
echo -e "${YELLOW}Current service file name: $SERVICE_FILE_NAME${RESET}"
source $HOME/.bash_profile

# Function to detect the service file name
function detect_service_file() {
  if [[ -f "/etc/systemd/system/0gchaind.service" ]]; then
    SERVICE_FILE_NAME="0gchaind.service"
  elif [[ -f "/etc/systemd/system/0gd.service" ]]; then
    SERVICE_FILE_NAME="0gd.service"
  else
    echo "No valid service file found (0gchaind.service or 0gd.service)."
    exit 1
  fi
}

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
    echo -e "\n${YELLOW}Press Enter to continue${RESET}"
    read -r
    menu
}

# Menu function
function menu() {
    echo "Menu:"
    echo -e "${GREEN}1. Validator Node${RESET}"
    echo "    a. Deploy Validator Node"
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
    echo "    p. Stop Validator Node"
    echo "    q. Restart Validator Node"
    echo "    r. Delete Validator Node (BACKUP YOUR SEEDS PHRASE/EVM-PRIVATE KEY AND priv_validator_key.json BEFORE YOU DO THIS)"
    echo "    s. Install 0gchain App only (v0.4.0)(for executing transactions without running the node)"
    echo -e "${GREEN}2. Storage Node${RESET}"
    echo "    a. Deploy Storage Node"
    echo "    b. Update Storage Node"
    echo "    c. Delete Storage Node"
    echo "    d. Change Storage Node"
    echo "    e. Show Storage Node Logs"
    echo "    f. Show Storage Node Status"
    echo "    g. Stop Storage Node"
    echo "    h. Restart Storage Node"
    echo -e "${GREEN}3. Storage KV${RESET}"
    echo "    a. Deploy Storage KV"
    echo "    b. Show Storage KV Logs"
    echo "    c. Update Storage KV"
    echo "    d. Delete Storage KV"
    echo "    e. Stop Storage KV"
    echo "    f. Restart Storage KV"
    echo -e "${GREEN}4. Show Grand Valley's Endpoints${RESET}"
    echo -e "${RED}5. Exit${RESET}"

    echo -e "${GREEN}Let's Buidl 0G Together - Grand Valley${RESET}"
    read -p "Choose an option (e.g., 1a or 1 then a): " OPTION

    if [[ $OPTION =~ ^[1-3][a-s]$ ]]; then
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
                p) stop_validator_node ;;
                q) restart_validator_node ;;
                r) delete_validator_node ;;
                s) install_0gchain_app ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        2)
            case $SUB_OPTION in
                a) deploy_storage_node ;;
                b) update_storage_node ;;
                c) delete_storage_node ;;
                d) change_storage_node ;;
                e) show_storage_logs ;;
                f) show_storage_status ;;
                g) stop_storage_node ;;
                h) restart_storage_node ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        3)
            case $SUB_OPTION in
                a) deploy_storage_kv ;;
                b) show_storage_kv_logs ;;
                c) update_storage_kv ;;
                d) delete_storage_kv ;;
                e) stop_storage_kv ;;
                f) restart_storage_kv ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        4) show_endpoints ;;
        5) exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
}

# Call the menu function to start the script
menu
