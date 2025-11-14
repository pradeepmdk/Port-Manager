#!/bin/bash

# Port Manager DMG Creation Script
set -e

APP_NAME="PortManager"
APP_PATH="/Users/pradeepkumar/Library/Developer/Xcode/DerivedData/PortManager-fdwlzwgeuwdfjnckonirisfvjtyd/Build/Products/Release/${APP_NAME}.app"
DMG_NAME="PortManager-v1.0.0"
OUTPUT_DIR="/Users/pradeepkumar/Documents/Projects/personal/erolabs/Port-Manager-Mac"
TEMP_DMG="${OUTPUT_DIR}/temp-${DMG_NAME}.dmg"
FINAL_DMG="${OUTPUT_DIR}/${DMG_NAME}.dmg"
VOLUME_NAME="Port Manager"
DMG_SIZE="100m"

echo "Creating DMG for Port Manager..."

# Remove old DMG files if they exist
if [ -f "${TEMP_DMG}" ]; then
    rm "${TEMP_DMG}"
fi

if [ -f "${FINAL_DMG}" ]; then
    rm "${FINAL_DMG}"
fi

# Create a temporary DMG
hdiutil create -size ${DMG_SIZE} -fs HFS+ -volname "${VOLUME_NAME}" "${TEMP_DMG}"

# Mount the DMG
hdiutil attach "${TEMP_DMG}" -mountpoint /Volumes/"${VOLUME_NAME}"

# Copy the app to the DMG
cp -R "${APP_PATH}" /Volumes/"${VOLUME_NAME}"/

# Create Applications symlink
ln -s /Applications /Volumes/"${VOLUME_NAME}"/Applications

# Create a README file
cat > /Volumes/"${VOLUME_NAME}"/README.txt << 'EOF'
Port Manager - Mac Menu Bar Utility
====================================

Installation:
1. Drag PortManager.app to the Applications folder
2. Open PortManager from Applications
3. The app will appear in your menu bar

Features:
- Monitor active network ports
- View process details for each port
- Kill processes directly from the menu bar
- Quick refresh functionality

For issues or questions, visit:
https://github.com/pradeepkumar35/Port-Manager-Mac
EOF

# Unmount the DMG
hdiutil detach /Volumes/"${VOLUME_NAME}"

# Convert to compressed, read-only DMG
hdiutil convert "${TEMP_DMG}" -format UDZO -o "${FINAL_DMG}"

# Remove temporary DMG
rm "${TEMP_DMG}"

echo "DMG created successfully: ${FINAL_DMG}"
ls -lh "${FINAL_DMG}"
