# 0gchain Storage CLI Guide

## Table of Contents

- [0gchain Storage CLI Guide](#0gchain-storage-cli-guide)
  - [Table of Contents](#table-of-contents)
  - [0g Storage-CLI Installation](#0g-storage-cli-installation)
    - [1. Install Dependencies](#1-install-dependencies)
    - [2. Install Go](#2-install-go)
    - [3. Download Binary](#3-download-binary)
    - [4. Build the Binary](#4-build-the-binary)
  - [Variables Configuration](#variables-configuration)
    - [1. Input Your JSON-RPC, Storage Node URL, and Private Key](#1-input-your-json-rpc-storage-node-url-and-private-key)
    - [2. Set CLI Variables](#2-set-cli-variables)
  - [Upload File Transaction](#upload-file-transaction)
    - [1. Input Size and Path of the File to Create and Upload](#1-input-size-and-path-of-the-file-to-create-and-upload)
    - [2. Execute the Transaction](#2-execute-the-transaction)
    - [Successful Result](#successful-result)
  - [Download File Transaction](#download-file-transaction)
    - [1. Input the Output Path and Root Hash](#1-input-the-output-path-and-root-hash)
    - [2. Execute the Transaction](#2-execute-the-transaction-1)
    - [Successful Result](#successful-result-1)
- [Lets Buidl 0G Together](#lets-buidl-0g-together)

---

Guide's current binary version: `v0.6.1`

---

## 0g Storage-CLI Installation

### 1. Install Dependencies

```bash
sudo apt update -y && sudo apt upgrade -y && \
sudo apt install -y curl git jq build-essential gcc unzip wget lz4 openssl \
libssl-dev pkg-config protobuf-compiler clang cmake llvm llvm-dev
```

### 2. Install Go

```bash
cd $HOME && ver="1.22.0" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile && \
source ~/.bash_profile && go version
```

### 3. Download Binary

```bash
git clone https://github.com/0glabs/0g-storage-client.git
```

### 4. Build the Binary

```bash
cd 0g-storage-client
git tag -d v0.6.1
git fetch --all --tags
git checkout 88f563d81a60208a44ed7662a240e307277f7965
git submodule update --init
go build
```

---

## Variables Configuration

### 1. Input Your JSON-RPC, Storage Node URL, and Private Key

- Please input your storage node URL (`http://STORAGE_NODE_IP:5678`), your JSON RPC endpoint (`http://VALIDATOR_NODE_IP:8545`), or you can use our endpoints (see [README](https://github.com/hubofvalley/Testnet-Guides/blob/main/0g%20(zero-gravity)/README.md)).

```bash
read -p "Enter json-rpc: " BLOCKCHAIN_RPC_ENDPOINT && echo "Current json-rpc: $BLOCKCHAIN_RPC_ENDPOINT"
read -p "Enter storage node url: " ZGS_NODE && echo "Current storage node url: $ZGS_NODE"
read -sp "Enter private key: " PRIVATE_KEY && echo "Current storage private key: $PRIVATE_KEY"
```

### 2. Set CLI Variables

```bash
echo "export BLOCKCHAIN_RPC_ENDPOINT=\"$BLOCKCHAIN_RPC_ENDPOINT\"" >> ~/.bash_profile
echo "export LOG_CONTRACT_ADDRESS=\"0xbD2C3F0E65eDF5582141C35969d66e34629cC768\"" >> ~/.bash_profile
echo "export ZGS_NODE=\"$ZGS_NODE\"" >> ~/.bash_profile
echo "export PRIVATE_KEY=\"$PRIVATE_KEY\"" >> ~/.bash_profile

source ~/.bash_profile

echo -e "\n\033[31mCHECK YOUR STORAGE CLI VARIABLES\033[0m\n"
echo "ZGS_NODE: $ZGS_NODE"
echo "LOG_CONTRACT_ADDRESS: $LOG_CONTRACT_ADDRESS"
echo "BLOCKCHAIN_RPC_ENDPOINT: $BLOCKCHAIN_RPC_ENDPOINT"
echo "PRIVATE_KEY: $PRIVATE_KEY"
echo -e "\033[3mlets buidl together - Grand Valley\033[0m"
```

---

## Upload File Transaction

> **These commands only work if the file path is inside the `0g-storage-client` directory. You must create or choose the file inside this directory.**

### 1. Input Size and Path of the File to Create and Upload

```bash
cd $HOME/0g-storage-client
read -p "Enter file size (byte): " FILE_SIZE && echo "file size (byte): $FILE_SIZE"
read -p "Enter file name: " INPUT_FILE_PATH && echo "Current file name: $INPUT_FILE_PATH"
./0g-storage-client gen --size $FILE_SIZE --file $INPUT_FILE_PATH
```

### 2. Execute the Transaction

```bash
cd $HOME/0g-storage-client
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

echo -e "\033[3mlets buidl together - Grand Valley\033[0m"
```

### Successful Result

![image](https://github.com/hubofvalley/Testnet-Guides/assets/100946299/421cb81a-3f2b-41d5-b798-e7f1897f2802)

---

## Download File Transaction

> **These commands only work if the file path is inside the `0g-storage-client` directory. You must upload your file first before you can download it. Input the root hash value from the upload transaction logs.**

### 1. Input the Output Path and Root Hash

```bash
cd $HOME/0g-storage-client
read -p "Enter your output file path: " OUTPUT_FILE_PATH && echo "Current output file path: $OUTPUT_FILE_PATH"
read -p "Enter the file root hash: " ROOT_HASH && echo "Current file root hash: $ROOT_HASH"
```

### 2. Execute the Transaction

```bash
cd $HOME/0g-storage-client
./0g-storage-client download \
  --node $ZGS_NODE \
  --root $ROOT_HASH \
  --file $OUTPUT_FILE_PATH \
  --proof

echo -e "\033[3mlets buidl together - Grand Valley\033[0m"
```

### Successful Result

![image](https://github.com/hubofvalley/Testnet-Guides/assets/100946299/ea095625-ae68-427e-a626-d742dcb575a7)

---

# Lets Buidl 0G Together
