#!/bin/bash

#=============================================================================
# Emergency Recovery Example
# Demonstrates using checkpoints, undo, and recovery features
#=============================================================================

echo "🚨 === Git-Submodules Plugin: Emergency Recovery ==="
echo ""

#=============================================================================
# Scenario 1: Undo Accidental Commit
#=============================================================================

echo "📋 Scenario 1: Undo Accidental Commit"
echo ""

# Oops! Made a wrong commit
# commit_all "wrong message"

# View recent operations
echo "1️⃣  View recent operations:"
git_submodules_history 5

# Undo the last commit
echo ""
echo "2️⃣  Undo the accidental commit:"
git_submodules_undo 1

# Verify it's undone
echo ""
echo "3️⃣  Verify undo:"
status_all

echo ""
echo "✅ Commit undone - changes are back in staging area"
echo ""

#=============================================================================
# Scenario 2: Rollback Failed Merge
#=============================================================================

echo "📋 Scenario 2: Rollback Failed Merge"
echo ""

# Create checkpoint before risky merge
echo "1️⃣  Create checkpoint before merge:"
git_submodules_checkpoint "before-merge-main"

# Attempt merge
echo ""
echo "2️⃣  Attempt merge:"
# merge_all
# ... merge conflicts occur ...

# List checkpoints
echo ""
echo "3️⃣  List available checkpoints:"
git_submodules_checkpoints

# Restore from checkpoint
echo ""
echo "4️⃣  Restore from checkpoint:"
git_submodules_restore "before-merge-main"

echo ""
echo "✅ Merge rolled back - repository restored to pre-merge state"
echo ""

#=============================================================================
# Scenario 3: Atomic Operation Failure Recovery
#=============================================================================

echo "📋 Scenario 3: Atomic Operation Failure Recovery"
echo ""

echo "1️⃣  Attempt atomic commit (some repos might fail):"
# This automatically creates a checkpoint and rolls back on failure
if ! atomic_commit_all "feat: experimental feature"; then
    echo ""
    echo "❌ Atomic commit failed"
    echo "✅ All changes automatically rolled back"
    echo ""
    echo "Current state:"
    status_all
fi

echo ""
echo "✅ No manual recovery needed - atomic operations handle it automatically"
echo ""

#=============================================================================
# Scenario 4: Complex Checkpoint Management
#=============================================================================

echo "📋 Scenario 4: Complex Checkpoint Management"
echo ""

# Create multiple checkpoints at key points
echo "1️⃣  Create checkpoints at key points:"

git_submodules_checkpoint "before-refactor-auth"
echo "  ✅ Checkpoint: before-refactor-auth"

# ... work on auth refactor ...
# commit_all "wip: auth refactor part 1"

git_submodules_checkpoint "auth-refactor-halfway"
echo "  ✅ Checkpoint: auth-refactor-halfway"

# ... continue work ...
# commit_all "wip: auth refactor part 2"

git_submodules_checkpoint "auth-refactor-complete"
echo "  ✅ Checkpoint: auth-refactor-complete"

# List all checkpoints
echo ""
echo "2️⃣  List all checkpoints:"
git_submodules_checkpoints

# Restore to specific checkpoint
echo ""
echo "3️⃣  Restore to specific checkpoint:"
echo "   To restore: git_submodules_restore <checkpoint-id>"

echo ""
echo "✅ Multiple restore points available"
echo ""

#=============================================================================
# Scenario 5: Emergency Full Repository Reset
#=============================================================================

echo "📋 Scenario 5: Emergency Full Repository Reset"
echo ""

echo "⚠️  WARNING: This is a destructive operation!"
echo ""
echo "If you need to reset everything to last commit:"
echo ""
echo "  Base repository:"
echo "    git reset --hard HEAD"
echo "    git clean -fd"
echo ""
echo "  All submodules:"
echo "    git submodule foreach --recursive 'git reset --hard HEAD && git clean -fd'"
echo ""
echo "Or use a checkpoint from before the mess:"
echo "  git_submodules_checkpoints"
echo "  git_submodules_restore <checkpoint-id>"
echo ""

#=============================================================================
# Recovery Best Practices
#=============================================================================

cat << 'EOF'

📚 === Recovery Best Practices ===

1️⃣  Create Checkpoints Proactively
   ✅ Before major refactors
   ✅ Before complex merges
   ✅ Before experimental changes
   ✅ Before mass operations

2️⃣  Use Atomic Operations
   ✅ automatic_commit_all - auto-rollback on failure
   ✅ atomic_merge_all - all-or-nothing merge
   ✅ atomic_checkout_all - consistent state

3️⃣  Leverage Operation History
   ✅ Review history: git_submodules_history
   ✅ Undo last operation: git_submodules_undo 1
   ✅ Track what went wrong

4️⃣  Preview with Dry-Run
   ✅ Always test first: --dry-run
   ✅ commit_all --dry-run "message"
   ✅ merge_all --dry-run

5️⃣  Regular Checkpoints
   ✅ Before each major task
   ✅ After successful milestones
   ✅ At end of day

6️⃣  Cleanup Old Checkpoints
   ✅ List: git_submodules_checkpoints
   ✅ Remove manually from: ~/.local/share/git-submodules/checkpoints/
   ✅ Keep last 5-10 checkpoints

🚨 Emergency Commands Quick Reference:

   View history:           git_submodules_history
   Undo last operation:    git_submodules_undo 1
   List checkpoints:       git_submodules_checkpoints
   Restore checkpoint:     git_submodules_restore <id>
   Create checkpoint:      git_submodules_checkpoint <name>

EOF

echo ""
echo "✅ Emergency recovery guide complete!"
