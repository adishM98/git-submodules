# git-submodules-tui

[![npm version](https://img.shields.io/npm/v/git-submodules-tui.svg)](https://www.npmjs.com/package/git-submodules-tui)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Interactive terminal UI for managing Git repositories with submodules. Built with [Ink](https://github.com/vadimdemedes/ink).

## Features

- 📊 **Visual Status Dashboard** - See all repos and submodules at a glance
- 🎨 **4 Color Themes** - Dark, Light, Nord, and Minimal
- ⌨️  **Vim-style Navigation** - hjkl or arrow keys
- 🔄 **Auto-refresh** - Real-time updates every 2 seconds
- 🎯 **Status Indicators** - Visual icons for clean/dirty/conflicts
- 📈 **Tracking Info** - Ahead/behind commit counts
- 🚀 **Fast** - Built with React/Ink for smooth performance

## Installation

### NPM Global Install (Recommended)

```bash
npm install -g git-submodules-tui
```

### Zsh Plugin

Part of the [git-submodules](https://github.com/adishM98/git-submodules) Oh My Zsh plugin:

```bash
git clone https://github.com/adishM98/git-submodules.git ~/.oh-my-zsh/custom/plugins/git-submodules
# Add 'git-submodules' to plugins in ~/.zshrc
```

## Requirements

- **Node.js** 14 or higher
- **zsh** shell
- **Git** 2.0 or higher

## Usage

Navigate to any git repository with submodules:

```bash
cd /path/to/repo/with/submodules
gsm-tui
```

### Keyboard Shortcuts

- `↑` / `k` - Move selection up
- `↓` / `j` - Move selection down
- `r` - Refresh data manually
- `t` - Cycle themes (dark → light → nord → minimal)
- `h` / `?` - Toggle help panel
- `q` / `Esc` - Quit

### Display

The TUI shows:

- **Repository tree** - Base repository + all submodules
- **Branch information** - Current branch per repository
- **Status icons**:
  - ✓ Clean (no changes)
  - ● Dirty (uncommitted changes)
  - ✗ Conflicts
- **Change counts** - Staged + unstaged + untracked files
- **Tracking indicators**:
  - ▲3 Ahead by 3 commits
  - ▼2 Behind by 2 commits

## Themes

Press `t` to cycle through themes:

- **Dark** - Bright colors on dark background (default)
- **Light** - Dark colors on light background
- **Nord** - Nord color palette
- **Minimal** - Monochrome ASCII-only

## Troubleshooting

### "bridge.zsh not found"

Ensure you installed via npm or the zsh plugin method:

```bash
npm uninstall -g git-submodules-tui
npm install -g git-submodules-tui
```

### "zsh is required"

Install zsh:

- macOS: `brew install zsh`
- Ubuntu/Debian: `sudo apt-get install zsh`
- See: https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH

### "Not a git repository"

Make sure you're in a git repository:

```bash
git status
# Should not show "fatal: not a git repository"
```

## Development

```bash
git clone https://github.com/adishM98/git-submodules.git
cd git-submodules/tui
npm install
npm run dev
```

### Build

```bash
npm run build
```

### Test Locally

```bash
npm link
gsm-tui
```

## Related Projects

This TUI is part of the larger [git-submodules](https://github.com/adishM98/git-submodules) Oh My Zsh plugin, which provides:

- 25+ git submodule commands
- Smart commit message generation
- Parallel operations
- Interactive branch management
- And much more

## License

MIT © [adishM98](https://github.com/adishM98)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

- 🐛 [Report bugs](https://github.com/adishM98/git-submodules/issues)
- 💡 [Request features](https://github.com/adishM98/git-submodules/issues)
- 📖 [View documentation](https://github.com/adishM98/git-submodules)
