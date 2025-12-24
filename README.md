# Git Submodules - Oh My Zsh Plugin

A clean and powerful Oh My Zsh plugin for managing Git repositories with submodules. This plugin provides essential utilities with an interactive, emoji-rich interface while maintaining simplicity and reliability.

## ✨ Features

### Core Capabilities
- 🎯 **Simple & Reliable** - Focused on core functionality that works
- 🎨 **Interactive UI** - Beautiful emoji-rich interface with 4 menu modes
- 🔄 **Smart Workflows** - User-friendly prompts for complex operations
- 📊 **Visual Feedback** - 4 progress indicator styles with real-time updates
- 🛡️ **Safe Operations** - Dry-run preview, validation, and error handling
- 🔧 **Stash Management** - Automatic stash handling with timestamp-based naming
- ⚙️ **Auto-Update** - Self-updating capability with interactive prompts
- 🔊 **Verbose Control** - Toggle detailed logging on/off with `toggle_verbose`

### Modern Features (v2.0+)
- 🚀 **Dynamic Detection** - Works on ANY repository (no hardcoded submodule paths!)
- ⚡ **Parallel Operations** - 3-5x faster operations with background execution
- 🎛️ **Configuration System** - 13 customizable settings via interactive wizard
- 🏴 **CLI Flags** - 10 standard flags (--help, --dry-run, --parallel, --json, etc.)
- 📋 **Shell Completion** - Full tab completion for Zsh and Bash
- 🔌 **JSON Output** - CI/CD integration with structured data export
- 🧪 **Dry-Run Mode** - Preview operations before execution
- ⚛️ **Atomic Operations** - All-or-nothing commits with automatic rollback
- 📜 **Operation History** - Track operations with undo capability
- 🎨 **Enhanced Menus** - Arrow navigation, keyboard shortcuts, multi-select
- 📊 **Smart Commit** - 10x faster analysis with single-pass optimization

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

## 🎨 TUI (Terminal User Interface)

An interactive terminal UI for visualizing git status across all submodules. Built with [Ink](https://github.com/vadimdemedes/ink).

### Installation

**Via NPM (Recommended):**
```bash
npm install -g git-submodules-tui
gsm-tui
```

**Via Plugin:**
The TUI is automatically available when you install the git-submodules plugin:
```bash
gsm-tui
```

### Features

- 📊 Visual status dashboard for base repo + all submodules
- 🎨 4 color themes (Dark, Light, Nord, Minimal)
- ⌨️ Vim-style navigation (hjkl/arrows)
- 🔄 Auto-refresh every 2 seconds
- 🎯 Status indicators (clean/dirty/conflicts)
- 📈 Ahead/behind tracking info

### Requirements

- Node.js 14+
- zsh shell

### Usage

```bash
cd /path/to/repo/with/submodules
gsm-tui
```

**Keyboard shortcuts:**
- `↑/k` and `↓/j` - Navigate
- `t` - Cycle themes
- `r` - Refresh
- `h/?` - Help
- `q/Esc` - Quit

See [tui/README.md](tui/README.md) for full documentation.

## 🚀 Quick Start

After installation, you can immediately start using commands like:

```bash
# Check plugin status and current repository
git_submodules_status

# Pull latest changes from all repositories
pull_all

# Pull with modern CLI flags
pull_all --parallel --jobs=8 --verbose

# Preview commit without executing
commit_all --dry-run "feat: new feature"

# Get JSON output for CI/CD
status_all --json | jq .

# Create a feature branch interactively
start_feature

# Configure the plugin interactively
configure_git_submodules

# Control logging verbosity
toggle_verbose
```

## ⚙️ Modern Configuration

### Interactive Setup

The plugin now includes a comprehensive configuration system:

```bash
# Run the interactive configuration wizard
configure_git_submodules

# View current configuration
show_git_submodules_config

# Reset to defaults
reset_git_submodules_config
```

### Configuration File

Settings are stored in `~/.config/git-submodules/config`:

```bash
# Performance
parallel_enabled=false        # Enable parallel operations
parallel_jobs=4               # Number of concurrent jobs

# User Interface
menu_style=numbered           # Menu interaction: numbered, arrow, keyboard, both
progress_style=bar            # Progress style: bar, spinner, dots, percentage
emoji_enabled=true            # Use emoji in output

# Safety
atomic_commits=false          # Enable all-or-nothing commits
dry_run_default=false         # Preview operations by default
confirm_destructive=true      # Confirm dangerous operations

# Caching
cache_enabled=true            # Cache submodule list
cache_ttl=60                  # Cache lifetime in seconds

# Output
verbose_mode=true             # Show detailed output
quiet_mode=false              # Minimal output
auto_stash=true               # Automatically stash/apply changes
```

## 🏴 CLI Flags

All commands now support modern CLI flags for flexibility:

### Standard Flags

```bash
# Help
pull_all --help              # Show command help

# Execution Control
commit_all --dry-run "msg"   # Preview without executing
push_all --force             # Skip confirmations
pull_all --yes               # Auto-confirm all prompts

# Output Control
status_all --quiet           # Minimal output (errors only)
pull_all --verbose           # Detailed output
status_all --json            # JSON format for CI/CD

# Performance
pull_all --parallel          # Use parallel execution
push_all --jobs=8            # Set parallel job count

# Scope Control
commit_all --scope=base "msg"  # Base repository only
push_all --scope=subs          # Submodules only
pull_all --scope=all           # All repositories (default)
```

### Examples

```bash
# Dry-run commit to preview changes
add_all && commit_all --dry-run "feat: add user auth"

# Parallel pull with 8 jobs
pull_all --parallel --jobs=8 --verbose

# JSON status for CI/CD pipeline
status_all --json > status.json

# Quiet push with auto-confirm
push_all --quiet --yes --scope=subs
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

### Atomic Operations (All-or-Nothing)

| Command | Description | Safety |
|---------|-------------|--------|
| `atomic_commit_all "<msg>"` | Atomic commit with rollback on failure | Creates checkpoint, rolls back on error |
| `atomic_merge_all <branch>` | Atomic merge with rollback on failure | All repos succeed or all rolled back |
| `atomic_checkout_all <branch>` | Atomic checkout with rollback | Consistent state across all repos |

### Parallel Operations (3-5x Faster)

| Command | Description | Performance |
|---------|-------------|-------------|
| `parallel_pull_all [jobs]` | Pull all repos in parallel | 3-5x faster than sequential |
| `parallel_push_all [jobs]` | Push all repos in parallel | Background execution |
| `parallel_fetch_all [jobs]` | Fetch all repos in parallel | Configurable job count |
| `parallel_status_all [jobs]` | Status check in parallel | Fast repository overview |

### Operation History & Undo

| Command | Description | Purpose |
|---------|-------------|---------|
| `git_submodules_history [count]` | Show recent operations | View last N operations |
| `git_submodules_undo [entry]` | Undo previous operation | Rollback commits, merges |
| `git_submodules_clear_history` | Clear operation history | Remove all history entries |

### Checkpoint Management

| Command | Description | Use Case |
|---------|-------------|----------|
| `git_submodules_checkpoint [name]` | Create manual checkpoint | Before risky operations |
| `git_submodules_restore [id]` | Restore from checkpoint | Recover from mistakes |
| `git_submodules_checkpoints` | List all checkpoints | View available restore points |

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

## 🎛️ Configuration (Legacy)

The plugin still supports legacy environment variables:

```bash
# Control output verbosity (default: true)
export GIT_SUBMODULES_VERBOSE=true
```

**Note:** For the modern configuration system with 13+ settings, see the [Modern Configuration](#modern-configuration) section above.

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

## 🚀 New Feature Usage Examples

### Atomic Operations

Atomic operations ensure all-or-nothing consistency across repositories:

```bash
# Atomic commit - if ANY repo fails, ALL are rolled back
atomic_commit_all "feat: add user authentication"

# Success output:
# ⚛️  === Atomic Commit (All-or-Nothing) ===
# 📸 Creating checkpoint...
# 💾 Committing base repository...
# 📦 Committing submodules...
# ✅ All repositories committed successfully

# Failure output (automatic rollback):
# ❌ === Atomic Commit Failed ===
#    🏠 Base repository: Failed
#    📦 frontend/ee: Failed
# 🔙 Rolling back all changes...
# ❌ Atomic commit failed and rolled back

# Atomic merge with automatic rollback on conflicts
atomic_merge_all main

# Atomic checkout - all repos switch or none do
atomic_checkout_all feature-branch
```

### Parallel Operations

Execute operations across multiple repos simultaneously:

```bash
# Pull all repos in parallel (3-5x faster)
parallel_pull_all

# Specify number of parallel jobs
parallel_pull_all 8

# Parallel push with 4 concurrent operations
parallel_push_all 4

# Fast status check across all repos
parallel_status_all

# Performance comparison
benchmark_parallel_vs_sequential pull
# Output:
# 📊 === Performance Benchmark: pull ===
# ⏱️  Sequential execution...
# ⚡ Parallel execution...
# 📈 Results:
#    Sequential: 12s
#    Parallel:   3s
#    Speedup:    4.00x faster
```

### Operation History & Undo

Track and undo operations:

```bash
# View recent operations
git_submodules_history

# Output:
# 📜 === Recent Operations (last 10) ===
#   1. [2025-01-15 14:30:00] ✅ commit_all "feat: add auth"
#   2. [2025-01-15 14:25:00] ✅ merge_all main
#   3. [2025-01-15 14:20:00] ✅ checkout_all feature-branch

# Undo last commit
git_submodules_undo 1

# Interactive confirmation:
# ⚠️  Undo Operation
#    Operation: commit_all "feat: add auth"
#    Time: 2025-01-15 14:30:00
#
#    Continue with undo? (y/N): y
#
# 🔙 Undoing last commit...
# ✅ Commit undone in all repositories

# Clear all history
git_submodules_clear_history
```

### Checkpoint Management

Create restore points before risky operations:

```bash
# Create checkpoint before dangerous operation
git_submodules_checkpoint "before-refactor"

# Perform risky changes...
# ... something goes wrong ...

# List available checkpoints
git_submodules_checkpoints

# Output:
# 📋 === Available Checkpoints ===
#   1. [2025-01-15 15:00:00] before-refactor
#   2. [2025-01-15 14:30:00] commit_all

# Restore from checkpoint
git_submodules_restore before-refactor

# Output:
# 🔙 === Restoring Checkpoint: before-refactor ===
# 🏠 Restoring base repository to main @ a1b2c3d
# 📦 Restoring frontend/ee to main @ e5f6g7h
# 📦 Restoring server/ee to main @ x1y2z3a
# ✅ Checkpoint restored successfully
```

### Dry-Run Mode

Preview operations before executing:

```bash
# Preview commit without executing
commit_all --dry-run "feat: add new feature"

# Output:
# 🔍 === DRY-RUN: commit_all ===
# 📋 Preview:
#    Message: "feat: add new feature"
#
# 🏠 Base Repository:
#      🔄 src/auth.js (modified)
#      ✅ src/utils.js (added)
#
# 📦 Submodules:
#      🔸 frontend/ee
#         🔄 components/Login.jsx (modified)
#      🔸 server/ee
#         ✅ routes/auth.js (added)
#
# ℹ️  This is a dry-run. No changes were made.

# Preview merge
merge_all --dry-run

# Preview with verbose output
pull_all --dry-run --verbose
```

### JSON Output for CI/CD

Export structured data for automation:

```bash
# Get status as JSON
status_all --json

# Output:
# {
#   "base": {
#     "branch": "main",
#     "status": "M src/app.js",
#     "ahead": 2,
#     "behind": 0
#   },
#   "submodules": [
#     {
#       "path": "frontend/ee",
#       "branch": "main",
#       "status": "",
#       "ahead": 1,
#       "behind": 0
#     }
#   ]
# }

# Use in CI/CD pipeline
status_all --json | jq '.base.ahead' > commits_ahead.txt

# Check for uncommitted changes in CI
if status_all --json | jq -e '.base.status != ""' > /dev/null; then
  echo "Uncommitted changes detected"
  exit 1
fi

# List submodules as JSON
git_submodules_list --json | jq '.submodules[].path'
```

### Enhanced Interactive Menus

Multiple interaction modes for different preferences:

```bash
# Configure menu style
configure_git_submodules

# Arrow navigation mode
# Use ↑/↓ to navigate, Enter to select

# Keyboard shortcuts mode
# Press letter keys for quick selection

# Combined mode
# Use both arrows and keyboard shortcuts

# Multi-select mode (space to toggle, enter to confirm)
# Select multiple repos/submodules at once
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