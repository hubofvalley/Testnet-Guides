#!/bin/bash

# Script: 0g_standard_zgs_node_snapshot.sh
# Purpose: Automated snapshot application for 0G Storage Node
# Version: 1.2

### Configuration ###
SERVICE_NAME="zgs"
TARGET_DIR="$HOME/0g-storage-node/run/db"
SNAPSHOT_URL="https://standard-zgs-node-snapshot-0g.grandvalleys.com/standard_zgs_snapshot.tar.gz"
LOG_FILE="$HOME/0g_snapshot_application_$(date +%Y%m%d%H%M%S).log"

### Initialize Environment ###
exec > >(tee -a "$LOG_FILE") 2>&1
set -e  # Exit immediately on error

### Header ###
echo "### 0G Standard ZGS Node Snapshot Application ###"
echo "Start Time: $(date)"
echo "Log File: $LOG_FILE"

### Dependency Check ###
echo -e "\n[1/4] Verifying dependencies..."
declare -A REQUIRED_TOOLS=(
    [curl]="sudo apt install curl"
    [gzip]="sudo apt install gzip"
    [tar]="sudo apt install tar"
)

for tool in "${!REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
        echo "Installing missing dependency: $tool"
        eval "${REQUIRED_TOOLS[$tool]}"
    fi
done

### Service Management ###
echo -e "\n[2/4] Managing $SERVICE_NAME service..."
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "Stopping service..."
    sudo systemctl stop "$SERVICE_NAME"
else
    echo "Service not running - proceeding without stop"
fi

### Data Management ###
echo "Cleaning target directory..."
rm -rf "${TARGET_DIR:?}"/*

### Snapshot Application ###
echo -e "\n[4/4] Applying snapshot..."
echo "Source: $SNAPSHOT_URL"
echo "Destination: $TARGET_DIR"

curl -# -L "$SNAPSHOT_URL" | \
    gzip -dc | \
    tar xf - -C "$TARGET_DIR"

### Finalization ###
echo -e "\n[✓] Restarting service..."
sudo systemctl restart "$SERVICE_NAME"

echo -e "\n### Application Completed Successfully ###"
echo "End Time: $(date)"
echo "Verify service status: sudo systemctl status $SERVICE_NAME"
echo "Verify data integrity: ls -lh $TARGET_DIR"