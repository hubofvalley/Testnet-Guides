# Story Protocol Testnet Guide

`will always update`

<p align="center">
  <img src="https://github.com/user-attachments/assets/2ac53a77-8eec-48be-9106-eb832ae5fee3" alt="let’s build Story together" width="600" height="300">
</p>

# Story Protocol <a><img src="https://github.com/user-attachments/assets/79083de3-697b-4771-ad0e-41445c2b066b" width="50" height="50">

## What Is Story?

Story is an innovative initiative designed to revolutionize the management of creative Intellectual Property (IP) by leveraging blockchain technology. By making IP "programmable," Story aims to streamline the processes of protection, licensing, and monetization of creative works. The core of this endeavor is the Story Network, a specialized layer 1 blockchain built to support efficient and scalable IP management.

![image](https://github.com/user-attachments/assets/2ceec88b-8c84-4b48-a31d-e2c888c6b80d)

In the sections below, we will delve deeper into this architecture and explore the key use cases it unlocks.

## Story’s Architecture

Story Network is a purpose-built layer 1 blockchain that combines the advantages of EVM (Ethereum Virtual Machine) and Cosmos SDK. It is fully EVM-compatible and features deep execution layer optimizations to support complex data structures like IP quickly and cost-efficiently. Key features include:

1. **Precompiled Primitives**: These allow the system to traverse complex data structures like IP graphs within seconds at marginal costs, ensuring that the licensing process is both fast and affordable.

2. **Consensus Layer**: Based on the mature CometBFT stack, this layer ensures fast finality and cheap transactions, further enhancing the efficiency of the network.

The Proof-of-Creativity Protocol is a set of smart contracts natively deployed on Story Network. It allows creators to register their IP as "IP Assets" (IPA) on the protocol.

### Components

- **On-Chain NFT**: Represents the IP, which could be an existing NFT or a new NFT minted to represent off-chain IP.
- **IP Account**: A modified ERC-6551 (Token Bound Account) implementation that manages the IP.

### Modules

- **Licensing Module**: Allows creators to set terms on their IP, such as whether derivative works can use the IP commercially.
- **Royalty Module**: Enables the creation of revenue streams from derivative works.
- **Dispute Module**: Facilitates the resolution of disputes.

## Programmable IP License (PIL)

The PIL is an off-chain legal contract that enforces the terms of IP Assets and License Tokens. It allows the redemption of tokenized IP into the off-chain legal system, outlining real legal terms for how creators can remix, monetize, and create derivatives of their IP.

## Story Solving Target

The increasing need for greater efficiency in IP management has coincided with the rise of blockchain technology, which is essential for addressing the current system's challenges. Traditional methods of protecting and licensing IP are cumbersome and expensive, often requiring the involvement of lawyers. This makes the process inaccessible for many creators, particularly those without substantial resources.

Moreover, the current system relies on one-to-one licensing deals, which are not scalable. This leads to many potential licensing opportunities being missed, stifling creativity and innovation. Additionally, the rapid proliferation of AI-generated media has outpaced the current IP system, which was designed for physical replication. There is an urgent need to automate and optimize the licensing of IP to keep up with the digital age.

Story offers a solution with a specialized layer 1 blockchain that combines the advantages of EVM and Cosmos SDK, providing the infrastructure needed for massive IP data scalability. Key applications of Story include:

1. **Creators**: Story enables creators to register their IP as IP Assets and set terms using the Programmable IP License (PIL).
2. **Derivative Works**: Creators of derivative works can license IP automatically through the blockchain, making the process efficient and scalable.
3. **AI-Generated Media**: Story supports the efficient management of AI-generated content by automating the licensing process.
4. **Scalable Licensing**: Story's approach to licensing ensures that all potential opportunities are captured, fostering creativity and collaboration.

## Example Use Case

Without Story, creating a comic with multiple IPs (e.g., Azuki and Pudgy NFTs) would require extensive legal work, making it impractical. With Story, IP holders can register their IP, set terms, and license their work automatically through the blockchain, making the process efficient and scalable.

## Conclusion

By leveraging blockchain technology, Story is poised to revolutionize IP management, making it more efficient, scalable, and accessible for creators worldwide. It provides a scalable, low-cost, and fully programmable IP management solution essential for bringing vast amounts of IP on-chain.

For more detailed information, visit the [Story Documentation](https://docs.story.foundation).

With Public Testnet, Story's docs and code become public. Check them out below!

- [Story Website](https://www.story.foundation/)
- [Story Twitter](https://x.com/StoryProtocol)
- [Story Discord](https://discord.gg/storyprotocol)
- [Story Docs](https://docs.story.foundation/)
- [Story GitHub](https://github.com/storyprotocol)
- [Story Explorer](https://testnet.storyscan.app/)

Grand Valley's Story public endpoints:

- cosmos rpc: https://lightnode-rpc-story.grandvalleys.com
- json-rpc: https://lightnode-json-rpc-story.grandvalleys.com
- cosmos rest-api: https://lightnode-api-story.grandvalleys.com
- cosmos ws: wss://lightnode-rpc-story.grandvalleys.com/websocket
- evm ws: wss://lightnode-wss-story.grandvalleys.com

## Story Node Deployment Guide With Cosmovisor

### **System Requirements**

| Category  | Requirements |
| --------- | ------------ |
| CPU       | 8+ cores     |
| RAM       | 32+ GB       |
| Storage   | 500+ GB      |
| Bandwidth | 10MBit/s     |

service file name: `story.service` `story-geth.service`
current chain: `iliad-0`
current version: `v0.9.12`

### 1. Install dependencies for building from source

```bash
sudo apt update && \
sudo apt install curl git jq build-essential gcc unzip wget lz4 openssl -y
sudo apt-get update -y
sudo apt-get install clang cmake build-essential -y
sudo apt install git -y
sudo apt install libssl-dev -y
sudo apt install pkg-config -y
sudo apt-get install protobuf-compiler -y
sudo apt-get install clang -y
sudo apt-get install llvm llvm-dev -y
```

### 2. install go

```bash
cd $HOME && \
ver="1.22.0" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile && \
source ~/.bash_profile && \
go version
```

### 3. install cosmovisor

```bash
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest
```

### 4. set vars

EDIT YOUR MONIKER & YOUR PREFERRED PORT NUMBER

```
echo "export MONIKER="<your-moniker>"" >> $HOME/.bash_profile
echo "export STORY_CHAIN_ID="iliad"" >> $HOME/.bash_profile
echo "export STORY_PORT="26"" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### 5. download geth and consensus client binaries

```bash
cd $HOME

# geth binary
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
geth_folder_name=$(tar -tf geth-linux-amd64-0.9.2-ea9f0d2.tar.gz | head -n 1 | cut -f1 -d"/")
tar -xvf geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
sudo mv $HOME/$geth_folder_name/geth $HOME/go/bin/
sudo rm -rf $HOME/$geth_folder_name $HOME/geth-linux-amd64-0.9.2-ea9f0d2.tar.gz

# consensus client binary
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.9.12-9ae4a63.tar.gz
story_folder_name=$(tar -tf story-linux-amd64-0.9.12-9ae4a63.tar.gz | head -n 1 | cut -f1 -d"/")
tar -xzf story-linux-amd64-0.9.12-9ae4a63.tar.gz
sudo mv $HOME/$story_folder_name/story $HOME/go/bin/
sudo rm -rf $HOME/$story_folder_name $HOME/story-linux-amd64-0.9.12-9ae4a63.tar.gz
```

### 6. init app

```bash
story init --network $STORY_CHAIN_ID --moniker $MONIKER
```

### 9. Add peers to the config.toml

```bash
peers=$(curl -sS https://lightnode--rpc-story.grandvalleys.com/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
echo $peers
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.story/story/config/config.toml
```

### 10. set custom ports in config.toml file

```bash
sed -i.bak -e "s%:26658%:${STORY_PORT}658%g;
s%:26657%:${STORY_PORT}657%g;
s%:26656%:${STORY_PORT}656%g;
s%:26660%:${STORY_PORT}660%g" $HOME/.story/story/config/config.toml
```

### 14. enable indexer (optional) (if u want to run a full node follow this step)

```bash
sed -i -e 's/^indexer = "null"/indexer = "kv"/' $HOME/.story/story/config/config.toml
```

### 15. configure cosmovisor folder

```bash
cosmovisor init $HOME/go/bin/story
mkdir -p $HOME/.story/story/cosmovisor/upgrades
mkdir -p $HOME/.story/story/cosmovisor/backup
```

### 16. define the path of cosmovisor for being used in the consensus client

```bash
input1=$(which cosmovisor)
input2=$(find $HOME -type d -name "story")
input3=$(find $HOME/.story/story/cosmovisor -type d -name "backup")
echo "export DAEMON_NAME=story" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$input2" >> $HOME/.bash_profile
echo "export DAEMON_DATA_BACKUP_DIR=$(find $HOME/.story/story/cosmovisor -type d -name "backup")" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo "input1. $input1"
echo "input2. $input2"
echo "input3. $input3"
```

#### save the results, they'll be used in the next step

#### this is an example of the result

![image](https://github.com/user-attachments/assets/21ef09d9-2595-46b6-b014-e30d5ff09cc1)

### 17. create service files

#### edit the `<input 1>` with the value of `input 1`

#### edit the `<input 2>` with the result of `input 2`

#### edit the `<input 3>` with the result of `input 3`

##### consensus service file

```bash
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Cosmovisor Story Node
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME/.story/story
ExecStart=<input 1> run run
Restart=on-failure
LimitNOFILE=65535
Environment="DAEMON_NAME=story"
Environment="DAEMON_HOME=<input 2>"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_DATA_BACKUP_DIR=<input 3>"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF
```

#### this is an example of the edited consensus client service file

![image](https://github.com/user-attachments/assets/80bcf6ea-42d7-4eda-8303-a44808d125e6)

##### geth service file

```bash
sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF
[Unit]
Description=Story Geth daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which geth) --iliad --syncmode full --http --http.api eth,net,web3,engine --http.vhosts '*' --http.addr 0.0.0.0 --http.port 8545 --ws --ws.api eth,web3,net,txpool --ws.addr 0.0.0.0 --ws.port 8546
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

### 18. start the node

#### start geth

```bash
sudo systemctl daemon-reload && \
sudo systemctl enable story-geth && \
sudo systemctl restart story-geth && sudo journalctl -u story-geth -fn 100 -o cat
```

#### start consensus client

```bash
sudo systemctl daemon-reload && \
sudo systemctl enable story && \
sudo systemctl restart story && sudo journalctl -u story -fn 100 -o cat
```

#### this is an example of the node running properly

##### story-geth logs

![story-geth logs](image.png)

##### story logs

![story logs](image-1.png)

### 21. check node synchronization

```bash
curl http://127.0.0.1:${STORY_PORT}657/status | jq
```

if u use default port (26):

```bash
curl http://127.0.0.1:26657/status | jq
```

### 22. chech the node version

```bash
cosmovisor run version
```

## you can use any snapshots and no need to manually update the binary version

## Validator and key Commands

### 1. export evm public key and private key

```bash
story validator export --export-evm-key && cat $HOME/.story/story/config/private_key.txt
```

make sure your node block height has been synced with the latest block height. or you can check the `catching_up` value must be `false`

### 2. claim faucet

https://faucet.story.foundation/

### 3. create validator

```bash
 story validator create --stake 1000000000000000000 --private-key <your private key>
```

### 4. BACKUP YOUR VALIDATOR <img src="https://img.shields.io/badge/IMPORTANT-red" alt="Important" width="100">

```bash
nano /$HOME/.story/story/config/priv_validator_key.json
```

```bash
nano /$HOME/.story/story/data/priv_validator_state.json
```

copy all of the contents of the ![priv_validator_key.json](https://img.shields.io/badge/priv__validator__key.json-red) !and ![priv_validator_key.json](https://img.shields.io/badge/priv__validator__state.json-red) files and save them in a safe place. This is a vital step in case you need to migrate your validator node

### 5. delegate token to validator

### self delegate

```bash
story validator stake --private-key <your private key> --stake 1024000000000000000000 --validator-pubkey <your validator public key>
```

#### delegate to <a href="https://testnet.storyscan.app/validators/storyvaloper1cvsdp0tsz25fhedd7cjvntq42347astvar06v8"><img src="https://github.com/hubofvalley/Testnet-Guides/assets/100946299/e8704cc4-2319-4a21-9138-0264e75e3a82" alt="GRAND VALLEY" width="50" height="50">

</a>

```bash
story validator stake --private-key <your private key> --stake 1024000000000000000000 --validator-pubkey A2p1z6hM9IXltKaET6ny/wP0EPfIwBSPTkyeU135yroi
```

### delete the node

```bash
sudo systemctl stop story-geth story
sudo systemctl disable story-geth story
sudo rm -rf /etc/systemd/system/story-geth.service /etc/systemd/system/story.service
sudo rm -r .story
sed -i "/STORY_/d" $HOME/.bash_profile
```

## Consensus client version update to v0.10.0

## Method 1: Place the new binary directly

### 1. define the path of cosmovisor for being used in the consensus client

```bash
input1=$(which cosmovisor)
input2=$(find $HOME -type d -name "story")
input3=$(find $HOME/.story/story/cosmovisor -type d -name "backup")
echo "export DAEMON_NAME=story" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$input2" >> $HOME/.bash_profile
echo "export DAEMON_DATA_BACKUP_DIR=$(find $HOME/.story/story/cosmovisor -type d -name "backup")" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo "input1. $input1"
echo "input2. $input2"
echo "input3. $input3"
```

### 2. download the node binary

```bash
cd $HOME && \
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.10.0-9603826.tar.gz
```

### 3. create the new version dir, extract the node binary and copy It to the cosmovisor upgrades directory

```bash
mkdir -p $HOME/.story/story/cosmovisor/upgrades/v0.10.0/bin
story_folder_name=$(tar -tf story-linux-amd64-0.10.0-9603826.tar.gz | head -n 1 | cut -f1 -d"/")
tar -xzf story-linux-amd64-0.10.0-9603826.tar.gz
sudo cp $HOME/$story_folder_name/story $HOME/.story/story/cosmovisor/upgrades/v0.10.0/bin/
```

### 4. stop the consensus client services

```bash
sudo systemctl stop story
```

### 5. copy the current node binary to the cosmovisor genesis directory

```bash
sudo cp $HOME/$story_folder_name/story $HOME/.story/story/cosmovisor/genesis/bin
```

### 6. restart consensus client services

```bash
sudo systemctl daemon-reload && \
sudo systemctl restart story
```

### 7. check the node version

```bash
cosmovisor run version
```

### 8. after the instructions are succesfully completed, u can delete the tar file and folder

```bash
sudo rm -rf $HOME/$story_folder_name $HOME/story-linux-amd64-0.10.0-9603826.tar.gz
```

## Method 2: Let Cosmovisor handle placing the binary itself (semi-automated)

### 1. define the path of cosmovisor for being used in the consensus client

```bash
input1=$(which cosmovisor)
input2=$(find $HOME -type d -name "story")
input3=$(find $HOME/.story/story/cosmovisor -type d -name "backup")
echo "export DAEMON_NAME=story" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$input2" >> $HOME/.bash_profile
echo "export DAEMON_DATA_BACKUP_DIR=$(find $HOME/.story/story/cosmovisor -type d -name "backup")" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo "input1. $input1"
echo "input2. $input2"
echo "input3. $input3"
```

### 2. download the node binary

```bash
cd $HOME && \
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.10.0-9603826.tar.gz
```

### 3. extract the new node binary

```bash
story_folder_name=$(tar -tf story-linux-amd64-0.10.0-9603826.tar.gz | head -n 1 | cut -f1 -d"/")
tar -xzf story-linux-amd64-0.10.0-9603826.tar.gz
```

### 4. execute the cosmovisor `add-upgrade` command

**v0.10.0 block height upgrade is 626575**

```bash
cosmovisor add-upgrade v0.10.0 $HOME/$story_folder_name/story --upgrade-height 626575 --force
```

### 5. after the instructions are succesfully completed, u can delete the tar file and folder

```bash
sudo rm -rf $HOME/$story_folder_name $HOME/story-linux-amd64-0.10.0-9603826.tar.gz
```

# let's buidl together
