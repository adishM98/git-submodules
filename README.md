# Git Submodules - Oh My Zsh Plugin

A clean and powerful Oh My Zsh plugin for managing Git repositories with submodules. This plugin provides essential utilities with an interactive, emoji-rich interface while maintaining simplicity and reliability.

## ✨ Features

- 🎯 **Simple & Reliable** - Focused on core functionality that works
- 🎨 **Interactive UI** - Beautiful emoji-rich interface with numbered options
- 🔄 **Smart Workflows** - User-friendly prompts for complex operations
- 📊 **Visual Feedback** - Clear, contextual emoji messages and progress indicators
- 🛡️ **Safe Operations** - Input validation and proper error handling
- 🔧 **Stash Management** - Automatic stash handling for checkout and merge operations
- ⚙️ **Auto-Update** - Self-updating capability with interactive prompts
- 🔊 **Verbose Control** - Toggle detailed logging on/off with `toggle_verbose`

### NEW in v2.1: CLI Friendliness Enhancements 🚀

- 🎨 **Theme System** - 4 display modes (emoji, ansi, plain, minimal) for different terminals
- 💡 **Enhanced Help** - Comprehensive help system with tutorials, workflows, and command discovery
- ⌨️ **Command Aliases** - 20+ built-in shortcuts + custom alias system
- ✅ **Better Errors** - Contextual error messages with recovery suggestions and validation
- 📚 **Interactive Tutorial** - Built-in beginner's guide and workflow patterns
- 🔍 **Command Discovery** - Search and list commands with `list_commands` and `search_commands`
- ⚡ **Tab Completion** - Intelligent auto-completion for commands, themes, and help topics
- 🆘 **--help Flags** - Quick help available on any command with `--help` or `-h`

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

### Smart Features

| Command | Description | Purpose |
|---------|-------------|---------|
| `generate_commit_message` | AI-like commit message suggestions | Smart conventional commits |
| `smart_commit_all` | Complete smart commit workflow | Automated commit with analysis |
| `resolve_submodule_conflicts` | Interactive submodule conflict resolution | Fix merge conflicts easily |

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
# Interactive prompts with emoji interface:
# 🌿 Enter the branch name to checkout: feature-branch
# 
# 🎯 Where do you want to checkout the 'feature-branch' branch?
# 1️⃣  🏠 Base repository
# 2️⃣  📦 Submodule repositories  
# 3️⃣  🌍 Both (Base + Submodules)
# 4️⃣  🌍💾 Both (Base + Submodules) with Stash Handling
# 🤔 Enter your choice (1/2/3/4): 4
```

**Features:**
- ✅ Automatic stash handling for uncommitted changes
- ✅ Smart upstream tracking and pulling
- ✅ Visual progress indicators with emojis
- ✅ Graceful error handling

### Smart Merge (`merge_all`) 

```bash
merge_all
# Interactive prompts with visual interface:
# 🌳 Enter the base branch to merge from: main
#
# 🎯 Where do you want to merge 'main' into 'feature-branch'?
# 1️⃣  🏠 Base repository
# 2️⃣  📦 Submodule repositories
# 3️⃣  🌍 Both (Base + Submodules)
# 4️⃣  🌍💾 Both (Base + Submodules) with Stash Handling
# 🤔 Enter your choice (1/2/3/4): 2
#
# 📦 Which submodule(s) do you want to merge into?
# 1️⃣  🔹 frontend/ee
# 2️⃣  🔹 server/ee  
# 3️⃣  🌍 Both
# 🤔 Enter your choice (1/2/3): 3
```

**Features:**
- 🔄 Flexible submodule selection with visual indicators
- 💾 Automatic stash management before/after merge
- 📊 Real-time progress feedback with emojis
- 🛡️ Pre-merge validation and fetching

### Interactive Branch Creation

```bash
start_feature
# Interactive branch creation with visual prompts:
# 🌿 Enter feature branch name: user-authentication
#
# 🎯 Where do you want to create the 'user-authentication' branch?
# 1️⃣  🏠 Base repository
# 2️⃣  📦 Submodule repositories
# 3️⃣  📁 Specific folders  
# 4️⃣  🌍 All (Base + Submodules)
# 🤔 Enter your choice (1/2/3/4): 4
#
# ℹ️  🌍 Creating branch 'user-authentication' in base repository and submodules...
# ✅ 🎉 Branch 'user-authentication' created successfully!
```

### Smart Commit Generation

```bash
smart_commit_all
# AI-like commit message generation:
# 🧠 === Smart Commit Workflow === 🧠
# ℹ️  Found staged changes in base repository
# 
# 🤖 === Smart Commit Message Generator === 🤖
# 📂 Files changed: 3
# 
# 💡 Suggested commit messages:
# 1️⃣  feat(frontend): add new functionality
# 2️⃣  feat(frontend): auth-component
# 
# 📜 Recent commit patterns:
#    🔸 fix: resolve login bug
#    🔸 feat: add user dashboard
# 
# 🎯 File summary:
#    ✅ Added: 1 files
#    🔄 Modified: 2 files
# 
# 📝 Choose an option:
# 1️⃣  Use suggested message #1
# 2️⃣  Use suggested message #2  
# 3️⃣  📝 Write custom message
# 4️⃣  🔍 Show detailed diff first
# 5️⃣  🚫 Cancel
# 🤔 Enter your choice (1/2/3/4/5): 1
#
# 📝 Using: feat(frontend): add new functionality
# 🚀 Proceeding with commit...
```

**Features:**
- 🤖 **Automatic Analysis** - Detects file types and suggests appropriate commit types
- 📋 **Conventional Commits** - Follows standard commit message format
- 🎯 **Smart Scoping** - Auto-detects scope based on directory structure  
- 📜 **Pattern Learning** - Shows recent commits to maintain consistency
- 📊 **File Summary** - Clear overview of added/modified/deleted files

### Submodule Conflict Resolution

```bash
resolve_submodule_conflicts
# Specialized submodule conflict assistant:
# 🔧 === Submodule Conflict Resolution Assistant === 🔧
# 
# 📊 Conflict Analysis:
#    🏗️  Submodule conflicts: 2
#    📄 Regular file conflicts: 0
# 
# 🎯 Submodule Conflicts Found:
#    1️⃣  📦 frontend/ee
#       🔄 Current (HEAD): a1b2c3d4
#       🔄 Incoming: e5f6g7h8
#    2️⃣  📦 server/ee  
#       🔄 Current (HEAD): x1y2z3a4
#       🔄 Incoming: b5c6d7e8
# 
# 🛠️  Resolution Options:
# 1️⃣  📋 Show detailed conflict info for each submodule
# 2️⃣  👈 Keep current version (HEAD) for all submodules
# 3️⃣  👉 Accept incoming version (MERGE_HEAD) for all submodules
# 4️⃣  🎯 Resolve each submodule individually
# 5️⃣  🔍 Update submodules to latest commits
# 6️⃣  🚫 Abort merge
# 🤔 Enter your choice (1/2/3/4/5/6): 4
```

**Features:**
- 🎯 **Submodule-Specific** - Focuses specifically on submodule conflicts
- 📊 **Smart Analysis** - Distinguishes between submodule and file conflicts
- 🔍 **Detailed Info** - Shows commit hashes and messages for each conflict
- 🎨 **Multiple Strategies** - Batch resolution or individual handling
- 🔄 **Latest Updates** - Option to update to newest commits

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
# Visual status display:
# 🔧 === Git Submodules Plugin Status === 🔧
# 📂 Plugin Directory: /path/to/plugin
# 🔊 Verbose Mode: true
# 🏠 Current Repository: ✅ Valid Git Repository
# 📦 Submodules Found: 2
#   🔸 frontend/ee
#   🔸 server/ee
```

### Repository Status  
```bash
status_all
# Visual status output:
# 🏠 === Base Repository Status ===
# ## main...origin/main
#  M src/app.js
#
# 📦 === Submodule Status ===
# 🔸 === frontend/ee ===  
# ## feature-branch
#  M components/Auth.jsx
#
# 🔸 === server/ee ===
# ## feature-branch
# ?? new-endpoint.js
```

## 🔄 Auto-Update

The plugin can update itself:

```bash
update_git_submodules_plugin
# Interactive update experience:
# 🔍 Checking for updates for git-submodules plugin...
# ✨ A new update is available for git-submodules plugin.
# 🤔 Do you want to update? (y/N): y
# ⬇️  Updating git-submodules plugin...
# ✅ 🎉 Update complete!
# 🔄 Would you like to reload Zsh now? (y/N): y
# 🔄 Reloading Zsh...
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

## ⚙️ Configuration & Themes (v2.1+)

The plugin now supports customizable themes and configuration!

### Environment Variables

```bash
export GIT_SUBMODULES_THEME="emoji"      # emoji, ansi, plain, minimal
export GIT_SUBMODULES_VERBOSE="true"     # true, false
export GIT_SUBMODULES_COLOR="auto"       # auto, always, never
```

### Change Theme

```bash
set_theme ansi           # ANSI colors with ASCII icons
set_theme plain          # Plain text (accessibility mode)
set_theme minimal        # Ultra-minimal output
set_theme emoji          # Rich emoji icons (default)
```

### Configuration Wizard

```bash
configure_git_submodules    # Interactive configuration wizard
show_config                 # View current settings
```

## 📖 Getting Help

The plugin includes a comprehensive help system:

```bash
help                     # Show all commands
help tutorial            # Beginner's step-by-step guide
help workflows           # Common workflow patterns
help <command>           # Detailed command help
<command> --help         # Quick help for any command

# Discovery
list_commands            # List all commands by category
search_commands commit   # Search commands by keyword
```

## 🔤 Aliases & Shortcuts

### Built-in Aliases

```bash
# Core operations
pall        # pull_all
phall       # push_all
aall        # add_all
call        # commit_all
sall        # status_all

# Interactive workflows
gfeat       # start_feature
gfix        # start_hotfix
grel        # start_release

# Smart features
scommit     # smart_commit_all
fixsub      # resolve_submodule_conflicts

# Utility
gsmstatus   # git_submodules_status
gsmhelp     # help
gsmtheme    # set_theme
```

### Custom Aliases

```bash
add_alias mywork "start_feature && echo 'Ready!'"
list_aliases
remove_alias mywork
```

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