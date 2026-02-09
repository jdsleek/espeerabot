#!/bin/bash
# Safe Mac disk cleanup - run with: bash cleanup-mac-space.sh
# For Cursor-related cleanup: QUIT CURSOR FIRST, then run this.

set -e
echo "=== Mac disk cleanup ==="

# 1. NPM cache (~7GB)
if command -v npm &>/dev/null; then
  echo "Cleaning npm cache..."
  npm cache clean --force
  echo "  Done."
fi

# 2. Homebrew cache (~779MB)
if command -v brew &>/dev/null; then
  echo "Cleaning Homebrew cache..."
  brew cleanup -s 2>/dev/null || true
  echo "  Done."
fi

# 3. Pip cache (~148MB)
if command -v pip3 &>/dev/null; then
  echo "Cleaning pip cache..."
  pip3 cache purge 2>/dev/null || true
  echo "  Done."
fi

# 4. Google Chrome/Chromium caches (~3.2GB)
GOOGLE_CACHE="$HOME/Library/Caches/Google"
if [ -d "$GOOGLE_CACHE" ]; then
  echo "Removing Google caches..."
  rm -rf "$GOOGLE_CACHE"/*
  echo "  Done."
fi

# 5. Cursor state BACKUP only (12GB) - safe to delete; Cursor will not use it
#    Only run if Cursor is NOT running to be safe
CURSOR_BACKUP="$HOME/Library/Application Support/Cursor/User/globalStorage/state.vscdb.backup"
if [ -f "$CURSOR_BACKUP" ]; then
  if pgrep -x "Cursor" &>/dev/null; then
    echo "Cursor is running. Skipping Cursor backup removal (quit Cursor and run again to free ~12GB)."
  else
    echo "Removing Cursor state backup (12GB)..."
    rm -f "$CURSOR_BACKUP"
    echo "  Done."
  fi
fi

# 6. Cursor CachedData (~339MB) - safe when Cursor is closed
CURSOR_CACHED="$HOME/Library/Application Support/Cursor/CachedData"
if [ -d "$CURSOR_CACHED" ] && ! pgrep -x "Cursor" &>/dev/null; then
  echo "Cleaning Cursor CachedData..."
  rm -rf "$CURSOR_CACHED"/*
  echo "  Done."
fi

# 7. VS Code ShipIt updater cache (659MB)
SHIPIT="$HOME/Library/Caches/com.microsoft.VSCode.ShipIt"
if [ -d "$SHIPIT" ]; then
  echo "Removing VS Code/Cursor ShipIt cache..."
  rm -rf "$SHIPIT"/*
  echo "  Done."
fi

echo ""
echo "=== Cleanup finished. Check free space with: df -h / ==="
