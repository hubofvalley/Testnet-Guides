#!/bin/bash

LOGO="
 __
/__ ._ _. ._   _|   \  / _. | |  _
\_| | (_| | | (_|    \/ (_| | | (/_ \/
                                    /
"

ENDPOINTS="
Grand Valley's 0G public endpoints:
- cosmos rpc: `https://lightnode-rpc-0g.grandvalleys.com`
- json-rpc: `https://lightnode-json-rpc-0g.grandvalleys.com`
- cosmos rest-api: `https://lightnode-api-0g.grandvalleys.com`
"

INTRO="
hubof0G by Grand Valley

0G Validator Node System Requirements
| Category  | Requirements                   |
| --------- | ------------------------------ |
| CPU       | 8 cores                        |
| RAM       | 64+ GB                         |
| Storage   | 1+ TB NVMe SSD                 |
| Bandwidth | 100 MBps for Download / Upload |

validator node's current binaries version: v0.2.5 will automatically update to the latest version
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

storage node's current binary version: `v0.6.1`

------------------------------------------------------------------

Storage KV System Requirements
| Category | Requirements                                |
| -------- | ------------------------------------------- |
| CPU      | 8+ cores                                    |
| RAM      | 32+ GB                                      |
| Storage  | Matches the size of kv streams it maintains |

storage kv's current binary version: `v1.2.2`

------------------------------------------------------------------

"

echo "$LOGO"
echo "$INTRO"
echo "$ENDPOINTS"

# Create Wallet
function create_wallet() {
    read -p "Enter wallet name: " WALLET_NAME
    0gchaind keys add $WALLET_NAME
}

# Check Wallets
function check_wallet() {
    0gchaind keys list
}

# Send Transaction
function send_transaction() {
    read -p "Enter sender wallet name: " SENDER_WALLET
    read -p "Enter recipient wallet address: " RECIPIENT_ADDRESS
    read -p "Enter amount to send: " AMOUNT
    0gchaind tx bank send $SENDER_WALLET $RECIPIENT_ADDRESS $AMOUNT --chain-id $OG_CHAIN_ID --gas auto --fees 5000ua0gi -y
}

# Query Balance
function query_balance() {
    read -p "Enter wallet address: " WALLET_ADDRESS
    0gchaind query bank balances $WALLET_ADDRESS --chain-id $OG_CHAIN_ID
}

# Stake Tokens
function stake_tokens() {
    read -p "Enter wallet name: " WALLET_NAME
    read -p "Enter validator address: " VALIDATOR_ADDRESS
    read -p "Enter amount to stake: " AMOUNT
    0gchaind tx staking delegate $VALIDATOR_ADDRESS $AMOUNT --from $WALLET_NAME --chain-id $OG_CHAIN_ID --gas auto --fees 5000ua0gi -y
}

# Unstake Tokens
function unstake_tokens() {
    read -p "Enter wallet name: " WALLET_NAME
    read -p "Enter validator address: " VALIDATOR_ADDRESS
    read -p "Enter amount to unstake: " AMOUNT
    0gchaind tx staking unbond $VALIDATOR_ADDRESS $AMOUNT --from $WALLET_NAME --chain-id $OG_CHAIN_ID --gas auto --fees 5000ua0gi -y
}

# Deploy Validator Node
function deploy_node() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_validator_node_install.sh)
}

# Menu
function menu() {
    echo "1. Create Wallet"
    echo "2. Send Transaction"
    echo "3. Query Balance"
    echo "4. Stake Tokens"
    echo "5. Unstake Tokens"
    echo "6. Deploy Node"
    echo "7. Exit"
    read -p "Choose an option: " OPTION

    case $OPTION in
        1) create_wallet ;;
        2) send_transaction ;;
        3) query_balance ;;
        4) stake_tokens ;;
        5) unstake_tokens ;;
        6) deploy_node ;;
        7) exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
}

# Run the menu
while true; do
    menu
done

please restructure the numbering. 'deploy_node' become 'validator_node' 

1. validator_node
    a. deploy_validator_node
    b. create_validator
    c. query_balance
    d. send_transaction
    e. stake_tokens
    f. unstake_tokens
    g. export_evm_private_key
    h. 
2. deploy_storage_node
3. deploy_storage_kv

the command:

export_evm_private_key: 0gchaind keys unsafe-export-eth-key $WALLET
deploy_storage_node: bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_storage_node_install.sh)
