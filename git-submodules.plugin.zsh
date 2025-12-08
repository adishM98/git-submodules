#!/bin/zsh

#=============================================================================
# Git Submodules Plugin
# Provides utilities for managing Git repositories with submodules
#=============================================================================

# Global configuration
GIT_SUBMODULES_PLUGIN_DIR="${${(%):-%x}:A:h}"
GIT_SUBMODULES_VERBOSE=${GIT_SUBMODULES_VERBOSE:-true}

#=============================================================================
# Load Modular Components (CLI Enhancements v2.0)
#=============================================================================

# Core modules
source "${GIT_SUBMODULES_PLUGIN_DIR}/lib/core/config.zsh"
source "${GIT_SUBMODULES_PLUGIN_DIR}/lib/core/errors.zsh"

# UI modules
source "${GIT_SUBMODULES_PLUGIN_DIR}/lib/ui/theme.zsh"
source "${GIT_SUBMODULES_PLUGIN_DIR}/lib/ui/logging.zsh"

# Help system modules
source "${GIT_SUBMODULES_PLUGIN_DIR}/lib/help/help.zsh"
source "${GIT_SUBMODULES_PLUGIN_DIR}/lib/help/command-help.zsh"
source "${GIT_SUBMODULES_PLUGIN_DIR}/lib/help/first-run.zsh"
source "${GIT_SUBMODULES_PLUGIN_DIR}/lib/help/discovery.zsh"

# Alias modules
source "${GIT_SUBMODULES_PLUGIN_DIR}/lib/aliases/aliases.zsh"
source "${GIT_SUBMODULES_PLUGIN_DIR}/lib/aliases/custom.zsh"
source "${GIT_SUBMODULES_PLUGIN_DIR}/lib/aliases/completion.zsh"

# Load user configuration and custom aliases
_load_config
_load_custom_aliases

# Optional: Show welcome message on first run (uncomment to enable)
# _check_first_run

#=============================================================================
# Utility Functions
#=============================================================================

# Note: Logging functions now sourced from lib/ui/logging.zsh
# (_log_info, _log_success, _log_warning, _log_error)

# Toggle verbose mode
toggle_verbose() {
    if [[ "$GIT_SUBMODULES_VERBOSE" == "true" ]]; then
        export GIT_SUBMODULES_VERBOSE=false
        echo "🔇 Verbose mode disabled"
    else
        export GIT_SUBMODULES_VERBOSE=true
        _log_success "🔊 Verbose mode enabled"
    fi
}

# Show plugin status
git_submodules_status() {
    echo "\n🔧 === Git Submodules Plugin Status === 🔧"
    echo "📂 Plugin Directory: $GIT_SUBMODULES_PLUGIN_DIR"
    echo "🔊 Verbose Mode: $GIT_SUBMODULES_VERBOSE"
    
    if git rev-parse --git-dir >/dev/null 2>&1; then
        echo "🏠 Current Repository: ✅ Valid Git Repository"
        local submodules
        submodules=($(git submodule status --recursive 2>/dev/null | awk '{print $2}'))
        echo "📦 Submodules Found: ${#submodules[@]}"
        for submodule in "${submodules[@]}"; do
            echo "  🔸 $submodule"
        done
    else
        echo "🏠 Current Repository: ❌ Not a Git Repository"
    fi
    echo
}

#=============================================================================
# Core Git Operations
#=============================================================================

# Checkout all repositories (including submodules)
checkout_interactive() {
    # Check for --help flag
    _with_help "checkout_all" "$@" && return 0

    # Validate git repository
    _validate_git_repo || return $?

    local branch_name scope

    # Prompt for branch name
    echo -n "🌿 Enter the branch name to checkout: "
    read branch_name

    # Validate branch name
    _validate_branch_name "$branch_name" "checkout_interactive" || return $?

    # Get the current branch
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)

    # Prompt for checkout type
    echo "\n🎯 Where do you want to checkout the '$branch_name' branch?"
    echo "1️⃣  🏠 Base repository"
    echo "2️⃣  📦 Submodule repositories"
    echo "3️⃣  🌍 Both (Base + Submodules)"
    echo "4️⃣  🌍💾 Both (Base + Submodules) with Stash Handling"
    echo -n "🤔 Enter your choice (1/2/3/4): "
    read scope

    stash_base_repo() {
        local branch_name="$1"
        if [ -n "$(git status --porcelain)" ]; then
            _log_info "💾 Stashing changes in base repository for branch $branch_name"
            git stash push -m "stash-for-$branch_name"
        else
            _log_info "👤 No changes to stash in base repository"
        fi
    }

    apply_stash_base_repo() {
        local branch_name="$1"
        local stash_entry
        stash_entry=$(git stash list | grep "stash-for-$branch_name" | head -1 | cut -d: -f1)
        if [ -n "$stash_entry" ]; then
            _log_info "🎯 Popping stash $stash_entry in base repository for branch $branch_name"
            git stash pop "$stash_entry"
        else
            _log_info "👤 No stash found for branch $branch_name in base repository"
        fi
    }

    stash_submodule() {
        local submodule_path="$1"
        local branch_name="$2"
        cd "$submodule_path" || exit
        if [ -n "$(git status --porcelain)" ]; then
            _log_info "💾 Stashing changes in $submodule_path for branch $branch_name"
            git stash push -m "stash-for-$branch_name"
        else
            _log_info "👤 No changes to stash in $submodule_path"
        fi
        cd - > /dev/null || exit
    }

    apply_stash() {
        local submodule_path="$1"
        local branch_name="$2"
        cd "$submodule_path" || exit
        local stash_entry
        stash_entry=$(git stash list | grep "stash-for-$branch_name" | head -1 | cut -d: -f1)
        if [ -n "$stash_entry" ]; then
            _log_info "🎯 Popping stash $stash_entry in $submodule_path for branch $branch_name"
            git stash pop "$stash_entry"
        else
            _log_info "👤 No stash found for branch $branch_name in $submodule_path"
        fi
        cd - > /dev/null || exit
    }

    case "$scope" in
        1)
            _log_info "🏠 Checking out branch '$branch_name' in base repository..."
            git checkout "$branch_name" && git pull
            ;;
        2)
            _log_info "📦 Checking out branch '$branch_name' in submodules..."
            git submodule foreach --quiet --recursive "git checkout $branch_name && git pull"
            ;;
        3)
            _log_info "🌍 Checking out branch '$branch_name' in base repository and submodules..."
            git checkout "$branch_name" && git pull
            git submodule foreach --quiet --recursive "git checkout $branch_name && git pull"
            ;;
        4)
            _log_info "💾 Handling stashing before switching..."
            stash_base_repo "$current_branch"
            stash_submodule "frontend/ee" "$current_branch"
            stash_submodule "server/ee" "$current_branch"

            _log_info "🔄 Checking out branch '$branch_name' in base repository and submodules..."
            git checkout --recurse-submodules "$branch_name"

            _log_info "🎯 Applying stash for base repository and submodules..."
            apply_stash_base_repo "$branch_name"
            apply_stash "frontend/ee" "$branch_name"
            apply_stash "server/ee" "$branch_name"
            ;;
        *)
            _log_error "Invalid choice! Please enter 1, 2, 3, or 4."
            return 1
            ;;
    esac

    _log_success "🎉 Checkout of '$branch_name' completed!"
}

# Wrapper function
checkout_all() { checkout_interactive; }

# Pull changes for all repositories (base + submodules)
pull_all() {
    _log_info "📥 Fetching and pulling base repository..."
    git fetch --all

    # Attempt to get the current branch and remote tracking info
    current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    upstream_branch=$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null)

    if [ -z "$upstream_branch" ]; then
        _log_warning "🔗 No upstream tracking branch set for '$current_branch'."
        echo "💡 To fix: git branch --set-upstream-to=origin/<branch> $current_branch"
    else
        _log_info "⬇️  Pulling latest changes from $upstream_branch..."
        git pull
    fi

    _log_info "📦 Pulling changes in submodules..."
    git submodule foreach --quiet --recursive '
        branch=$(git symbolic-ref --short HEAD 2>/dev/null)
        if [ -z "$branch" ]; then
            echo "⚠️  Submodule $(basename $PWD) is in detached HEAD. Skipping..."
        else
            echo "Fetching and pulling branch $branch in $(basename $PWD)..."
            git fetch origin "$branch" 2>/dev/null
            if git ls-remote --exit-code origin "$branch" >/dev/null 2>&1; then
                git pull origin "$branch"
            else
                echo "⚠️  Remote branch $branch not found in $(basename $PWD). Skipping pull."
            fi
        fi
    '
    
    _log_success "🎉 Pull completed for all repositories"
}

# Stage all changes
add_all() {
    _log_info "🏠 Staging changes in base repository..."
    git add -A
    _log_info "📦 Staging changes in submodules..."
    git submodule foreach 'git add -A'
    _log_success "🎉 All changes staged"
}

# Create a new branch across repositories
create_branch_all() {
    # Check for --help flag
    _with_help "create_branch_all" "$@" && return 0

    # Validate git repository
    _validate_git_repo || return $?

    local branch_name="$1"

    # Validate branch name
    _validate_branch_name "$branch_name" "create_branch_all" || return $?
    
    _log_info "🏠 Creating branch '$branch_name' in base repository..."
    git checkout -b "$branch_name" || return 1
    
    _log_info "📦 Creating branch '$branch_name' in submodules..."
    git submodule foreach --quiet --recursive "git checkout -b $branch_name"
    
    _log_success "🌿 Branch '$branch_name' created in all repositories"
}

# Helper function to create prefixed branches
create_prefixed_branch() {
    local prefix="$1"
    local name="$2"
    if [ -z "$name" ]; then
        _log_error "Name required! Usage: create_${prefix}_all <name>"
        return 1
    fi
    local branch="$prefix/$name"
    create_branch_all "$branch"
}

create_feature_all() { create_prefixed_branch "feature" "$1"; }
create_hotfix_all()  { create_prefixed_branch "hotfix" "$1"; }
create_release_all() { create_prefixed_branch "release" "$1"; }
create_revamp_all()  { create_prefixed_branch "revamp" "$1"; }
create_sprint_all()  { create_prefixed_branch "sprint" "$1"; }

# Create a new tag across repositories
create_tag_all() {
    local tag_name="$1"
    if [ -z "$tag_name" ]; then
        _log_error "Tag name required! Usage: create_tag_all <tag_name>"
        return 1
    fi
    
    _log_info "🏷️  Creating and pushing tag '$tag_name' in base repository..."
    git tag "$tag_name" && git push origin "$tag_name" || return 1
    
    _log_info "📦 Creating and pushing tag '$tag_name' in submodules..."
    git submodule foreach --quiet --recursive "git tag $tag_name && git push origin $tag_name"
    
    _log_success "🎉 Tag '$tag_name' created and pushed in all repositories"
}

# Commit all changes with a message
commit_all() {
    # Check for --help flag
    _with_help "commit_all" "$@" && return 0

    # Validate git repository
    _validate_git_repo || return $?

    local message="$1"
    if [ -z "$message" ]; then
        _error_with_help $ERR_INVALID_INPUT "Commit message required" "commit_all <message>"
        return $ERR_INVALID_INPUT
    fi
    
    _log_info "💾 Committing changes in base repository..."
    git commit -m "$message" || return 1
    
    _log_info "📦 Committing changes in submodules..."
    git submodule foreach --quiet --recursive "git commit -m '$message'"
    
    _log_success "🎉 Changes committed in all repositories"
}

# Push all changes (base + submodules), setting upstream if needed
push_all() {
    _log_info "⬆️  Pushing base repository..."
    current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    upstream_branch=$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null)

    if [ -z "$upstream_branch" ]; then
        _log_warning "🔗 No upstream set for '$current_branch'. Setting upstream to origin/$current_branch..."
        git push --set-upstream origin "$current_branch" || return 1
    else
        git push || return 1
    fi

    _log_info "📦 Pushing submodules..."
    git submodule foreach --quiet --recursive '
        branch=$(git symbolic-ref --short HEAD 2>/dev/null)
        if [ -z "$branch" ]; then
            echo "⚠️  Submodule $(basename $PWD) is in detached HEAD. Skipping..."
        else
            upstream=$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null)
            if [ -z "$upstream" ]; then
                echo "⚠️  No upstream for $branch in $(basename $PWD). Setting upstream to origin/$branch..."
                git push --set-upstream origin "$branch"
            else
                echo "Pushing $branch in $(basename $PWD)..."
                git push
            fi
        fi
    '
    
    _log_success "🚀 All repositories pushed successfully"
}

# Show status of all repositories
status_all() {
    echo "\n🏠 === Base Repository Status ==="
    git status --short --branch
    
    echo "\n📦 === Submodule Status ==="
    git submodule foreach --quiet --recursive 'echo "\n🔸 === $(basename $PWD) ==="; git status --short --branch'
    echo
}

#=============================================================================
# Interactive Branch Management
#=============================================================================

create_branch_interactive() {
    local branch_type="$1"
    local branch_name scope
    local -a folder_paths

    # If branch_type is empty (when called from start_branch), skip the type prompt
    if [ -z "$branch_type" ]; then
        echo -n "🌱 Enter branch name: "
    else
        echo -n "🌿 Enter $branch_type branch name: "
    fi
    read branch_name

    if [ -z "$branch_name" ]; then
        _log_error "Branch name is required!"
        return 1
    fi

    # Prompt for scope
    echo "\n🎯 Where do you want to create the '$branch_name' branch?"
    echo "1️⃣  🏠 Base repository"
    echo "2️⃣  📦 Submodule repositories"
    echo "3️⃣  📁 Specific folders"
    echo "4️⃣  🌍 All (Base + Submodules)"
    echo -n "🤔 Enter your choice (1/2/3/4): "
    read scope

    case "$scope" in
        1)
            _log_info "🏠 Creating branch '$branch_name' in base repository..."
            git checkout -b "$branch_name" && git push -u origin "$branch_name"
            ;;
        2)
            _log_info "📦 Creating branch '$branch_name' in submodules..."
            git submodule foreach --quiet --recursive "git checkout -b $branch_name && git push -u origin $branch_name"
            ;;
        3)
            echo -n "📁 Enter folder paths (separated by spaces): "
            read -r folder_input
            folder_paths=(${=folder_input})

            if [ ${#folder_paths[@]} -eq 0 ]; then
                _log_error "No valid folders provided!"
                return 1
            fi

            _log_info "📋 Processing the following folders: ${folder_paths[@]}"
            for folder in "${folder_paths[@]}"; do
                if [ -d "$folder" ]; then
                    _log_info "🔸 Creating branch '$branch_name' in $folder..."
                    (cd "$folder" && git checkout -b "$branch_name")
                else
                    _log_error "Folder '$folder' does not exist. Skipping..."
                fi
            done
            ;;
        4)
            _log_info "🌍 Creating branch '$branch_name' in base repository and submodules..."
            git checkout -b "$branch_name" && git push -u origin "$branch_name" || return 1
            git submodule foreach --quiet --recursive "git checkout -b $branch_name"
            ;;
        *)
            _log_error "Invalid choice! Please enter 1, 2, 3, or 4."
            return 1
            ;;
    esac

    _log_success "🎉 Branch '$branch_name' created successfully!"
}

# Interactive wrapper functions
start_feature() { create_branch_interactive "feature"; }
start_hotfix() { create_branch_interactive "hotfix"; }
start_release() { create_branch_interactive "release"; }
start_sprint() { create_branch_interactive "sprint"; }
start_branch() { create_branch_interactive ""; }

#=============================================================================
# Merge Operations
#=============================================================================

merge_all() {
    # Check for --help flag
    _with_help "merge_all" "$@" && return 0

    # Validate git repository
    _validate_git_repo || return $?

    local base_branch current_branch scope

    echo -n "🌳 Enter the base branch to merge from: "
    read base_branch

    # Validate branch name
    _validate_branch_name "$base_branch" "merge_all" || return $?

    if [ -z "$base_branch" ]; then
        _log_error "Base branch is required!"
        return 1
    fi

    current_branch=$(git rev-parse --abbrev-ref HEAD)

    echo "\n🎯 Where do you want to merge '$base_branch' into '$current_branch'?"
    echo "1️⃣  🏠 Base repository"
    echo "2️⃣  📦 Submodule repositories"
    echo "3️⃣  🌍 Both (Base + Submodules)"
    echo "4️⃣  🌍💾 Both (Base + Submodules) with Stash Handling"
    echo -n "🤔 Enter your choice (1/2/3/4): "
    read scope

    stash_submodule() {
        local submodule_path="$1"
        cd "$submodule_path" || exit
        if [ -n "$(git status --porcelain)" ]; then
            _log_info "Stashing changes in $submodule_path for branch $current_branch"
            git stash push -m "stash-for-$current_branch"
        else
            _log_info "No changes to stash in $submodule_path"
        fi
        cd - > /dev/null || exit
    }

    apply_stash_submodule() {
        local submodule_path="$1"
        cd "$submodule_path" || exit
        local stash_entry
        stash_entry=$(git stash list | grep "stash-for-$current_branch" | head -1 | cut -d: -f1)
        if [ -n "$stash_entry" ]; then
            _log_info "Popping stash $stash_entry in $submodule_path for branch $current_branch"
            git stash pop "$stash_entry"
        else
            _log_info "No stash found for branch $current_branch in $submodule_path"
        fi
        cd - > /dev/null || exit
    }

    stash_base_repo() {
        if [ -n "$(git status --porcelain)" ]; then
            _log_info "Stashing changes in base repository for branch $current_branch"
            git stash push -m "stash-for-$current_branch"
        else
            _log_info "No changes to stash in base repository"
        fi
    }

    apply_stash_base_repo() {
        local stash_entry
        stash_entry=$(git stash list | grep "stash-for-$current_branch" | head -1 | cut -d: -f1)
        if [ -n "$stash_entry" ]; then
            _log_info "Popping stash $stash_entry in base repository for branch $current_branch"
            git stash pop "$stash_entry"
        else
            _log_info "No stash found for branch $current_branch in base repository"
        fi
    }

    git fetch origin "$base_branch"
    case "$scope" in
        1)
            _log_info "🏠 Merging base repository..."
            git merge origin/"$base_branch"
            ;;
        2)
            echo "\n📦 Which submodule(s) do you want to merge into?"
            echo "1️⃣  🔹 frontend/ee"
            echo "2️⃣  🔹 server/ee"
            echo "3️⃣  🌍 Both"
            echo -n "🤔 Enter your choice (1/2/3): "
            read submodule_choice

            case "$submodule_choice" in
                1)
                    _log_info "🔹 Merging into frontend/ee..."
                    (cd frontend/ee && git fetch origin "$base_branch" && git merge origin/"$base_branch")
                    ;;
                2)
                    _log_info "🔹 Merging into server/ee..."
                    (cd server/ee && git fetch origin "$base_branch" && git merge origin/"$base_branch")
                    ;;
                3)
                    _log_info "🔹 Merging into frontend/ee..."
                    (cd frontend/ee && git fetch origin "$base_branch" && git merge origin/"$base_branch")
                    _log_info "🔹 Merging into server/ee..."
                    (cd server/ee && git fetch origin "$base_branch" && git merge origin/"$base_branch")
                    ;;
                *)
                    _log_error "Invalid submodule choice. Please enter 1, 2, or 3."
                    return 1
                    ;;
            esac
            ;;
        3)
            _log_info "🏠 Merging base repository..."
            git merge origin/"$base_branch"
            _log_info "🔹 Merging into frontend/ee..."
            (cd frontend/ee && git fetch origin "$base_branch" && git merge origin/"$base_branch")
            _log_info "🔹 Merging into server/ee..."
            (cd server/ee && git fetch origin "$base_branch" && git merge origin/"$base_branch")
            ;;
        4)
            _log_info "💾 Stashing changes before merge..."
            stash_base_repo
            stash_submodule "frontend/ee"
            stash_submodule "server/ee"

            _log_info "🏠 Merging base repository..."
            git merge origin/"$base_branch"

            _log_info "🔹 Merging into frontend/ee..."
            (cd frontend/ee && git fetch origin "$base_branch" && git merge origin/"$base_branch")

            _log_info "🔹 Merging into server/ee..."
            (cd server/ee && git fetch origin "$base_branch" && git merge origin/"$base_branch")

            _log_info "🎯 Applying stashes after merge..."
            apply_stash_base_repo
            apply_stash_submodule "frontend/ee"
            apply_stash_submodule "server/ee"
            ;;
        *)
            _log_error "Invalid choice! Please enter 1, 2, 3, or 4."
            return 1
            ;;
    esac

    _log_success "🎉 Merge from '$base_branch' completed!"
}

#=============================================================================
# Smart Commit Generation
#=============================================================================

# Analyze actual diff content to understand changes
_analyze_diff_content() {
    local diff_content=$(git diff --cached)
    local added_lines=$(echo "$diff_content" | grep -c "^+[^+]" || echo "0")
    local removed_lines=$(echo "$diff_content" | grep -c "^-[^-]" || echo "0")
    
    # Analyze what types of changes were made
    local has_function_additions=false
    local has_function_modifications=false
    local has_imports=false
    local has_exports=false
    local has_error_handling=false
    local has_logging=false
    local has_tests=false
    local has_comments=false
    local has_configs=false
    local has_dependencies=false
    local has_styling=false
    local has_database=false
    local has_api_endpoints=false
    local has_ui_components=false
    
    # Function-related changes
    if echo "$diff_content" | grep -q "^+.*function\|^+.*def \|^+.*const.*=\|^+.*let.*=\|^+.*var.*=\|^+.*=>\|^+.*func "; then
        has_function_additions=true
    fi
    
    if echo "$diff_content" | grep -q "^-.*function\|^-.*def \|^+.*function\|^+.*def "; then
        has_function_modifications=true
    fi
    
    # Import/Export changes
    if echo "$diff_content" | grep -q "^+.*import\|^+.*require\|^+.*from.*import\|^+.*#include\|^+.*use "; then
        has_imports=true
    fi
    
    if echo "$diff_content" | grep -q "^+.*export\|^+.*module\.exports\|^+.*__all__"; then
        has_exports=true
    fi
    
    # Error handling
    if echo "$diff_content" | grep -q "^+.*try\|^+.*catch\|^+.*except\|^+.*finally\|^+.*throw\|^+.*raise\|^+.*error"; then
        has_error_handling=true
    fi
    
    # Logging
    if echo "$diff_content" | grep -q "^+.*log\|^+.*print\|^+.*console\|^+.*debug\|^+.*info\|^+.*warn\|^+.*error"; then
        has_logging=true
    fi
    
    # Tests
    if echo "$diff_content" | grep -q "^+.*test\|^+.*spec\|^+.*expect\|^+.*assert\|^+.*should\|^+.*describe\|^+.*it("; then
        has_tests=true
    fi
    
    # Comments and documentation
    if echo "$diff_content" | grep -q "^+.*//\|^+.*#\|^+.*/\*\|^+.*\"\"\"\|^+.*'''"; then
        has_comments=true
    fi
    
    # Configuration changes
    if echo "$diff_content" | grep -q "^+.*config\|^+.*settings\|^+.*env\|^+.*\.json\|^+.*\.yaml\|^+.*\.toml"; then
        has_configs=true
    fi
    
    # Dependencies
    if echo "$diff_content" | grep -q "^+.*package\.json\|^+.*requirements\.txt\|^+.*go\.mod\|^+.*Cargo\.toml\|^+.*pom\.xml"; then
        has_dependencies=true
    fi
    
    # Styling
    if echo "$diff_content" | grep -q "^+.*\.css\|^+.*\.scss\|^+.*\.less\|^+.*style\|^+.*className\|^+.*class="; then
        has_styling=true
    fi
    
    # Database
    if echo "$diff_content" | grep -q "^+.*SELECT\|^+.*INSERT\|^+.*UPDATE\|^+.*DELETE\|^+.*CREATE TABLE\|^+.*ALTER TABLE\|^+.*database\|^+.*query"; then
        has_database=true
    fi
    
    # API endpoints
    if echo "$diff_content" | grep -q "^+.*@app\.route\|^+.*@router\|^+.*app\.get\|^+.*app\.post\|^+.*app\.put\|^+.*app\.delete\|^+.*router\.\|^+.*/api/"; then
        has_api_endpoints=true
    fi
    
    # UI components
    if echo "$diff_content" | grep -q "^+.*<\|^+.*React\|^+.*Component\|^+.*render\|^+.*return.*<\|^+.*jsx\|^+.*tsx"; then
        has_ui_components=true
    fi
    
    # Export results
    echo "$added_lines:$removed_lines:$has_function_additions:$has_function_modifications:$has_imports:$has_exports:$has_error_handling:$has_logging:$has_tests:$has_comments:$has_configs:$has_dependencies:$has_styling:$has_database:$has_api_endpoints:$has_ui_components"
}

# Generate meaningful description based on actual changes
_generate_smart_description() {
    local files_changed="$1"
    local files_added="$2" 
    local files_modified="$3"
    local files_deleted="$4"
    local analysis="$5"
    
    # Parse analysis results
    local IFS=':'
    local analysis_array=($analysis)
    local added_lines=${analysis_array[0]}
    local removed_lines=${analysis_array[1]}
    local has_function_additions=${analysis_array[2]}
    local has_function_modifications=${analysis_array[3]}
    local has_imports=${analysis_array[4]}
    local has_exports=${analysis_array[5]}
    local has_error_handling=${analysis_array[6]}
    local has_logging=${analysis_array[7]}
    local has_tests=${analysis_array[8]}
    local has_comments=${analysis_array[9]}
    local has_configs=${analysis_array[10]}
    local has_dependencies=${analysis_array[11]}
    local has_styling=${analysis_array[12]}
    local has_database=${analysis_array[13]}
    local has_api_endpoints=${analysis_array[14]}
    local has_ui_components=${analysis_array[15]}
    
    local commit_type="feat"
    local description=""
    
    # Determine commit type and description based on actual changes
    if [[ "$has_tests" == "true" ]]; then
        commit_type="test"
        if [[ $(echo "$files_added" | wc -l | tr -d ' ') -gt 0 ]]; then
            description="add test coverage for $(echo "$files_added" | head -1 | sed 's|.*/||' | sed 's|\.[^.]*$||')"
        else
            description="update test cases"
        fi
    elif echo "$files_changed" | grep -q -E "README|CHANGELOG|\.md$|docs/"; then
        commit_type="docs"
        if [[ "$has_comments" == "true" ]]; then
            description="improve code documentation and comments"
        else
            description="update documentation"
        fi
    elif [[ "$has_dependencies" == "true" ]] || echo "$files_changed" | grep -q -E "package\.json|requirements\.txt|go\.mod|Cargo\.toml"; then
        commit_type="build"
        if [[ "$added_lines" -gt "$removed_lines" ]]; then
            description="add new dependencies"
        else
            description="update dependencies"
        fi
    elif [[ "$has_configs" == "true" ]] || echo "$files_changed" | grep -q -E "\.config|\.env|settings"; then
        commit_type="config"
        description="update configuration settings"
    elif [[ "$has_styling" == "true" ]]; then
        commit_type="style"
        if [[ $(echo "$files_added" | wc -l | tr -d ' ') -gt 0 ]]; then
            description="add styling for $(echo "$files_changed" | grep -v '\.css$\|\.scss$' | head -1 | sed 's|.*/||' | sed 's|\.[^.]*$||')"
        else
            description="update component styles"
        fi
    elif [[ "$has_api_endpoints" == "true" ]]; then
        commit_type="feat"
        if [[ $(echo "$files_added" | wc -l | tr -d ' ') -gt 0 ]]; then
            description="add API endpoint for $(echo "$files_changed" | head -1 | sed 's|.*/||' | sed 's|\.[^.]*$||')"
        else
            description="update API endpoints"
        fi
    elif [[ "$has_ui_components" == "true" ]]; then
        commit_type="feat" 
        if [[ $(echo "$files_added" | wc -l | tr -d ' ') -gt 0 ]]; then
            local component_name=$(echo "$files_added" | head -1 | sed 's|.*/||' | sed 's|\.[^.]*$||')
            description="add $component_name component"
        else
            description="update UI components"
        fi
    elif [[ "$has_database" == "true" ]]; then
        commit_type="feat"
        description="update database operations"
    elif [[ "$has_error_handling" == "true" ]]; then
        commit_type="fix"
        description="improve error handling"
    elif [[ "$has_function_additions" == "true" ]]; then
        commit_type="feat"
        local main_file=$(echo "$files_changed" | head -1 | sed 's|.*/||' | sed 's|\.[^.]*$||')
        description="add functionality to $main_file"
    elif [[ "$has_function_modifications" == "true" ]]; then
        if echo "$files_changed" | grep -q -E "fix|bug|error" || [[ "$has_error_handling" == "true" ]]; then
            commit_type="fix"
            description="resolve issues in $(echo "$files_changed" | head -1 | sed 's|.*/||' | sed 's|\.[^.]*$||')"
        else
            commit_type="feat" 
            description="enhance $(echo "$files_changed" | head -1 | sed 's|.*/||' | sed 's|\.[^.]*$||') functionality"
        fi
    elif [[ $(echo "$files_deleted" | wc -l | tr -d ' ') -gt 0 ]]; then
        commit_type="refactor"
        description="remove unused $(echo "$files_deleted" | head -1 | sed 's|.*/||')"
    elif [[ "$has_imports" == "true" ]] && [[ "$added_lines" -gt 5 ]]; then
        commit_type="feat"
        description="integrate new functionality"
    else
        # Default based on file changes
        if [[ $(echo "$files_added" | wc -l | tr -d ' ') -gt 0 ]]; then
            commit_type="feat"
            local added_file=$(echo "$files_added" | head -1 | sed 's|.*/||' | sed 's|\.[^.]*$||')
            description="add $added_file"
        elif [[ $(echo "$files_modified" | wc -l | tr -d ' ') -gt 0 ]]; then
            if [[ "$removed_lines" -gt "$added_lines" ]]; then
                commit_type="refactor"
                description="simplify $(echo "$files_modified" | head -1 | sed 's|.*/||' | sed 's|\.[^.]*$||')"
            else
                commit_type="feat"
                description="enhance $(echo "$files_modified" | head -1 | sed 's|.*/||' | sed 's|\.[^.]*$||')"
            fi
        fi
    fi
    
    echo "$commit_type:$description"
}

# Analyze staged changes and suggest conventional commit messages
generate_commit_message() {
    local files_changed=$(git diff --cached --name-only)
    local files_added=$(git diff --cached --name-only --diff-filter=A)
    local files_modified=$(git diff --cached --name-only --diff-filter=M)
    local files_deleted=$(git diff --cached --name-only --diff-filter=D)
    
    if [[ -z "$files_changed" ]]; then
        _log_warning "No staged changes found. Run 'add_all' first."
        return 1
    fi
    
    echo "\n🤖 === Smart Commit Message Generator === 🤖"
    echo "📂 Files changed: $(echo "$files_changed" | wc -l | tr -d ' ')"
    
    # Analyze actual diff content
    _log_info "🔍 Analyzing code changes..."
    local content_analysis=$(_analyze_diff_content)
    local smart_result=$(_generate_smart_description "$files_changed" "$files_added" "$files_modified" "$files_deleted" "$content_analysis")
    
    # Parse smart analysis results
    local IFS=':'
    local smart_array=($smart_result)
    local commit_type=${smart_array[0]}
    local description=${smart_array[1]}
    
    # Determine scope from directory structure
    local scope=""
    local main_dir=$(echo "$files_changed" | head -1 | cut -d'/' -f1)
    case "$main_dir" in
        "frontend"|"client"|"ui"|"web") scope="frontend" ;;
        "backend"|"server"|"api") scope="backend" ;;
        "mobile"|"app"|"ios"|"android") scope="mobile" ;;
        "docs"|"documentation") scope="docs" ;;
        "tests"|"test"|"spec") scope="test" ;;
        *) scope="" ;;
    esac
    
    # Parse content analysis for display
    local IFS=':'
    local analysis_array=($content_analysis)
    local added_lines=${analysis_array[0]}
    local removed_lines=${analysis_array[1]}
    
    # Generate alternative descriptions
    local alt_description="update $(echo "$files_changed" | head -1 | sed 's|.*/||' | sed 's|\.[^.]*$||')"
    if [[ $(echo "$files_added" | wc -l | tr -d ' ') -gt 0 ]]; then
        alt_description="implement $(echo "$files_added" | head -1 | sed 's|.*/||' | sed 's|\.[^.]*$||')"
    fi
    
    # Generate suggestions
    echo "\n💡 Smart commit suggestions (based on code analysis):"
    local base_msg="$commit_type"
    [[ -n "$scope" ]] && base_msg="$commit_type($scope)"
    
    echo "1️⃣  $base_msg: $description"
    echo "2️⃣  $base_msg: $alt_description"
    
    # Show what was actually changed
    echo "\n🔍 Code Analysis:"  
    if [[ "$added_lines" =~ ^[0-9]+$ ]] && [[ "$removed_lines" =~ ^[0-9]+$ ]]; then
        echo "   📊 +$added_lines/-$removed_lines lines"
    else
        echo "   📊 Significant changes detected"
    fi
    
    # Show detected change types
    local change_types=()
    [[ "${analysis_array[2]}" == "true" ]] && change_types+=("new functions")
    [[ "${analysis_array[3]}" == "true" ]] && change_types+=("modified functions")  
    [[ "${analysis_array[4]}" == "true" ]] && change_types+=("imports")
    [[ "${analysis_array[6]}" == "true" ]] && change_types+=("error handling")
    [[ "${analysis_array[7]}" == "true" ]] && change_types+=("logging")
    [[ "${analysis_array[8]}" == "true" ]] && change_types+=("tests")
    [[ "${analysis_array[12]}" == "true" ]] && change_types+=("styling")
    [[ "${analysis_array[13]}" == "true" ]] && change_types+=("database")
    [[ "${analysis_array[14]}" == "true" ]] && change_types+=("API endpoints")
    [[ "${analysis_array[15]}" == "true" ]] && change_types+=("UI components")
    
    if [[ ${#change_types[@]} -gt 0 ]]; then
        echo "   🎯 Detected: ${change_types[*]}"
    fi
    
    # Show recent commits for pattern matching
    echo "\n📜 Recent commit patterns:"
    git log --oneline -3 --pretty=format:"   🔸 %s"
    
    echo "\n🎯 File summary:"
    [[ -n "$files_added" ]] && echo "   ✅ Added: $(echo "$files_added" | wc -l | tr -d ' ') files"
    [[ -n "$files_modified" ]] && echo "   🔄 Modified: $(echo "$files_modified" | wc -l | tr -d ' ') files"  
    [[ -n "$files_deleted" ]] && echo "   🗑️  Deleted: $(echo "$files_deleted" | wc -l | tr -d ' ') files"
    
    echo "\n📝 Choose an option:"
    echo "1️⃣  Use suggested message #1"
    echo "2️⃣  Use suggested message #2"
    echo "3️⃣  📝 Write custom message"
    echo "4️⃣  🔍 Show detailed diff first"
    echo "5️⃣  🚫 Cancel"
    echo -n "🤔 Enter your choice (1/2/3/4/5): "
    
    read choice
    case "$choice" in
        1)
            local msg="$base_msg: $description"
            echo "\n📝 Using: $msg"
            export GIT_SUBMODULES_GENERATED_MSG="$msg"
            return 0
            ;;
        2)
            local file_based=$(echo "$files_changed" | head -1 | sed 's|.*/||' | sed 's|\.[^.]*$||')
            local msg="$base_msg: $file_based"
            echo "\n📝 Using: $msg"
            export GIT_SUBMODULES_GENERATED_MSG="$msg"
            return 0
            ;;
        3)
            echo -n "📝 Enter your commit message: "
            read custom_msg
            if [[ -n "$custom_msg" ]]; then
                echo "\n📝 Using: $custom_msg"
                export GIT_SUBMODULES_GENERATED_MSG="$custom_msg"
                return 0
            else
                _log_error "Empty message provided"
                return 1
            fi
            ;;
        4)
            echo "\n🔍 Showing staged changes:"
            git diff --cached --stat
            echo "\n🔄 Run generate_commit_message again to create commit"
            return 1
            ;;
        5)
            _log_info "Operation cancelled"
            return 1
            ;;
        *)
            _log_error "Invalid choice"
            return 1
            ;;
    esac
}

# Smart commit command that integrates with commit_all
smart_commit_all() {
    echo "\n🧠 === Smart Commit Workflow === 🧠"
    
    # Check if there are any staged changes
    if ! git diff --cached --quiet; then
        _log_info "Found staged changes in base repository"
    else
        _log_info "No staged changes in base repository"
    fi
    
    # Check submodules for staged changes
    local submodules_with_changes=()
    local submodules=($(git submodule status --recursive 2>/dev/null | awk '{print $2}'))
    
    for submodule in "${submodules[@]}"; do
        if [[ -d "$submodule" ]]; then
            if ! (cd "$submodule" && git diff --cached --quiet); then
                submodules_with_changes+=("$submodule")
            fi
        fi
    done
    
    if [[ ${#submodules_with_changes[@]} -gt 0 ]]; then
        _log_info "Submodules with staged changes: ${submodules_with_changes[*]}"
    fi
    
    # Generate smart commit message
    if generate_commit_message; then
        local commit_msg="$GIT_SUBMODULES_GENERATED_MSG"
        if [[ -n "$commit_msg" ]]; then
            echo "\n🚀 Proceeding with commit..."
            commit_all "$commit_msg"
        fi
    fi
}

#=============================================================================
# Submodule Conflict Resolution
#=============================================================================

# Detect and resolve submodule-specific conflicts
resolve_submodule_conflicts() {
    echo "\n🔧 === Submodule Conflict Resolution Assistant === 🔧"
    
    # Check if we're in the middle of a merge
    if [[ ! -f ".git/MERGE_HEAD" ]]; then
        _log_warning "No active merge detected. This tool works during merge conflicts."
        return 1
    fi
    
    # Find conflicted files, focusing on submodules
    local conflicted_files=$(git diff --name-only --diff-filter=U)
    local submodule_conflicts=()
    local regular_conflicts=()
    local submodules=($(git submodule status --recursive 2>/dev/null | awk '{print $2}'))
    
    for file in $conflicted_files; do
        local is_submodule=false
        for submodule in "${submodules[@]}"; do
            if [[ "$file" == "$submodule" ]]; then
                submodule_conflicts+=("$file")
                is_submodule=true
                break
            fi
        done
        [[ "$is_submodule" == "false" ]] && regular_conflicts+=("$file")
    done
    
    echo "📊 Conflict Analysis:"
    echo "   🏗️  Submodule conflicts: ${#submodule_conflicts[@]}"
    echo "   📄 Regular file conflicts: ${#regular_conflicts[@]}"
    
    if [[ ${#submodule_conflicts[@]} -eq 0 ]]; then
        _log_info "No submodule conflicts detected"
        if [[ ${#regular_conflicts[@]} -gt 0 ]]; then
            echo "💡 For regular file conflicts, use your preferred merge tool"
            echo "   Example: git mergetool"
        fi
        return 0
    fi
    
    echo "\n🎯 Submodule Conflicts Found:"
    for i in "${!submodule_conflicts[@]}"; do
        local submodule="${submodule_conflicts[i]}"
        echo "   $((i+1))️⃣  📦 $submodule"
        
        # Show commit information for the conflict
        echo "      🔄 Current (HEAD): $(git ls-tree HEAD $submodule | awk '{print substr($3,1,8)}')"
        echo "      🔄 Incoming: $(git ls-tree MERGE_HEAD $submodule | awk '{print substr($3,1,8)}')"
    done
    
    echo "\n🛠️  Resolution Options:"
    echo "1️⃣  📋 Show detailed conflict info for each submodule"
    echo "2️⃣  👈 Keep current version (HEAD) for all submodules"
    echo "3️⃣  👉 Accept incoming version (MERGE_HEAD) for all submodules"
    echo "4️⃣  🎯 Resolve each submodule individually"
    echo "5️⃣  🔍 Update submodules to latest commits"
    echo "6️⃣  🚫 Abort merge"
    echo -n "🤔 Enter your choice (1/2/3/4/5/6): "
    
    read choice
    case "$choice" in
        1)
            show_submodule_conflict_details "${submodule_conflicts[@]}"
            ;;
        2)
            resolve_all_submodules "current" "${submodule_conflicts[@]}"
            ;;
        3)
            resolve_all_submodules "incoming" "${submodule_conflicts[@]}"
            ;;
        4)
            resolve_submodules_individually "${submodule_conflicts[@]}"
            ;;
        5)
            update_conflicted_submodules "${submodule_conflicts[@]}"
            ;;
        6)
            echo "🚫 Aborting merge..."
            git merge --abort
            _log_success "Merge aborted successfully"
            ;;
        *)
            _log_error "Invalid choice"
            return 1
            ;;
    esac
}

show_submodule_conflict_details() {
    local submodules=("$@")
    
    for submodule in "${submodules[@]}"; do
        echo "\n📦 === $submodule Conflict Details ==="
        
        local current_commit=$(git ls-tree HEAD $submodule | awk '{print $3}')
        local incoming_commit=$(git ls-tree MERGE_HEAD $submodule | awk '{print $3}')
        
        echo "👈 Current (HEAD): $current_commit"
        if [[ -d "$submodule" ]]; then
            echo "   $(cd $submodule && git log --oneline -1 $current_commit 2>/dev/null || echo 'Commit not found locally')"
        fi
        
        echo "👉 Incoming (MERGE_HEAD): $incoming_commit"  
        if [[ -d "$submodule" ]]; then
            echo "   $(cd $submodule && git log --oneline -1 $incoming_commit 2>/dev/null || echo 'Commit not found locally')"
        fi
        
        # Show if one is ahead of the other
        if [[ -d "$submodule" ]]; then
            local ahead_behind=$(cd $submodule && git rev-list --count --left-right $current_commit...$incoming_commit 2>/dev/null)
            if [[ -n "$ahead_behind" ]]; then
                echo "📊 Relationship: $ahead_behind (current ahead, incoming ahead)"
            fi
        fi
    done
    
    echo "\n🔄 Run resolve_submodule_conflicts again to choose resolution"
}

resolve_all_submodules() {
    local choice="$1"
    shift
    local submodules=("$@")
    
    for submodule in "${submodules[@]}"; do
        if [[ "$choice" == "current" ]]; then
            _log_info "👈 Keeping current version of $submodule"
            git add "$submodule"
        else
            _log_info "👉 Accepting incoming version of $submodule"
            local incoming_commit=$(git ls-tree MERGE_HEAD $submodule | awk '{print $3}')
            git update-index --add --cacheinfo 160000 $incoming_commit $submodule
        fi
    done
    
    _log_success "All submodule conflicts resolved"
    echo "💡 Next steps:"
    echo "   1️⃣  Review: git status"
    echo "   2️⃣  Commit: git commit"
}

resolve_submodules_individually() {
    local submodules=("$@")
    
    for submodule in "${submodules[@]}"; do
        echo "\n📦 Resolving: $submodule"
        echo "👈 1️⃣  Keep current version (HEAD)"
        echo "👉 2️⃣  Accept incoming version (MERGE_HEAD)"
        echo "🔄 3️⃣  Update to latest origin/main"
        echo "⏭️  4️⃣  Skip this submodule"
        echo -n "🤔 Choice for $submodule (1/2/3/4): "
        
        read choice
        case "$choice" in
            1)
                _log_info "👈 Keeping current version of $submodule"
                git add "$submodule"
                ;;
            2)
                _log_info "👉 Accepting incoming version of $submodule"
                local incoming_commit=$(git ls-tree MERGE_HEAD $submodule | awk '{print $3}')
                git update-index --add --cacheinfo 160000 $incoming_commit $submodule
                ;;
            3)
                _log_info "🔄 Updating $submodule to latest origin/main"
                if [[ -d "$submodule" ]]; then
                    (cd "$submodule" && git fetch origin main && git checkout origin/main)
                    git add "$submodule"
                fi
                ;;
            4)
                _log_info "⏭️  Skipping $submodule"
                continue
                ;;
            *)
                _log_error "Invalid choice, skipping $submodule"
                continue
                ;;
        esac
    done
    
    _log_success "Individual submodule resolution completed"
}

update_conflicted_submodules() {
    local submodules=("$@")
    
    _log_info "🔄 Updating conflicted submodules to latest commits..."
    
    for submodule in "${submodules[@]}"; do
        if [[ -d "$submodule" ]]; then
            _log_info "📦 Updating $submodule..."
            (cd "$submodule" && git fetch origin && git checkout origin/main)
            git add "$submodule"
        else
            _log_warning "Submodule directory $submodule not found, skipping"
        fi
    done
    
    _log_success "Submodules updated to latest commits"
}

#=============================================================================
# Plugin Management
#=============================================================================

update_git_submodules_plugin() {
    # Store the current directory
    local ORIGINAL_DIR="$(pwd)"

    echo "🔍 Checking for updates for git-submodules plugin..."
    
    # Validate plugin directory exists
    if [[ ! -d "$GIT_SUBMODULES_PLUGIN_DIR" ]]; then
        _log_error "Plugin directory not found: $GIT_SUBMODULES_PLUGIN_DIR"
        return 1
    fi
    
    # Change to plugin directory
    if ! cd "$GIT_SUBMODULES_PLUGIN_DIR"; then
        _log_error "Failed to change to plugin directory"
        return 1
    fi
    
    # Verify it's a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        _log_error "Plugin directory is not a git repository"
        cd "$ORIGINAL_DIR"
        return 1
    fi

    # Fetch latest changes from the main branch quietly
    if ! git fetch origin main --quiet; then
        _log_error "Failed to fetch updates"
        cd "$ORIGINAL_DIR"
        return 1
    fi

    # Check if there are new updates
    if ! git diff --quiet HEAD origin/main; then
        echo "✨ A new update is available for git-submodules plugin."

        # Ask user if they want to update
        read "RESPONSE?🤔 Do you want to update? (y/N): "

        if [[ "$RESPONSE" =~ ^[Yy]$ ]]; then
            echo "⬇️  Updating git-submodules plugin..."
            if git reset --hard origin/main --quiet && git pull origin main --quiet; then
                _log_success "🎉 Update complete!"

                # Ask if they want to reload Zsh
                read "RELOAD?🔄 Would you like to reload Zsh now? (y/N): "

                if [[ "$RELOAD" =~ ^[Yy]$ ]]; then
                    echo "🔄 Reloading Zsh..."
                    # Store the current directory in an environment variable
                    export PREV_DIR="$ORIGINAL_DIR"
                    # Reload Zsh and restore the working directory
                    exec zsh -c 'cd "$PREV_DIR"; exec zsh'
                else
                    echo "💡 You can reload manually by running: source ~/.zshrc"
                fi
            else
                _log_error "Update failed"
                cd "$ORIGINAL_DIR"
                return 1
            fi
        else
            echo "⏭️  Skipping update."
        fi
    else
        _log_success "🚀 You're already using the latest version of git-submodules plugin."
    fi
    
    # Return to original directory
    cd "$ORIGINAL_DIR"
}