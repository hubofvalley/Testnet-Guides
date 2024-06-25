# Make storage transaction using 0g storage-cli

## Preparation

### 1. Input your private key
 ```bash
    read -sp "Enter your private key: " PRIVATE_KEY && echo
 ```

### 2. Set variables
PLEASE INPUT YOUR STORAGE NODE URL (http://STORAGE_NODE_IP:5678) YOUR JSON RPC ENDPOINT (VALIDATOR_NODE_IP:8545) OR YOU CAN OUR ENDPOINTS PLEASE CHECK [README](https://github.com/hubofvalley/Testnet-Guides/blob/main/0g%20(zero-gravity)/README.md)

 ```bash
    echo 'export BLOCKCHAIN_RPC_ENDPOINT="<your json rpc endpoint>"' >> ~/.bash_profile
    echo 'export LOG_CONTRACT_ADDRESS="0x8873cc79c5b3b5666535C825205C9a128B1D75F1"' >> ~/.bash_profile
    echo 'export ZGS_NODE="<your storage node url>"' >> ~/.bash_profile

    source ~/.bash_profile

    echo -e "\n\033[31mCHECK YOUR STORAGE CLI VARIABLES\033[0m\n\nZGS_NODE: $ZGS_NODE\nLOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS\nBLOCKCHAIN_RPC_ENDPOINT: $BLOCKCHAIN_RPC_ENDPOINT\n\n"
 ```

## Upload file transaction
INPUT DESTINATION PATH OF THE FILE YOU WANT TO UPLOAD
 ```bash
    ./0g-storage-client upload \
    --url $BLOCKCHAIN_RPC_ENDPOINT \
    --contract $LOG_CONTRACT_ADDRESS \
    --key $PRIVATE_KEY \
    --node $ZGS_NODE \
    --file <input_file_path>
 ```

## Download file transaction
YOU MUST UPLOAD YOUR FILE FIRST BEFORE YOU CAN DOWNLOAD IT. INPUT THE ROOT HASH VALUE FROM THE UPLOAD TRANSACTION LOGS. SET THE OUTPUT FILE PATH
 ```bash
    ./0g-storage-client download \
    --node $BLOCKCHAIN_RPC_ENDPOINT \
    --root <file_root_hash> \
    --file <output_file_path>
 ```
