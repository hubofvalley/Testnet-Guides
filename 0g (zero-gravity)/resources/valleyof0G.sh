#!/bin/bash

LOGO="
 __      __     _  _                        __    ___    _____  
 \ \    / /    | || |                      / _|  / _ \  / ____| 
  \ \  / /__ _ | || |  ___  _   _    ___  | |_  | | | || |  __  
  _\ \/ // _` || || | / _ \| | | |  / _ \ |  _| | | | || | |_ | 
 | |\  /| (_| || || ||  __/| |_| | | (_) || |   | |_| || |__| | 
 | |_\/  \__,_||_||_| \___| \__, |  \___/ |_|    \___/  \_____| 
 | _ \ | | | |              __/ |                              
 | |_) || |_| |             |___/                               
 |___/  \__, |                                                 
          __/ |                                                 
         |___/                                                  

 __                                   
/__ ._ _. ._   _|   \  / _. | |  _    
\_| | (_| | | (_|    \/ (_| | | (/_ \/
                                    /
"

INTRO="
Valley Of 0G by Grand Valley

0G Validator Node System Requirements
| Category  | Requirements                   |
| --------- | ------------------------------ |
| CPU       | 8 cores                        |
| RAM       | 64+ GB                         |
| Storage   | 1+ TB NVMe SSD                 |
| Bandwidth | 100 MBps for Download / Upload |

validator node current binaries version: v0.2.5 will automatically update to the latest version
service file name: 0gchaind.service
current chain : zgtendermint_16600-2

------------------------------------------------------------------

Storage Node System Requirements
| Category  | Requirements                   |
| --------- | ------------------------------ |
| CPU       | 8+ cores                       |
| RAM       | 32+ GB                         |
| Storage   | 500GB / 1TB NVMe SSD           |
| Bandwidth | 100 MBps for Download / Upload |

storage node current binary version: v0.6.1

------------------------------------------------------------------

Storage KV System Requirements
| Category | Requirements                                |
| -------- | ------------------------------------------- |
| CPU      | 8+ cores                                    |
| RAM      | 32+ GB                                      |
| Storage  | Matches the size of kv streams it maintains |

storage kvs current binary version: v1.2.2

------------------------------------------------------------------
"

ENDPOINTS="
Grand Valley 0G public endpoints:
- cosmos rpc: https://lightnode-rpc-0g.grandvalleys.com
- json-rpc: https://lightnode-json-rpc-0g.grandvalleys.com
- cosmos rest-api: https://lightnode-api-0g.grandvalleys.com

Grand Valley social media:
- X: https://x.com/bacvalley
- GitHub: https://github.com/hubofvalley
- Email: letsbuidltogether@grandvalleys.com
"

# Display LOGO and wait for user input to continue
echo "$LOGO"
echo -e "\nPress Enter to continue..."
read -r

# Display INTRO section and wait for user input to continue
echo "$INTRO"
echo -e "\nPress Enter to continue"
read -r

# Display ENDPOINTS section
echo "$ENDPOINTS"

# Validator Node Functions
function deploy_validator_node() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_validator_node_install.sh)
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
    --details="let's buidl 0g together" \
    --gas=auto --gas-adjustment=1.4 \
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
    0gchaind tx bank send $SENDER_WALLET $RECIPIENT_ADDRESS $AMOUNT --chain-id $OG_CHAIN_ID --gas auto --fees 5000ua0gi -y
    menu
}

function stake_tokens() {
    read -p "Enter wallet name: " WALLET_NAME
    read -p "Enter validator address: " VALIDATOR_ADDRESS
    read -p "Enter amount to stake: " AMOUNT
    0gchaind tx staking delegate $VALIDATOR_ADDRESS $AMOUNT --from $WALLET_NAME --chain-id $OG_CHAIN_ID --gas auto --fees 5000ua0gi -y
    menu
}

function unstake_tokens() {
    read -p "Enter wallet name: " WALLET_NAME
    read -p "Enter validator address: " VALIDATOR_ADDRESS
    read -p "Enter amount to unstake: " AMOUNT
    0gchaind tx staking unbond $VALIDATOR_ADDRESS $AMOUNT --from $WALLET_NAME --chain-id $OG_CHAIN_ID --gas auto --fees 5000ua0gi -y
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
    sudo systemctl stop 0gchaind
    sudo systemctl disable 0gchaind
    sudo rm -rf /etc/systemd/system/0gchaind.service
    sudo rm -r 0g-chain
    sudo rm -rf $HOME/.0gchain
    sed -i "/OG_/d" $HOME/.bash_profile
    echo "Validator node deleted successfully."
    menu
}

function show_validator_logs() {
    sudo journalctl -u 0gchaind -fn 100
    menu
}

function show_node_status() {
    0gchaind status | jq
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

# Storage KV Functions
function deploy_storage_kv() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_storage_kv_install.sh)
    menu
}

function show_storage_kv_logs() {
    sudo journalctl -u zgskv -fn 100
    menu
}

# Menu
function menu() {
    echo "1. Validator Node"
    echo "    a. Deploy Validator Node"
    echo "    b. Create Validator"
    echo "    c. Query Balance"
    echo "    d. Send Transaction"
    echo "    e. Stake Tokens"
    echo "    f. Unstake Tokens"
    echo "    g. Export EVM Private Key"
    echo "    h. Restore Wallet"
    echo "    i. Create Wallet"
    echo "    j. Delete Validator Node"
    echo "    k. Show Validator Logs"
    echo "    l. Show Node Status"
    echo "2. Storage Node"
    echo "    a. Deploy Storage Node"
    echo "    b. Update Storage Node"
    echo "    c. Delete Storage Node"
    echo "    d. Change Storage Node"
    echo "    e. Show Storage Node Logs"
    echo "3. Storage KV"
    echo "    a. Deploy Storage KV"
    echo "    b. Show Storage KV Logs"
    echo "4. Exit"
    read -p "Choose an option: " OPTION

    case $OPTION in
        1)
            read -p "Choose a sub-option: " SUB_OPTION
            case $SUB_OPTION in
                a) deploy_validator_node ;;
                b) create_validator ;;
                c) query_balance ;;
                d) send_transaction ;;
                e) stake_tokens ;;
                f) unstake_tokens ;;
                g) export_evm_private_key ;;
                h) restore_wallet ;;
                i) create_wallet ;;
                j) delete_validator_node ;;
                k) show_validator_logs ;;
                l) show_node_status ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        2)
            read -p "Choose a sub-option: " SUB_OPTION
            case $SUB_OPTION in
                a) deploy_storage_node ;;
                b) update_storage_node ;;
                c) delete_storage_node ;;
                d) change_storage_node ;;
                e) show_storage_logs ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        3)
            read -p "Choose a sub-option: " SUB_OPTION
            case $SUB_OPTION in
                a) deploy_storage_kv ;;
                b) show_storage_kv_logs ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        4) exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
}

# Run the menu
while true; do
    menu
done
