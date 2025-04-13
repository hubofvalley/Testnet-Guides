# Initia Testnet Guide

> _This guide is continuously updated._

![Initia](initia.png)

---

## What is Initia?

Initia is a platform designed for creating secure, scalable modular blockchains using Celestia's DA infrastructure. It aims to streamline the multichain experience by vertically integrating the entire tech stack. Initia connects Layer 1 with Layer 2 application chains ("Minitias") using its rollup framework and supports inter-minitia communication through a dedicated messaging layer.

---

## The Initiation

The Initiation is an 8-week Incentivized Public Testnet adventure by Initia. This is the first chance to explore Initia's new multi-chain world developed over the past year. Join the Initia Militia, provide feedback, explore Minitias, and enjoy the experience.

![Initia Apps](apps.png)

---

## Join and Study Initia

With Public Testnet, Initia’s docs and code become public. Check them out below!

- [Initia Website](https://initia.xyz/)
- [Initia X](https://x.com/initiaFDN)
- [Initia Discord](https://discord.gg/initia)
- [Initia Docs](http://docs.initia.xyz/)
- [Initia Github](https://github.com/initia-labs)
- [Initia Medium](https://medium.com/@initiafdn?source=post_page-----e6e78e3d2f46--------------------------------)
- [Initia Explorer - initiation-1](https://scan.testnet.initia.xyz/initiation-1)

---

## Initia Node Deploy Guide

### 1. Install Dependencies for Building from Source

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
```

### 2. Install Go

```bash
sudo rm -rf /usr/local/go
curl -L https://go.dev/dl/go1.21.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
source .bash_profile
```

### 3. Set Vars

```bash
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export MONIKER=<insert your moniker>" >> $HOME/.bash_profile
echo "export IDENTITY=<insert your identity>" >> $HOME/.bash_profile
echo "export DETAILS=<insert your details>" >> $HOME/.bash_profile
echo "export INITIA_CHAIN_ID=initiation-1" >> $HOME/.bash_profile
echo "export INITIA_PORT=26" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### 4. Download Binary

```bash
cd $HOME
rm -rf initia
git clone https://github.com/initia-labs/initia.git
cd initia
git checkout v0.2.15
make install
```

### 5. Config and Init App

```bash
initiad init $MONIKER
initiad config set client chain-id initiation-1
initiad config set client node tcp://localhost:${INITIA_PORT}657
sed -i -e "s|^node *=.*|node = \"tcp://localhost:${INITIA_PORT}657\"|" $HOME/.initia/config/client.toml
```

### 6. Download Genesis and Addrbook

```bash
wget -O $HOME/.initia/config/genesis.json https://testnet-files.itrocket.net/initia/genesis.json
wget -O $HOME/.initia/config/addrbook.json https://testnet-files.itrocket.net/initia/addrbook.json
```

### 7. Set Seeds and Peers

```bash
PEERS="b858c16307a9730007d67918272b4b81bfdccee9@136.243.75.46:51656,..." # (truncated for brevity)
SEEDS="2eaa272622d1ba6796100ab39f58c75d458b9dbc@34.142.181.82:26656,c28827cb96c14c905b127b92065a3fb4cd77d7f6@testnet-seeds.whispernode.com:25756"
sed -i \
 -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" \
 -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" \
 "$HOME/.initia/config/config.toml"
```

### 8. Set Custom Ports in app.toml

```bash
sed -i.bak -e "s%:1317%:${INITIA_PORT}317%g;
s%:8080%:${INITIA_PORT}080%g;
s%:9090%:${INITIA_PORT}090%g;
s%:9091%:${INITIA_PORT}091%g;
s%:8545%:${INITIA_PORT}545%g;
s%:8546%:${INITIA_PORT}546%g;
s%:6065%:${INITIA_PORT}065%g" $HOME/.initia/config/app.toml
```

### 9. Set Custom Ports in config.toml

```bash
sed -i.bak -e "s%:26658%:${INITIA_PORT}658%g;
s%:26657%:${INITIA_PORT}657%g;
s%:6060%:${INITIA_PORT}060%g;
s%:26656%:${INITIA_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${INITIA_PORT}656\"%;
s%:26660%:${INITIA_PORT}660%g" $HOME/.initia/config/config.toml
```

### 10. Config Pruning to Save Storage (Optional)

```bash
sed -i \
-e "s/^pruning *=.*/pruning = \"custom\"/" \
-e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" \
-e "s/^pruning-interval *=.*/pruning-interval = \"10\"/" \
"$HOME/.initia/config/app.toml"
```

### 11. Set Minimum Gas Price, Enable Prometheus, and Disable Indexing

```bash
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.15uinit,0.01uusdc"|g' $HOME/.initia/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.initia/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.initia/config/config.toml
```

### 12. Create Service File

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

### 13. Start the Node

```bash
sudo systemctl daemon-reload && \
sudo systemctl enable initiad && \
sudo systemctl restart initiad && sudo journalctl -u initiad -fn 100 -o cat
```

### 14. Create Wallet

```bash
initiad keys add $WALLET
```

### 15. Import Wallet by Using Seed Phrase

```bash
initiad keys add $WALLET --recover
```

### 16. Save Wallet and Validator Address

```bash
WALLET_ADDRESS=$(initiad keys show $WALLET -a)
VALOPER_ADDRESS=$(initiad keys show $WALLET --bech val -a)
echo "export WALLET_ADDRESS=$WALLET_ADDRESS" >> $HOME/.bash_profile
echo "export VALOPER_ADDRESS=$VALOPER_ADDRESS" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### 17. Get the Testnet Token (INIT) from Faucet

_You need to verify by using your Discord account and get the faucet role on Initia's Discord channel._  
[**Faucet**](https://faucet.testnet.initia.xyz/)

### 18. Check Sync Status

```bash
curl http://127.0.0.1:26657/status | jq
```

### 19. Check Wallet's Balance

_Make sure your node is fully synced, otherwise it won't work._

```bash
initiad query bank balances $WALLET_ADDRESS
```

### 20. Create Validator

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

---

## Download Fresh addrbook.json and Persistent Peers

_Thanks to TRUSTEDLABS_

### 1. Fresh addrbook.json

```bash
wget -O $HOME/.initia/config/addrbook.json https://rpc-initia-testnet.trusted-point.com/addrbook.json
```

### 2. Fresh Persistent Peers

#### Hetzner Peers

```bash
PEERS=$(curl -s --max-time 3 --retry 2 --retry-connrefused "https://rpc-initia-testnet.trusted-point.com/hetzner_peers.txt")
if [ -z "$PEERS" ]; then
  echo "No peers were retrieved from the URL."
else
  echo -e "\nPEERS: $PEERS"
  sed -i "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" "$HOME/.initia/config/config.toml"
  echo -e "\nConfiguration file updated successfully.\n"
fi
```

#### Non-Contabo Peers

```bash
PEERS=$(curl -s --max-time 3 --retry 2 --retry-connrefused "https://rpc-initia-testnet.trusted-point.com/non_contabo_peers.txt")
if [ -z "$PEERS" ]; then
  echo "No peers were retrieved from the URL."
else
  echo -e "\nPEERS: $PEERS"
  sed -i "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" "$HOME/.initia/config/config.toml"
  echo -e "\nConfiguration file updated successfully.\n"
fi
```

### 3. Restart the Node

```bash
sudo systemctl restart initiad && sudo journalctl -u initiad -fn 100 -o cat
```

---

## Stake Commands

### 1. Delegate to Your Validator

```bash
initiad tx mstaking delegate $(initiad keys show $WALLET --bech val -a) 1000000uinit --from $WALLET --chain-id initiation-1 --gas auto --fees 80000uinit -y
```

### 2. Delegate to Grand Valley (Optional)

```bash
initiad tx mstaking delegate initvaloper1freq4t9maa98mysv9jl03v7cmflevmvtrskv6u 1000000uinit --from $WALLET --chain-id initiation-1 --gas auto --fees 80000uinit -y
```

### 3. Withdraw All Rewards

```bash
initiad tx distribution withdraw-all-rewards --from $WALLET --chain-id initiation-1 --gas auto --fees 80000uinit
```

### 4. Withdraw Rewards and Commission from Your Validator

```bash
initiad tx distribution withdraw-rewards $VALOPER_ADDRESS --from $WALLET --commission --chain-id initiation-1 --gas auto --fees 80000uinit -y
```

### 5. Redelegate from Validator to Another Validator

```bash
initiad tx mstaking redelegate <FROM_VALOPER_ADDRESS> <TO_VALOPER_ADDRESS> 1000000uinit --from $WALLET --chain-id initiation-1 --gas auto --fees 80000uinit -y
```

### 6. Redelegate from Your Validator to Another Validator

```bash
initiad tx mstaking redelegate $VALOPER_ADDRESS <TO_VALOPER_ADDRESS> 1000000uinit --from $WALLET --chain-id initiation-1 --gas auto --fees 80000uinit -y
```

### 7. Undelegate

```bash
initiad tx mstaking unbond <VALOPER_ADDRESS> 1000000uinit --from $WALLET --chain-id initiation-1 --gas auto --fees 80000uinit -y
```

### 8. Undelegate from Your Validator

```bash
initiad tx mstaking unbond $(initiad keys show $WALLET --bech val -a) 1000000uinit --from $WALLET --chain-id initiation-1 --gas auto --fees 80000uinit -y
```

---

## Snapshot

_Thanks to Crouton Digital_

```bash
sudo systemctl stop initiad

cp $HOME/.initia/data/priv_validator_state.json $HOME/.initia/priv_validator_state.json.backup

initiad tendermint unsafe-reset-all --home $HOME/.initia --keep-addr-book

curl https://storage.crouton.digital/testnet/initia/snapshots/initia_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.initia

mv $HOME/.initia/priv_validator_state.json.backup $HOME/.initia/data/priv_validator_state.json

sudo systemctl restart initiad && sudo journalctl -u initiad -fn 100 -o cat
