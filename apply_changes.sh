#!/bin/bash -e

# This script applies custom packages and patches to a target OpenWrt SDK.
PROJECT_FILES_DIR="project_files"

if [ -z "$1" ]; then
    echo "ERROR: You must provide a path to the target SDK."
    echo "Usage: $0 /path/to/sdk"
    exit 1
fi

TARGET_SDK_PATH=$(realpath "$1")

if [ ! -d "$TARGET_SDK_PATH" ]; then
    echo "ERROR: SDK directory not found at '$TARGET_SDK_PATH'"
    exit 1
fi

(
    cd "$TARGET_SDK_PATH"
    echo "Updating feeds..."
    ./scripts/feeds update -a
    echo "Installing required package recipes (wget, libpcre)..."
    ./scripts/feeds install wget libpcre
    echo "Feeds are ready."
)

echo "Applying custom patches ..."

WGET_RECIPE_PATH="$TARGET_SDK_PATH/feeds/packages/net/wget"

if [ -d "$WGET_RECIPE_PATH" ]; then
    (
        cd "$WGET_RECIPE_PATH"
        echo "Applying patches to wget recipe..."
        git reset --hard HEAD > /dev/null
        git clean -fd > /dev/null

        git apply --verbose "/work/$PROJECT_FILES_DIR/common/patches/101-wget-add-banner-config.patch"
        git apply --verbose "/work/$PROJECT_FILES_DIR/common/patches/103-enable-pcre-support.patch"
        echo "Patches for wget applied."
    )
else
    echo "WARNING: wget recipe not found at '$WGET_RECIPE_PATH'. Skipping patches."
fi

WGET_PATCH_DIR="$WGET_RECIPE_PATH=/patches"

if [ -d "$WGET_PATCH_DIR" ]; then
    echo "Copying source code patches for wget..."
    cp "/work/$PROJECT_FILES_DIR/common/patches/102-wget-add-banner-to-output.patch" "$WGET_PATCH_DIR/"
    echo "Source code patches copied."
fi

echo "Applying build configuration..."

touch "$TARGET_SDK_PATH/.config"

CONFIG_FRAGMENT="/work/$PROJECT_FILES_DIR/common/build.config"

if [ -f "$CONFIG_FRAGMENT" ]; then
    echo "Merging custom configuration..."
    cat "$CONFIG_FRAGMENT" >> "$TARGET_SDK_PATH/.config"

    (
        cd "$TARGET_SDK_PATH"
        make defconfig > /dev/null
    )
else
    echo "No custom 'build.config' found. Skipping auto-configuration."
fi

echo ""
echo "--- SDK is fully prepared and ready for build. ---"
