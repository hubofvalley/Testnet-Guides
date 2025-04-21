#!/bin/bash
set -euo pipefail

# Configuration
INDEXER_DIR="$HOME/namada-masp-indexer"
SNAPSHOT_URL="https://masp-indexer-snapshot-mainnet-namada.grandvalleys.com/masp_indexer_snapshot.sql"

# User confirmation
echo "Indexer Snapshot Update Script"
echo "-------------------------------"
read -p "This will refresh the indexer database. Continue? (y/n) " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 0

# Check dependencies
command -v docker >/dev/null || { echo "Docker required"; exit 1; }
command -v wget >/dev/null || { echo "wget required"; exit 1; }

cd "$INDEXER_DIR" || { echo "Directory missing: $INDEXER_DIR"; exit 1; }

# Strict flow execution with forced continuation
echo "1. Stopping services..."
docker compose down

echo "2. Downloading snapshot..."
wget -O masp_indexer_snapshot.sql "$SNAPSHOT_URL"

echo "3. Starting PostgreSQL..."
docker compose up -d postgres
sleep 2  # Brief initialization wait

echo "4. Transferring and restoring..."
docker compose cp masp_indexer_snapshot.sql postgres:/tmp/masp_indexer_snapshot.sql

# Force continuation regardless of pg_restore exit status
echo "5. Database restore (errors ignored)..."
docker compose exec postgres pg_restore -d masp_indexer_local --clean /tmp/masp_indexer_snapshot.sql --verbose || true

echo "6. Finalizing..."
docker compose exec postgres rm -f /tmp/masp_indexer_snapshot.sql
rm -f masp_indexer_snapshot.sql

echo "7. Restarting services..."
docker compose up -d

echo "8. Monitoring..."
docker logs --tail 50 -f namada-masp-indexer-crawler-1

echo "Let's Buidl Namada Together"