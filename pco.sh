#!/bin/bash
set -e

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
export DYLD_INSERT_LIBRARIES="$SCRIPT_DIR/hook.dylib"
exec "$SCRIPT_DIR/CrossOver.o" "$@"
