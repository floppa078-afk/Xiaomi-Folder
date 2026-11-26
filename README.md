# Xiaomi-Folder

Theos tweak for iOS 16.7.15 with Dopamine rootless jailbreak.

## Modes

- **Default**: use the native iOS folder appearance.
- **Large**: enlarged folder with a 2×2 app preview layout.
- **XXL**: larger folder preview than the native layout.

## Build

Requires Theos and an iOS 16 SDK:

```sh
make clean
make package
make do
```

The resulting rootless `.deb` package is created in the `packages/` directory.

## Install

Install the generated `.deb` package through Sileo/Zebra and respring SpringBoard.
