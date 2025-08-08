# Git Submodules - Oh My Zsh Plugin

A clean and powerful Oh My Zsh plugin for managing Git repositories with submodules. This plugin provides essential utilities while maintaining simplicity and reliability.

## ✨ Features

- 🎯 **Simple & Reliable** - Focused on core functionality that works
- 🔄 **Interactive Operations** - User-friendly prompts for complex workflows
- 📊 **Smart Logging** - Clear, emoji-based status messages with verbose control
- 🛡️ **Safe Operations** - Input validation and proper error handling
- 🔧 **Stash Management** - Automatic stash handling for checkout and merge operations
- ⚙️ **Auto-Update** - Self-updating capability with interactive prompts

## 📦 Installation

### Method 1: Oh My Zsh Plugin (Recommended)

1. Clone this repository:
   ```bash
   git clone https://github.com/adishM98/git-submodules.git ~/.oh-my-zsh/custom/plugins/git-submodules
   ```

2. Add the plugin to your `~/.zshrc`:
   ```bash
   plugins=(... git-submodules)
   ```

3. Reload Zsh:
   ```bash
   source ~/.zshrc
   ```

### Method 2: Direct Installation

1. Clone the repository anywhere:
   ```bash
   git clone https://github.com/adishM98/git-submodules.git
   ```

2. Source the plugin in your shell configuration:
   ```bash
   source /path/to/git-submodules/git-submodules.plugin.zsh
   ```

## 🚀 Quick Start

After installation, you can immediately start using commands like:

```bash
# Check plugin status and current repository
git_submodules_status

# Pull latest changes from all repositories
pull_all

# Create a feature branch interactively
start_feature

# Control logging verbosity
toggle_verbose
```

## 📋 Available Commands

### Core Git Operations

| Command | Description | Example |
|---------|-------------|---------|
| `pull_all` | Pull changes for main repo and all submodules | `pull_all` |
| `push_all` | Push changes across all repositories | `push_all` |
| `add_all` | Stage changes in main repo and submodules | `add_all` |
| `commit_all "<message>"` | Commit changes across all repositories | `commit_all "Fix authentication bug"` |
| `status_all` | Show Git status for all repositories | `status_all` |

### Branch Management

| Command | Description | Example |
|---------|-------------|---------|
| `checkout_all` | Interactive checkout with stash support | `checkout_all` |
| `create_branch_all <name>` | Create branch in all repositories | `create_branch_all my-feature` |
| `create_feature_all <name>` | Create `feature/` prefixed branch | `create_feature_all user-auth` |
| `create_hotfix_all <name>` | Create `hotfix/` prefixed branch | `create_hotfix_all critical-fix` |
| `create_release_all <name>` | Create `release/` prefixed branch | `create_release_all v2.1.0` |
| `create_sprint_all <name>` | Create `sprint/` prefixed branch | `create_sprint_all sprint-23` |
| `create_revamp_all <name>` | Create `revamp/` prefixed branch | `create_revamp_all ui-redesign` |

### Interactive Commands

| Command | Description | Features |
|---------|-------------|----------|
| `start_branch` | Create branch with interactive selection | Choose repos, folders, or all |
| `start_feature` | Interactive feature branch creation | Guided prompts and validation |
| `start_hotfix` | Interactive hotfix branch creation | Smart repo selection |
| `start_release` | Interactive release branch creation | Comprehensive options |
| `start_sprint` | Interactive sprint branch creation | Flexible targeting |

### Advanced Operations

| Command | Description | Features |
|---------|-------------|----------|
| `merge_all` | Interactive merge with stash handling | Smart conflict resolution |
| `create_tag_all <name>` | Create and push tags across repos | Validation and error handling |

### Utility Commands

| Command | Description | Purpose |
|---------|-------------|---------|
| `git_submodules_status` | Show plugin and repository status | Debug and overview |
| `toggle_verbose` | Control output verbosity | Customize logging |
| `update_git_submodules_plugin` | Update plugin to latest version | Auto-update |

## ⚙️ Configuration

The plugin supports environment variables for customization:

```bash
# Control output verbosity (default: true)
export GIT_SUBMODULES_VERBOSE=true
```

Add this to your `~/.zshrc` to make it persistent, or use the runtime toggle:

```bash
toggle_verbose  # Enable/disable verbose output
```

## 🔧 Detailed Command Usage

### Interactive Checkout (`checkout_all`)

```bash
checkout_all
# Prompts:
# 1. Enter branch name
# 2. Choose scope: base, submodules, both, or both with stash handling
```

**Features:**
- ✅ Automatic stash handling for uncommitted changes
- ✅ Smart upstream tracking and pulling
- ✅ Validation before operations
- ✅ Graceful error handling

### Smart Merge (`merge_all`) 

```bash
merge_all
# Prompts:
# 1. Enter base branch to merge from
# 2. Choose merge scope and stash handling
# 3. Select specific submodules if needed
```

**Features:**
- 🔄 Flexible submodule selection (frontend/ee, server/ee, or both)
- 💾 Automatic stash management before/after merge
- ⚠️ Clear feedback on merge operations
- 🛡️ Pre-merge validation and fetching

### Interactive Branch Creation

```bash
start_feature
# Creates feature/branch-name with guided selection:
# 1. Base repository only
# 2. Submodules only  
# 3. Specific folders (custom paths)
# 4. All repositories
```

## 🛡️ Safety Features

### Input Validation
- **Branch name validation** - Ensures valid Git branch names
- **Directory validation** - Confirms paths exist before operations
- **Git repository validation** - Checks for valid Git repositories
- **Error recovery** - Graceful handling of failures

### Smart Stash Management
- **Automatic detection** - Only stashes when there are changes
- **Branch-specific stashing** - Uses descriptive stash messages
- **Intelligent recovery** - Applies correct stash after operations
- **Clean handling** - No orphaned stashes

## 📊 Status and Monitoring

### Plugin Status
```bash
git_submodules_status
# Shows:
# - Plugin directory and configuration
# - Repository validation status
# - Discovered submodules list
# - Current verbose mode setting
```

### Repository Status  
```bash
status_all
# Enhanced output with:
# - Base repository status with branch info
# - Individual submodule status sections
# - Clean, formatted display
```

## 🔄 Auto-Update

The plugin can update itself:

```bash
update_git_submodules_plugin
# Features:
# - Checks for new versions from main branch
# - Interactive update confirmation
# - Automatic Zsh reload option
# - Error handling with rollback
```

## 🚨 Troubleshooting

### Common Issues

**"Not a git repository" error:**
```bash
# Ensure you're in the base repository
cd /path/to/your/main/repo
git_submodules_status  # Verify repository status
```

**Submodules not detected:**
```bash
# Check if submodules are properly initialized
git submodule status
git submodule update --init --recursive
```

**Branch creation failures:**
```bash
# Enable verbose mode for detailed information
toggle_verbose
start_feature  # Try creating branch with verbose output
```

**Stash conflicts:**
```bash
# Check existing stashes
git stash list
# Apply specific stash manually if needed
git stash pop stash@{0}
```

### Debug Mode

```bash
# Enable comprehensive logging
toggle_verbose
git_submodules_status  # Check plugin status
```

## 🎯 Best Practices

### Recommended Workflow

1. **Start with status check:**
   ```bash
   git_submodules_status
   status_all
   ```

2. **Use interactive commands for complex operations:**
   ```bash
   start_feature     # Interactive branch creation
   checkout_all      # Interactive checkout with stash handling
   merge_all         # Interactive merge with stash support
   ```

3. **Regular maintenance:**
   ```bash
   pull_all                        # Stay synchronized
   update_git_submodules_plugin    # Keep plugin updated
   ```

### Safety Guidelines

- ✅ Always run from the **base repository** (main repo containing submodules)
- ✅ **Commit or stash** changes before major operations
- ✅ **Verify submodule status** before bulk operations
- ✅ Use **interactive commands** for complex workflows
- ✅ **Keep backups** of important work

## 🔒 Security Notes

- All user inputs are **validated and sanitized**
- Commands use **proper parameter handling** to prevent issues
- **Directory validation** prevents path problems
- **Git operations** are executed safely with error handling

## 📄 Plugin Design

This plugin focuses on:
- **Simplicity** - Clean, understandable code
- **Reliability** - Proven functionality that works
- **User Experience** - Interactive prompts and clear feedback
- **Safety** - Input validation and error handling
- **Maintainability** - Easy to understand and extend

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📝 Uninstallation

To remove the plugin:

1. Remove it from your `.zshrc` plugins list:
   ```bash
   plugins=( ... )  # Remove 'git-submodules' from the list
   ```

2. Delete the plugin directory:
   ```bash
   rm -rf ~/.oh-my-zsh/custom/plugins/git-submodules
   ```

3. Reload Zsh:
   ```bash
   source ~/.zshrc
   ```

---

**⚠️ Important Note:** All commands should be executed from the **base repository** (the main Git repository that contains submodules). The plugin automatically detects and works with all submodules in your repository structure.