#!/bin/bash

#=============================================================================
# CI/CD Integration Example
# Demonstrates using git-submodules plugin in automated pipelines
#=============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

echo "🤖 === Git-Submodules Plugin: CI/CD Integration ==="
echo ""

#=============================================================================
# 1. Check Repository Status (JSON Output)
#=============================================================================

echo "1️⃣  Checking repository status..."

# Get status as JSON
STATUS_JSON=$(status_all --json)

# Parse with jq
BASE_AHEAD=$(echo "$STATUS_JSON" | jq -r '.base.ahead')
BASE_BEHIND=$(echo "$STATUS_JSON" | jq -r '.base.behind')
BASE_STATUS=$(echo "$STATUS_JSON" | jq -r '.base.status')

echo "Base repository: $BASE_AHEAD ahead, $BASE_BEHIND behind"

# Fail if uncommitted changes
if [[ -n "$BASE_STATUS" ]]; then
    echo "❌ Error: Uncommitted changes detected"
    echo "$BASE_STATUS"
    exit 1
fi

#=============================================================================
# 2. Validate All Submodules
#=============================================================================

echo ""
echo "2️⃣  Validating submodules..."

# Get submodule list
SUBMODULES=$(git_submodules_list --json | jq -r '.submodules[].path')

# Check each submodule
for submodule in $SUBMODULES; do
    echo "  Checking $submodule..."

    # Get submodule status
    SUB_STATUS=$(echo "$STATUS_JSON" | jq -r ".submodules[] | select(.path == \"$submodule\") | .status")

    if [[ -n "$SUB_STATUS" ]]; then
        echo "  ❌ Error: Uncommitted changes in $submodule"
        exit 1
    fi
done

echo "  ✅ All submodules clean"

#=============================================================================
# 3. Pull Latest Changes (Quiet Mode)
#=============================================================================

echo ""
echo "3️⃣  Pulling latest changes..."

# Parallel pull with quiet output
pull_all --parallel --quiet --jobs=8

#=============================================================================
# 4. Run Tests (Example)
#=============================================================================

echo ""
echo "4️⃣  Running tests..."

# Run tests in base repo
# npm test || exit 1

# Run tests in submodules
# for submodule in $SUBMODULES; do
#     echo "  Testing $submodule..."
#     (cd "$submodule" && npm test) || exit 1
# done

echo "  ✅ All tests passed"

#=============================================================================
# 5. Build (Example)
#=============================================================================

echo ""
echo "5️⃣  Building..."

# Build base repo
# npm run build || exit 1

# Build submodules
# for submodule in $SUBMODULES; do
#     echo "  Building $submodule..."
#     (cd "$submodule" && npm run build) || exit 1
# done

echo "  ✅ Build successful"

#=============================================================================
# 6. Deploy (Example with Atomic Operations)
#=============================================================================

echo ""
echo "6️⃣  Deploying..."

# Use atomic commit for deployment
# Ensures all repos are tagged consistently or none are
if atomic_commit_all "chore: release v1.2.3"; then
    echo "  ✅ Deployment commit successful"

    # Create release tag atomically
    create_tag_all "v1.2.3"

    # Push atomically
    push_all --quiet --yes

    echo "  ✅ Deployment complete"
else
    echo "  ❌ Deployment failed - rolled back"
    exit 1
fi

#=============================================================================
# 7. Record Deployment in History
#=============================================================================

echo ""
echo "7️⃣  Recording deployment..."

# History is automatically recorded by atomic_commit_all
git_submodules_history 5

echo ""
echo "✅ CI/CD pipeline complete!"

#=============================================================================
# Example GitHub Actions Workflow
#=============================================================================

cat << 'EOF'

📝 Example GitHub Actions workflow:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
        with:
          submodules: recursive

      - name: Setup git-submodules plugin
        run: |
          git clone https://github.com/adishM98/git-submodules.git
          source git-submodules/git-submodules.plugin.zsh

      - name: Check status
        run: |
          status_all --json > status.json
          cat status.json | jq .

      - name: Pull latest
        run: pull_all --parallel --quiet --jobs=8

      - name: Run tests
        run: |
          npm test
          # Test submodules

      - name: Build
        run: npm run build

      - name: Deploy (on main branch only)
        if: github.ref == 'refs/heads/main'
        run: |
          atomic_commit_all "chore: release ${{ github.sha }}"
          create_tag_all "${{ github.sha }}"
          push_all --quiet --yes
```

EOF
