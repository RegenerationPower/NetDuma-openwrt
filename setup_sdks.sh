#!/bin/bash -e

MIPS_SDK_URL="https://downloads.openwrt.org/releases/22.03.0/targets/ramips/mt7621/openwrt-sdk-22.03.0-ramips-mt7621_gcc-11.2.0_musl.Linux-x86_64.tar.xz"
X86_SDK_URL="https://downloads.openwrt.org/releases/22.03.0/targets/x86/generic/openwrt-sdk-22.03.0-x86-generic_gcc-11.2.0_musl.Linux-x86_64.tar.xz"

MIPS_SDK_DIR="openwrt-sdk-22.03.0-ramips-mt7621_gcc-11.2.0_musl.Linux-x86_64"
X86_SDK_DIR="openwrt-sdk-22.03.0-x86-generic_gcc-11.2.0_musl.Linux-x86_64"

# Handle download and extraction
download_and_extract() {
    local sdk_url=$1
    local sdk_dir=$2
    local sdk_archive=$(basename "$sdk_url")

    # Check if the directory already exists
    if [ -d "$sdk_dir" ]; then
        echo "'$sdk_dir' already exists. Skipping"
        return
    fi

    echo "'$sdk_dir' not found. Starting download..."
    wget -q --show-progress -O "$sdk_archive" "$sdk_url"

    echo "Extracting '$sdk_archive'..."
    tar -xf "$sdk_archive"

    echo "Cleaning up '$sdk_archive'..."
    rm "$sdk_archive"

    echo "Successfully set up '$sdk_dir'"
}

download_and_extract "$MIPS_SDK_URL" "$MIPS_SDK_DIR"
download_and_extract "$X86_SDK_URL" "$X86_SDK_DIR"
