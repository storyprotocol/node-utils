#!/bin/bash

# URL of the tar.gz file
TAR_URL="https://story-network-node.s3.amazonaws.com/release/geth_iliad_20240720_214600_linux_amd64.tar.gz"

# Extracted folder name (assumes the tar file creates a folder with the same name)
EXTRACTED_FOLDER="geth_iliad_20240720_214600_linux_amd64"

# Function to download and extract the binaries
download_and_extract() {
    # Check if the tar file already exists
    TAR_FILE=$(basename $TAR_URL)
    if [ ! -f "$TAR_FILE" ]; then
        echo "Downloading binaries..."
        curl -O $TAR_URL
    else
        echo "Tar file already exists, skipping download..."
    fi

    # Remove any existing extracted folder
    if [ -d "$EXTRACTED_FOLDER" ]; then
        echo "Removing existing $EXTRACTED_FOLDER directory..."
        rm -rf "$EXTRACTED_FOLDER"
    fi

    # Extract the tar.gz file
    echo "Extracting binaries..."
    tar -xzf $TAR_FILE
}

# Function to prompt user for Moniker
prompt_for_moniker() {
    read -p "Enter the moniker: " MONIKER
}

# Function to handle geth operations
run_geth() {
    # Ensure ~/geth/ folder doesn't exist
    if [ -d "${HOME}/geth" ]; then
        echo "Removing existing ~/geth/ directory..."
        rm -rf "${HOME}/geth"
    fi

    # Full path to geth.toml
    GETH_TOML_PATH="${BASE_FILE_PATH}geth/config/geth.toml"

    cd "$EXTRACTED_FOLDER/geth/"

    # Replace '/home/ec2-user/' with '${HOME}/' in the provided GETH_TOML_PATH
    sed -i "s|/home/ec2-user/|${HOME}/|g" "$GETH_TOML_PATH"

    # Initialize geth with the specified data directory and genesis file
    ./geth init --datadir="${HOME}/geth/data" "${BASE_FILE_PATH}geth/config/genesis.json"

    # Run geth with the provided configuration file
    ./geth --config "$GETH_TOML_PATH"
}

# Function to handle iliad operations
run_iliad() {

    # Prompt for moniker
    prompt_for_moniker

    # Full path to iliad.toml
    ILIAD_TOML_PATH="${BASE_FILE_PATH}iliad/config/iliad.toml"

    cd "$EXTRACTED_FOLDER/iliad/"

    # Initialize iliad with the testnet network and force option
    ./iliad init --network testnet --home "${BASE_FILE_PATH}iliad/" --force

    # Update the moniker in iliad's configuration file
    sed -i "s|moniker = \".*\"|moniker = \"$MONIKER\"|g" "${BASE_FILE_PATH}iliad/config/config.toml"

    # Replace '/home/ec2-user/' with '${HOME}/' in the provided ILIAD_TOML_PATH
    sed -i "s|/home/ec2-user/|${HOME}/|g" "$ILIAD_TOML_PATH"

    # Run iliad with the specified home directory
    ./iliad run --home "${BASE_FILE_PATH}iliad/"
}

# Function to display a simple menu and get user selection
show_menu() {
    echo "Please choose a client to start:"
    echo "1) geth"
    echo "2) iliad"
    read -p "Enter your choice [1 or 2]: " choice
    case $choice in
        1)
            CLIENT="geth"
            ;;
        2)
            CLIENT="iliad"
            ;;
        *)
            echo "Invalid choice, please run the script again and choose 1 or 2."
            exit 1
            ;;
    esac
}

# Show the menu and get user selection
show_menu

# Download and extract binaries
download_and_extract

# Set the base file path to the extracted folder
BASE_FILE_PATH="$(pwd)/$EXTRACTED_FOLDER/"

# Run the chosen client
if [ "$CLIENT" == "geth" ]; then
    run_geth
elif [ "$CLIENT" == "iliad" ]; then
    run_iliad
else
    echo "Invalid client choice. Please choose 'geth' or 'iliad'."
fi
