# storage-cli

- [storage-cli](#storage-cli)
  - [0g storage-cli installation](#0g-storage-cli-installation)
    - [1. install dependencies](#1-install-dependencies)
    - [2. install go](#2-install-go)
    - [3. Download binary](#3-download-binary)
    - [4. Build the binary](#4-build-the-binary)
  - [variables configuration](#variables-configuration)
    - [1. Input your json-rpc, storage node url and private key](#1-input-your-json-rpc-storage-node-url-and-private-key)
    - [2. Set cli variables](#2-set-cli-variables)
  - [Upload file transaction](#upload-file-transaction)
    - [1. input size and path of the file you want to create then upload](#1-input-size-and-path-of-the-file-you-want-to-create-then-upload)
    - [2. execute the transaction](#2-execute-the-transaction)
    - [SUCCESSFUL RESULT: ](#successful-result-)
  - [Download file transaction](#download-file-transaction)
    - [1. input the output path and the root hash of the file you want to download](#1-input-the-output-path-and-the-root-hash-of-the-file-you-want-to-download)
    - [2. execute the transaction](#2-execute-the-transaction-1)
    - [SUCCESSFUL RESULT: ](#successful-result--1)
- [let's buidl together](#lets-buidl-together)

guide's current binary version: `v0.6.1`

## 0g storage-cli installation

### 1. install dependencies

```bash
sudo apt update -y && sudo apt upgrade -y && \
sudo apt install -y curl git jq build-essential gcc unzip wget lz4 openssl \
libssl-dev pkg-config protobuf-compiler clang cmake llvm llvm-dev
```

### 2. install go

```bash
cd $HOME && ver="1.22.0" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile && \
source ~/.bash_profile && go version
```

### 3. Download binary

```bash
git clone https://github.com/0glabs/0g-storage-client.git
```

### 4. Build the binary

```bash
cd 0g-storage-client
git tag -d v0.6.1
git fetch --all --tags
git checkout 88f563d81a60208a44ed7662a240e307277f7965
git submodule update --init
go build
```

## variables configuration

### 1. Input your json-rpc, storage node url and private key

- PLEASE INPUT YOUR STORAGE NODE URL (http://STORAGE_NODE_IP:5678) YOUR JSON RPC ENDPOINT (http://VALIDATOR_NODE_IP:8545) OR YOU CAN OUR ENDPOINTS PLEASE CHECK [README](<https://github.com/hubofvalley/Testnet-Guides/blob/main/0g%20(zero-gravity)/README.md>)

```bash
read -p "Enter json-rpc: " BLOCKCHAIN_RPC_ENDPOINT && echo "Current json-rpc: $BLOCKCHAIN_RPC_ENDPOINT" && read -p "Enter storage node url: " ZGS_NODE && echo "Current storage node url: $ZGS_NODE" && read -sp "Enter private key: " PRIVATE_KEY && echo "Current storage private key: $PRIVATE_KEY"
```

### 2. Set cli variables

```bash
echo "export BLOCKCHAIN_RPC_ENDPOINT=\"$BLOCKCHAIN_RPC_ENDPOINT\"" >> ~/.bash_profile
echo "export LOG_CONTRACT_ADDRESS=\"0xbD2C3F0E65eDF5582141C35969d66e34629cC768\"" >> ~/.bash_profile
echo "export ZGS_NODE=\"$ZGS_NODE\"" >> ~/.bash_profile
echo "export PRIVATE_KEY=\"$PRIVATE_KEY\"" >> ~/.bash_profile

source ~/.bash_profile

echo -e "\n\033[31mCHECK YOUR STORAGE CLI VARIABLES\033[0m\n\nZGS_NODE: $ZGS_NODE\nLOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS\nBLOCKCHAIN_RPC_ENDPOINT: $BLOCKCHAIN_RPC_ENDPOINT\nPRIVATE_KEY: $PRIVATE_KEY \n\n"
echo -e "\033[3m\"lets buidl together\" - Grand Valley\033[0m"
```

## Upload file transaction

- **THESE COMMANDS CAN ONLY WORK IF THE FILE PATH IS INSIDE THE 0g-storage-client DIRECTORY.**
- **THIS MEANS YOU MUST CREATE OR CHOOSE THE FILE INSIDE THE 0g-storage-client DIRECTORY**.

### 1. input size and path of the file you want to create then upload

```bash
cd $HOME/0g-storage-client && read -p "Enter file size (byte): " FILE_SIZE && echo "file size (byte): $FILE_SIZE" && read -p "Enter file name: " INPUT_FILE_PATH && echo "Current file name: $INPUT_FILE_PATH" && ./0g-storage-client gen --size $FILE_SIZE --file $INPUT_FILE_PATH
```

### 2. execute the transaction

```bash
   cd $HOME/0g-storage-client &&
   ./0g-storage-client upload \
   --url $BLOCKCHAIN_RPC_ENDPOINT \
   --contract $LOG_CONTRACT_ADDRESS \
   --key $PRIVATE_KEY \
   --node $ZGS_NODE \
   --file $INPUT_FILE_PATH \
   --gas-limit 25000000 \
   --finality-required true

   # Check if the upload was successful and then delete the file
   if [ $? -eq 0 ]; then
   rm $INPUT_FILE_PATH
   echo "File $INPUT_FILE_PATH has been deleted after upload."
   else
   echo "Upload failed, file $INPUT_FILE_PATH was not deleted."
   fi

   echo -e "\033[3m\"lets buidl together\" - Grand Valley\033[0m"
```

### SUCCESSFUL RESULT: ![image](https://github.com/hubofvalley/Testnet-Guides/assets/100946299/421cb81a-3f2b-41d5-b798-e7f1897f2802)

## Download file transaction

- **THESE COMMANDS CAN ONLY WORK IF THE FILE PATH IS INSIDE THE 0g-storage-client DIRECTORY**.
- **THIS MEANS YOU MUST CREATE OR CHOOSE THE FILE INSIDE THE 0g-storage-client DIRECTORY**.
- **YOU MUST UPLOAD YOUR FILE FIRST BEFORE YOU CAN DOWNLOAD IT. INPUT THE ROOT HASH VALUE FROM THE UPLOAD TRANSACTION LOGS**.

### 1. input the output path and the root hash of the file you want to download

```bash
   cd $HOME/0g-storage-client && read -p "Enter your output file path: " OUTPUT_FILE_PATH && echo "Current output file path: $OUTPUT_FILE_PATH" && read -p "Enter the file root hash: " ROOT_HASH && echo "Current file root hash: $ROOT_HASH"
```

### 2. execute the transaction

```bash
   cd $HOME/0g-storage-client &&
   ./0g-storage-client download \
   --node $ZGS_NODE \
   --root $ROOT_HASH \
   --file $OUTPUT_FILE_PATH \
   --proof

   echo -e "\033[3m\"lets buidl together\" - Grand Valley\033[0m"
```

### SUCCESSFUL RESULT: ![image](https://github.com/hubofvalley/Testnet-Guides/assets/100946299/ea095625-ae68-427e-a626-d742dcb575a7)

# let's buidl together
