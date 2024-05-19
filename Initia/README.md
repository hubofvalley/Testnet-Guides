# Initia Testnet Guide
```will always update```

## Initia
![alt text](initia.png)
- **WHAT IS INITIA?** 
Initia is a platform designed for creating secure, scalable modular blockchains using Celestia's DA infrastructure. It aims to streamline the multichain experience by vertically integrating the entire tech stack. Initia connects Layer 1 with Layer 2 application chains ("Minitias") using its rollup framework and supports inter-minitia communication through a dedicated messaging layer.

- **THE INITIATION**
is an 8-week Incentivized Public Testnet adventure by Initia. This is the first chance to explore Initia's new multi-chain world developed over the past year. Join the Initia Militia, provide feedback, explore Minitias, and enjoy the experience.

![alt text](apps.png)

- **JOIN AND STUDY INITIA**
With Public Testnet, Initia’s docs and code become public. Check them out below!
    - [Initia Website](https://initia.xyz/)
    - [Initia X](https://x.com/initiaFDN)
    - [Initia Discord](https://discord.gg/initia)
    - [Initia Docs](http://docs.initia.xyz/)
    - [Initia Github](https://github.com/initia-labs)
    - [Initia Medium](https://medium.com/@initiafdn?source=post_page-----e6e78e3d2f46--------------------------------)
    - [Initia Explorer - initiation-1](https://scan.testnet.initia.xyz/initiation-1)

## Initia Node Deploy Guide

### 1. Install dependencies for building from source
   ```bash
   sudo apt update && sudo apt upgrade -y
   sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
   ```

### 2. install go
   ```bash
   cd $HOME
   VER="1.22.2"
   wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"sudo rm -rf /usr/local/go
   sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
   rm "go$VER.linux-amd64.tar.gz"
   [ ! -f ~/.bash_profile ] && touch ~/.bash_profile
   echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
   source $HOME/.bash_profile
   [ ! -d ~/go/bin ] && mkdir -p ~/go/bin
   ```

### 3. set vars
   ```bash
   echo "export WALLET="wallet"" >> $HOME/.bash_profile
   echo "export MONIKER="<insert your moniker>"" >> $HOME/.bash_profile
   echo "export IDENTITY="<insert your identity>"" >> $HOME/.bash_profile
   echo "export DETAILS="<insert your details>"" $HOME/.bash_profile
   echo "export INITIA_CHAIN_ID="initiation-1"" >> $HOME/.bash_profile
   echo "export INITIA_PORT="51"" >> $HOME/.bash_profile
   source $HOME/.bash_profile
   ```

### 4. download binary
   ```bash
   cd $HOME
   rm -rf initia
   git clone https://github.com/initia-labs/initia.git
   cd initia
   git checkout v0.2.14
   make install
   ```

### 5. config and init app
   ```bash
   initiad init $MONIKER
   initiad config set client chain-id initiation-1
   initiad config set client node tcp://localhost:${INITIA_PORT}657
   sed -i -e "s|^node *=.*|node = \"tcp://localhost:${INITIA_PORT}657\"|" $HOME/.initia/config/client.toml
   ```

### 6. download genesis and addrbook
   ```bash
   wget -O $HOME/.initia/config/genesis.json https://testnet-files.itrocket.net/initia/genesis.json
   wget -O $HOME/.initia/config/addrbook.json https://testnet-files.itrocket.net/initia/addrbook.json
   ```

### 7. set seeds and peers
   ```bash
   PEERS="e3ac92ce5b790c76ce07c5fa3b257d83a517f2f6@178.18.251.146:30656,2692225700832eb9b46c7b3fc6e4dea2ec044a78@34.126.156.141:26656,2a574706e4a1eba0e5e46733c232849778faf93b@84.247.137.184:53456,40d3f977d97d3c02bd5835070cc139f289e774da@168.119.10.134:26313,1f6633bc18eb06b6c0cab97d72c585a6d7a207bc@65.109.59.22:25756,4a988797d8d8473888640b76d7d238b86ce84a2c@23.158.24.168:26656,e3679e68616b2cd66908c460d0371ac3ed7795aa@176.34.17.102:26656,d2a8a00cd5c4431deb899bc39a057b8d8695be9e@138.201.37.195:53456,329227cf8632240914511faa9b43050a34aa863e@43.131.13.84:26656,517c8e70f2a20b8a3179a30fe6eb3ad80c407c07@37.60.231.212:26656,07632ab562028c3394ee8e78823069bfc8de7b4c@37.27.52.25:19656,028999a1696b45863ff84df12ebf2aebc5d40c2d@37.27.48.77:26656,3c44f7dbb473fee6d6e5471f22fa8d8095bd3969@185.219.142.137:53456,8db320e665dbe123af20c4a5c667a17dc146f4d0@51.75.144.149:26656,c424044f3249e73c050a7b45eb6561b52d0db456@158.220.124.183:53456,767fdcfdb0998209834b929c59a2b57d474cc496@207.148.114.112:26656,edcc2c7098c42ee348e50ac2242ff897f51405e9@65.109.34.205:36656,140c332230ac19f118e5882deaf00906a1dba467@185.219.142.119:53456,4eb031b59bd0210481390eefc656c916d47e7872@37.60.248.151:53456,ff9dbc6bb53227ef94dc75ab1ddcaeb2404e1b0b@178.170.47.171:26656,ffb9874da3e0ead65ad62ac2b569122f085c0774@149.28.134.228:26656" && \
   SEEDS="2eaa272622d1ba6796100ab39f58c75d458b9dbc@34.142.181.82:26656,c28827cb96c14c905b127b92065a3fb4cd77d7f6@testnet-seeds.whispernode.com:25756" && \
   sed -i \
   -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" \
   -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" \
   "$HOME/.initia/config/config.toml"
   ```

### 8. set custom ports in app.toml
   ```bash
   sed -i.bak -e "s%:1317%:${INITIA_PORT}317%g;
   s%:8080%:${INITIA_PORT}080%g;
   s%:9090%:${INITIA_PORT}090%g;
   s%:9091%:${INITIA_PORT}091%g;
   s%:8545%:${INITIA_PORT}545%g;
   s%:8546%:${INITIA_PORT}546%g;
   s%:6065%:${INITIA_PORT}065%g" $HOME/.initia/config/app.toml
   ```

### 9. set custom ports in config.toml file
   ```bash
   sed -i.bak -e "s%:26658%:${INITIA_PORT}658%g;
   s%:26657%:${INITIA_PORT}657%g;
   s%:6060%:${INITIA_PORT}060%g;
   s%:26656%:${INITIA_PORT}656%g;
   s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${INITIA_PORT}656\"%;
   s%:26660%:${INITIA_PORT}660%g" $HOME/.initia/config/config.toml
   ```

### 10. config pruning to save storage (optional)
   ```bash
   sed -i \
   -e "s/^pruning *=.*/pruning = \"custom\"/" \
   -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" \
   -e "s/^pruning-interval *=.*/pruning-interval = \"10\"/" \
   "$HOME/.initia/config/app.toml"
   ```

### 11. set minimum gas price, enable prometheus and disable indexing
   ```bash
   sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.15uinit,0.01uusdc"|g' $HOME/.initia/config/app.toml
   sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.initia/config/config.toml
   sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.initia/config/config.toml
   ```

### 12. create service file
   ```bash
   sudo tee /etc/systemd/system/initiad.service > /dev/null <<EOF
   [Unit]
   Description=Initia Node
   After=network.target

   [Service]
   User=$USER
   Type=simple
   ExecStart=$(which initiad) start --home $HOME/.initia
   Restart=on-failure
   LimitNOFILE=65535

   [Install]
   WantedBy=multi-user.target
   EOF
   ```

### 13. start the node
   ```bash
   sudo systemctl daemon-reload && \
   sudo systemctl enable initiad && \
   sudo systemctl restart initiad && sudo journalctl -u initiad -fn 100 -o cat
   ```

### 14. create wallet
   ```bash
   initiad keys add $WALLET
   ```

### 15. import wallet by using seed phrase
   ```bash
   initiad keys add $WALLET --recover
   ```

### 16. save wallet and validator address
   ```bash
   WALLET_ADDRESS=$(initiad keys show $WALLET -a)
   VALOPER_ADDRESS=$(initiad keys show $WALLET --bech val -a)
   echo "export WALLET_ADDRESS="$WALLET_ADDRESS >> $HOME/.bash_profile
   echo "export VALOPER_ADDRESS="$VALOPER_ADDRESS >> $HOME/.bash_profile
   source $HOME/.bash_profile
   ```

### 17. get the testnet token (INIT) from faucet (**YOU NEED TO VERIFY BY USING YOUR DISCORD ACCOUNT, GET THE FAUCET ROLE ON INITIA'S DISCORD CHANNEL**) [[**FAUCET**](https://faucet.testnet.initia.xyz/)]

### 18. check sync status
   ```bash
   curl http://127.0.0.1:26657/status | jq
   ```

### 19. check wallet's balance (**MAKE SURE YOUR NODE IS FULLY SYNCED, OTHERWISE IT WON'T WORK**)
   ```bash
   initiad query bank balances $WALLET_ADDRESS
   ```

### 20. create validator
   ```bash
    initiad tx mstaking create-validator \
    --amount 20000000uinit \
    --from $WALLET \
    --commission-rate 0.05 \
    --commission-max-rate 0.2 \
    --commission-max-change-rate 0.01 \
    --pubkey $(initiad tendermint show-validator) \
    --moniker $MONIKER \
    --identity $IDENTITY \
    --details $DETAILS \
    --chain-id initiation-1 \
    --gas auto --fees 80000uinit \
    -y
   ```

## download fresh addrbook.json and persistent peers (**thank you to TRUSTEDLABS**)
### 1. fresh addrbook.json
   ```bash
   wget -O $HOME/.initia/config/addrbook.json https://rpc-initia-testnet.trusted-point.com/addrbook.json
   ```

### 2. fresh persistent peers
   ```bash
   PEERS=$(curl -s --max-time 3 --retry 2 --retry-connrefused "https://rpc-initia-testnet.trusted-point.com/peers.txt")
   if [ -z "$PEERS" ]; then
   echo "No peers were retrieved from the URL."
   else
   echo -e "\nPEERS: "$PEERS""
   sed -i "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" "$HOME/.initia/config/config.toml"
   echo -e "\nConfiguration file updated successfully.\n"
   fi
   ```

### 3. restart the node
   ```bash
   sudo systemctl restart initiad && sudo journalctl -u initiad -fn 100 -o cat
   ```

## stake commands
### 1. delegate to your validator
   ```bash
   initiad tx mstaking delegate $(initiad keys show $WALLET --bech val -a) 1000000uinit --from $WALLET --chain-id initiation-1 --gas auto --fees 80000uinit -y 
   ```

### 2. delegate to Grand Valley (OPTIONAL)
   ```bash
   initiad tx mstaking delegate initvaloper1freq4t9maa98mysv9jl03v7cmflevmvtrskv6u 1000000uinit --from $WALLET --chain-id initiation-1 --gas auto --fees 80000uinit -y
   ```

### 3. withdraw all rewards
   ```bash
   initiad tx distribution withdraw-all-rewards --from $WALLET --chain-id initiation-1 --gas auto --fees 80000uinit 
   ```

### 4. withdraw rewards and commision from your validator
   ```bash
   initiad tx distribution withdraw-rewards $VALOPER_ADDRESS --from $WALLET --commission --chain-id initiation-1 --gas auto --fees 80000uinit -y 
   ```

### 5. redelegate from validator to another validator
   ```bash
   initiad tx mstaking redelegate <FROM_VALOPER_ADDRESS> <TO_VALOPER_ADDRESS> 1000000uinit --from $WALLET --chain-id initiation-1 --gas auto --fees 80000uinit -y
   ```

### 5. redelegate from your validator to another validator
   ```bash
   initiad tx mstaking redelegate $VALOPER_ADDRESS <TO_VALOPER_ADDRESS> 1000000uinit --from $WALLET --chain-id initiation-1 --gas auto --fees 80000uinit -y
   ```

### 6. undelegate
   ```bash
   initiad tx mstaking unbond <VALOPER_ADDRESS> 1000000uinit --from $WALLET --chain-id initiation-1 --gas auto --fees 80000uinit -y
   ```

### 7. undelegate from your validator
   ```bash
   initiad tx mstaking unbond $(initiad keys show $WALLET --bech val -a) 1000000uinit --from $WALLET --chain-id initiation-1 --gas auto --fees 80000uinit -y
   ```


