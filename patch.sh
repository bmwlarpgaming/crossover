#!/bin/bash
# forked from totallynotinteresting/crossover

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HOOK_SOURCE="$SCRIPT_DIR/hook.m"
HOOK_PREBUILT="$SCRIPT_DIR/hook.dylib"
LAUNCHER_SOURCE="$SCRIPT_DIR/pco.sh"

find_crossover_app() {
    if [ -n "${CROSSOVER_APP_PATH:-}" ]; then
        printf '%s\n' "$CROSSOVER_APP_PATH"
        return
    fi

    local candidate
    for candidate in "/Applications/CrossOver.app" "$HOME/Applications/CrossOver.app"; do
        if [ -d "$candidate" ]; then
            printf '%s\n' "$candidate"
            return
        fi
    done

    if command -v mdfind >/dev/null 2>&1; then
        mdfind "kMDItemFSName == 'CrossOver.app'" \
            -onlyin /Applications \
            -onlyin "$HOME/Applications" 2>/dev/null | sed -n '1p' || true
    fi
}

CROSSOVER_APP_PATH="$(find_crossover_app)"
if [ -z "$CROSSOVER_APP_PATH" ]; then
    echo "CrossOver.app was not found in /Applications or $HOME/Applications."
    echo "Set CROSSOVER_APP_PATH to its full path if it is installed elsewhere."
    exit 1
fi

CROSSOVER_MACOS_PATH="$CROSSOVER_APP_PATH/Contents/MacOS"
if [ ! -d "$CROSSOVER_MACOS_PATH" ]; then
    echo "CrossOver.app does not have the expected MacOS directory:"
    echo "  $CROSSOVER_MACOS_PATH"
    exit 1
fi

if [ ! -f "$LAUNCHER_SOURCE" ]; then
    echo "Missing local launcher: $LAUNCHER_SOURCE"
    echo "Run patch.sh from a complete local copy of this repository."
    exit 1
fi

if ! command -v codesign >/dev/null 2>&1; then
    echo "codesign is required but was not found."
    exit 1
fi

STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/crossover-patch.XXXXXX")"
cleanup() {
    rm -rf "$STAGING_DIR"
}
trap cleanup EXIT

STAGED_HOOK="$STAGING_DIR/hook.dylib"
if [ -f "$HOOK_SOURCE" ] && command -v clang >/dev/null 2>&1; then
    echo "Building hook.dylib from the local hook.m..."
    if ! clang -dynamiclib -framework Foundation -framework AppKit \
        -o "$STAGED_HOOK" "$HOOK_SOURCE"; then
        rm -f "$STAGED_HOOK"
    fi
fi

if [ ! -f "$STAGED_HOOK" ]; then
    if [ -f "$HOOK_PREBUILT" ]; then
        echo "Using the local prebuilt hook.dylib..."
        cp "$HOOK_PREBUILT" "$STAGED_HOOK"
    else
        echo "Unable to build hook.m and no local hook.dylib is available."
        echo "Install the Xcode Command Line Tools or place hook.dylib beside patch.sh."
        exit 1
    fi
fi

echo "Signing hook.dylib..."
codesign -f -s - "$STAGED_HOOK"

ORIGINAL="$CROSSOVER_MACOS_PATH/CrossOver"
BACKUP="$CROSSOVER_MACOS_PATH/CrossOver.o"
TARGET_HOOK="$CROSSOVER_MACOS_PATH/hook.dylib"

if [ ! -f "$BACKUP" ]; then
    if [ ! -f "$ORIGINAL" ]; then
        echo "CrossOver executable was not found at $ORIGINAL"
        exit 1
    fi

    echo "Ad-hoc signing the original CrossOver executable..."
    codesign -f -s - "$ORIGINAL"
fi

echo "Installing the local hook..."
install -m 755 "$STAGED_HOOK" "$TARGET_HOOK"

if [ ! -f "$BACKUP" ]; then
    echo "Backing up the original executable as CrossOver.o..."
    mv "$ORIGINAL" "$BACKUP"
else
    echo "Existing CrossOver.o backup found; keeping it unchanged."
fi

echo "Installing the local launcher..."
if ! install -m 755 "$LAUNCHER_SOURCE" "$ORIGINAL"; then
    if [ -f "$BACKUP" ] && [ ! -f "$ORIGINAL" ]; then
        mv "$BACKUP" "$ORIGINAL"
    fi
    exit 1
fi

echo "Patch installed from local files."
