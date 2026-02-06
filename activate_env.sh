#!/bin/bash
#
# Activate the Python virtual environment
# This script must be sourced, not executed: source activate_env.sh
#

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if the virtual environment exists
if [ ! -d "$SCRIPT_DIR/.build-env" ]; then
    echo "Error: Virtual environment not found at $SCRIPT_DIR/.build-env"
    echo "Please run bootstrap.sh first to create the environment."
    exit 1
fi

# Activate the virtual environment
source "$SCRIPT_DIR/.build-env/bin/activate"

echo "Virtual environment activated: $VIRTUAL_ENV"
