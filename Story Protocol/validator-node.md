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
current version: `v0.9.13`

### 1. install dependencies for building from source

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

### 3. install cosmovisor

```bash
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest
```

### 4. set vars

EDIT YOUR MONIKER & YOUR PREFERRED PORT NUMBER

```bash
echo "export MONIKER="<your-moniker>"" >> $HOME/.bash_profile
echo "export STORY_CHAIN_ID="iliad"" >> $HOME/.bash_profile
echo "export STORY_PORT="26"" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### 5. download geth and consensus client binaries

```bash
cd $HOME

# geth binary
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.3-b224fdf.tar.gz
geth_folder_name=$(tar -tf geth-linux-amd64-0.9.3-b224fdf.tar.gz | head -n 1 | cut -f1 -d"/")
tar -xvf geth-linux-amd64-0.9.3-b224fdf.tar.gz
mv $HOME/$geth_folder_name/geth $HOME/go/bin/
sudo rm -rf $HOME/$geth_folder_name $HOME/geth-linux-amd64-0.9.3-b224fdf.tar.gz

# consensus client binary
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.9.13-b4c7db1.tar.gz
story_folder_name=$(tar -tf story-linux-amd64-0.9.13-b4c7db1.tar.gz | head -n 1 | cut -f1 -d"/")
tar -xzf story-linux-amd64-0.9.13-b4c7db1.tar.gz
mv $HOME/$story_folder_name/story $HOME/go/bin/
sudo rm -rf $HOME/$story_folder_name $HOME/story-linux-amd64-0.9.13-b4c7db1.tar.gz
```

### 6. init app

```bash
story init --network $STORY_CHAIN_ID --moniker $MONIKER
```

### 7. add peers to the config.toml

```bash
peers=$(curl -sS https://lightnode-rpc-story.grandvalleys.com/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.story/story/config/config.toml
echo $peers
```

### 8. set custom ports in config.toml file

```bash
sed -i.bak -e "s%:26658%:${STORY_PORT}658%g;
s%:26657%:${STORY_PORT}657%g;
s%:26656%:${STORY_PORT}656%g;
s%:26660%:${STORY_PORT}660%g" $HOME/.story/story/config/config.toml
```

### 9. enable indexer (optional) (if u want to run a full node follow this step)

```bash
sed -i -e 's/^indexer = "null"/indexer = "kv"/' $HOME/.story/story/config/config.toml
```

### 10. init cosmovisor

```bash
echo "export DAEMON_NAME=story" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$(find $HOME -type d -name "story")" >> $HOME/.bash_profile
cosmovisor init $HOME/go/bin/story && \
mkdir -p $HOME/.story/story/cosmovisor/upgrades && \
mkdir -p $HOME/.story/story/cosmovisor/backup
```

### 11. define the path of cosmovisor for being used in the consensus client

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

### 12. create service files

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

### 13. start the node

#### start geth

```bash
sudo systemctl daemon-reload && \
sudo systemctl enable story-geth && \
sudo systemctl restart story-geth && \
sudo journalctl -u story-geth -fn 100
```

#### start consensus client

```bash
sudo systemctl daemon-reload && \
sudo systemctl enable story && \
sudo systemctl restart story && \
sudo journalctl -u story -fn 100
```

#### this is an example of the node running properly

##### story-geth logs

![story-geth logs](resources/image.png)

##### story logs

![story logs](resources/image-1.png)

### 14. check node synchronization

```bash
curl http://127.0.0.1:${STORY_PORT}657/status | jq
```

if u use default port (26):

```bash
curl http://127.0.0.1:26657/status | jq
```

### 15. check the node version

```bash
cosmovisor run version
```

### 16. use the [SNAPSHOT](https://github.com/hubofvalley/Testnet-Guides/blob/main/Story%20Protocol/README.md#method-3-use-snapshot-for-the-post-upgrade-thank-you-to-mandragora-for-allowing-me-to-publish-his-snapshot-file-here)

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

### delegate to <a href="https://testnet.storyscan.app/validators/storyvaloper1cvsdp0tsz25fhedd7cjvntq42347astvar06v8"><img src="https://github.com/hubofvalley/Testnet-Guides/assets/100946299/e8704cc4-2319-4a21-9138-0264e75e3a82" alt="GRAND VALLEY" width="50" height="50">

</a>

```bash
story validator stake --private-key <your private key> --stake 1024000000000000000000 --validator-pubkey A2p1z6hM9IXltKaET6ny/wP0EPfIwBSPTkyeU135yroi
```

# delete the node

```bash
sudo systemctl stop story-geth story
sudo systemctl disable story-geth story
sudo rm -rf /etc/systemd/system/story-geth.service /etc/systemd/system/story.service
sudo rm -r .story
sed -i "/STORY_/d" $HOME/.bash_profile
```

# Consensus client version update to v0.10.0 (HARDFORK at height 626575)

## Method 1: Place the new binary directly (this method is only applicable when your node has reached the required block)

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
cp $HOME/$story_folder_name/story $HOME/.story/story/cosmovisor/upgrades/v0.10.0/bin/
```

### 4. stop the consensus client services

```bash
sudo systemctl stop story
```

### 5. copy the current node binary to the cosmovisor genesis directory

```bash
cp $HOME/$story_folder_name/story $HOME/.story/story/cosmovisor/genesis/bin
```

### 6. set access and delete the existing upgrade file in data dir

```bash
sudo chown -R $USER:$USER $HOME/.story && sudo rm $HOME/.story/story/data/upgrade-info.json
```

### 7. restart consensus client services

```bash
sudo systemctl daemon-reload && \
sudo systemctl restart story
```

### 8. check the node version

```bash
cosmovisor run version
```

### 9. after the instructions are succesfully completed, u can delete the tar file and folder

```bash
sudo rm -rf $HOME/$story_folder_name $HOME/story-linux-amd64-0.10.0-9603826.tar.gz
```

## Method 2: Let Cosmovisor handle placing the binary itself (this can be applied before the node reaches the hard-fork block height, making it semi-automated)

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

### 4. set access and delete the existing upgrade file in data dir

```bash
sudo chown -R $USER:$USER $HOME/.story && sudo rm $HOME/.story/story/data/upgrade-info.json
```

### 5. execute the cosmovisor `add-upgrade` command

**v0.10.0 block height upgrade is 626575**

```bash
cosmovisor add-upgrade v0.10.0 $HOME/$story_folder_name/story --upgrade-height 626575 --force
```

### 6. after the instructions are succesfully completed, u can delete the tar file and folder

```bash
sudo rm -rf $HOME/$story_folder_name $HOME/story-linux-amd64-0.10.0-9603826.tar.gz
```

## Method 3: Use snapshot for the post upgrade (thank you to Mandragora for allowing me to publish his snapshot file here)

### 1. stop your geth and consensus client services

```bash
sudo systemctl stop story-geth
sudo systemctl stop story
```

### 2. backup `priv_state_validator.json` file

```bash
sudo cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/priv_validator_state.json.backup
```

### 3. delete geth and consensus client db

```bash
sudo rm -rf $HOME/.story/geth/iliad/geth/chaindata
sudo rm -rf $HOME/.story/story/data
```

### 4. download the geth snapshot file

```bash
wget -O geth_snapshot.lz4 https://snapshots.mandragora.io/geth_snapshot.lz4
```

`wait until it's finished`

### 5. download the story snapshot file

```bash
wget -O story_snapshot.lz4 https://snapshots.mandragora.io/story_snapshot.lz4
```

`wait until it's finished`

### 6. extract the geth snapshot file

```bash
lz4 -c -d geth_snapshot.lz4 | tar -x -C $HOME/.story/geth/iliad/geth
```

`wait until it's finished`

### 5. extract the story snapshot file

```bash
lz4 -c -d story_snapshot.lz4 | tar -x -C $HOME/.story/story
```

`wait until it's finished`

### 6. delete the snapshot file (optional)

```bash
sudo rm -v geth_snapshot.lz4
sudo rm -v story_snapshot.lz4
```

### 7. restore your `priv_state_validator.json` file

```bash
sudo cp $HOME/.story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json
```

### 8. download the node binary

```bash
cd $HOME && \
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.10.0-9603826.tar.gz
```

### 9. extract the new node binary

```bash
story_folder_name=$(tar -tf story-linux-amd64-0.10.0-9603826.tar.gz | head -n 1 | cut -f1 -d"/")
tar -xzf story-linux-amd64-0.10.0-9603826.tar.gz
```

### 10. define the path of cosmovisor for being used in the consensus client

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

### 11. set access and delete the existing upgrade file in data dir

```bash
sudo chown -R $USER:$USER $HOME/.story && sudo rm $HOME/.story/story/data/upgrade-info.json
```

### 12. execute the cosmovisor `add-upgrade` command (if u still use the old version)

**v0.10.0 block height upgrade is 626575**

```bash
cosmovisor add-upgrade v0.10.0 $HOME/$story_folder_name/story --upgrade-height 626575 --force
```

### 13. after the instructions are succesfully completed, u can delete the tar file and folder

```bash
sudo rm -rf $HOME/$story_folder_name $HOME/story-linux-amd64-0.10.0-9603826.tar.gz
```

### 14. start geth service

```bash
sudo systemctl daemon-reload && \
sudo systemctl restart story-geth && \
sudo journalctl -u story-geth -fn 100
```

### 15. start consensus client service

```bash
sudo systemctl daemon-reload && \
sudo systemctl restart story && \
sudo journalctl -u story -fn 100
```

# Geth version update to v0.9.3 (before height 1,069,000)

### 1. download geth binary

```bash
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.3-b224fdf.tar.gz
geth_folder_name=$(tar -tf geth-linux-amd64-0.9.3-b224fdf.tar.gz | head -n 1 | cut -f1 -d"/")
tar -xvf geth-linux-amd64-0.9.3-b224fdf.tar.gz
mv $HOME/$geth_folder_name/geth $HOME/go/bin/
sudo rm -rf $HOME/$geth_folder_name $HOME/geth-linux-amd64-0.9.3-b224fdf.tar.gz
geth --version
```

### 2. restart geth service

```bash
sudo systemctl daemon-reload && \
sudo systemctl restart story-geth && \
sudo journalctl -u story-geth -fn 100
```

### let's buidl together