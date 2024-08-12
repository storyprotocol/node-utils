# URL of the tar.gz file
$TAR_URL = "https://story-network-node.s3.amazonaws.com/release/geth_iliad_20240720_214600_windows_amd64.tar.gz"

# Extracted folder name (assumes the tar file creates a folder with the same name)
$EXTRACTED_FOLDER = "geth_iliad_20240720_214600_windows_amd64"

# Function to download and extract the binaries
function Download-AndExtract {
    $TAR_FILE = [System.IO.Path]::GetFileName($TAR_URL)
    if (-Not (Test-Path -Path $TAR_FILE)) {
        Write-Host "Downloading binaries..."
        Invoke-WebRequest -Uri $TAR_URL -OutFile $TAR_FILE
    } else {
        Write-Host "Tar file already exists, skipping download..."
    }

    # Remove any existing extracted folder
    if (Test-Path -Path $EXTRACTED_FOLDER) {
        Write-Host "Removing existing $EXTRACTED_FOLDER directory..."
        Remove-Item -Recurse -Force $EXTRACTED_FOLDER
    }

    # Extract the tar.gz file
    Write-Host "Extracting binaries..."
    tar -xzf $TAR_FILE
}

# Function to prompt user for Moniker
function Prompt-ForMoniker {
    $global:MONIKER = Read-Host -Prompt "Enter the moniker"
}

# Function to handle geth operations
function Run-Geth {
    # Ensure ~/geth/ folder doesn't exist
    $gethDataDir = "$env:USERPROFILE\geth\data"
    if (Test-Path -Path $gethDataDir) {
        Write-Host "Removing existing ~/geth/ directory..."
        Remove-Item -Recurse -Force "$env:USERPROFILE\geth"
    }

    # Full path to geth.toml
    $GETH_TOML_PATH = "$BASE_FILE_PATH\geth\config\geth.toml"

    Set-Location "$EXTRACTED_FOLDER\geth"

    # Replace '/home/ec2-user/' with '%USERPROFILE%/' in the provided GETH_TOML_PATH
    (Get-Content $GETH_TOML_PATH) -replace '/home/ec2-user/', "$env:USERPROFILE\" | Set-Content $GETH_TOML_PATH

    # Initialize geth with the specified data directory and genesis file
    .\geth.exe init --datadir="$gethDataDir" "$BASE_FILE_PATH\geth\config\genesis.json"

    # Run geth with the provided configuration file
    .\geth.exe --config $GETH_TOML_PATH
}

# Function to handle iliad operations
function Run-Iliad {
    # Prompt for moniker
    Prompt-ForMoniker

    # Full path to iliad.toml
    $ILIAD_TOML_PATH = "$BASE_FILE_PATH\iliad\config\iliad.toml"

    Set-Location "$EXTRACTED_FOLDER\iliad"

    # Initialize iliad with the testnet network and force option
    .\iliad.exe init --network testnet --home "$BASE_FILE_PATH\iliad" --force

    # Update the moniker in iliad's configuration file
    (Get-Content "$BASE_FILE_PATH\iliad\config\config.toml") -replace 'moniker = ".*"', "moniker = `"$MONIKER`"" | Set-Content "$BASE_FILE_PATH\iliad\config\config.toml"

    # Replace '/home/ec2-user/' with '%USERPROFILE%/' in the provided ILIAD_TOML_PATH
    (Get-Content $ILIAD_TOML_PATH) -replace '/home/ec2-user/', "$env:USERPROFILE\" | Set-Content $ILIAD_TOML_PATH

    # Run iliad with the specified home directory
    .\iliad.exe run --home "$BASE_FILE_PATH\iliad"
}

# Function to display a simple menu and get user selection
function Show-Menu {
    Write-Host "Please choose a client to start:"
    Write-Host "1) geth"
    Write-Host "2) iliad"
    $choice = Read-Host -Prompt "Enter your choice [1 or 2]"
    switch ($choice) {
        1 { $global:CLIENT = "geth" }
        2 { $global:CLIENT = "iliad" }
        default {
            Write-Host "Invalid choice, please run the script again and choose 1 or 2."
            exit
        }
    }
}

# Show the menu and get user selection
Show-Menu

# Download and extract binaries
Download-AndExtract

# Set the base file path to the extracted folder
$BASE_FILE_PATH = (Get-Location).Path + "\$EXTRACTED_FOLDER"

# Run the chosen client
if ($CLIENT -eq "geth") {
    Run-Geth
} elseif ($CLIENT -eq "iliad") {
    Run-Iliad
} else {
    Write-Host "Invalid client choice. Please choose 'geth' or 'iliad'."
}
