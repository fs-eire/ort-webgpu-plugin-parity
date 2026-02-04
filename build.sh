#!/bin/sh
#
# Main build script for ORT WebGPU Plugin EP Parity Test
#

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$SCRIPT_DIR"

echo "=== Syncing git submodules ==="
git submodule sync --recursive
git submodule update --init --recursive

echo "=== Building base version ==="
"$SCRIPT_DIR/build_base.sh"
if [ $? -ne 0 ]; then
    echo "Build base failed with error $?"
    exit 1
fi

echo "=== Building plugin version ==="
"$SCRIPT_DIR/build_plugin.sh"
if [ $? -ne 0 ]; then
    echo "Build plugin failed with error $?"
    exit 1
fi

echo "=== Build completed successfully ==="
