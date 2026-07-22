#!/usr/bin/env bash
# PyStore installer 📦 — installs PyStore as a real native desktop app.
# Usage: curl -fsSL <this-script-url> | bash -s -- <url-to-pystore.tar.gz>

set -euo pipefail

TARBALL_URL="${1:-}"
if [ -z "$TARBALL_URL" ]; then
    echo "Usage: curl -fsSL <url-to-install.sh> | bash -s -- <url-to-pystore.tar.gz>"
    exit 1
fi

INSTALL_DIR="$HOME/.local/share/pystore"

echo "📦 Installing PyStore to $INSTALL_DIR"
echo

# --- Package manager detection -------------------------------------------
PKG_INSTALL=""
if command -v apt-get >/dev/null 2>&1; then
    PKG_INSTALL="sudo apt-get update -qq && sudo apt-get install -y"
elif command -v dnf >/dev/null 2>&1; then
    PKG_INSTALL="sudo dnf install -y"
elif command -v pacman >/dev/null 2>&1; then
    PKG_INSTALL="sudo pacman -Sy --noconfirm"
elif command -v zypper >/dev/null 2>&1; then
    PKG_INSTALL="sudo zypper install -y"
elif command -v apk >/dev/null 2>&1; then
    PKG_INSTALL="sudo apk add"
fi

install_pkg() {
    # $1 = human name, remaining args = package names to try
    local name="$1"; shift
    if [ -z "$PKG_INSTALL" ]; then
        echo "❌ Couldn't detect a package manager to install $name automatically."
        echo "   Please install $name yourself and re-run this installer."
        exit 1
    fi
    echo "📥 Installing $name…"
    eval "$PKG_INSTALL $*"
}

# --- Python3 (required) ---------------------------------------------------
if ! command -v python3 >/dev/null 2>&1; then
    install_pkg "Python 3" "python3 python3-venv python3-pip"
fi

# --- Flatpak (required for installing apps) -------------------------------
if ! command -v flatpak >/dev/null 2>&1; then
    install_pkg "Flatpak" "flatpak"
fi
if command -v flatpak >/dev/null 2>&1; then
    if ! flatpak remote-list 2>/dev/null | grep -q flathub; then
        echo "🌐 Adding the Flathub remote…"
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
fi

# --- Node.js + npm (required to build the native desktop app) ------------
if ! command -v npm >/dev/null 2>&1; then
    install_pkg "Node.js" "nodejs npm"
fi
if ! command -v npm >/dev/null 2>&1; then
    echo "❌ npm still isn't available after attempting to install it."
    echo "   Install Node.js + npm manually, then re-run this installer."
    exit 1
fi

# --- Download & unpack -----------------------------------------------------
mkdir -p "$INSTALL_DIR"
TMP_TAR=$(mktemp)
echo "⬇️  Downloading PyStore…"
curl -fsSL "$TARBALL_URL" -o "$TMP_TAR"
tar -xzf "$TMP_TAR" -C "$INSTALL_DIR" --strip-components=1
rm -f "$TMP_TAR"
cd "$INSTALL_DIR"

# --- Python environment ----------------------------------------------------
echo "🐍 Setting up Python environment…"
python3 -m venv venv
./venv/bin/pip install --upgrade pip >/dev/null
./venv/bin/pip install -r requirements.txt

echo "🗄️  Preparing the database…"
./venv/bin/python manage.py migrate --noinput

# --- Build the native desktop app (mandatory, no fallback) -----------------
chmod +x run-store.sh install-desktop-icon.sh build-desktop-app.sh

echo "🖥️  Building the native desktop app (downloads Electron, ~120MB — this takes a few minutes)…"
./build-desktop-app.sh

echo "🖱️  Creating your desktop icon…"
./install-desktop-icon.sh

echo
echo "🎉 PyStore is installed as a native desktop app!"
echo "   Look for it in your app menu, or double-click the icon on your Desktop."
