#!/bin/bash
set -e

###############################################################################
# Install Required Dependencies
###############################################################################
echo "Checking and installing required dependencies..."

install_if_missing() {
    local pkg_name="$1"
    local cmd_check="$2"
    if ! command -v "$cmd_check" &> /dev/null; then
        echo "Installing $pkg_name..."
        if [ -f /etc/debian_version ]; then
            sudo apt-get update
            sudo apt-get install -y "$pkg_name"
        elif [ -f /etc/redhat-release ]; then
            sudo yum install -y "$pkg_name"
        else
            echo "Unsupported OS. Please install $pkg_name manually."
            exit 1
        fi
    else
        echo "$pkg_name is already installed."
    fi
}

install_if_missing "git" "git"
install_if_missing "jq" "jq"
install_if_missing "wget" "wget"

# -------------------------------
# Docker + Compose Plugin Setup
# -------------------------------

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker and Compose plugin from Docker’s official APT repo..."

    # Install prerequisites
    install_if_missing "ca-certificates" "update-ca-certificates"
    install_if_missing "curl" "curl"
    install_if_missing "gnupg" "gpg"
    install_if_missing "lsb-release" "lsb_release"

    # Add Docker's GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Add Docker’s APT repo if not present
    if ! grep -q "download.docker.com" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
          https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
          | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    fi

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
                            docker-buildx-plugin docker-compose-plugin
else
    echo "Docker is already installed."
fi

# Fix for missing `docker compose` command
if ! docker compose version &>/dev/null; then
    echo "Trying to manually link docker compose plugin..."
    if [ -f /usr/libexec/docker/cli-plugins/docker-compose ]; then
        sudo ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose || true
    fi
fi

# Final check
if ! docker --version &>/dev/null || ! docker compose version &>/dev/null; then
    echo "❌ Docker or docker compose is still missing. Please install manually and retry."
    exit 1
else
    echo "✅ Docker and docker compose are available."
fi

# Start Docker if not running
if ! pgrep -f dockerd > /dev/null; then
    echo "Docker is not running. Attempting to start it..."
    sudo systemctl start docker || sudo service docker start || echo "Please start Docker manually."
fi

# Add user to docker group
if ! groups "$USER" | grep -q '\bdocker\b'; then
    echo "Adding $USER to docker group..."
    sudo usermod -aG docker "$USER"
    echo "Please log out and back in for group changes to take effect."
fi

###############################################################################
# Function to ensure input is not empty
###############################################################################
validate_non_empty() {
    local input="$1"
    local prompt="$2"
    while [[ -z "$input" ]]; do
        read -p "$prompt" input
    done
    echo "$input"
}

###############################################################################
# Interactive Input Section
###############################################################################
read -p "Please input RPC you want to use (leave empty for Grand Valley's RPC): " input_tendermint_url
TENDERMINT_URL_INPUT="${input_tendermint_url:-https://lightnode-rpc-namada.grandvalleys.com}"

POSTGRES_USER=$(validate_non_empty "" "Enter postgres username (can't be empty): ")
POSTGRES_PASSWORD=$(validate_non_empty "" "Enter postgres password (can't be empty): ")

###############################################################################
# Export Environment Variables
###############################################################################
export WIPE_DB=${WIPE_DB:-false}
export POSTGRES_PORT="5433"
export DATABASE_URL="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:$POSTGRES_PORT/namada-indexer"
export TENDERMINT_URL="$TENDERMINT_URL_INPUT"
export CHAIN_ID="housefire-alpaca.cc0d3e0c033be"
export CACHE_URL="redis://dragonfly:6379"
export WEBSERVER_PORT="6000"
export PORT="$WEBSERVER_PORT"

echo -e "\nProceeding with:
CHAIN_ID: $CHAIN_ID
TENDERMINT_URL: $TENDERMINT_URL
POSTGRES_USER: $POSTGRES_USER
POSTGRES_PASSWORD: *******"

read -p "Confirm to proceed? (y/n) " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] || exit 1

###############################################################################
# Clone and Prepare the Namada Indexer Repository
###############################################################################
cd "$HOME" || exit 1
rm -rf namada-indexer
git clone https://github.com/anoma/namada-indexer.git
cd namada-indexer || exit 1

LATEST_TAG="v2.3.0"
git fetch --all
git checkout "$LATEST_TAG"
git reset --hard "$LATEST_TAG"

###############################################################################
# Generate docker-compose-db.yml using the exported environment variables
###############################################################################
cat > docker-compose-db.yml << EOF
services:
  postgres:
    image: postgres:16-alpine
    command: ["postgres", "-c", "listen_addresses=0.0.0.0", "-c", "max_connections=200", "-p", "$POSTGRES_PORT"]
    expose:
      - "$POSTGRES_PORT"
    ports:
      - "$POSTGRES_PORT:$POSTGRES_PORT"
    environment:
      POSTGRES_PASSWORD: $POSTGRES_PASSWORD
      POSTGRES_USER: $POSTGRES_USER
      PGUSER: $POSTGRES_USER
      POSTGRES_DB: namada-indexer
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $POSTGRES_USER -d namada-indexer -h localhost -p $POSTGRES_PORT"]
      interval: 5s
      timeout: 5s
      retries: 5
    restart: unless-stopped
    volumes:
      - type: volume
        source: postgres-data
        target: /var/lib/postgresql/data

  dragonfly:
    image: docker.dragonflydb.io/dragonflydb/dragonfly
    command: --logtostderr --cache_mode=true --port 6379 -dbnum 1
    ulimits:
      memlock: -1
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD-SHELL", "redis-cli ping | grep PONG"]
      interval: 5s
      timeout: 5s
      retries: 5
    restart: unless-stopped

volumes:
  postgres-data:
EOF

docker system prune -f

###############################################################################
# Create .env file
###############################################################################
cat > .env << EOF
DATABASE_URL="$DATABASE_URL"
TENDERMINT_URL="$TENDERMINT_URL"
CHAIN_ID="$CHAIN_ID"
CACHE_URL="$CACHE_URL"
WEBSERVER_PORT="$WEBSERVER_PORT"
PORT="$PORT"
WIPE_DB="$WIPE_DB"
POSTGRES_PORT="$POSTGRES_PORT"
EOF

INDEXER_DIR="$HOME/namada-indexer"
ENV_FILE="${INDEXER_DIR}/.env"

wget -q https://indexer-snapshot-namada.grandvalleys.com/checksums.json || echo "Warning: Failed to download checksums"

docker stop $(docker container ls --all | grep 'namada-indexer' | awk '{print $1}') || true
docker container rm --force $(docker container ls --all | grep 'namada-indexer' | awk '{print $1}') || true
docker image rm --force $(docker image ls --all | grep -E '^namada/.*-indexer.*$' | awk '{print $3}') || true
docker image rm --force $(docker image ls --all | grep '<none>' | awk '{print $3}') || true

docker compose -f docker-compose.yml --env-file $ENV_FILE up -d --pull always --force-recreate

echo -e "\n✅ Installation complete. Services are running with the custom database configuration."
