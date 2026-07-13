#!/bin/zsh
set -euo pipefail
ROOT="${0:A:h}"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT/Info.plist")"
WORK="$ROOT/dmg-build"
STAGE="$ROOT/dmg-root-v${VERSION}"
OUTPUT="$ROOT/../../outputs/电池内显-${VERSION}.dmg"
APP="$ROOT/build/电池内显.app"
mkdir -p "$WORK/iconset" "$STAGE" "${OUTPUT:h}"
clang -fobjc-arc "$ROOT/DmgIconMaker.m" -o "$WORK/DmgIconMaker" -framework AppKit
clang -fobjc-arc "$ROOT/IcnsMaker.m" -o "$WORK/IcnsMaker" -framework Foundation
"$WORK/DmgIconMaker" "$WORK/iconset/icon_16x16.png" 16
"$WORK/DmgIconMaker" "$WORK/iconset/icon_16x16@2x.png" 32
"$WORK/DmgIconMaker" "$WORK/iconset/icon_32x32.png" 32
"$WORK/DmgIconMaker" "$WORK/iconset/icon_32x32@2x.png" 64
"$WORK/DmgIconMaker" "$WORK/iconset/icon_128x128.png" 128
"$WORK/DmgIconMaker" "$WORK/iconset/icon_128x128@2x.png" 256
"$WORK/DmgIconMaker" "$WORK/iconset/icon_256x256.png" 256
"$WORK/DmgIconMaker" "$WORK/iconset/icon_256x256@2x.png" 512
"$WORK/DmgIconMaker" "$WORK/iconset/icon_512x512.png" 512
"$WORK/DmgIconMaker" "$WORK/iconset/icon_512x512@2x.png" 1024
"$WORK/IcnsMaker" "$WORK/iconset" "$STAGE/.VolumeIcon.icns"
ditto "$APP" "$STAGE/电池内显.app"
ditto "$ROOT/安装与使用说明.txt" "$STAGE/安装与使用说明.txt"
[[ -e "$STAGE/应用程序" ]] || ln -s /Applications "$STAGE/应用程序"
SetFile -a C "$STAGE"
hdiutil create -volname "电池内显 ${VERSION}" -srcfolder "$STAGE" -ov -format UDZO "$OUTPUT"
cp "$WORK/iconset/icon_512x512@2x.png" "$WORK/dmg-file-icon.png"
sips -i "$WORK/dmg-file-icon.png" >/dev/null
DeRez -only icns "$WORK/dmg-file-icon.png" > "$WORK/AppIcon.rsrc"
Rez -append "$WORK/AppIcon.rsrc" -o "$OUTPUT"
SetFile -a C "$OUTPUT"
hdiutil verify "$OUTPUT"
