#!/bin/bash
#
# Builds Radio.app for local use (Apple Silicon + Intel, ad-hoc signed).
#
# Usage:
#   ./build-local.sh            build into ./build/Radio.app
#   ./build-local.sh --install  build and copy to /Applications
#
# Requirements: Xcode. The FFmpeg libraries are prebuilt in
# Radio/Radio/Third-Party-Libs/ffmpeg; rebuild them with
# FFmpeg-build/build-ffmpeg-macos if needed.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
DERIVED_DATA="$ROOT_DIR/build/DerivedData"
OUTPUT_APP="$ROOT_DIR/build/Radio.app"

INFO_PLIST="$ROOT_DIR/Radio/Radio/Radio-Info.plist"
# The project bumps CFBundleVersion on every build; restore it afterwards
# so local builds don't touch the repo.
BUNDLE_VERSION="$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFO_PLIST")"
trap '/usr/libexec/PlistBuddy -c "Set CFBundleVersion $BUNDLE_VERSION" "$INFO_PLIST"' EXIT

xcodebuild \
    -project "$ROOT_DIR/Radio/Radio.xcodeproj" \
    -scheme Radio \
    -configuration Release \
    -derivedDataPath "$DERIVED_DATA" \
    ARCHS="arm64 x86_64" \
    ONLY_ACTIVE_ARCH=NO \
    build

rm -rf "$OUTPUT_APP"
cp -R "$DERIVED_DATA/Build/Products/Release/Radio.app" "$OUTPUT_APP"
echo "Built: $OUTPUT_APP"

if [[ "${1:-}" == "--install" ]]; then
    rm -rf /Applications/Radio.app
    cp -R "$OUTPUT_APP" /Applications/Radio.app
    echo "Installed: /Applications/Radio.app"
fi
