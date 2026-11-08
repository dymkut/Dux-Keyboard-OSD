# Dux Keyboard OSD

A lightweight, customizable alternative keyboard layout OSD plugin for Dux Shell, currently tested on Niri.

<img width="201" height="66" alt="Keyboard layout OSD preview" src="https://github.com/user-attachments/assets/985b01d1-d4fc-451c-82cf-69ee83b428d4" />

## Overview

Dux Keyboard OSD is a small open-source project developed to explore QML, JavaScript, and plugin development within the Dux Shell environment.

It provides a customizable on-screen indicator for the active keyboard layout, including country flags, ISO codes, and custom labels.

The project focuses on simplicity, readability, and learning while offering an alternative to Dux Shell's native keyboard layout indicator.

## Features

- Keyboard layout detection for Niri.
- Country flag and ISO code display.
- Support for keyboard layout variants.
- Custom labels and layout aliases.
- Configurable display modes and OSD behavior.
- Persistent settings.

## Installation

1. Make sure Dux Shell is installed and running.
2. Clone this repository into the Dux Shell plugins directory:

   ```bash
   mkdir -p ~/.config/DankMaterialShell/plugins
   git clone https://github.com/dymkut/Dux-Keyboard-OSD.git ~/.config/DankMaterialShell/plugins/dux-keyboard-osd
   ```

3. Open the plugin manager in Dux Shell.
4. Enable **Dux Keyboard OSD** and configure it through its settings panel.

### Updating

Dux Shell includes a built-in plugin updater, which can be used to check for and install available updates.

Alternatively, if you installed the plugin using Git, you can update it manually:

```bash
cd ~/.config/DankMaterialShell/plugins/dux-keyboard-osd
git pull
```

Restart or reload the plugin if necessary.

## Configuration

The plugin includes settings for customizing the keyboard layout indicator, including its appearance, display format, and custom labels.

<img width="547" height="533" alt="image" src="https://github.com/user-attachments/assets/6d5c710d-33a0-4f26-8c91-6bf70e101768" />

## Development

This project was developed as a personal learning exercise, with AI assistance used for studying QML concepts, reviewing code, and exploring implementation alternatives.

The main goals are to keep the code understandable, minimize unnecessary dependencies, and make the implementation accessible to other learners.

When I first started using DankMaterialShell, I couldn't find a native keyboard layout indicator, so I decided to experiment and build my own. I've been using this little project as a temporary solution ever since.

Dux Shell now includes its own native indicator, but I decided to share my implementation anyway, both as a learning project and as an alternative for anyone interested in customizing their setup.

And to anyone who needed this feature back then, sorry I didn't share it sooner! :)

## Future Features

Some ideas I'd like to explore as I continue learning and improving the project:

- [ ] Add interactive keyboard layout switching using mouse scrolling.
- [ ] Explore vertical and horizontal layout selection.
- [ ] Improve keyboard layout and variant detection.
- [ ] Add more customization options for the OSD.
- [ ] Explore additional display styles and animations.
- [ ] Optimize the code while keeping it simple and readable.

These are just ideas for now, and there's no planned release schedule. Contributions and suggestions are always welcome!

## Compatibility

- **Shell:** Originally developed for DankMaterialShell. Dux Shell compatibility is still being evaluated.
- **Compositor:** Niri (tested).
- **Hyprland:** Experimental support included in the code, but not yet tested.
- **Language:** QML and JavaScript.

## License

Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0-only). See [LICENSE](LICENSE) for details.
