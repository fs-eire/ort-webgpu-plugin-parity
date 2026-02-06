#!/bin/sh
#
# Clean up all generated files from build scripts
#

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Cleaning up build artifacts ==="

# Build output directories
rm -rf "$SCRIPT_DIR/ort_base"
rm -rf "$SCRIPT_DIR/ort_generic"
rm -rf "$SCRIPT_DIR/ort_shared"
rm -rf "$SCRIPT_DIR/ort_genai_base"
rm -rf "$SCRIPT_DIR/ort_genai_plugin"

# ORT home directories (headers/libs for genai builds)
rm -rf "$SCRIPT_DIR/ort_home_base"
rm -rf "$SCRIPT_DIR/ort_home_plugin"

# Final artifact directories
rm -rf "$SCRIPT_DIR/parity_base"
rm -rf "$SCRIPT_DIR/parity_plugin"

echo "=== Clean completed ==="
