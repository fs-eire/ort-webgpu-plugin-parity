#!/bin/sh
#
# Build base (monolithic) version of onnxruntime with WebGPU built-in
#

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Activate Python virtual environment
source "$SCRIPT_DIR/activate_env.sh"
if [ $? -ne 0 ]; then
    echo "Failed to activate virtual environment"
    exit 1
fi

# Detect OS for shared library extension
case "$(uname -s)" in
    Darwin*)
        SHARED_LIB_EXT="dylib"
        ;;
    Linux*)
        SHARED_LIB_EXT="so"
        ;;
    *)
        echo "Unsupported OS: $(uname -s)"
        exit 1
        ;;
esac

echo "=== STEP 1: Build onnxruntime (base) ==="
cd "$SCRIPT_DIR/external/onnxruntime"
./build.sh \
    --parallel \
    --config RelWithDebInfo \
    --use_webgpu \
    --build_dir "$SCRIPT_DIR/ort_base" \
    --skip_tests \
    --build_shared_lib \
    --target onnxruntime \
    --disable_rtti \
    --use_binskim_compliant_compile_flags \
    --enable_lto

if [ $? -ne 0 ]; then
    echo "Build failed with error $?"
    exit 1
fi

echo "=== STEP 2: Prepare ort_home_base ==="
mkdir -p "$SCRIPT_DIR/ort_home_base/include"
mkdir -p "$SCRIPT_DIR/ort_home_base/lib"

# Copy headers
cp -f "$SCRIPT_DIR/external/onnxruntime/include/onnxruntime/core/session/"*.h "$SCRIPT_DIR/ort_home_base/include/"

# Copy libraries
cp -f "$SCRIPT_DIR/ort_base/RelWithDebInfo/libonnxruntime."* "$SCRIPT_DIR/ort_home_base/lib/" 2>/dev/null || \
cp -f "$SCRIPT_DIR/ort_base/RelWithDebInfo/onnxruntime."* "$SCRIPT_DIR/ort_home_base/lib/" 2>/dev/null || true

echo "=== STEP 3: Build onnxruntime-genai (base) ==="
cd "$SCRIPT_DIR/external/onnxruntime-genai"
./build.sh \
    --parallel \
    --config RelWithDebInfo \
    --build_dir "$SCRIPT_DIR/ort_genai_base" \
    --skip_tests \
    --skip_wheel \
    --skip_examples \
    --ort_home "$SCRIPT_DIR/ort_home_base"

if [ $? -ne 0 ]; then
    echo "Build failed with error $?"
    exit 1
fi

echo "=== STEP 4: Gather artifacts (base) ==="
mkdir -p "$SCRIPT_DIR/parity_base"

# Copy onnxruntime library
if [ -f "$SCRIPT_DIR/ort_base/RelWithDebInfo/libonnxruntime.$SHARED_LIB_EXT" ]; then
    cp -f "$SCRIPT_DIR/ort_base/RelWithDebInfo/libonnxruntime.$SHARED_LIB_EXT" "$SCRIPT_DIR/parity_base/"
fi

# Copy model_benchmark executable
if [ -f "$SCRIPT_DIR/ort_genai_base/RelWithDebInfo/benchmark/c/model_benchmark" ]; then
    cp -f "$SCRIPT_DIR/ort_genai_base/RelWithDebInfo/benchmark/c/model_benchmark" "$SCRIPT_DIR/parity_base/"
fi

# Copy onnxruntime_genai library
if [ -f "$SCRIPT_DIR/ort_genai_base/RelWithDebInfo/libonnxruntime-genai.$SHARED_LIB_EXT" ]; then
    cp -f "$SCRIPT_DIR/ort_genai_base/RelWithDebInfo/libonnxruntime-genai.$SHARED_LIB_EXT" "$SCRIPT_DIR/parity_base/"
fi

echo "=== Base build completed ==="
echo "Artifacts are in: $SCRIPT_DIR/parity_base/"
ls -la "$SCRIPT_DIR/parity_base/"
