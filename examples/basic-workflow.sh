#!/bin/bash

#=============================================================================
# Basic Workflow Example
# Demonstrates common daily operations with git-submodules plugin
#=============================================================================

echo "📚 === Git-Submodules Plugin: Basic Workflow ==="
echo ""

# 1. Check plugin and repository status
echo "1️⃣  Check status"
git_submodules_status
status_all

# 2. Pull latest changes from all repositories
echo ""
echo "2️⃣  Pull latest changes"
pull_all

# 3. Create a new feature branch
echo ""
echo "3️⃣  Create feature branch"
# Interactive way:
# start_feature

# Programmatic way:
create_feature_all "user-authentication"

# 4. Make changes and stage them
echo ""
echo "4️⃣  Make changes and stage"
# ... edit files ...
add_all

# 5. Commit changes with smart commit
echo ""
echo "5️⃣  Commit changes"
# Interactive smart commit:
# smart_commit_all

# Direct commit:
commit_all "feat: add user authentication system"

# 6. Push changes
echo ""
echo "6️⃣  Push changes"
push_all

# 7. Merge from main branch
echo ""
echo "7️⃣  Merge from main (optional)"
# merge_all  # Interactive

echo ""
echo "✅ Basic workflow complete!"
