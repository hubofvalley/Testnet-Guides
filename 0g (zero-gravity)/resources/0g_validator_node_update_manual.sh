#!/bin/bash

function update_version {
    VERSION=$1
    RELEASE_URL="$2/galileo-${VERSION}.tar.gz"
    BACKUP_DIR="$HOME/backups"

    echo "Updating to version $VERSION..."
    
    # Stop services
    sudo systemctl stop 0g-geth.service || { echo "Failed to stop 0g-geth"; exit 1; }
    sudo systemctl stop 0gchaind.service || { echo "Failed to stop 0gchaind"; exit 1; }

    # Backup old binaries
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    mkdir -p $BACKUP_DIR
    [ -f $HOME/go/bin/0g-geth ] && cp $HOME/go/bin/0g-geth $BACKUP_DIR/0g-geth.$TIMESTAMP
    [ -f $HOME/go/bin/0gchaind ] && cp $HOME/go/bin/0gchaind $BACKUP_DIR/0gchaind.$TIMESTAMP

    # Download and install new version
    cd $HOME
    wget $RELEASE_URL || { echo "Download failed"; exit 1; }
    tar -xzf galileo-${VERSION}.tar.gz || { echo "Extraction failed"; exit 1; }
    rm galileo-${VERSION}.tar.gz

    cp galileo-${VERSION}/bin/geth $HOME/go/bin/0g-geth
    cp galileo-${VERSION}/bin/0gchaind $HOME/go/bin/0gchaind
    sudo chmod +x $HOME/go/bin/0g-geth
    sudo chmod +x $HOME/go/bin/0gchaind

    # Rollback
    0gchaind rollback --home $HOME/.0gchaind/0g-home/0gchaind-home/

    # Restart services
    sudo systemctl daemon-reload
    sudo systemctl start 0g-geth.service || { echo "Failed to start 0g-geth"; exit 1; }
    sudo systemctl start 0gchaind.service || { echo "Failed to start 0gchaind"; exit 1; }

    echo "Update to $VERSION completed!"
}

function setup_environment {
    NODE_TYPE=$1
    ETH_RPC_URL=$2
    BLOCK_NUM=$3
    
    {
        echo "export NODE_TYPE=\"$NODE_TYPE\""
        if [ "$NODE_TYPE" = "validator" ]; then
            echo "export ETH_RPC_URL=\"$ETH_RPC_URL\""
            echo "export BLOCK_NUM=\"$BLOCK_NUM\""
        fi
        echo 'export PATH=$PATH:$HOME/galileo-v2.0.4/bin'
    } >> ~/.bash_profile
    source ~/.bash_profile
}

function create_service_file {
    NODE_TYPE=$1
    ETH_RPC_URL=$2
    BLOCK_NUM=$3
    OG_PORT=${4:-26656} # Default port if not provided
    
    EXTERNAL_IP=$(curl -4 -s ifconfig.me)
    SERVICE_FILE="/etc/systemd/system/0gchaind.service"
    
    if [ "$NODE_TYPE" = "validator" ]; then
        sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=0gchaind Node Service (Validator)
After=network-online.target

[Service]
User=$USER
Environment=CHAIN_SPEC=devnet
WorkingDirectory=$HOME/.0gchaind
ExecStart=$HOME/go/bin/0gchaind start \\
    --chaincfg.chain-spec devnet \\
    --chaincfg.restaking.enabled \\
    --chaincfg.restaking.symbiotic-rpc-dial-url ${ETH_RPC_URL} \\
    --chaincfg.restaking.symbiotic-get-logs-block-range ${BLOCK_NUM} \\
    --home $HOME/.0gchaind/0g-home/0gchaind-home \\
    --chaincfg.kzg.trusted-setup-path=$HOME/.0gchaind/kzg-trusted-setup.json \\
    --chaincfg.engine.jwt-secret-path=$HOME/.0gchaind/jwt-secret.hex \\
    --chaincfg.kzg.implementation=crate-crypto/go-kzg-4844 \\
    --chaincfg.engine.rpc-dial-url=http://localhost:${OG_PORT}551 \\
    --p2p.seeds 85a9b9a1b7fa0969704db2bc37f7c100855a75d9@8.218.88.60:26656 \\
    --p2p.external_address=${EXTERNAL_IP}:${OG_PORT}656
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
    else
        sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=0gchaind Node Service (RPC)
After=network-online.target

[Service]
User=$USER
Environment=CHAIN_SPEC=devnet
WorkingDirectory=$HOME/.0gchaind
ExecStart=$HOME/go/bin/0gchaind start \\
    --chaincfg.chain-spec devnet \\
    --home $HOME/.0gchaind/0g-home/0gchaind-home \\
    --chaincfg.kzg.trusted-setup-path=$HOME/.0gchaind/kzg-trusted-setup.json \\
    --chaincfg.engine.jwt-secret-path=$HOME/.0gchaind/jwt-secret.hex \\
    --chaincfg.kzg.implementation=crate-crypto/go-kzg-4844 \\
    --chaincfg.engine.rpc-dial-url=http://localhost:${OG_PORT}551 \\
    --p2p.seeds 85a9b9a1b7fa0969704db2bc37f7c100855a75d9@8.218.88.60:26656 \\
    --p2p.external_address=${EXTERNAL_IP}:${OG_PORT}656
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
    fi
}

BASE_URL="https://github.com/0glabs/0gchain-NG/releases/download"

# Display menu
echo "Select version to update:"
echo "a) v1.2.1"
echo "b) v2.0.4"
echo "c) v2.0.4"

read -p "Enter the letter corresponding to the version: " choice

case $choice in
    a)
        VERSION="v1.2.1"
        ZIP_URL="https://0gchain-archive.grandvalleys.com/galileo-v1.2.1.zip"
        BACKUP_DIR="$HOME/backups"

        echo "Updating to version $VERSION (special ZIP process)..."

        # Stop services
        sudo systemctl stop 0g-geth.service || { echo "Failed to stop 0g-geth"; exit 1; }
        sudo systemctl stop 0gchaind.service || { echo "Failed to stop 0gchaind"; exit 1; }

        # Backup old binaries
        TIMESTAMP=$(date +%Y%m%d%H%M%S)
        mkdir -p $BACKUP_DIR
        [ -f $HOME/go/bin/0g-geth ] && cp $HOME/go/bin/0g-geth $BACKUP_DIR/0g-geth.$TIMESTAMP
        [ -f $HOME/go/bin/0gchaind ] && cp $HOME/go/bin/0gchaind $BACKUP_DIR/0gchaind.$TIMESTAMP

        # Download and install new version
        cd $HOME
        wget -O galileo-v1.2.1.zip "$ZIP_URL" || { echo "Download failed"; exit 1; }
        unzip -o galileo-v1.2.1.zip || { echo "Extraction failed"; exit 1; }

        cp -f galileo-v1.2.1/bin/geth $HOME/go/bin/0g-geth
        cp -f galileo-v1.2.1/bin/0gchaind $HOME/go/bin/0gchaind
        sudo chmod +x $HOME/go/bin/0g-geth
        sudo chmod +x $HOME/go/bin/0gchaind

        # rollback
        0gchaind rollback --home $HOME/.0gchaind/0g-home/0gchaind-home/

        # Restart services
        sudo systemctl daemon-reload
        sudo systemctl start 0g-geth.service || { echo "Failed to start 0g-geth"; exit 1; }
        sudo systemctl start 0gchaind.service || { echo "Failed to start 0gchaind"; exit 1; }

        echo "Update to $VERSION completed!"
        ;;
    b)
        while true; do
            read -p "Deploy type? (validator/rpc): " NODE_TYPE
            NODE_TYPE=$(echo "$NODE_TYPE" | tr '[:upper:]' '[:lower:]')
            if [[ "$NODE_TYPE" == "validator" || "$NODE_TYPE" == "rpc" ]]; then
                break
            else
                echo "Please type exactly 'validator' or 'rpc'."
            fi
        done

        # Extra prompts for VALIDATOR
        if [ "$NODE_TYPE" = "validator" ]; then
            read -p "Enter Holesky ETH RPC endpoint (ETH_RPC_URL): " ETH_RPC_URL
            while [ -z "$ETH_RPC_URL" ]; do
                echo "ETH_RPC_URL cannot be empty for validator mode."
                read -p "Enter Holesky ETH RPC endpoint (ETH_RPC_URL): " ETH_RPC_URL
            done
            read -p "Enter block range to fetch logs (BLOCK_NUM), e.g. 2000: " BLOCK_NUM
            while ! [[ "$BLOCK_NUM" =~ ^[0-9]+$ ]]; do
                echo "BLOCK_NUM must be a positive integer."
                read -p "Enter block range to fetch logs (BLOCK_NUM), e.g. 2000: " BLOCK_NUM
            done
        fi

        read -p "Enter port number (default: 26656): " OG_PORT
        OG_PORT=${OG_PORT:-26656}

        setup_environment "$NODE_TYPE" "$ETH_RPC_URL" "$BLOCK_NUM"
        create_service_file "$NODE_TYPE" "$ETH_RPC_URL" "$BLOCK_NUM" "$OG_PORT"
        
        update_version "v2.0.4" "$BASE_URL/v2.0.4"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo "Let's Buidl 0G Together!"

