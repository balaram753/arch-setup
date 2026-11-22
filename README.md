# Purple Nebula — Fedora GNOME Rice

A one-command desktop customization setup for **Fedora Linux + GNOME**. Purple aesthetics, polished icons, terminal customization, GNOME extensions, and YouTube Ambilight.

## Features

- Purple Nebula wallpaper and dark appearance
- Adwair icon theme
- JetBrainsMono Nerd Font
- Yaru sound theme (when available)
- Kitty terminal configuration
- Starship shell prompt
- `fetch` system information tool
- GNOME extension installation attempts
- YouTube Ambilight build setup
- Automatic backup of selected existing configurations

## Supported platform

| Component | Target |
|---|---|
| Distribution | Fedora Linux |
| Desktop | GNOME |
| Shell | Bash / Zsh |
| Terminal | Kitty |
| Theme | Purple Nebula |
| Icons | Adwair |

This installer is designed for Fedora GNOME. It is not a Hyprland or KDE installer.

## GNOME Extensions

The installer attempts to locate and install compatible versions of:

- Arc Menu
- Blur my Shell
- Dash to Dock
- Mosaic
- Rounded Window Corners
- Sanket
- Space Bar
- Status Tray
- V-Shell
- Wallpaper Slideshow

**Compatibility note:** GNOME extensions depend on your GNOME Shell version. Some extensions may not be available or compatible. Check the installation output if one fails.

## Installation

### 1. Clone the repository

### 2. Make the installer executable

```bash
chmod +x setup.sh
```

### 3. Run the installer

```bash
./setup.sh
```

The installer requests administrator privileges only when installing system packages.

## ⚙️ Manual configuration

### V-Shell preferences

After installation, open the GNOME Extensions application and configure V-Shell:

| Setting | Value |
|---|---:|
| Overview blur | Disabled |
| Workspace switch animations | Disabled |
| Dock features | Disabled |
| App grid height | 100 |
| App grid width | 90 |
| Workspace thumbnail position | 0 |
| Workspace thumbnail max scale | 13 |
| Workspace thumbnail app view | 6 |
| Workspace thumbnail search | 6 |
| Startup state | Desktop |

Some preference names can differ between V-Shell versions.

### YouTube Ambilight

The installer prepares the Ambilight project. Browser integration may require additional setup depending on your browser.

Project: https://github.com/WesselKroos/youtube-ambilight

## Included projects

| Project | Repository |
|---|---|
| Adwair icons | https://github.com/kusaida/Adwair |
| Fetch | https://github.com/areofyl/fetch |
| YouTube Ambilight | https://github.com/WesselKroos/youtube-ambilight |

## Wallpaper transitions

The Pocket-Dots wallpaper transition project is designed around a Hyprland workflow.

Repository: https://github.com/diegoMalagrida/pocket-dots

It is **not included in the Fedora GNOME installer**, because its integration is not a drop-in GNOME feature.

## Backup and recovery

The installer creates backups of selected configuration files before changing them.

Review the installer output for the backup location. Restore your saved files manually if you need to undo changes.

## Important notes

- Review `install.sh` before executing it.
- Run as your normal user, not as root.
- An internet connection is required.
- Extension availability depends on GNOME Shell compatibility.
- Log out and log back in if a theme or extension does not appear immediately.
- This project does not guarantee compatibility with every Fedora release.

## License

Choose and add a license before publishing this repository. If you intend to distribute the installer publicly, include the relevant licenses and notices for third-party projects.

---

**Purple Nebula — Fedora GNOME, reimagined. 💜**
