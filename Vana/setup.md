## Setups guide

### 1. install dependencies

```bash
sudo apt update -y && sudo apt install -y git software-properties-common curl && \
sudo add-apt-repository ppa:deadsnakes/ppa && sudo apt update -y && \
sudo apt install -y python3.11 python3.11-venv python3.11-dev && \
curl -sSL https://install.python-poetry.org | python3.11 - && \
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc && \
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && \
sudo apt install -y nodejs && \
git --version && python3.11 --version && poetry --version && node --version && npm --version
```

### 2. download binary

```bash
git clone https://github.com/vana-com/vana-dlp-chatgpt.git
cd vana-dlp-chatgpt
```

### 3. create `.env` file

```bash
cp .env.example .env
```

### 4. install app dependencies

```bash
source myenv/bin/activate
poetry env use python3.11
poetry install
```

### 5. install Vana CLI (optional)

```bash
pip install vana
deactivate
```

### 6. create a wallet

input your wallet name, create your wallet password and backup the coldkey and hotkey mnemonic

```bash
vanacli wallet create --wallet.name default --wallet.hotkey default
```

- Coldkey: for human-managed transactions (like staking)
- Hotkey: for validator-managed transactions (like submitting scores)

### 7. add Satori Testnet to EVM Wallet Extension (i.e Metamask)

| Network name | Satori Testnet |
| RPC URL | https://rpc.satori.vana.org |
| Chain ID | 14801 |
| Currency | VANA |

### 8. export your private keys

```bash
vanacli wallet export_private_key  --wallet.name default
```

enter `coldkey` then backup the coldkey's private key. execute the command again, enter `hotkey` then backup the hotkey's private key

### 9. import both your coldkey and hotkey addresses into the EVM wallet extension using their private keys

save those addresses

### 10. request [faucet](https://faucet.vana.org) funds for both addresses

- Note: you can only use the faucet once per day. Use the testnet faucet available at https://faucet.vana.org to fund your wallets, or ask a VANA holder to send you some test VANA tokens.

## Create a DLP

### 1. generate encryption keys

```bash
cd $HOME/vana-dlp-chatgpt/ && \
./keygen.sh
```

- backup the generated keys
- backup public_key.asc, public_key_base64.asc, private_key.asc and private_key_base64.asc files

# [CONTINUE TO DLP SMART CONTRACTS DEPLOYMENT](https://github.com/hubofvalley/Testnet-Guides/blob/main/Vana/DLP-smart-contracts.md)

### let's buidl together
