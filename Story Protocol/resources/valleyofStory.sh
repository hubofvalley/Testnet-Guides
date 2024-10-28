#!/bin/bash

LOGO="
 __      __     _  _                        __    _____  _                       
 \ \    / /    | || |                      / _|  / ____|| |                      
  \ \  / /__ _ | || |  ___  _   _    ___  | |_  | (___  | |_  ___   _ __  _   _  
  _\ \/ // _` || || | / _ \| | | |  / _ \ |  _|  \___ \ | __|/ _ \ | '__|| | | | 
 | |\  /| (_| || || ||  __/| |_| | | (_) || |    ____) || |_| (_) || |   | |_| | 
 | |_\/  \__,_||_||_| \___| \__, |  \___/ |_|   |_____/  \__|\___/ |_|    \__, | 
 | '_ \ | | | |              __/ |                                         __/ | 
 | |_) || |_| |             |___/                                         |___/  
 |_.__/  \__, |                                                                  
          __/ |                                                                  
         |___/                                                                   
 __                                   
/__ ._ _. ._   _|   \  / _. | |  _    
\_| | (_| | | (_|    \/ (_| | | (/_ \/
                                    /
"

INTRO="
Valley Of 0G by Grand Valley

Story Validator Node System Requirements

| Category  | Requirements     |
| --------- | ---------------- |
| CPU       | 8+ cores         |
| RAM       | 32+ GB           |
| Storage   | 500+ GB NVMe SSD |
| Bandwidth | 100+ MBit/s         |

- service file name: `story.service` `story-geth.service`
- current chain: `odyssey`
- current story node version: `v0.12.0`
- current story-geth node version: `v0.10.0`

"

ENDPOINTS="
Grand Valley Story Protocol public endpoints:
- cosmos rpc: `https://lightnode-rpc-story.grandvalleys.com`
- json-rpc: `https://lightnode-json-rpc-story.grandvalleys.com`
- cosmos rest-api: `https://lightnode-api-story.grandvalleys.com`
- cosmos ws: `wss://lightnode-rpc-story.grandvalleys.com/websocket`
- evm ws: `wss://lightnode-wss-story.grandvalleys.com`

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
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/Story%20Protocol/resources/story_validator_node_install_odyssey)
    menu
}

function create_validator() {
    read -p "Enter your private key: " PRIVATE_KEY
    story validator create --stake 1000000000000000000 --private-key $(grep -oP '(?<=PRIVATE_KEY=).*' $HOME/.story/story/config/private_key.txt)
    menu
}

function query_validator_pub_key() {
    story validator export | grep -oP '(?<=Compressed Public Key (base64): ).*'
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
            geth --exec "eth.getBalance('$(story validator export | grep -oP '(?<=EVM Public Key: ).*')')" attach $HOME/.story/geth/odyssey/geth.ipc
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


function export_evm_private_key() {
    story validator export --evm-key-path $HOME/.story/story/config/private_key.txt --export-evm-key
    cat $HOME/.story/story/config/private_key.txt
    menu
}

function export_evm_public_key() {
    story validator export | grep -oP '(?<=EVM Public Key: ).*'
    menu
}

function restore_wallet() {
    read -p "Enter priv_validator_key: " PRIV_VALIDATOR_KEY
    echo "$PRIV_VALIDATOR_KEY" > $HOME/.story/story/config/priv_validator_key.json
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

function show_consensus_client_logs() {
    sudo journalctl -u story -fn 100
    menu
}

function show_geth_logs() {
    sudo journalctl -u story-geth -fn 100
    menu
}

function show_node_status() {
    story status
    menu
}

# Menu
function menu() {
    echo "1. Deploy Validator Node"
    echo "2. Create Validator"
    echo "3. Query Validator Public Key"
    echo "4. Query Balance"
    echo "5. Stake Tokens"
    echo "6. Unstake Tokens"
    echo "7. Export EVM Private Key"
    echo "8. Export EVM Public Key"
    echo "9. Restore Wallet"
    echo "10. Delete Validator Node"
    echo "11. Show Consensus Client Logs"
    echo "12. Show Geth Logs"
    echo "13. Show Node status"
    echo "14. Exit"
    read -p "Choose an option: " OPTION

    case $OPTION in
        1) deploy_validator_node ;;
        2) create_validator ;;
        3) query_validator_pub_key ;;
        4) query_balance ;;
        5) stake_tokens ;;
        6) unstake_tokens ;;
        7) export_evm_private_key ;;
        8) export_evm_public_key ;;
        9) restore_wallet ;;
        10) delete_validator_node ;;
        11) show_consensus_client_logs ;;
        12) show_geth_logs ;;
        13) show_node_status ;;
        13) exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
}

# Run the menu
while true; do
    menu
done
