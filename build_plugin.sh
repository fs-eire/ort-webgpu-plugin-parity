#!/bin/sh
#
# Build plugin version of onnxruntime with WebGPU as a shared library plugin
#

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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

echo "=== STEP 1a: Build onnxruntime with generic interface ==="
cd "$SCRIPT_DIR/external/onnxruntime"
./build.sh \
    --parallel \
    --config RelWithDebInfo \
    --use_webgpu \
    --build_dir "$SCRIPT_DIR/ort_generic" \
    --enable_generic_interface \
    --skip_tests \
    --build_shared_lib \
    --target onnxruntime \
    --disable_rtti \
    --enable_lto

if [ $? -ne 0 ]; then
    echo "Build failed with error $?"
    exit 1
fi

echo "=== STEP 1b: Build onnxruntime WebGPU provider shared library ==="
./build.sh \
    --parallel \
    --config RelWithDebInfo \
    --use_webgpu shared_lib \
    --build_dir "$SCRIPT_DIR/ort_shared" \
    --skip_tests \
    --target onnxruntime_providers_webgpu \
    --disable_rtti \
    --enable_lto

if [ $? -ne 0 ]; then
    echo "Build failed with error $?"
    exit 1
fi

echo "=== STEP 2: Prepare ort_home_plugin ==="
mkdir -p "$SCRIPT_DIR/ort_home_plugin/include"
mkdir -p "$SCRIPT_DIR/ort_home_plugin/lib"

# Copy headers
cp -f "$SCRIPT_DIR/external/onnxruntime/include/onnxruntime/core/session/"*.h "$SCRIPT_DIR/ort_home_plugin/include/"

# Copy libraries
cp -f "$SCRIPT_DIR/ort_generic/RelWithDebInfo/libonnxruntime."* "$SCRIPT_DIR/ort_home_plugin/lib/" 2>/dev/null || \
cp -f "$SCRIPT_DIR/ort_generic/RelWithDebInfo/onnxruntime."* "$SCRIPT_DIR/ort_home_plugin/lib/" 2>/dev/null || true

echo "=== STEP 3: Build onnxruntime-genai (plugin) ==="
cd "$SCRIPT_DIR/external/onnxruntime-genai"
./build.sh \
    --parallel \
    --config RelWithDebInfo \
    --build_dir "$SCRIPT_DIR/ort_genai_plugin" \
    --skip_tests \
    --skip_wheel \
    --skip_examples \
    --ort_home "$SCRIPT_DIR/ort_home_plugin" \
    --cmake_extra_defines "ORT_GENAI_USE_WEBGPU_PLUGIN=ON"

if [ $? -ne 0 ]; then
    echo "Build failed with error $?"
    exit 1
fi

echo "=== STEP 4: Gather artifacts (plugin) ==="
mkdir -p "$SCRIPT_DIR/parity_plugin"

# Copy onnxruntime library
if [ -f "$SCRIPT_DIR/ort_generic/RelWithDebInfo/libonnxruntime.$SHARED_LIB_EXT" ]; then
    cp -f "$SCRIPT_DIR/ort_generic/RelWithDebInfo/libonnxruntime.$SHARED_LIB_EXT" "$SCRIPT_DIR/parity_plugin/"
fi

# Copy onnxruntime_providers_webgpu library
if [ -f "$SCRIPT_DIR/ort_shared/RelWithDebInfo/libonnxruntime_providers_webgpu.$SHARED_LIB_EXT" ]; then
    cp -f "$SCRIPT_DIR/ort_shared/RelWithDebInfo/libonnxruntime_providers_webgpu.$SHARED_LIB_EXT" "$SCRIPT_DIR/parity_plugin/"
fi

# Copy model_benchmark executable
if [ -f "$SCRIPT_DIR/ort_genai_plugin/RelWithDebInfo/benchmark/c/model_benchmark" ]; then
    cp -f "$SCRIPT_DIR/ort_genai_plugin/RelWithDebInfo/benchmark/c/model_benchmark" "$SCRIPT_DIR/parity_plugin/"
fi

# Copy onnxruntime_genai library
if [ -f "$SCRIPT_DIR/ort_genai_plugin/RelWithDebInfo/libonnxruntime-genai.$SHARED_LIB_EXT" ]; then
    cp -f "$SCRIPT_DIR/ort_genai_plugin/RelWithDebInfo/libonnxruntime-genai.$SHARED_LIB_EXT" "$SCRIPT_DIR/parity_plugin/"
fi

echo "=== Plugin build completed ==="
echo "Artifacts are in: $SCRIPT_DIR/parity_plugin/"
ls -la "$SCRIPT_DIR/parity_plugin/"
