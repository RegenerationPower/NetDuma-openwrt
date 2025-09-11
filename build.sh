#!/bin/bash -e

# This is the main build script.
# It prepares the SDKs, builds the packages, and places artifacts in the 'output' directory.

MIPS_SDK_DIR=$(find . -maxdepth 1 -type d -name "openwrt-sdk-*-ramips-*")
X86_SDK_DIR=$(find . -maxdepth 1 -type d -name "openwrt-sdk-*-x86-*")
OUTPUT_DIR="output"

if [ -z "$MIPS_SDK_DIR" ] || [ -z "$X86_SDK_DIR" ]; then
    echo "ERROR: SDK directories not found. Please run ./setup-sdks.sh first."
    exit 1
fi

echo "Starting build..."
mkdir -p "$OUTPUT_DIR"

build_target() {
    local sdk_dir=$1
    local target_name=$2

    echo "--------------------------------------------------"
    echo "--- Building for target: $target_name ---"
    echo "--------------------------------------------------"

    (cd "$sdk_dir")
    ./apply_changes.sh "$sdk_dir"

    echo "Compiling wget for $target_name..."
    (
        cd "$sdk_dir"
        make package/wget/compile V=s # It can be used with -j $(($(nproc)+1))
    )

    local ipk_file=$(find "$sdk_dir/bin/packages" -name "wget_*.ipk")

    if [ -n "$ipk_file" ]; then
        cp "$ipk_file" "$OUTPUT_DIR/"
        echo "Artifact copied to $OUTPUT_DIR/$(basename $ipk_file)"
    else
        echo "ERROR: .ipk file for $target_name not found!"
        exit 1
    fi
}

build_target "$MIPS_SDK_DIR" "MIPS (ramips)"
build_target "$X86_SDK_DIR" "x86 (generic)"

echo "Build completed. Artifacts are in '$OUTPUT_DIR'."
