#!/bin/bash

#=============================================================================
# Modern Features Example
# Demonstrates v2.0+ features: parallel ops, atomic commits, history, etc.
#=============================================================================

echo "🚀 === Git-Submodules Plugin: Modern Features ==="
echo ""

#=============================================================================
# 1. Configuration
#=============================================================================

echo "1️⃣  Configure plugin interactively"
# configure_git_submodules

# View current configuration
show_git_submodules_config

#=============================================================================
# 2. CLI Flags
#=============================================================================

echo ""
echo "2️⃣  Using CLI flags"

# Dry-run to preview changes
commit_all --dry-run "feat: new feature"

# Parallel pull with verbose output
pull_all --parallel --jobs=8 --verbose

# JSON output for CI/CD
status_all --json > status.json

# Quiet mode for scripting
push_all --quiet --yes

#=============================================================================
# 3. Parallel Operations (3-5x faster)
#=============================================================================

echo ""
echo "3️⃣  Parallel operations"

# Pull all repos in parallel
parallel_pull_all 8

# Push all repos in parallel
parallel_push_all 4

# Fast status check
parallel_status_all

# Benchmark performance
benchmark_parallel_vs_sequential pull

#=============================================================================
# 4. Atomic Operations (All-or-Nothing)
#=============================================================================

echo ""
echo "4️⃣  Atomic operations"

# Atomic commit - rolls back if any repo fails
atomic_commit_all "feat: critical feature"

# Atomic merge - all succeed or all rolled back
atomic_merge_all main

# Atomic checkout - consistent state across all repos
atomic_checkout_all feature-branch

#=============================================================================
# 5. Operation History & Undo
#=============================================================================

echo ""
echo "5️⃣  Operation history"

# View recent operations
git_submodules_history 10

# Undo last operation
git_submodules_undo 1

# Clear history
# git_submodules_clear_history

#=============================================================================
# 6. Checkpoint Management
#=============================================================================

echo ""
echo "6️⃣  Checkpoint management"

# Create checkpoint before risky operation
git_submodules_checkpoint "before-major-refactor"

# ... perform risky changes ...

# List checkpoints
git_submodules_checkpoints

# Restore if something went wrong
# git_submodules_restore "before-major-refactor"

#=============================================================================
# 7. Enhanced Menus
#=============================================================================

echo ""
echo "7️⃣  Enhanced interactive menus"

# Configure menu style
# menu_style options: numbered, arrow, keyboard, both
# Set in config: configure_git_submodules

# Use interactive commands with enhanced menus
# start_feature  # Try arrow navigation!
# checkout_all   # Try keyboard shortcuts!
# merge_all      # Multi-select submodules!

echo ""
echo "✅ Modern features demo complete!"
echo ""
echo "💡 Tips:"
echo "  - Use --dry-run to preview operations"
echo "  - Enable parallel_enabled in config for automatic parallel execution"
echo "  - Set atomic_commits=true for automatic rollback protection"
echo "  - Use JSON output in CI/CD pipelines"
