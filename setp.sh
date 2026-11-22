
#!/usr/bin/env bash
set -Eeuo pipefail

# =========================================================
# PURPLE NEBULA - FEDORA GNOME EDITION
# Extensions | Adwair | Yaru | Fetch | Wallpaper | Terminal
# =========================================================

PURPLE='\033[38;5;141m'
RESET='\033[0m'
info(){ echo -e "${PURPLE}[PURPLE NEBULA]${RESET} $*"; }
warn(){ echo "[WARNING] $*" >&2; }

[[ $EUID -ne 0 ]] || {
  echo "Run as your normal user, not root."
  exit 1
}

[[ -r /etc/fedora-release ]] || {
  echo "This installer is designed for Fedora."
  exit 1
}

[[ "${XDG_CURRENT_DESKTOP:-}" == *GNOME* ]] || {
  echo "GNOME session not detected. Log into GNOME first."
  exit 1
}

[[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]] || {
  echo "Run this inside your graphical desktop session."
  exit 1
}

GNOME_VERSION=$(gnome-shell --version | grep -oE '[0-9]+' | head -1)
SHELL_VERSION="$GNOME_VERSION"

BASE="$HOME/.local/share/purple-nebula"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions"
WALL="$HOME/Pictures/Wallpapers"
FETCH_DIR="$BASE/fetch"
ADWAIR_DIR="$BASE/Adwair"
AMBILIGHT_DIR="$BASE/youtube-ambilight"
BACKUP="$BASE/backup-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BASE" "$WALL" "$EXT_DIR" "$BACKUP"
mkdir -p "$HOME/.local/bin" "$HOME/.config/kitty"

info "Fedora detected"
info "GNOME Shell: $GNOME_VERSION"
info "Session: ${XDG_SESSION_TYPE:-unknown}"

# ---------------------------------------------------------
# 1. BACKUP CONFIGURATION
# ---------------------------------------------------------

info "Creating configuration backup..."

for path in \
  "$HOME/.config/gtk-3.0" \
  "$HOME/.config/gtk-4.0" \
  "$HOME/.config/kitty" \
  "$HOME/.config/starship.toml"
do
  if [[ -e "$path" ]]; then
    cp -a "$path" "$BACKUP/"
  fi
done

dconf dump /org/gnome/ > "$BACKUP/gnome-settings.ini" 2>/dev/null || true

# ---------------------------------------------------------
# 2. FEDORA PACKAGES
# ---------------------------------------------------------

info "Installing dependencies..."

sudo dnf install -y \
  git curl wget jq unzip zip \
  gcc gcc-c++ make \
  zsh fish \
  kitty \
  gnome-tweaks \
  gnome-extensions-app \
  gnome-menus \
  gtk-murrine-engine \
  gtk-update-icon-cache \
  glib2-devel \
  gettext \
  python3 \
  python3-pip \
  nodejs npm \
  fontconfig \
  google-noto-emoji-color-fonts

# ---------------------------------------------------------
# 3. FONTS
# ---------------------------------------------------------

info "Installing JetBrains Mono Nerd Font..."

mkdir -p "$HOME/.local/share/fonts/JetBrainsMono"

if [[ ! -f "$HOME/.local/share/fonts/JetBrainsMono/JetBrainsMonoNerdFont-Regular.ttf" ]]; then
  curl -fL \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz \
    -o "$BASE/JetBrainsMono.tar.xz"

  tar -xf "$BASE/JetBrainsMono.tar.xz" \
    -C "$HOME/.local/share/fonts/JetBrainsMono"
fi

fc-cache -f

# ---------------------------------------------------------
# 4. PURPLE WALLPAPER
# ---------------------------------------------------------

info "Creating Purple Nebula wallpaper..."

cat > "$WALL/Purple-Nebula.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="2560" height="1440">
<defs>
 <linearGradient id="bg" x2="1" y2="1">
  <stop stop-color="#080612"/>
  <stop offset=".48" stop-color="#241039"/>
  <stop offset="1" stop-color="#090b1c"/>
 </linearGradient>
 <radialGradient id="glow">
  <stop stop-color="#c084fc" stop-opacity=".85"/>
  <stop offset=".45" stop-color="#9333ea" stop-opacity=".3"/>
  <stop offset="1" stop-color="#581c87" stop-opacity="0"/>
 </radialGradient>
 <filter id="blur"><feGaussianBlur stdDeviation="100"/></filter>
</defs>
<rect width="100%" height="100%" fill="url(#bg)"/>
<ellipse cx="1750" cy="500" rx="950" ry="750" fill="url(#glow)" filter="url(#blur)"/>
<ellipse cx="500" cy="1200" rx="800" ry="600" fill="url(#glow)" filter="url(#blur)"/>
<path d="M0 1050 Q650 350 1250 850 T2560 250"
 fill="none" stroke="#c084fc" stroke-opacity=".2" stroke-width="3"/>
<path d="M0 1150 Q650 450 1250 950 T2560 350"
 fill="none" stroke="#c084fc" stroke-opacity=".1" stroke-width="2"/>
</svg>
SVG

gsettings set org.gnome.desktop.background picture-uri \
  "file://$WALL/Purple-Nebula.svg"

gsettings set org.gnome.desktop.background picture-uri-dark \
  "file://$WALL/Purple-Nebula.svg"

# ---------------------------------------------------------
# 5. GNOME APPEARANCE
# ---------------------------------------------------------

info "Applying purple GNOME appearance..."

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true

if gsettings range org.gnome.desktop.interface accent-color 2>/dev/null |
   grep -q purple; then
  gsettings set org.gnome.desktop.interface accent-color 'purple'
fi

gsettings set org.gnome.desktop.interface enable-animations true || true

# ---------------------------------------------------------
# 6. ADWAIR ICON THEME
# ---------------------------------------------------------

info "Installing Adwair..."

if [[ ! -d "$ADWAIR_DIR/.git" ]]; then
  git clone --depth 1 \
    https://github.com/kusaida/Adwair.git "$ADWAIR_DIR"
else
  git -C "$ADWAIR_DIR" pull --ff-only
fi

if [[ -f "$ADWAIR_DIR/install.sh" ]]; then
  chmod +x "$ADWAIR_DIR/install.sh"
  (cd "$ADWAIR_DIR" && ./install.sh)
fi

if [[ -d "$HOME/.local/share/icons/Adwair-dark" ]]; then
  gsettings set org.gnome.desktop.interface icon-theme 'Adwair-dark'
fi

# ---------------------------------------------------------
# 7. YARU SOUND THEME
# ---------------------------------------------------------

info "Checking Yaru sound theme..."

if sudo dnf install -y yaru-theme-sound; then
  if [[ -d /usr/share/sounds/Yaru ]]; then
    gsettings set org.gnome.desktop.sound theme-name 'Yaru' || true
  fi
else
  warn "Yaru sound package is unavailable in enabled Fedora repositories."
  warn "No sound theme was replaced."
fi

# ---------------------------------------------------------
# 8. KITTY TERMINAL
# ---------------------------------------------------------

info "Configuring Kitty..."

cat > "$HOME/.config/kitty/kitty.conf" <<'EOF'
font_family JetBrainsMono Nerd Font
font_size 11.5

background #100b1b
foreground #eadcff

selection_background #563477
selection_foreground #ffffff

cursor #d8b4fe
url_color #c4a7e7

active_border_color #a855f7
inactive_border_color #39264f

active_tab_background #6d28d9
active_tab_foreground #ffffff

inactive_tab_background #1b1230
inactive_tab_foreground #c4b5d6

tab_bar_style powerline
background_opacity 0.94
EOF

# ---------------------------------------------------------
# 9. STARSHIP
# ---------------------------------------------------------

info "Configuring Starship..."

cat > "$HOME/.config/starship.toml" <<'EOF'
add_newline = true
format = "[╭─](bold purple)$all[╰─](bold purple)$character"

[character]
success_symbol = "[❯](bold purple)"
error_symbol = "[❯](bold red)"

[directory]
style = "bold purple"
truncation_length = 3

[git_branch]
style = "bold bright-purple"

[cmd_duration]
style = "bold yellow"
EOF

# ---------------------------------------------------------
# 10. FETCH - 3D SYSTEM INFORMATION
# ---------------------------------------------------------

info "Building areofyl/fetch..."

if [[ ! -d "$FETCH_DIR/.git" ]]; then
  git clone --depth 1 \
    https://github.com/areofyl/fetch.git "$FETCH_DIR"
else
  git -C "$FETCH_DIR" pull --ff-only
fi

(
  cd "$FETCH_DIR"
  make
  make PREFIX="$HOME/.local" install
)

# ---------------------------------------------------------
# 11. SHELL CONFIGURATION
# ---------------------------------------------------------

for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
  touch "$RC"

  if ! grep -q 'PURPLE_NEBULA_MANAGED' "$RC"; then
    cat >> "$RC" <<'EOF'

# PURPLE_NEBULA_MANAGED
if [[ $- == *i* ]]; then
  if command -v starship >/dev/null 2>&1; then
    eval "$(starship init ${SHELL##*/})"
  fi

  if command -v fetch >/dev/null 2>&1; then
    fetch
  elif command -v fastfetch >/dev/null 2>&1; then
    fastfetch
  fi
fi
EOF
  fi
done

# ---------------------------------------------------------
# 12. GNOME EXTENSION INSTALLER
# Resolve exact extension names and GNOME-compatible builds
# from the GNOME Extensions catalogue.
# ---------------------------------------------------------

info "Resolving GNOME extension compatibility..."

install_extension() {
  local name="$1"
  local search="$2"
  local result uuid pk zipfile

  info "Checking: $name"

  result=$(python3 - "$search" "$SHELL_VERSION" <<'PY'
import json
import sys
import urllib.parse
import urllib.request

query, shell = sys.argv[1], sys.argv[2]
url = "https://extensions.gnome.org/extension-query/?" + urllib.parse.urlencode({
    "search": query
})

req = urllib.request.Request(
    url, headers={"User-Agent": "PurpleNebulaInstaller/1.0"}
)

try:
    with urllib.request.urlopen(req, timeout=30) as response:
        data = json.load(response)
except Exception as exc:
    print("ERROR|" + str(exc))
    sys.exit(0)

def normalize(value):
    return "".join(c.lower() for c in value if c.isalnum())

matches = data.get("extensions", [])
matches = [e for e in matches if normalize(e.get("name", "")) == normalize(query)]

if not matches:
    print("NOTFOUND")
    sys.exit(0)

ext = matches[0]
build = ext.get("shell_version_map", {}).get(shell)

if not build:
    print("INCOMPATIBLE|" + ext.get("uuid", ""))
    sys.exit(0)

print("OK|" + ext["uuid"])
PY
)

  case "$result" in
    OK\|*)
      uuid="${result#OK|}"
      ;;
    INCOMPATIBLE\|*)
      warn "$name exists but has no published GNOME $SHELL_VERSION build."
      return 0
      ;;
    NOTFOUND*)
      warn "$name was not found in the GNOME Extensions catalogue."
      return 0
      ;;
    *)
      warn "Could not resolve $name: $result"
      return 0
      ;;
  esac

  zipfile="$BASE/${uuid}.zip"

  if ! curl -fsSL \
    "https://extensions.gnome.org/download-extension/${uuid}.shell_version=${SHELL_VERSION}.zip" \
    -o "$zipfile"; then
    warn "Download failed for $name."
    return 0
  fi

  if ! unzip -tq "$zipfile" >/dev/null 2>&1; then
    warn "Invalid extension archive for $name."
    return 0
  fi

  if gnome-extensions install --force "$zipfile"; then
    info "Installed $name ($uuid)"
    gnome-extensions enable "$uuid" 2>/dev/null || true
  else
    warn "Could not install $name."
  fi
}

# Exact catalogue names. Missing/unpublished extensions are skipped.
install_extension "ArcMenu" "ArcMenu"
install_extension "Blur my Shell" "Blur my Shell"
install_extension "Dash to Dock" "Dash to Dock"
install_extension "Mosaic" "Mosaic"
install_extension "Rounded Window Corners" "Rounded Window Corners"
install_extension "Space Bar" "Space Bar"
install_extension "V-Shell" "V-Shell"

# These names may not be published under the exact requested title.
install_extension "Sanket" "Sanket"
install_extension "Status Tray" "Status Tray"
install_extension "Wallpaper Slideshow" "Wallpaper Slideshow"

# ---------------------------------------------------------
# 13. YOUTUBE AMBILIGHT
# ---------------------------------------------------------

info "Building YouTube Ambilight..."

if [[ ! -d "$AMBILIGHT_DIR/.git" ]]; then
  git clone --depth 1 \
    https://github.com/WesselKroos/youtube-ambilight.git \
    "$AMBILIGHT_DIR"
else
  git -C "$AMBILIGHT_DIR" pull --ff-only
fi

if [[ -f "$AMBILIGHT_DIR/package.json" ]]; then
  (
    cd "$AMBILIGHT_DIR"
    npm install
    npm run build
  )
fi

# ---------------------------------------------------------
# 14. FINISH
# ---------------------------------------------------------

info "Installation complete."

echo
echo "============================================"
echo "          PURPLE NEBULA FEDORA"
echo "============================================"
echo
echo "GNOME: $GNOME_VERSION"
echo "Wallpaper: $WALL/Purple-Nebula.svg"
echo "Icons: Adwair-dark"
echo "Terminal: Kitty"
echo "Prompt: Starship"
echo "System fetch: Fetch"
echo "Ambilight: $AMBILIGHT_DIR"
echo "Backup: $BACKUP"
echo
echo "NEXT ACTIONS:"
echo "1. Log out and log back into GNOME."
echo "2. Open Extensions and inspect enabled extensions."
echo "3. Configure V-Shell preferences manually."
echo "4. Configure Blur my Shell and Dash to Dock."
echo "5. Configure wallpaper slideshow."
echo "6. Load Ambilight manually in your browser."
echo
echo "Extensions that lack a compatible build were skipped."
echo "============================================"
