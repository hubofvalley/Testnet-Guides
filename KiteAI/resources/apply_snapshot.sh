#!/bin/bash
# KiteAI apply_snapshot.sh - Example script for snapshot application
set -e

echo "=== KiteAI: Applying snapshot to node data directory ==="
SNAPSHOT_URL="${KITEAI_SNAPSHOT_URL:-https://example.com/kiteai-snapshot.tar.gz}"
DATA_DIR="${KITEAI_DATA_DIR:-./data}"

echo "Downloading snapshot from $SNAPSHOT_URL ..."
curl -L "$SNAPSHOT_URL" -o /tmp/kiteai-snapshot.tar.gz

echo "Extracting snapshot to $DATA_DIR ..."
mkdir -p "$DATA_DIR"
tar -xzvf /tmp/kiteai-snapshot.tar.gz -C "$DATA_DIR"

echo "Snapshot applied successfully."