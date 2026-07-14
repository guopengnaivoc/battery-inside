#!/bin/zsh
set -euo pipefail
ROOT="${0:A:h}"
OUT="$ROOT/build"
APP="$OUT/电池内显.app"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"
cp "$ROOT/Info.plist" "$APP/Contents/Info.plist"
export CLANG_MODULE_CACHE_PATH="$ROOT/.module-cache"
clang -fobjc-arc "$ROOT/IconMaker.m" -o "$OUT/IconMaker" -framework AppKit
mkdir -p "$OUT/AppIcon.iconset"
"$OUT/IconMaker" "$OUT/AppIcon.iconset/icon_16x16.png" 16
"$OUT/IconMaker" "$OUT/AppIcon.iconset/icon_16x16@2x.png" 32
"$OUT/IconMaker" "$OUT/AppIcon.iconset/icon_32x32.png" 32
"$OUT/IconMaker" "$OUT/AppIcon.iconset/icon_32x32@2x.png" 64
"$OUT/IconMaker" "$OUT/AppIcon.iconset/icon_128x128.png" 128
"$OUT/IconMaker" "$OUT/AppIcon.iconset/icon_128x128@2x.png" 256
"$OUT/IconMaker" "$OUT/AppIcon.iconset/icon_256x256.png" 256
"$OUT/IconMaker" "$OUT/AppIcon.iconset/icon_256x256@2x.png" 512
"$OUT/IconMaker" "$OUT/AppIcon.iconset/icon_512x512.png" 512
"$OUT/IconMaker" "$OUT/AppIcon.iconset/icon_512x512@2x.png" 1024
cp "$OUT/AppIcon.iconset/icon_512x512@2x.png" "$OUT/AppIcon-1024.png"
clang -fobjc-arc "$ROOT/IcnsMaker.m" -o "$OUT/IcnsMaker" -framework Foundation
"$OUT/IcnsMaker" "$OUT/AppIcon.iconset" "$APP/Contents/Resources/BatteryInsideRoundedIcon.icns"
xcrun --sdk macosx clang -fobjc-arc -arch arm64 -arch x86_64 -mmacosx-version-min=13.0 \
  "$ROOT/BatteryInside.m" -o "$APP/Contents/MacOS/BatteryInside" \
  -framework AppKit -framework IOKit -framework ServiceManagement -framework UserNotifications
codesign --force --deep --sign - "$APP"
echo "$APP"
