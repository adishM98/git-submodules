#!/bin/zsh

#=============================================================================
# Git Submodules Plugin
# Provides utilities for managing Git repositories with submodules
#=============================================================================

# Global configuration
GIT_SUBMODULES_PLUGIN_DIR="${${(%):-%x}:A:h}"
GIT_SUBMODULES_VERBOSE=${GIT_SUBMODULES_VERBOSE:-true}

#=============================================================================
# Utility Functions
#=============================================================================

# Logging functions
_log_info() {
    [[ "$GIT_SUBMODULES_VERBOSE" == "true" ]] && echo "ℹ️  $*"
}

_log_success() {
    echo "✅ $*"
}

_log_warning() {
    echo "⚠️  $*"
}

_log_error() {
    echo "❌ $*" >&2
}

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
    local branch_name scope

    # Prompt for branch name
    echo -n "🌿 Enter the branch name to checkout: "
    read branch_name

    if [ -z "$branch_name" ]; then
        _log_error "Branch name is required!"
        return 1
    fi

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
    local branch_name="$1"
    if [ -z "$branch_name" ]; then
        _log_error "Branch name required! Usage: create_branch_all <branch_name>"
        return 1
    fi
    
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
    local message="$1"
    if [ -z "$message" ]; then
        _log_error "Commit message required! Usage: commit_all \"<message>\""
        return 1
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
    local base_branch current_branch scope

    echo -n "🌳 Enter the base branch to merge from: "
    read base_branch

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