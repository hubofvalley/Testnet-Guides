#!/bin/bash

# Detect OS and version
source /etc/os-release
SERVICE_NAME="namadad"

echo "Detected OS: $NAME $VERSION_ID"

# Available versions and their details (manually sorted)
# ⚠️ MAINTAINER NOTE:
# When a new Namada version is released, update this block manually:
# 1. Add the version below in correct order (e.g., v1.1.6 after v1.1.5)
# 2. Use format: ["version"]="block_range download_url"
# 3. Update also the for-loop in show_version_options and version_map array accordingly
# Example:
# ["v1.1.6"]="1605000-next https://github.com/anoma/namada/releases/download/v1.1.6"

declare -A versions=(
    ["v1.0.0"]="0-893999 https://github.com/anoma/namada/releases/download/v1.0.0"
    ["v1.1.1"]="894000-next https://github.com/anoma/namada/releases/download/v1.1.1"
    ["v1.1.5"]="1604223-next https://github.com/anoma/namada/releases/download/v1.1.5"
)

# Function to show version options
show_version_options() {
    echo -e "\n\033[1mChoose the version to install:\033[0m"
    local index=1

    for version in "v1.0.0" "v1.1.1" "v1.1.5"; do
        details=(${versions[$version]})
        block_height_range=${details[0]}
        echo "$index. Namada $version (Block height: $block_height_range)"
        ((index++))
    done

    echo "$index. Exit"
}

# Method 1: Pre-built binary
method1() {
    echo -e "\n\033[1mMethod 1: Using pre-built binary\033[0m"
    version=$1
    download_url=$2
    namada_file_name="namada-$version-Linux-x86_64"

    echo -e "\nStarting download for version $version..."
    temp_dir=$(mktemp -d -t namada-XXXXXX)

    if ! wget -P "$temp_dir" "$download_url/$namada_file_name.tar.gz"; then
        echo "Failed to download the binary. Exiting."
        exit 1
    fi

    echo "Download complete. Stopping Namada service..."
    sudo systemctl stop $SERVICE_NAME

    tar -xvf "$temp_dir/$namada_file_name.tar.gz" -C "$temp_dir"
    sudo chmod +x "$temp_dir/$namada_file_name/namada"*
    sudo mv "$temp_dir/$namada_file_name/namada"* "/usr/local/bin/"
    rm -rf "$temp_dir"

    echo "Binary installed successfully"
}

# Method 2: Build from source
method2() {
    echo -e "\n\033[1mMethod 2: Building from source\033[0m"
    version=$1

    sudo apt update -y
    sudo apt install -y libssl-dev pkg-config protobuf-compiler \
        clang cmake llvm llvm-dev libudev-dev git

    if [ ! -d "$HOME/namada" ]; then
        git clone https://github.com/anoma/namada.git $HOME/namada
    fi

    cd $HOME/namada
    git fetch --all --tags
    git checkout "$version"
    cargo build --release

    echo "Build complete. Stopping Namada service..."
    sudo systemctl stop $SERVICE_NAME
    sudo cp target/release/namada* /usr/local/bin/

    echo "Source build completed successfully"
}

# Main script
while true; do
    show_version_options
    read -p "Enter your choice: " version_choice

    if (( version_choice == 4 )); then
        echo "Exiting..."
        exit 0
    fi

    version_map=("v1.0.0" "v1.1.1" "v1.1.5")
    selected_version=${version_map[$version_choice-1]}

    if [[ -z $selected_version ]]; then
        echo "Invalid option, please try again"
        continue
    fi

    details=(${versions[$selected_version]})
    block_height_range=${details[0]}
    url=${details[1]}

    echo "Selected version: $selected_version (Block height: $block_height_range)"
    read -p "Are you sure you want to proceed with this version? (yes/no): " confirm
    if [[ $confirm != "yes" ]]; then
        echo "Operation cancelled."
        exit 0
    fi

    if [ "$VERSION_ID" = "22.04" ]; then
        method2 "$selected_version"
    elif dpkg --compare-versions "$VERSION_ID" "gt" "22.04"; then
        method1 "$selected_version" "$url"
    else
        echo "Error: Unsupported Ubuntu version. Only Ubuntu 22.04 and newer are supported."
        exit 1
    fi
    break
done

# Final steps
echo -e "\n\033[1mFinalizing installation...\033[0m"
sudo chown -R $USER:$USER /usr/local/bin/namada*
sudo chmod +x /usr/local/bin/namada*

echo -e "\nRestarting $SERVICE_NAME service..."
if ! sudo systemctl daemon-reload && sudo systemctl restart $SERVICE_NAME; then
    echo "Service restart failed! Check configuration."
    exit 1
fi

echo -e "\nVerifying installation..."
namada --version | grep "$selected_version" && echo "Success!" || echo "Version mismatch detected!"
