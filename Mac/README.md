# Mac Configuration

A comprehensive collection of configuration files and setups for macOS development environment. This repository contains dotfiles, application configurations, and automation scripts for a productive Mac setup.

## 📁 Repository Structure

```
Mac/
├── README.md                           # This file
├── zshrc                              # Zsh shell configuration
├── p10k.zsh                           # Powerlevel10k theme configuration
├── ghostty/                           # Ghostty terminal emulator config
│   └── config                         # Main Ghostty configuration file
├── hammerspoon/                       # Hammerspoon automation framework
│   ├── init.lua                       # Main Hammerspoon entry point
│   ├── README.md                      # Detailed Hammerspoon documentation
│   ├── SHORTCUT.md                    # Keyboard shortcuts reference
│   ├── config/
│   │   └── hotkeys.json              # Keyboard shortcuts configuration
│   ├── modules/                       # Modular Lua scripts
│   │   ├── display_focus.lua         # Display and focus management
│   │   └── window_management.lua     # Window manipulation functions
│   ├── printable-shortcuts-list/     # PDF documentation
│   │   ├── shortcuts-list.pdf        # Printable shortcuts reference
│   │   ├── shortcuts-list.synctex.gz # LaTeX sync file
│   │   └── shortcuts-list.tex        # LaTeX source
│   ├── Spoons/                       # Hammerspoon extensions
│   └── utils/                        # Utility functions
├── lima/                             # Lima VM configuration
│   └── dockerimg/
│       └── lima.yaml                 # Docker-enabled Lima VM config
└── ssh/                              # SSH client configuration
    └── config                        # SSH hosts and settings
```

## 🚀 Quick Setup

### Prerequisites

Before applying these configurations, ensure you have the following installed:

- [Homebrew](https://brew.sh/) - Package manager for macOS
- [Oh My Zsh](https://ohmyz.sh/) - Zsh framework
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Zsh theme
- [Ghostty](https://ghostty.org/) - Terminal emulator
- [Hammerspoon](https://www.hammerspoon.org/) - macOS automation
- [Lima](https://lima-vm.io/) - Linux VMs on macOS

### Installation

1. **Clone this repository:**
   ```bash
   git clone <your-repo-url> ~/Dropbox/PC-Configurations/Mac
   cd ~/Dropbox/PC-Configurations/Mac
   ```

2. **Apply shell configuration:**
   ```bash
   # Backup existing configuration
   cp ~/.zshrc ~/.zshrc.backup
   
   # Link new configuration
   ln -sf ~/Dropbox/PC-Configurations/Mac/zshrc ~/.zshrc
   ln -sf ~/Dropbox/PC-Configurations/Mac/p10k.zsh ~/.p10k.zsh
   ```

3. **Setup Ghostty:**
   ```bash
   # Create Ghostty config directory if it doesn't exist
   mkdir -p ~/Library/Application\ Support/com.mitchellh.ghostty/
   
   # Link configuration
   ln -sf ~/Dropbox/PC-Configurations/Mac/ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config
   ```

4. **Setup Hammerspoon:**
   ```bash
   # Link Hammerspoon configuration
   ln -sf ~/Dropbox/PC-Configurations/Mac/hammerspoon ~/.hammerspoon
   ```

5. **Setup SSH configuration:**
   ```bash
   # Backup existing SSH config
   cp ~/.ssh/config ~/.ssh/config.backup
   
   # Link SSH configuration
   ln -sf ~/Dropbox/PC-Configurations/Mac/ssh/config ~/.ssh/config
   ```

6. **Setup Lima (optional):**
   ```bash
   # Start Lima VM with Docker support
   limactl start ~/Dropbox/PC-Configurations/Mac/lima/dockerimg/lima.yaml
   ```

## 🛠 Components Overview

### Shell Configuration (zshrc)

- **Oh My Zsh** framework with Powerlevel10k theme
- Custom aliases and functions
- Enhanced command history and completion
- Git integration and status display

### Terminal (Ghostty)

- Modern, fast terminal emulator configuration
- Custom color schemes and fonts
- Optimized performance settings
- Keyboard shortcuts and mouse interactions

### Automation (Hammerspoon)

A modular Hammerspoon setup featuring:

- **Window Management**: Advanced window positioning and resizing
- **Display Focus**: Multi-monitor workflow optimization  
- **Keyboard Shortcuts**: Customizable hotkey system via JSON configuration
- **Extensible Architecture**: Easy to add new modules and functionality

Key features:
- JSON-based hotkey configuration
- Error-resistant module loading
- Comprehensive window management
- Multi-display support

### SSH Configuration

- Predefined host configurations
- Integration with Colima for container development
- GitHub and development server access
- Secure connection settings

### Lima VM Configuration

- Docker-enabled Linux VM for containerized development
- x86_64 architecture support
- Optimized for macOS integration
- Development environment isolation

## 📚 Documentation

- **Hammerspoon**: See `hammerspoon/README.md` for detailed setup and usage
- **Shortcuts**: Check `hammerspoon/SHORTCUT.md` for keyboard shortcuts reference
- **Printable Reference**: Use `hammerspoon/printable-shortcuts-list/shortcuts-list.pdf`

## 🔧 Customization

### Adding New Hammerspoon Modules

1. Create a new `.lua` file in `hammerspoon/modules/`
2. Export functions as a table
3. Add corresponding shortcuts to `hammerspoon/config/hotkeys.json`

### Modifying Shell Configuration

Edit `zshrc` and reload with:
```bash
source ~/.zshrc
```

### Updating SSH Hosts

Add new host configurations to `ssh/config` following the existing pattern.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test configurations thoroughly
5. Submit a pull request

## 📄 License

This configuration is provided as-is for personal use. Feel free to adapt and modify according to your needs.

## 🆘 Troubleshooting

### Hammerspoon Not Loading Modules

- Check Hammerspoon console for error messages
- Verify file permissions on `.hammerspoon` directory
- Ensure JSON configuration syntax is valid

### Shell Theme Issues

- Verify Oh My Zsh installation
- Check Powerlevel10k theme installation
- Run `p10k configure` to reconfigure theme

### SSH Connection Problems

- Verify host configurations in SSH config
- Check SSH key permissions (`chmod 600 ~/.ssh/id_*`)
- Test connections with `ssh -v hostname`

---

**Last Updated**: September 2025

For questions or issues, please refer to the individual component documentation or create an issue in this repository.