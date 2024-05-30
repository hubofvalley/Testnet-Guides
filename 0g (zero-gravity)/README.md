# 0gchain Testnet Guide
```will always update```
<p align="center">
  <img src="https://github.com/hubofvalley/Testnet-Guides/assets/100946299/fe21ef6a-0979-4ac1-8d92-6d1bcf76c7cc" alt="let’s build 0G together" width="600" height="300">
</p>

## 0gchain

- **WHAT IS 0gchain?** 
ZeroGravity (0G) is the first infinitely scalable, decentralized data availability layer featuring a built-in general-purpose storage system. This enables 0G to offer a highly scalable on-chain database suitable for various Web2 and Web3 data needs, including on-chain AI. Additionally, as a data availability layer, 0G ensures seamless verification of accurate data storage.

In the sections below, we will delve deeper into this architecture and explore the key use cases it unlocks.

- **0G’s Architecture**
0G achieves high scalability by dividing the data availability workflow into two main lanes:

  1. **Data Storage Lane**: This lane achieves horizontal scalability through data partitioning, allowing for rapid storage and access of large amounts of data.

  2. **Data Publishing Lane**: This lane ensures data availability using a quorum-based system with an "honest majority" assumption, where the quorum is randomly selected via a Verifiable Random Function (VRF). This method avoids data broadcasting bottlenecks and supports larger data transfers in the Storage Lane.

0G Storage is an on-chain database made up of Storage Nodes that participate in a Proof of Random Access (PoRA) mining process. Nodes are rewarded for correctly responding to random data queries, promoting network participation and scalability.

0G DA (Data Availability) Layer is built on 0G Storage and uses a quorum-based architecture for data availability confirmation. The system relies on an honest majority of nodes, with quorum selection randomized by VRF and GPUs enhancing the erasure coding process for data storage.

- **0G solving target**
The increasing need for greater Layer 2 (L2) scalability has coincided with the rise of Data Availability Layers (DALs), which are essential for addressing Ethereum's scaling challenges. L2s handle transactions off-chain and settle on Ethereum for security, requiring transaction data to be posted somewhere for validation. By publishing data directly on Ethereum, high fees are distributed among L2 users, enhancing scalability.

DALs offer a more efficient method for publishing and maintaining off-chain data for inspection. However, existing DALs struggle to manage the growing volume of on-chain data, especially for data-intensive applications like on-chain AI, due to limited storage capacity and throughput.

0G offers a solution with a 1,000x performance improvement over Ethereum's danksharding and a 4x improvement over Solana's Firedancer, providing the infrastructure needed for massive Web3 data scalability. Key applications of 0G include:

1. **AI**: 0G Storage can handle large datasets, and 0G DA enables the rapid deployment of AI models on-chain.
2. **L1s / L2s**: These networks can use 0G for data availability and storage, with partners like Polygon, Arbitrum, Fuel, and Manta Network.
3. **Bridges**: Networks can store their state using 0G, facilitating secure cross-chain transfers by storing and communicating user balances.
4. **Rollups-as-a-Service (RaaS)**: 0G provides DA and storage infrastructure for RaaS providers like Caldera and AltLayer.
5. **DeFi**: 0G's scalable DA supports efficient DeFi on specific L2s and L3s, enabling fast settlement and high-frequency trading.
6. **On-chain Gaming**: Gaming requires reliable storage of cryptographic proofs and metadata, such as player assets and actions.
7. **Data Markets**: Web3 data markets can store their data on-chain, feasible on a large scale with 0G.

0G is a scalable, low-cost, and programmable DA solution essential for bringing vast amounts of data on-chain. Its role as an on-chain data storage solution unlocks numerous use cases, providing the database infrastructure for any on-chain application. 0G efficiently stores and proves the availability of any Web2 or Web3 data, extending benefits beyond confirming L2 transactions.

For more detailed information, visit the [0G DA documentation](https://docs.0g.ai/0g-doc/docs/0g-da)

With Public Testnet, 0gchain’s docs and code become public. Check them out below!
    - [0gchainWebsite](https://0g.ai/)
    - [0gchainX](https://x.com/0G_labs)
    - [0gchainDiscord](https://discord.com/invite/0glabs)
    - [0gchainDocs](https://docs.0g.ai/0g-doc)
    - [0gchainGithub](https://github.com/0glabs)
    - [0gchainExplorer - 0gchaintion-1](https://testnet.blockhub.id/0gchain)

## 0gchain Node Deployment Guide

### 1. Install dependencies for building from source
   ```bash
    sudo apt update && \
    sudo apt install curl git jq build-essential gcc unzip wget lz4 openssl -y
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

### 3. set vars
   ```
   echo 'export MONIKER="<your-moniker>"' >> ~/.bash_profile
   echo 'export CHAIN_ID="zgtendermint_16600-1"' >> ~/.bash_profile
   echo 'export WALLET_NAME="wallet"' >> ~/.bash_profile
   echo 'export 0G_PORT=26' >> $HOME/.bash_profile
   source $HOME/.bash_profile
   ```

### 4. download binary
   ```bash
   git clone -b v0.1.0 https://github.com/0glabs/0g-chain.git
   cd 0g-chain
   make install
   0gchaind version
   ```

### 5. config and init app
   ```bash
   cd $HOME
   0gchaind init $MONIKER --chain-id $CHAIN_ID
   0gchaind config chain-id $CHAIN_ID
   0gchaind config node tcp://localhost:${0G_PORT}657
   0gchaind config keyring-backend os
   ```

### 6. download genesis.json
   ```bash
   wget https://github.com/0glabs/0g-chain/releases/download/v0.1.0/genesis.json -O $HOME/.0gchain/config/genesis.json
   ```

### 7. Add seeds to the config.toml
   ```bash
   SEEDS="c4d619f6088cb0b24b4ab43a0510bf9251ab5d7f@54.241.167.190:26656,44d11d4ba92a01b520923f51632d2450984d5886@54.176.175.48:26656,f2693dd86766b5bf8fd6ab87e2e970d564d20aff@54.193.250.204:26656,f878d40c538c8c23653a5b70f615f8dccec6fb9f@54.215.187.94:26656" && \
   sed -i.bak -e "s/^seeds *=.*/seeds = \"${SEEDS}\"/" $HOME/.0gchain/config/config.toml
   ```

### 8. set custom ports in app.toml
   ```bash
   sed -i.bak -e "s%:26658%:${0G_PORT}658%g;
   s%:26657%:${0G_PORT}657%g;
   s%:6060%:${0G_PORT}060%g;
   s%:26656%:${0G_PORT}656%g;
   s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${0G_PORT}656\"%;
   s%:26660%:${0G_PORT}660%g" $HOME/.0G/config/config.toml
   ```

### 9. set custom ports in config.toml file
   ```bash
   sed -i.bak -e "s%:26658%:${0G_PORT}658%g;
   s%:26657%:${0G_PORT}657%g;
   s%:6060%:${0G_PORT}060%g;
   s%:26656%:${0G_PORT}656%g;
   s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${0G_PORT}656\"%;
   s%:26660%:${0G_PORT}660%g" $HOME/.initia/config/config.toml
   ```

### 10. config pruning to save storage (optional)
   ```bash
   sed -i \
      -e "s/^pruning *=.*/pruning = \"custom\"/" \
      -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" \
      -e "s/^pruning-interval *=.*/pruning-interval = \"10\"/" \
      "$HOME/.0gchain/config/app.toml"
   ```

### 11. set minimum gas price, enable prometheus and disable indexing
   ```bash
   sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.15uinit,0.01uusdc"|g' $HOME/.0gchain/config/app.toml
   sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.0gchain/config/config.toml
   sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.0gchain/config/config.toml
   ```

### 12. create service file
   ```bash
   sudo tee /etc/systemd/system/0ghcaind.service > /dev/null <<EOF
   [Unit]
   Description=0G Node
   After=network.target

   [Service]
   User=$USER
   Type=simple
   ExecStart=$(which 0gchaind) start --home $HOME/.0gchain
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
   sudo systemctl restart 0gchaind && sudo journalctl -u initiad -fn 100 -o cat
   ```
