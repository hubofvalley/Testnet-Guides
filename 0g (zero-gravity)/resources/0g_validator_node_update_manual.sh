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
    chmod +x $HOME/go/bin/0g-geth
    chmod +x $HOME/go/bin/0gchaind

    # Restart services
    sudo systemctl daemon-reload
    sudo systemctl start 0g-geth.service
    sudo systemctl start 0gchaind.service

    echo "Update to $VERSION completed!"
    echo "Check service status:"
    echo "sudo journalctl -u 0gchaind -u 0g-geth -fn 100"
}

BASE_URL="https://github.com/0glabs/0gchain-NG/releases/download"

# Display menu
echo "Select version to update:"
echo "a) v1.1.1"
# Uncomment and add more versions as needed
echo "b) v1.2.1"
# echo "c) v1.3.0"

read -p "Enter the letter corresponding to the version: " choice

case $choice in
    a)
        update_version "v1.1.1" "$BASE_URL/v1.1.1"
        ;;
    # Uncomment and add more versions as needed
    b)
        update_version "v1.2.1" "$BASE_URL/v1.2.1"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo "Let's Buidl 0G Together!"

