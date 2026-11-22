
#!/usr/bin/env bash
set -Eeuo pipefail

# ==========================================================
# PURPLE NEBULA - UNIVERSAL LINUX RICE
# KDE | Hyprland | GNOME | Cinnamon | XFCE
# ==========================================================

REPO="$HOME/.local/share/purple-nebula"
BACKUP="$HOME/.local/share/purple-nebula-backup"
WALL="$HOME/Pictures/Wallpapers"
AMBILIGHT="$HOME/.local/share/youtube-ambilight"

PURPLE='\033[35m'
RESET='\033[0m'
info(){ echo -e "${PURPLE}[NEBULA]${RESET} $*"; }
warn(){ echo "[WARNING] $*"; }
has(){ command -v "$1" >/dev/null 2>&1; }

[[ $EUID -ne 0 ]] || {
  echo "Run as normal user, NOT root."
  exit 1
}

[[ -f /etc/os-release ]] || exit 1
source /etc/os-release

mkdir -p "$BACKUP" "$WALL" "$HOME/.config"

# 1. BACKUP
info "Backing up existing configuration..."
tar -czf "$BACKUP/config-$(date +%Y%m%d-%H%M%S).tar.gz" \
  -C "$HOME" .config 2>/dev/null || true

# 2. DETECT DESKTOP
DESKTOP="${XDG_CURRENT_DESKTOP:-unknown}"
SESSION="${XDG_SESSION_TYPE:-unknown}"

info "Distribution: $PRETTY_NAME"
info "Desktop: $DESKTOP"
info "Session: $SESSION"

# 3. INSTALL PACKAGES
install_arch() {
  sudo pacman -Syu --needed --noconfirm \
    git curl wget zsh fish starship fastfetch kitty \
    papirus-icon-theme noto-fonts noto-fonts-emoji \
    ttf-jetbrains-mono-nerd nodejs npm jq
}

install_debian() {
  sudo apt-get update
  sudo apt-get install -y \
    git curl wget zsh fish starship fastfetch kitty \
    papirus-icon-theme fonts-jetbrains-mono fonts-noto-color-emoji \
    nodejs npm jq
}

install_fedora() {
  sudo dnf install -y \
    git curl wget zsh fish starship fastfetch kitty \
    papirus-icon-theme jetbrains-mono-fonts-all \
    google-noto-emoji-color-fonts nodejs npm jq
}

case "$ID" in
  arch|manjaro|endeavouros|garuda)
    install_arch ;;
  debian|ubuntu|linuxmint|pop)
    install_debian ;;
  fedora)
    install_fedora ;;
  *)
    warn "Unknown distribution. Install git, curl, zsh, fish, kitty, starship, fastfetch, nodejs and npm manually."
    exit 1 ;;
esac

# 4. PURPLE WALLPAPER
cat > "$WALL/Purple-Nebula.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="2560" height="1440">
<defs>
 <linearGradient id="bg" x2="1" y2="1">
  <stop stop-color="#080612"/>
  <stop offset=".5" stop-color="#211035"/>
  <stop offset="1" stop-color="#090b1c"/>
 </linearGradient>
 <radialGradient id="glow">
  <stop stop-color="#bd72ff" stop-opacity=".85"/>
  <stop offset=".5" stop-color="#7928ca" stop-opacity=".3"/>
  <stop offset="1" stop-color="#7928ca" stop-opacity="0"/>
 </radialGradient>
 <filter id="blur"><feGaussianBlur stdDeviation="90"/></filter>
</defs>
<rect width="100%" height="100%" fill="url(#bg)"/>
<ellipse cx="1750" cy="550" rx="1000" ry="800" fill="url(#glow)" filter="url(#blur)"/>
<ellipse cx="500" cy="1200" rx="800" ry="600" fill="url(#glow)" filter="url(#blur)"/>
<path d="M0 1100 Q800 200 1400 900 T2560 300"
 fill="none" stroke="#b56cff" stroke-opacity=".18" stroke-width="3"/>
</svg>
SVG

# 5. KITTY TERMINAL
mkdir -p "$HOME/.config/kitty"

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
tab_bar_style powerline
active_tab_background #6d28d9
active_tab_foreground #ffffff
inactive_tab_background #1b1230
inactive_tab_foreground #c4b5d6
background_opacity 0.94
EOF

# 6. STARSHIP PROMPT
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

# 7. SHELL CONFIGURATION
for shell_rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  touch "$shell_rc"

  if ! grep -q "PURPLE_NEBULA_CONFIG" "$shell_rc"; then
    cat >> "$shell_rc" <<'EOF'

# PURPLE_NEBULA_CONFIG
if [[ $- == *i* ]]; then
  if command -v starship >/dev/null 2>&1; then
    eval "$(starship init ${SHELL##*/})"
  fi
  if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
  fi
fi
EOF
  fi
done

# 8. GTK DARK MODE
if has gsettings; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface enable-animations true 2>/dev/null || true
fi

# 9. DESKTOP-SPECIFIC CONFIGURATION

case "$DESKTOP" in

  *KDE*|*Plasma*)
    info "KDE Plasma detected."

    if [[ "$SESSION" == "wayland" ]] && has qmake6; then
      QT=$(qmake6 -query QT_VERSION 2>/dev/null || echo 0)
      QT_MAJOR="${QT%%.*}"
      QT_MINOR="$(echo "$QT" | cut -d. -f2)"

      if [[ "$QT_MAJOR" =~ ^[0-9]+$ ]] &&
         [[ "$QT_MINOR" =~ ^[0-9]+$ ]] &&
         (( QT_MAJOR > 6 || (QT_MAJOR == 6 && QT_MINOR >= 9) )); then

        info "Installing Caelestia KDE..."
        git clone --depth 1 --recurse-submodules \
          https://github.com/caelestia-kde/caelestia.git \
          "$HOME/caelestia-kde" 2>/dev/null ||
          git -C "$HOME/caelestia-kde" pull --ff-only

        if [[ -f "$HOME/caelestia-kde/install.sh" ]]; then
          bash "$HOME/caelestia-kde/install.sh"
        fi
      else
        warn "Qt 6.9+ required for Caelestia KDE."
      fi
    else
      warn "KDE Wayland and Qt 6.9+ required."
    fi
    ;;

  *Hyprland*)
    info "Hyprland detected."

    if [[ "$ID" == "arch" || "$ID" == "endeavouros" || "$ID" == "manjaro" ]]; then
      if has paru; then
        paru -S --needed caelestia-cli
        caelestia install
      elif has yay; then
        yay -S --needed caelestia-cli
        caelestia install
      else
        warn "Install an AUR helper, then run:"
        echo "paru -S caelestia-cli && caelestia install"
      fi
    else
      warn "Original Caelestia dotfiles require a separate manual installation on this distribution."
      echo "https://github.com/caelestia-dots/caelestia"
    fi
    ;;

  *GNOME*)
    info "GNOME detected."

    if has gsettings; then
      gsettings set org.gnome.desktop.background picture-uri \
        "file://$WALL/Purple-Nebula.svg" || true
      gsettings set org.gnome.desktop.background picture-uri-dark \
        "file://$WALL/Purple-Nebula.svg" || true
      gsettings set org.gnome.desktop.screensaver picture-uri \
        "file://$WALL/Purple-Nebula.svg" || true
      gsettings set org.gnome.desktop.interface color-scheme \
        'prefer-dark' || true
    fi

    warn "For GNOME extensions, install and configure Dash to Dock and Blur my Shell through Extension Manager."
    ;;

  *Cinnamon*)
    info "Cinnamon detected."

    if has gsettings; then
      gsettings set org.cinnamon.desktop.background picture-uri \
        "file://$WALL/Purple-Nebula.svg" || true
      gsettings set org.cinnamon.desktop.screensaver picture-uri \
        "file://$WALL/Purple-Nebula.svg" || true
    fi
    ;;

  *XFCE*)
    info "XFCE detected."

    if has xfconf-query; then
      for prop in $(xfconf-query -c xfce4-desktop -l 2>/dev/null |
                    grep 'last-image$' || true); do
        xfconf-query -c xfce4-desktop -p "$prop" \
          -s "$WALL/Purple-Nebula.svg" || true
      done
    fi
    ;;

  *)
    warn "Unknown desktop: $DESKTOP"
    warn "Common theme and terminal installed; desktop-specific setup skipped."
    ;;
esac

# 10. YOUTUBE AMBILIGHT
if [[ ! -d "$AMBILIGHT/.git" ]]; then
  git clone --depth 1 \
    https://github.com/WesselKroos/youtube-ambilight.git \
    "$AMBILIGHT"
else
  git -C "$AMBILIGHT" pull --ff-only
fi

if [[ -f "$AMBILIGHT/package.json" ]]; then
  (
    cd "$AMBILIGHT"
    npm ci
    npm run build
  )
fi

# 11. SUMMARY
echo
echo "========================================"
echo "       PURPLE NEBULA INSTALLED"
echo "========================================"
echo
echo "Wallpaper: $WALL/Purple-Nebula.svg"
echo "Terminal: Kitty"
echo "Prompt: Starship"
echo "System info: Fastfetch"
echo "Icons: Papirus Dark (where supported)"
echo "Backup: $BACKUP"
echo "Ambilight: $AMBILIGHT/dist"
echo
echo "NEXT:"
echo "1. Load Ambilight extension from its dist folder."
echo "2. Restart your desktop session."
echo "3. Configure desktop-specific lockscreen and animations."
echo "4. Open Kitty."
echo
echo "Your existing desktop environment was not replaced."
echo "========================================"
