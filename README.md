# Git Submodules - Enhanced Oh My Zsh Plugin

A robust and feature-rich Oh My Zsh plugin that provides powerful utilities for managing Git repositories with submodules. This enhanced version includes improved error handling, security features, and better user experience.

## ✨ Features

- 🛡️ **Robust Error Handling** - Comprehensive validation and safe operations
- 🔒 **Security Enhanced** - Input sanitization and secure command execution  
- 🎯 **Smart Submodule Detection** - Automatically discovers all submodules
- 🔄 **Dry Run Mode** - Preview operations before execution
- 📊 **Enhanced Logging** - Clear, emoji-based status messages
- ⚙️ **Configurable** - Environment variables for customization
- 🔧 **Interactive Operations** - User-friendly prompts and selections

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
   source /path/to/git-submodules/git-submodules-improved.plugin.zsh
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

# Enable dry-run mode to preview operations
toggle_dry_run
```

## 📋 Available Commands

### Core Git Operations

| Command | Description | Example |
|---------|-------------|---------|
| `pull_all` | Pull changes for main repo and all submodules | `pull_all` |
| `push_all` | Push changes across all repositories | `push_all` |
| `add_all` | Stage changes in main repo and submodules | `add_all` |
| `commit_all "<message>"` | Commit changes across all repositories | `commit_all "Fix bug in authentication"` |
| `status_all` | Show Git status for all repositories | `status_all` |

### Branch Management

| Command | Description | Example |
|---------|-------------|---------|
| `checkout_all` | Interactive checkout with stash support | `checkout_all` |
| `create_branch_all <name>` | Create branch in all repositories | `create_branch_all my-feature` |
| `create_feature_all <name>` | Create `feature/` prefixed branch | `create_feature_all user-auth` |
| `create_hotfix_all <name>` | Create `hot-fix/` prefixed branch | `create_hotfix_all critical-bug` |
| `create_release_all <name>` | Create `release/` prefixed branch | `create_release_all v2.1.0` |
| `create_sprint_all <name>` | Create `sprint/` prefixed branch | `create_sprint_all sprint-23` |

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
| `toggle_dry_run` | Enable/disable dry-run mode | Safe testing |
| `toggle_verbose` | Control output verbosity | Customize logging |
| `update_git_submodules_plugin` | Update plugin to latest version | Auto-update |

## ⚙️ Configuration

The plugin supports several environment variables for customization:

### Environment Variables

```bash
# Enable dry-run mode (preview operations without executing)
export GIT_SUBMODULES_DRY_RUN=true

# Control output verbosity (true/false)
export GIT_SUBMODULES_VERBOSE=true

# Set default submodules (space-separated list)
export GIT_SUBMODULES_DEFAULT_SUBMODULES="frontend/ee server/ee mobile/app"
```

Add these to your `~/.zshrc` or shell profile to make them persistent.

### Runtime Configuration

```bash
# Toggle modes during usage
toggle_dry_run      # Enable/disable dry-run mode
toggle_verbose      # Enable/disable verbose output
```

## 🔧 Detailed Command Usage

### Interactive Checkout (`checkout_all`)

```bash
checkout_all
# Prompts:
# 1. Enter branch name
# 2. Choose scope: base, submodules, both, or both with stash
```

**Features:**
- ✅ Automatic stash handling for uncommitted changes
- ✅ Smart upstream tracking
- ✅ Validation before operations
- ✅ Rollback on failures

### Smart Merge (`merge_all`) 

```bash
merge_all
# Prompts:
# 1. Enter base branch to merge from
# 2. Choose merge scope and stash handling
```

**Enhanced Features:**
- 🔄 Dynamic submodule detection and selection
- 💾 Automatic stash management
- ⚠️ Conflict detection and user guidance
- 🛡️ Pre-merge validation

### Interactive Branch Creation

```bash
start_feature
# Creates feature/branch-name with guided selection:
# 1. Base repository only
# 2. Submodules only  
# 3. Specific folders
# 4. All repositories
```

## 🛡️ Safety Features

### Input Validation
- **Branch name validation** - Prevents invalid characters
- **Directory validation** - Ensures paths exist before operations
- **Git repository validation** - Confirms valid Git repos
- **Command sanitization** - Prevents injection attacks

### Error Handling
- **Graceful failures** - No shell exits, proper return codes
- **Detailed error messages** - Clear explanations and suggestions
- **Operation rollback** - Undo partial operations on failures
- **Safe directory changes** - Automatic cleanup and restoration

### Dry Run Mode
```bash
# Preview operations without executing
toggle_dry_run
pull_all  # Shows what would be done
toggle_dry_run  # Disable to execute normally
```

## 📊 Status and Monitoring

### Plugin Status
```bash
git_submodules_status
# Shows:
# - Plugin configuration
# - Repository validation
# - Discovered submodules
# - Current modes (dry-run, verbose)
```

### Repository Status  
```bash
status_all
# Enhanced output with:
# - Formatted section headers
# - Branch information
# - Clean status indicators
```

## 🔄 Auto-Update

The plugin can update itself automatically:

```bash
update_git_submodules_plugin
# Features:
# - Checks for new versions
# - Interactive update confirmation
# - Automatic Zsh reload option
# - Rollback on update failures
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
# Enable verbose mode for detailed error information
toggle_verbose
create_branch_all my-branch
```

**Stash conflicts:**
```bash
# Manually resolve stash conflicts
git stash list
git stash pop stash@{0}  # Apply specific stash
```

### Debug Mode

```bash
# Enable comprehensive logging
export GIT_SUBMODULES_VERBOSE=true
toggle_dry_run  # Preview operations
git_submodules_status  # Check configuration
```

## 🎯 Best Practices

### Recommended Workflow

1. **Start with status check:**
   ```bash
   git_submodules_status
   status_all
   ```

2. **Use dry-run for complex operations:**
   ```bash
   toggle_dry_run
   merge_all  # Preview the merge
   toggle_dry_run  # Execute when ready
   ```

3. **Interactive commands for flexibility:**
   ```bash
   start_feature  # Interactive branch creation
   checkout_all   # Interactive checkout with stash
   ```

4. **Regular updates:**
   ```bash
   pull_all  # Stay synchronized
   update_git_submodules_plugin  # Keep plugin updated
   ```

### Safety Guidelines

- ✅ Always run from the **base repository** (main repo containing submodules)
- ✅ Use **dry-run mode** for testing complex operations
- ✅ **Commit or stash** changes before major operations
- ✅ **Verify submodule status** before bulk operations
- ✅ **Keep backups** of important work

## 🔒 Security Notes

- All user inputs are **validated and sanitized**
- Commands use **proper quoting** to prevent injection
- **Directory validation** prevents path traversal
- **Git operations** are executed safely with error handling

## 🆚 Legacy Compatibility  

The enhanced version maintains **100% backward compatibility** with the original plugin while adding:

- Enhanced error handling and validation
- Security improvements
- Better user experience
- Additional utility functions
- Configurable behavior

Existing scripts and workflows will continue to work unchanged.

## 📄 Version Information

- **Enhanced Version**: Includes all improvements and new features
- **Original Version**: Available as `git-submodules.plugin.zsh`
- **Recommended**: Use enhanced version for new installations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 🙏 Acknowledgments

- Original inspiration from Git submodule workflows
- Oh My Zsh plugin architecture
- Community feedback and contributions

---

**⚠️ Important Note:** All commands should be executed from the **base repository** (the main Git repository that contains submodules). The plugin automatically detects and works with all submodules in your repository structure.

### Uninstallation

To remove the plugin, follow these steps:

1. Remove it from your `.zshrc` plugins list:

   ```sh
   plugins=( ... )  # Remove 'git-submodules' from the list
   ```

2. Delete the plugin directory:

   ```sh
   rm -rf ~/.oh-my-zsh/custom/plugins/git-submodules
   ```

3. Reload Zsh:

   ```sh
   source ~/.zshrc
   ```

#### Note:

**⚠️ Important Note:** All commands should be executed from the **base repository** (the main Git repository that contains submodules). The plugin automatically detects and works with all submodules in your repository structure.