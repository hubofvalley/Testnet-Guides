# Make storage transaction using 0g storage-cli

## 0g storage-cli installation
### 1. Download binary
 ```bash
    git clone https://github.com/0glabs/0g-storage-client.git
 ```

### 2. Build the binary
 ```bash
    cd 0g-storage-client
    go build
 ```

## Preparation
### 1. Input your private key (DO THIS EVERY NEW SESSION OF YOUR INSTANCE TO EXECUTE THE STORAGE-CLI TX)
 ```bash
    read -sp "Enter private key: " PRIVATE_KEY && echo
 ```

### 2. Input your json-rpc and storage node url
-   PLEASE INPUT YOUR STORAGE NODE URL (http://STORAGE_NODE_IP:5678) YOUR JSON RPC ENDPOINT (http://VALIDATOR_NODE_IP:8545) OR YOU CAN OUR ENDPOINTS PLEASE CHECK [README](https://github.com/hubofvalley/Testnet-Guides/blob/main/0g%20(zero-gravity)/README.md)
 ```bash
    read -p "Enter json-rpc: " BLOCKCHAIN_RPC_ENDPOINT && echo "Current json-rpc: $BLOCKCHAIN_RPC_ENDPOINT" && read -p "Enter storage node url: " ZGS_NODE && echo "Current storage node url: $ZGS_NODE"
 ```

### 3. Set variables
 ```bash
    echo "export BLOCKCHAIN_RPC_ENDPOINT=\"$BLOCKCHAIN_RPC_ENDPOINT\"" >> ~/.bash_profile
    echo "export LOG_CONTRACT_ADDRESS=\"0x8873cc79c5b3b5666535C825205C9a128B1D75F1\"" >> ~/.bash_profile
    echo "export ZGS_NODE=\"$ZGS_NODE\"" >> ~/.bash_profile

    source ~/.bash_profile

    echo -e "\n\033[31mCHECK YOUR STORAGE CLI VARIABLES\033[0m\n\nZGS_NODE: $ZGS_NODE\nLOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS\nBLOCKCHAIN_RPC_ENDPOINT: $BLOCKCHAIN_RPC_ENDPOINT\n\n"
echo -e "\033[3m\"lets buidl together\" - Grand Valley\033[0m"
 ```

## Upload file transaction
-   THESE COMMANDS CAN WORK IF THE FILE PATH IS INSIDE THE 0g-storage-client DIRECTORY.
-   THIS MEANS YOU MUST CREATE OR CHOOSE THE FILE INSIDE THE 0g-storage-client DIRECTORY.
### 1. input the input path of the file you want to upload
 ```bash
    read -p "Enter your input file path: " INPUT_FILE_PATH && echo "Current input file path: $INPUT_FILE_PATH"
 ```

### 2. execute the transaction
 ```bash
    ./0g-storage-client upload \
    --url $BLOCKCHAIN_RPC_ENDPOINT \
    --contract $LOG_CONTRACT_ADDRESS \
    --key $PRIVATE_KEY \
    --node $ZGS_NODE \
    --file $INPUT_FILE_PATH
 ```

 ###  SUCCESSFUL RESULT: ![image](https://github.com/hubofvalley/Testnet-Guides/assets/100946299/421cb81a-3f2b-41d5-b798-e7f1897f2802)

## Download file transaction
-   THESE COMMANDS CAN WORK IF THE FILE PATH IS INSIDE THE 0g-storage-client DIRECTORY.
-   THIS MEANS YOU MUST CREATE OR CHOOSE THE FILE INSIDE THE 0g-storage-client DIRECTORY.
-   YOU MUST UPLOAD YOUR FILE FIRST BEFORE YOU CAN DOWNLOAD IT. INPUT THE ROOT HASH VALUE FROM THE UPLOAD TRANSACTION LOGS.

### 1. input the output path and the root hash of the file you want to download
 ```bash
    read -p "Enter your output file path: " OUTPUT_FILE_PATH && echo "Current output file path: $OUTPUT_FILE_PATH" && read -p "Enter the file root hash: " ROOT_HASH && echo "Current file root hash: $ROOT_HASH"
 ```

### 2.  execute the transaction
 ```bash
    ./0g-storage-client download \
    --node $ZGS_NODE \
    --root $ROOT_HASH\
    --file $OUTPUT_FILE_PATH
 ```

### SUCCESSFUL RESULT: ![image](https://github.com/hubofvalley/Testnet-Guides/assets/100946299/ea095625-ae68-427e-a626-d742dcb575a7)
