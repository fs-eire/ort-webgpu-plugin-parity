#!/bin/bash
set -e

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "Error: uv is not installed."
    echo "Please install uv from: https://docs.astral.sh/uv/getting-started/installation/"
    exit 1
fi
echo "uv is already installed."

# Change to script directory
cd "$(dirname "$0")"

# Install Python 3.12
uv python install 3.12

# Create virtual environment
uv venv .build-env --python 3.12 --clear

# Activate virtual environment
source .build-env/bin/activate

# Install Python packages
uv pip install requests

exit 0
