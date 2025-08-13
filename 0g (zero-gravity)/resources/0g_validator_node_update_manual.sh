#!/bin/bash

function update_version {
    VERSION=$1
    RELEASE_URL="$2/galileo-${VERSION}.tar.gz"
    BACKUP_DIR="$HOME/backups"

    echo "Updating to version $VERSION..."
    
    # Stop services
    sudo systemctl stop 0g-geth.service
    sudo systemctl stop 0gchaind.service

    # Backup old binaries
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    mkdir -p $BACKUP_DIR
    cp $HOME/go/bin/0g-geth $BACKUP_DIR/0g-geth.$TIMESTAMP
    cp $HOME/go/bin/0gchaind $BACKUP_DIR/0gchaind.$TIMESTAMP

    # Download and install new version
    cd $HOME
    wget $RELEASE_URL || { echo "Download failed"; exit 1; }
    tar -xzf galileo-${VERSION}.tar.gz || { echo "Extraction failed"; exit 1; }
    rm galileo-${VERSION}.tar.gz

    mv galileo-${VERSION}/0g-geth $HOME/go/bin/0g-geth
    mv galileo-${VERSION}/0gchaind $HOME/go/bin/0gchaind
    sudo chmod +x $HOME/go/bin/0g-geth
    sudo chmod +x $HOME/go/bin/0gchaind

    # Restart services
    sudo systemctl daemon-reload
    sudo systemctl start 0g-geth.service
    sudo systemctl start 0gchaind.service

    echo "Update to $VERSION completed!"
}

BASE_URL="https://github.com/0glabs/0gchain-NG/releases/download"

# Display menu
echo "Select version to update:"
echo "a) v1.1.1"
# Uncomment and add more versions as needed
echo "b) v1.2.1"
echo "c) v2.0.2"
# echo "c) v1.3.0"

read -p "Enter the letter corresponding to the version: " choice

case $choice in
    a)
        update_version "v1.1.1" "$BASE_URL/v1.1.1"
        ;;
    # Uncomment and add more versions as needed
    b)
        # Custom update process for v1.2.1 (Notion ZIP)
        VERSION="v1.2.1"
        ZIP_URL="https://0gchain-archive.grandvalleys.com/galileo-v1.2.1.zip"
        BACKUP_DIR="$HOME/backups"

        echo "Updating to version $VERSION (special ZIP process)..."

        # Stop services
        sudo systemctl stop 0g-geth.service
        sudo systemctl stop 0gchaind.service

        # Backup old binaries
        TIMESTAMP=$(date +%Y%m%d%H%M%S)
        mkdir -p $BACKUP_DIR
        cp $HOME/go/bin/0g-geth $BACKUP_DIR/0g-geth.$TIMESTAMP
        cp $HOME/go/bin/0gchaind $BACKUP_DIR/0gchaind.$TIMESTAMP

        # Download and install new version
        cd $HOME
        wget -O galileo-v1.2.1.zip "$ZIP_URL" || { echo "Download failed"; exit 1; }
        unzip -o galileo-v1.2.1.zip || { echo "Extraction failed"; exit 1; }

        # Move new binaries (assume they are in galileo-v1.2.1/)
        cp -f galileo-v1.2.1/bin/geth $HOME/go/bin/0g-geth
        cp -f galileo-v1.2.1/bin/0gchaind $HOME/go/bin/0gchaind
        sudo chmod +x $HOME/go/bin/0g-geth
        sudo chmod +x $HOME/go/bin/0gchaind

        # rollback
        0gchaind rollback --home $HOME/.0gchaind/0g-home/0gchaind-home/

        # Restart services
        sudo systemctl daemon-reload
        sudo systemctl start 0g-geth.service
        sudo systemctl start 0gchaind.service

        echo "Update to $VERSION completed!"
        ;;
    c)
        update_version "v2.0.2" "$BASE_URL/v2.0.2"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo "Let's Buidl 0G Together!"

