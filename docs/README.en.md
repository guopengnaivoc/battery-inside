# BatteryInside

[中文](../README.md) · [English](README.en.md) · [日本語](README.ja.md) · [Français](README.fr.md) · [Italiano](README.it.md)

![BatteryInside menu bar preview](images/hero.svg)

BatteryInside is a lightweight, read-only macOS menu bar indicator that puts the percentage, remaining level, and power state inside one compact battery icon.

Author: Guo Peng (郭鹏)

## Install in three steps

![Download the DMG, drag the app to Applications, and open it](images/install.svg)

1. Download the latest `BatteryInside-version.dmg` from [Releases](/guopengnaivoc/battery-inside/releases/latest).
2. Open the DMG and drag BatteryInside to Applications.
3. Open BatteryInside from Finder → Applications. The indicator appears in the menu bar.

### If macOS blocks the first launch

The current public build is ad-hoc signed and has not been notarized with an Apple Developer ID. If macOS says the developer cannot be verified or Apple cannot check the app for malicious software:

1. Try to open the app once, then dismiss the warning.
2. Open System Settings → Privacy & Security.
3. Find the BatteryInside message in Security and click Open Anyway.

Only do this for a package downloaded from this project's GitHub Release whose SHA-256 checksum matches. Do not disable Gatekeeper globally.

## Read the status at a glance

![Battery colors and power states](images/status.svg)

- 30% or more: white fill bar
- 10%–29%: orange fill bar
- 9% or less: red fill bar
- Charging: lightning bolt
- Connected to power but not charging: plug
- Battery data unavailable: `--`

The fill width follows the level continuously: `20.8 pt × percentage`. Each 1% is about `0.208 pt`, rendered with Core Graphics subpixels, so the icon does not need 100 integer pixels. The number gives the exact value while the bar gives a visual estimate. The outline and cap follow macOS `labelColor`; text and power symbols are black over the fill and use the system color over the empty area for contrast in both appearances.

Power state is determined only from the explicit macOS values `Is Charging`, `Power Source State`, and `Is Charged`.

## Settings and replacing the system icon

![Open settings and optionally hide Apple's battery icon](images/settings.svg)

The menu bar indicator is read-only and does not react to clicks. To change settings, open BatteryInside again from Finder → Applications. You can enable launch at login, enable low-battery alerts at 20% and 10%, quit, or safely uninstall the app.

To keep only BatteryInside in the menu bar:

- Newer macOS: System Settings → Menu Bar → Menu Bar Controls → Battery → turn off menu bar display
- macOS 13–15: System Settings → Control Center → Battery → turn off Show in Menu Bar

This does not remove or modify macOS battery features. Turn the option on again at any time to restore Apple's icon.

## Requirements and privacy

- macOS 13 or later
- Apple silicon and Intel Macs
- No network access, analytics, or data collection

## Build from source

Xcode Command Line Tools are required. There are no third-party dependencies.

```zsh
cd work/BatteryInside
./build.sh
./package_dmg.sh
```

Build products are written to the repository's `outputs/` directory.

## Copyright

Copyright © 2026 郭鹏. No open-source license is currently included; public visibility does not grant permission to copy, modify, or redistribute the code.
