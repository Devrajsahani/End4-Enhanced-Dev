# End4 Enhanced Dev (Dotfiles)

An enhanced, high-performance **Arch Linux + Hyprland + Quickshell** rice combining the fluid aesthetics of **End4's Illogical Impulse** with productivity features, rofi workflows, and visual controls inspired by **Dusky Linux**.

---

## Highlights & Features

### 1. 󰕾 Rofi Quick Controls & Volume / Brightness Hub (`SUPER + ALT + C`)
- **Direct Volume Presets**: 100%, 80%, 60%, 40%, 20%, fine tuning (+/-5%, +/-1%), and mute toggle (`SUPER + ALT + V`).
- **Direct Brightness Presets**: 100%, 75%, 50%, 25%, 10%, 1%, fine tuning (+/-5%, +/-1%), and night light toggle.
- **Type-To-Set**: Type any number `0-150` directly into Rofi to instantly jump to that exact percentage!
- **Fast Access**: Launchers for Audio Output Switcher, Microphone Mute, Screen / GIF Recorder, Screen Snip & Search, Btop task manager, and Cache purge.
- **OSD Sync**: Every adjustment displays an animated progress bar overlay via `notify-send`.

### 2. 󰇚 Real-Time Top Bar Download Speed Indicator
- Seamlessly integrated beside the **Power Profile Switch Button** across all **5 Top Bar Layouts**.
- Powered by high-speed, zero-fork `/proc/net/dev` polling in Quickshell.
- Shows dynamic throughput (e.g., `1.2 MB/s`, `450 KB/s`, `0 B/s`).
- Interactive: Hover for full upload/download stats and network interface; click to toggle showing upload stats alongside download.

### 3. 󰌨 5-Style Top Bar Layout Switcher (`SUPER + ALT + B`)
Choose dynamically between 5 curated top bar configurations:
1. **Floating Islands (Reference)**: Independent floating dark capsules.
2. **Noctalia Zones**: Three consolidated module islands.
3. **Control Deck**: Workspaces and clock combined in a central command bridge.
4. **Quiet Essentials (Minimal)**: Ultra-clean, distraction-free edge-to-edge layout.
5. **Center Capsule**: Centered workspace indicators and time.

### 4. 󰏘 Modernized Visual Pickers
- **Wallpaper Picker (`SUPER + ALT + W`)**: 4×2 hero card grid with 145px high-resolution previews, single-click mouse accept, sanitized names, and fuzzy search.
- **Theme Pack Switcher (`SUPER + ALT + T`)**: 3×2 deck showcasing all 6 theme packs (Catppuccin Mocha, Tokyo Night, Gruvbox Dark, Everforest Dark, Nord, Cars Racing) without vertical scrolling.
- **Fluid Animation Switcher (`SUPER + ALT + A`)**: 12 custom cubic-bezier and spring animation curves ported from Dusky Linux with instant live switching.
- **Audio Switcher (`SUPER + ALT + O`)**: PipeWire audio output and microphone device selector.

### 5. 󰌌 Dynamic Keybindings Cheatsheet (`SUPER + /`, `SUPER + F1`, `SUPER + ALT + K`)
- Live query of `hyprctl binds` parsed into searchable, categorized sections (Window, Workspace, Appearance, Media, System, Utilities).
- Click or press Enter on any command to execute it directly from the cheatsheet!

---

## ⌨️ Essential Keybindings

| Keybinding | Action | Description |
| :--- | :--- | :--- |
| `SUPER + ALT + C` | **Quick Controls Hub** | Open Volume, Brightness & Tools Rofi menu |
| `SUPER + ALT + V` | **Volume Controls** | Open Volume Presets & Rofi Slider |
| `SUPER + ALT + Up / Down` | **Volume Adjust** | Increase / Decrease Volume (+/- 5%) |
| `SUPER + ALT + Right / Left`| **Brightness Adjust** | Increase / Decrease Brightness (+/- 5%) |
| `SUPER + ALT + M` | **Mute Audio** | Toggle audio mute with OSD |
| `SUPER + ALT + B` | **Top Bar Layout** | Switch between 5 Top Bar designs |
| `SUPER + ALT + W` | **Wallpaper Selector** | 4×2 Card Grid Wallpaper Picker |
| `SUPER + ALT + T` | **Theme Pack Selector**| 3×2 Deck Theme Switcher |
| `SUPER + ALT + A` | **Animation Profile** | Switch between 12 fluid curves |
| `SUPER + ALT + O` | **Audio Devices** | Switch PipeWire audio output / mic |
| `SUPER + /` or `SUPER + F1` | **Keybinds Cheatsheet**| Live interactive shortcut cheatsheet |
| `XF86AudioRaise / Lower` | **Hardware Volume** | Standard 5% volume step |
| `ALT + XF86Audio...` | **Precise Volume** | Precise 1% volume step |
| `XF86MonBrightness...` | **Hardware Brightness**| Standard 5% brightness step |
| `ALT + XF86MonBrightness...`| **Precise Brightness**| Precise 1% brightness step |

---

## 📁 Repository Structure

```
.
├── .config/
│   ├── hypr/                 # Hyprland config (Lua syntax + custom rules/keybinds)
│   │   ├── custom/           # User keybinds, rules, animations & profiles
│   │   │   ├── animations/   # 12 Dusky animation profiles
│   │   │   ├── keybinds.lua  # Custom keybindings
│   │   │   └── rules.lua     # Hyprland window & layer blur rules
│   │   └── hyprland.lua      # Master Hyprland loader
│   ├── quickshell/           # Quickshell Qt6/QML desktop shell
│   │   └── ii/
│   │       ├── modules/ii/bar/DownloadSpeed.qml # Live download speed widget
│   │       └── services/NetworkSpeed.qml        # Real-time network throughput service
│   ├── illogical-impulse/    # Themes, presets & Rofi configs
│   │   └── theme-packs/      # Rofi card layouts (wallpapers, themes, bars, controls)
│   ├── kitty/                # Kitty terminal configuration
│   ├── matugen/              # Dynamic Material You color scheme templates
│   ├── wlogout/              # Session logout menu
│   ├── cava/                 # Audio visualizer
│   ├── fuzzel/               # Wayland application launcher
│   └── fish/                 # Fish shell configuration
├── .local/
│   └── bin/                  # Rice utility CLI scripts
│       ├── ii-anim           # Animation switcher
│       ├── ii-audio          # PipeWire audio switcher
│       ├── ii-bar-layout     # Top bar layout switcher
│       ├── ii-control        # Quick controls & volume/brightness hub
│       ├── ii-keybinds       # Live keybinds cheatsheet
│       └── ii-theme          # Wallpaper and theme switcher
├── install.sh                # Automated deploy script
├── sync.sh                   # Dotfile synchronization script
├── .gitignore
└── README.md
```

---

## 🚀 Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Devrajsahani/End4-Enhanced-Dev.git ~/End4-Enhanced-Dev
   cd ~/End4-Enhanced-Dev
   ```

2. **Deploy dotfiles**:
   ```bash
   ./install.sh
   ```

3. **Sync changes back to repo**:
   Whenever you customize configs locally, update the repo with:
   ```bash
   ./sync.sh
   git commit -am "Update dotfiles"
   git push origin main
   ```

---

## 🎨 Acknowledgements & Credits
- **[End4](https://github.com/end-4/dots-hyprland)**: Upstream Illogical Impulse Hyprland & Quickshell rice.
- **[Dusky Linux](https://github.com/dusklinux/dusky)**: Inspiration for precise media controls, animation curves, audio routers, and quick productivity workflows.
