## Story Node Deployment Guide With Cosmovisor
service file name: ``story.service`` ``story-geth.service``
current chain : ``iliad-0``

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
   tar -xvf geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
   sudo mv $HOME/geth-linux-amd64-0.9.2-ea9f0d2/geth $HOME/go/bin/

   # consensus client binary
   wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.9.11-2a25df1.tar.gz
   tar -xvf story-linux-amd64-0.9.11-2a25df1.tar.gz
   sudo mv $HOME/story-linux-amd64-0.9.11-2a25df1/story $HOME/go/bin/
   ```

### 6. init app
   ```bash
   story init --network $STORY_CHAIN_ID --moniker $MONIKER
   ```

### 9. Add peers to the config.toml
   ```bash
   peers=$(curl -sS https://rpc-story.grandvalleys.com/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
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
   mkdir -p $HOME/.story/story/cosmovisor/genesis/bin
   mkdir -p $HOME/.story/story/cosmovisor/upgrades
   mkdir -p $HOME/.story/story/cosmovisor/backup
   cp $HOME/go/bin/story $HOME/.story/story/cosmovisor/genesis/bin
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
#### edit the ``<input 1>`` with the value of ``input 1``
#### edit the ``<input 2>`` with the result of ``input 2``
#### edit the ``<input 3>`` with the result of ``input 3``
   ##### consensus service file
   ```bash
   sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
   [Unit]
   Description=Cosmovisor 0G Node
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
   sudo systemctl restart story-geth && sudo systemctl status story-geth
   ```

   #### start consensus client
   ```bash
   sudo systemctl daemon-reload && \
   sudo systemctl enable story && \
   sudo systemctl restart story && sudo systemctl status story
   ```

   #### this is an example of the node running properly
   ![image](https://github.com/user-attachments/assets/129dd95d-de3e-437f-a6af-0c807044e230)

### 19. check the geth logs
   ```bash
   sudo journalctl -u story-geth -fn 100 -o cat
   ``` 

### 20. check the consensus client logs
   ```bash
   sudo journalctl -u story -fn 100 -o cat
   ```

## you can use any snapshots and no need to manually update the binary version

#   Validator and key Commands
## 1. export evm public key and private key
  ```bash
  story validator export --export-evm-key && cat $HOME/.story/story/config/private_key.txt
  ```

## 2. check node synchronization
  ```bash
  curl http://127.0.0.1:${STORY_PORT}657/status | jq
  ```
  make sure your node block height has been synced with the latest block height. or you can check the ```catching_up``` value must be ```false```

## 3. claim faucet
   https://faucet.story.foundation/

## 4. create validator
  ```bash
   story validator create --stake 1000000000000000000 --private-key <your private key>
  ```

## 5. BACKUP YOUR VALIDATOR <img src="https://img.shields.io/badge/IMPORTANT-red" alt="Important" width="100">
  ```bash
  nano /$HOME/.story/story/config/priv_validator_key.json
  ```
  ```bash
  nano /$HOME/.story/story/data/priv_validator_state.json
  ```
  copy all of the contents of the ![priv_validator_key.json](https://img.shields.io/badge/priv__validator__key.json-red) !and ![priv_validator_key.json](https://img.shields.io/badge/priv__validator__state.json-red) files and save them in a safe place. This is a vital step in case you need to migrate your validator node

## 6. delegate token to validator
  ### self delegate
  ```bash
  story validator stake --private-key <your private key> --stake 1024000000000000000000 --validator-pubkey <your validator public key>
  ```
  ### delegate to <a href="https://testnet.storyscan.app/validators/storyvaloper1cvsdp0tsz25fhedd7cjvntq42347astvar06v8"><img src="https://github.com/hubofvalley/Testnet-Guides/assets/100946299/e8704cc4-2319-4a21-9138-0264e75e3a82" alt="GRAND VALLEY" width="50" height="50">
</a>

  ```bash
  story validator stake --private-key <your private key> --stake 1024000000000000000000 --validator-pubkey A2p1z6hM9IXltKaET6ny/wP0EPfIwBSPTkyeU135yroi
  ```

#  delete the node
  ```bash
  sudo systemctl stop story-geth story
  sudo systemctl disable story-geth story
  sudo rm -rf /etc/systemd/system/story-geth.service /etc/systemd/system/story.service
  sudo rm -r .story
  sed -i "/STORY_/d" $HOME/.bash_profile
  ```
