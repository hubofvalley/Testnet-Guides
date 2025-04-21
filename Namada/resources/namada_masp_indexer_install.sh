#!/bin/bash
set -euo pipefail

###############################################################################
# Install Required Dependencies
###############################################################################
install_dependencies() {
    echo "=== Checking and installing required dependencies ==="

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
    install_if_missing "curl" "curl"
    install_if_missing "jq" "jq"
    install_if_missing "wget" "wget"
    install_if_missing "lsb-release" "lsb_release"
    install_if_missing "ca-certificates" "update-ca-certificates"
    install_if_missing "gnupg" "gpg"

    # Docker
    if ! command -v docker &> /dev/null; then
        echo "Docker not found. Installing Docker and Compose plugin from Docker’s official APT repo..."

        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
            | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

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

    # Docker Compose plugin fix
    if ! docker compose version &>/dev/null; then
        echo "Trying to manually link docker compose plugin..."
        if [ -f /usr/libexec/docker/cli-plugins/docker-compose ]; then
            sudo ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose || true
        fi
    fi

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
}

###############################################################################
# Configuration
###############################################################################
INDEXER_DIR="$HOME/namada-masp-indexer"
COMPOSE_FILE="${INDEXER_DIR}/docker-compose.yml"
ENV_FILE="${INDEXER_DIR}/.env"
WEBSERVER_PORT="8000"
PROJECT_NAME="namada-masp"

trap 'echo "Error occurred at line $LINENO. Aborting."; exit 1' ERR

stop_and_clean() {
    echo "=== Cleaning existing deployment ==="

    if docker compose ls | grep -q "${PROJECT_NAME}"; then
        echo "Stopping compose project..."
        docker compose -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" down --volumes --remove-orphans --timeout 30
    fi

    local containers=$(docker ps -aq --filter "name=${PROJECT_NAME}-*")
    if [[ -n "$containers" ]]; then
        echo "Removing orphaned containers..."
        docker rm -f "$containers" || true
    fi

    local images=$(docker images -q "namada-masp-*")
    if [[ -n "$images" ]]; then
        echo "Removing existing images..."
        docker rmi -f "$images" || true
    fi

    local volumes=$(docker volume ls -q --filter "name=${PROJECT_NAME}-*")
    if [[ -n "$volumes" ]]; then
        echo "Removing volumes..."
        docker volume rm -f "$volumes" || true
    fi
}

deploy() {
    echo "=== Deploying new instance ==="

    rm -rf "${INDEXER_DIR}" || true
    git clone https://github.com/anoma/namada-masp-indexer.git "${INDEXER_DIR}"
    cd "${INDEXER_DIR}"
    git fetch --all
    LATEST_TAG="v1.2.0"
    git checkout $LATEST_TAG
    git reset --hard $LATEST_TAG

    read -p "Enter RPC URL [https://lightnode-rpc-mainnet-namada.grandvalleys.com]: " TENDERMINT_URL
    TENDERMINT_URL=${TENDERMINT_URL:-"https://lightnode-rpc-mainnet-namada.grandvalleys.com"}

    cat > "${ENV_FILE}" <<EOF
COMETBFT_URL="${TENDERMINT_URL}"
PORT="${WEBSERVER_PORT}"
EOF

    docker compose -f "${COMPOSE_FILE}" --env-file $ENV_FILE up -d --pull always --build --force-recreate
}

verify_deployment() {
    echo "=== Verifying deployment ==="

    local web_status=$(docker compose -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" ps -q webserver)
    if [[ -z "$web_status" ]]; then
        echo "Error: Webserver container not running!"
        exit 1
    fi

    echo "Services running successfully:"
    docker compose -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" ps

    echo -e "\nAccess points:"
    echo "Webserver: http://localhost:${WEBSERVER_PORT}"
    echo "PostgreSQL: localhost:5432"
}

main() {
    install_dependencies

    if ! docker info >/dev/null 2>&1; then
        echo "Docker daemon not running. Please start Docker first."
        exit 1
    fi

    stop_and_clean
    deploy
    verify_deployment

    echo -e "\n=== Deployment complete ==="
    echo "To view logs: docker logs --tail 50 -f namada-masp-indexer-crawler-1"
}

main
