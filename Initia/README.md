# Initia Testnet Guide

`will always update`

## Initia

![alt text](initia.png)

- **WHAT IS INITIA?**
  Initia is a platform designed for creating secure, scalable modular blockchains using Celestia's DA infrastructure. It aims to streamline the multichain experience by vertically integrating the entire tech stack. Initia connects Layer 1 with Layer 2 application chains ("Minitias") using its rollup framework and supports inter-minitia communication through a dedicated messaging layer.

- **THE INITIATION**
  is an 8-week Incentivized Public Testnet adventure by Initia. This is the first chance to explore Initia's new multi-chain world developed over the past year. Join the Initia Militia, provide feedback, explore Minitias, and enjoy the experience.

![alt text](apps.png)

- **JOIN AND STUDY INITIA**
  With Public Testnet, Initia’s docs and code become public. Check them out below! - [Initia Website](https://initia.xyz/) - [Initia X](https://x.com/initiaFDN) - [Initia Discord](https://discord.gg/initia) - [Initia Docs](http://docs.initia.xyz/) - [Initia Github](https://github.com/initia-labs) - [Initia Medium](https://medium.com/@initiafdn?source=post_page-----e6e78e3d2f46--------------------------------) - [Initia Explorer - initiation-1](https://scan.testnet.initia.xyz/initiation-1)

## Initia Node Deploy Guide

### 1. Install dependencies for building from source

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
```

### 2. install go

```bash
sudo rm -rf /usr/local/go
curl -L https://go.dev/dl/go1.21.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
source .bash_profile
```

### 3. set vars

```bash
echo "export WALLET="wallet"" >> $HOME/.bash_profile
echo "export MONIKER="<insert your moniker>"" >> $HOME/.bash_profile
echo "export IDENTITY="<insert your identity>"" >> $HOME/.bash_profile
echo "export DETAILS="<insert your details>"" $HOME/.bash_profile
echo "export INITIA_CHAIN_ID="initiation-1"" >> $HOME/.bash_profile
echo "export INITIA_PORT="26"" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### 4. download binary

```bash
cd $HOME
rm -rf initia
git clone https://github.com/initia-labs/initia.git
cd initia
git checkout v0.2.15
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
PEERS="b858c16307a9730007d67918272b4b81bfdccee9@136.243.75.46:51656,b5d5108a5b11b55fa7725569517a2d19ff6ed096@135.181.213.169:26656,3194727c8195c5819093b677a982be0d512fa033@89.187.191.103:26656,bbed6acb41d66403e27294471f742d56b7929740@84.32.186.161:26656,9bd20099d508f40d5b0f803e36613fb4d2b5cd82@147.45.197.205:26656,0763b4a372cc0c2c50ceeca3205fa47a770ba489@37.27.118.144:27656,78cd568357be4e89a25cbb91dadd69153d27319f@37.27.100.124:27656,bdda79344c3d0a1399fc1df5afa3b3eeed42b030@37.27.100.171:27656,88fc1ceb74ae35907b96fde508fb00ed16dc7fb9@95.216.23.165:26656,d0e59cf5607ed3241e193995f344c80c536a3b9f@37.27.119.209:27656,2e120200e1ce0e5db42f8de0664304bc6e780c3b@85.190.240.122:25756,42ef41a1c59ca4078123e2a204d63ddcec58a3a2@149.56.107.219:53456,20bc0588df61ad3027919035ba2a4403f3e58d1c@65.108.129.151:26656,30fe1a5ce80ed5868202d61117480fa16b056255@37.27.100.240:27656,5f8b1929e71923d3466eee1178922eb15cec5210@93.189.29.18:26656,ef38a927103d86091019d4a2d9289f91607f2ac6@139.99.208.153:26656,b54d4bdf047f0c60a965b1f9b03bdcf58c79e7a3@158.220.113.67:26656,7f45e6641b481e7b6bd4c19a1cb603d84d7b1765@51.195.60.216:26656,ab137f5c7eed1bb5172bd7cbe642ec17180ec397@193.34.213.155:33756,39fdd2b916bd54b36d4cf0bf491014f1d20b12d7@51.178.79.51:26656,01c5d72c07aa846283494d9fe023c829c84bfdcc@65.109.126.231:25756,7c1176aec5e64985f1d979eff8a0130b20620a40@135.125.189.52:26656,19d1b74e90dac092160b423adb07b7e292bb6056@148.113.6.161:26656,1d7009d9a98534134d1f11e37ac3117a2ffa5664@95.31.9.170:26656,a8820aa280a4aeceae186651b824fc6db973747f@148.113.9.177:26656,8129b714b137164c29faaa3848a11be1eb32fa58@54.37.245.232:26656,54e3a3fd945e1769806a3c38fa6c708ee3e6dc15@194.60.87.37:27656,79591d0c20517a24ab9ea8525f22892fa3695fff@159.69.75.169:26656,afe2a5fe959581caa90cc0295f068690b00285a5@147.135.255.123:26656,da659e3dee0f7fd38bcf054bc30b934a55dfb5be@77.221.152.108:26656,2692225700832eb9b46c7b3fc6e4dea2ec044a78@34.126.156.141:26656,0975601aa5e06e3ef71a1b1d22c2f68b39523baa@136.243.148.16:26656,911e6dc9b21cc37bf6c0b09e86a426304a927cfa@51.91.31.25:26656,3441b75ab16d6ef1e2f1ce1eb94e5a222d3781c7@116.202.229.240:26656,b6391aa0a89a80713e10cc9d4d1600b06b39753b@95.216.227.103:26656,31dbc8c4e2fd7f4dbda96c1de35f2abf7bc4bdb1@144.76.27.3:26656,01b9a8ca119b272c9c903b4dcaabd9a9ed3882f9@86.57.164.166:26656,05fd9f29f2f7b8563d7e147e0dd75212cfea1332@148.113.6.141:26656,0418283fab9185d5c89b0529955d2b33d61fa291@92.100.157.81:26656,6d3e665b42db96ae18b660efed0289e189d13695@109.120.187.4:26656,fbb7d528c2e9bb117fc4b646894e30ba533f7274@88.99.6.62:26656,7a5ad140cb410cf74da7159e5fc752a08cf3146f@138.201.54.184:26656,0c15954d902f9a9fae13e2099de66b1ffad46296@43.133.57.57:26656,04febac7ef2311b980875f6efec66408aad90535@5.182.87.193:17956,0bb11eaf1867a11c2fbbbe250c4d33850329a2df@109.205.181.106:26656,8ce3867af7fb05558ea37848f1aece4680529f08@195.179.229.255:26656,64bf379a6d1c03f1fcb4427ecfc89ea2e709c840@95.216.228.170:26656,1b9111d2403a4ac7a7db3cccb67011e055dd1ebd@38.242.205.216:26656,58cc35a74fe9596dc5da199d4bdb827e81c0ec41@195.3.221.233:26656,d945ecc1524d4caf8ca43c197faff7578e7ae39d@84.247.133.31:53456,0e3a6f70d8f9dbf7207834ea7cd2a380ce93086e@95.216.189.71:26656,5480ce7d9beeccc362dfd7249c5b310c9af990c4@138.201.123.228:26656,04c8dc8e5c7b1c4d45c24c3e6032f78bf34f277e@159.223.82.33:26656,823c33d713c82151e821c8ebd5a999afcbc4ed9a@77.90.13.187:26656,72999c6ecdbf7d71ee14aea3d3783911a4a77109@159.69.68.183:26656,5ef43490bfe9a6dda06d4599cac1ec35a23b8d88@65.109.122.105:26656,62be132afdc1691e9537377447003cdf4f72bb09@43.156.12.114:26656,ae59b844d4c4967b2a1badc11e7f7378dfee791a@38.242.128.172:26656,1b570dc5c2fa944edd3c16938b10561c56442eb2@194.163.133.165:25756,7214e5af9db4a2318bba558f41c018d26f5420dd@176.124.220.146:26656" && \
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

#### HETZNER PEERS

```bash
PEERS=$(curl -s --max-time 3 --retry 2 --retry-connrefused "https://rpc-initia-testnet.trusted-point.com/hetzner_peers.txt")
if [ -z "$PEERS" ]; then
echo "No peers were retrieved from the URL."
else
echo -e "\nPEERS: "$PEERS""
sed -i "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" "$HOME/.initia/config/config.toml"
echo -e "\nConfiguration file updated successfully.\n"
fi
```

#### NON-CONTABO PEERS

```bash
PEERS=$(curl -s --max-time 3 --retry 2 --retry-connrefused "https://rpc-initia-testnet.trusted-point.com/non_contabo_peers.txt")
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

## SNAPSHOT

### THANKS TO CROUTON DIGITAL

```bash
sudo systemctl stop initiad

cp $HOME/.initia/data/priv_validator_state.json $HOME/.initia/priv_validator_state.json.backup

initiad tendermint unsafe-reset-all --home $HOME/.initia --keep-addr-book

curl https://storage.crouton.digital/testnet/initia/snapshots/initia_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.initia

mv $HOME/.initia/priv_validator_state.json.backup $HOME/.initia/data/priv_validator_state.json

sudo systemctl restart initiad && sudo journalctl -u initiad -fn 100 -o cat
```
