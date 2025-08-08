#!/bin/zsh

#=============================================================================
# Git Submodules Plugin
# Provides utilities for managing Git repositories with submodules
#=============================================================================

# Global configuration
GIT_SUBMODULES_PLUGIN_DIR="${0:A:h}"
GIT_SUBMODULES_DRY_RUN=${GIT_SUBMODULES_DRY_RUN:-false}
GIT_SUBMODULES_VERBOSE=${GIT_SUBMODULES_VERBOSE:-true}
GIT_SUBMODULES_DEFAULT_SUBMODULES=("frontend/ee" "server/ee")

#=============================================================================
# Utility Functions
#=============================================================================

# Logging and output functions
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

_log_dry_run() {
    [[ "$GIT_SUBMODULES_DRY_RUN" == "true" ]] && echo "🔍 [DRY RUN] $*"
}

# Input validation functions
_validate_branch_name() {
    local branch="$1"
    if [[ -z "$branch" ]]; then
        _log_error "Branch name is required"
        return 1
    fi
    # Check for invalid characters in branch names
    if [[ "$branch" =~ [[:space:]] || "$branch" =~ [\~\^\:\?\*\[] ]]; then
        _log_error "Invalid branch name: '$branch'"
        return 1
    fi
    return 0
}

_validate_git_repo() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        _log_error "Not a git repository"
        return 1
    fi
    return 0
}

_validate_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        _log_error "Directory does not exist: '$dir'"
        return 1
    fi
    return 0
}

# Safe command execution
_safe_git() {
    local cmd="$*"
    if [[ "$GIT_SUBMODULES_DRY_RUN" == "true" ]]; then
        _log_dry_run "git $cmd"
        return 0
    fi
    
    _log_info "Executing: git $cmd"
    if ! git $cmd; then
        _log_error "Git command failed: git $cmd"
        return 1
    fi
    return 0
}

_safe_cd() {
    local dir="$1"
    if ! _validate_directory "$dir"; then
        return 1
    fi
    
    if [[ "$GIT_SUBMODULES_DRY_RUN" == "true" ]]; then
        _log_dry_run "cd '$dir'"
        return 0
    fi
    
    if ! cd "$dir"; then
        _log_error "Failed to change directory to: '$dir'"
        return 1
    fi
    return 0
}

# Get current branch safely
_get_current_branch() {
    git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null
}

# Check if branch exists
_branch_exists() {
    local branch="$1"
    local repo_path="${2:-.}"
    
    if [[ "$repo_path" != "." ]]; then
        (cd "$repo_path" && git show-ref --verify --quiet "refs/heads/$branch")
    else
        git show-ref --verify --quiet "refs/heads/$branch"
    fi
}

# Get submodule paths dynamically
_get_submodule_paths() {
    git submodule status --recursive 2>/dev/null | awk '{print $2}' || echo ""
}

# Check if we have unstaged changes
_has_unstaged_changes() {
    local path="${1:-.}"
    if [[ "$path" != "." ]]; then
        (cd "$path" && [[ -n "$(git status --porcelain)" ]])
    else
        [[ -n "$(git status --porcelain)" ]]
    fi
}

#=============================================================================
# Stash Management Functions
#=============================================================================

_stash_changes() {
    local path="$1"
    local branch="$2"
    local repo_name="${path:-.}"
    
    if [[ "$path" != "." ]] && ! _validate_directory "$path"; then
        return 1
    fi
    
    local original_dir="$(pwd)"
    if [[ "$path" != "." ]]; then
        _safe_cd "$path" || return 1
    fi
    
    if _has_unstaged_changes "."; then
        local stash_message="stash-for-${branch}-$(date +%s)"
        _log_info "Stashing changes in ${repo_name} for branch '$branch'"
        _safe_git "stash push -m '$stash_message'"
    else
        _log_info "No changes to stash in ${repo_name}"
    fi
    
    if [[ "$path" != "." ]]; then
        cd "$original_dir" || return 1
    fi
    return 0
}

_apply_stash() {
    local path="$1"
    local branch="$2"
    local repo_name="${path:-.}"
    
    if [[ "$path" != "." ]] && ! _validate_directory "$path"; then
        return 1
    fi
    
    local original_dir="$(pwd)"
    if [[ "$path" != "." ]]; then
        _safe_cd "$path" || return 1
    fi
    
    local stash_entry
    stash_entry=$(git stash list | grep "stash-for-$branch" | head -1 | cut -d: -f1)
    if [[ -n "$stash_entry" ]]; then
        _log_info "Applying stash $stash_entry in ${repo_name} for branch '$branch'"
        _safe_git "stash pop '$stash_entry'"
    else
        _log_info "No stash found for branch '$branch' in ${repo_name}"
    fi
    
    if [[ "$path" != "." ]]; then
        cd "$original_dir" || return 1
    fi
    return 0
}

#=============================================================================
# Core Git Operations
#=============================================================================

# Enhanced checkout with better error handling
checkout_interactive() {
    _validate_git_repo || return 1
    
    local branch_name scope
    
    echo -n "Enter the branch name to checkout: "
    read branch_name
    
    _validate_branch_name "$branch_name" || return 1
    
    local current_branch
    current_branch=$(_get_current_branch)
    
    echo "Where do you want to checkout the '$branch_name' branch?"
    echo "1) Base repository"
    echo "2) Submodule repositories"
    echo "3) Both (Base + Submodules)"
    echo "4) Both (Base + Submodules) with Stash Handling"
    echo -n "Enter your choice (1/2/3/4): "
    read scope
    
    case "$scope" in
        1)
            _log_info "Checking out branch '$branch_name' in base repository..."
            _safe_git "checkout '$branch_name'" && _safe_git "pull"
            ;;
        2)
            _log_info "Checking out branch '$branch_name' in submodules..."
            local submodules
            submodules=($(_get_submodule_paths))
            if [[ ${#submodules[@]} -eq 0 ]]; then
                _log_warning "No submodules found"
                return 1
            fi
            _safe_git "submodule foreach --quiet --recursive 'git checkout \"$branch_name\" && git pull'"
            ;;
        3)
            _log_info "Checking out branch '$branch_name' in base repository and submodules..."
            _safe_git "checkout '$branch_name'" && _safe_git "pull" &&
            _safe_git "submodule foreach --quiet --recursive 'git checkout \"$branch_name\" && git pull'"
            ;;
        4)
            _log_info "Handling stashing before switching..."
            _stash_changes "." "$current_branch"
            
            local submodules
            submodules=($(_get_submodule_paths))
            for submodule in "${submodules[@]}"; do
                _stash_changes "$submodule" "$current_branch"
            done
            
            _log_info "Checking out branch '$branch_name' in base repository and submodules..."
            _safe_git "checkout --recurse-submodules '$branch_name'"
            
            _log_info "Applying stashes..."
            _apply_stash "." "$branch_name"
            for submodule in "${submodules[@]}"; do
                _apply_stash "$submodule" "$branch_name"
            done
            ;;
        *)
            _log_error "Invalid choice! Please enter 1, 2, 3, or 4."
            return 1
            ;;
    esac
    
    _log_success "Checkout of '$branch_name' completed!"
}

# Enhanced pull with better upstream handling
pull_all() {
    _validate_git_repo || return 1
    
    _log_info "Fetching and pulling base repository..."
    _safe_git "fetch --all" || return 1
    
    local current_branch upstream_branch
    current_branch=$(_get_current_branch)
    upstream_branch=$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null)
    
    if [[ -z "$upstream_branch" ]]; then
        _log_warning "No upstream tracking branch set for '$current_branch'"
        _log_info "To fix: git branch --set-upstream-to=origin/$current_branch $current_branch"
        return 1
    else
        _log_info "Pulling latest changes from $upstream_branch..."
        _safe_git "pull" || return 1
    fi
    
    _log_info "Pulling changes in submodules..."
    local submodules
    submodules=($(_get_submodule_paths))
    
    if [[ ${#submodules[@]} -eq 0 ]]; then
        _log_info "No submodules found"
        return 0
    fi
    
    for submodule in "${submodules[@]}"; do
        _log_info "Processing submodule: $submodule"
        if ! _validate_directory "$submodule"; then
            continue
        fi
        
        local original_dir="$(pwd)"
        _safe_cd "$submodule" || continue
        
        local sub_branch
        sub_branch=$(_get_current_branch)
        
        if [[ -z "$sub_branch" ]]; then
            _log_warning "Submodule $submodule is in detached HEAD. Skipping..."
            cd "$original_dir"
            continue
        fi
        
        _log_info "Fetching and pulling branch $sub_branch in $submodule..."
        if _safe_git "fetch origin '$sub_branch'" 2>/dev/null; then
            if git ls-remote --exit-code origin "$sub_branch" >/dev/null 2>&1; then
                _safe_git "pull origin '$sub_branch'"
            else
                _log_warning "Remote branch $sub_branch not found in $submodule. Skipping pull."
            fi
        else
            _log_warning "Failed to fetch from $submodule"
        fi
        
        cd "$original_dir"
    done
    
    _log_success "Pull completed for all repositories"
}

# Safe add all with validation
add_all() {
    _validate_git_repo || return 1
    
    _log_info "Staging changes in base repository..."
    _safe_git "add -A" || return 1
    
    local submodules
    submodules=($(_get_submodule_paths))
    
    if [[ ${#submodules[@]} -eq 0 ]]; then
        _log_info "No submodules found"
        return 0
    fi
    
    for submodule in "${submodules[@]}"; do
        if _validate_directory "$submodule"; then
            _log_info "Staging changes in $submodule..."
            (cd "$submodule" && _safe_git "add -A")
        fi
    done
    
    _log_success "All changes staged"
}

# Enhanced branch creation with validation
create_branch_all() {
    local branch_name="$1"
    
    _validate_git_repo || return 1
    _validate_branch_name "$branch_name" || {
        echo "Usage: create_branch_all <branch_name>"
        return 1
    }
    
    # Check if branch already exists
    if _branch_exists "$branch_name"; then
        _log_error "Branch '$branch_name' already exists in base repository"
        return 1
    fi
    
    _log_info "Creating branch '$branch_name' in base repository..."
    _safe_git "checkout -b '$branch_name'" || return 1
    
    local submodules
    submodules=($(_get_submodule_paths))
    
    if [[ ${#submodules[@]} -eq 0 ]]; then
        _log_info "No submodules found"
        return 0
    fi
    
    local failed_submodules=()
    for submodule in "${submodules[@]}"; do
        if _validate_directory "$submodule"; then
            _log_info "Creating branch '$branch_name' in $submodule..."
            if ! (cd "$submodule" && _safe_git "checkout -b '$branch_name'"); then
                failed_submodules+=("$submodule")
            fi
        fi
    done
    
    if [[ ${#failed_submodules[@]} -gt 0 ]]; then
        _log_warning "Failed to create branch in: ${failed_submodules[*]}"
        return 1
    fi
    
    _log_success "Branch '$branch_name' created in all repositories"
}

# Helper function for prefixed branches with validation
create_prefixed_branch() {
    local prefix="$1"
    local name="$2"
    
    if [[ -z "$name" ]]; then
        _log_error "Name required! Usage: create_${prefix}_all <name>"
        return 1
    fi
    
    _validate_branch_name "$name" || return 1
    
    local branch="$prefix/$name"
    create_branch_all "$branch"
}

create_feature_all() { create_prefixed_branch "feature" "$1"; }
create_hotfix_all()  { create_prefixed_branch "hot-fix" "$1"; }
create_release_all() { create_prefixed_branch "release" "$1"; }
create_revamp_all()  { create_prefixed_branch "revamp" "$1"; }
create_sprint_all()  { create_prefixed_branch "sprint" "$1"; }

# Enhanced tag creation with validation
create_tag_all() {
    local tag_name="$1"
    
    _validate_git_repo || return 1
    
    if [[ -z "$tag_name" ]]; then
        _log_error "Tag name required! Usage: create_tag_all <tag_name>"
        return 1
    fi
    
    # Validate tag name
    if [[ "$tag_name" =~ [[:space:]] ]]; then
        _log_error "Invalid tag name: '$tag_name'"
        return 1
    fi
    
    _log_info "Creating and pushing tag '$tag_name' in base repository..."
    _safe_git "tag '$tag_name'" && _safe_git "push origin '$tag_name'" || return 1
    
    local submodules
    submodules=($(_get_submodule_paths))
    
    if [[ ${#submodules[@]} -eq 0 ]]; then
        _log_info "No submodules found"
        return 0
    fi
    
    local failed_submodules=()
    for submodule in "${submodules[@]}"; do
        if _validate_directory "$submodule"; then
            _log_info "Creating and pushing tag '$tag_name' in $submodule..."
            if ! (cd "$submodule" && _safe_git "tag '$tag_name'" && _safe_git "push origin '$tag_name'"); then
                failed_submodules+=("$submodule")
            fi
        fi
    done
    
    if [[ ${#failed_submodules[@]} -gt 0 ]]; then
        _log_warning "Failed to create tag in: ${failed_submodules[*]}"
        return 1
    fi
    
    _log_success "Tag '$tag_name' created and pushed in all repositories"
}

# Safe commit with message validation
commit_all() {
    local message="$1"
    
    _validate_git_repo || return 1
    
    if [[ -z "$message" ]]; then
        _log_error "Commit message required! Usage: commit_all \"<message>\""
        return 1
    fi
    
    # Validate commit message (basic checks)
    if [[ ${#message} -lt 3 ]]; then
        _log_error "Commit message too short (minimum 3 characters)"
        return 1
    fi
    
    _log_info "Committing changes in base repository..."
    _safe_git "commit -m '$message'" || return 1
    
    local submodules
    submodules=($(_get_submodule_paths))
    
    if [[ ${#submodules[@]} -eq 0 ]]; then
        _log_info "No submodules found"
        return 0
    fi
    
    local failed_submodules=()
    for submodule in "${submodules[@]}"; do
        if _validate_directory "$submodule"; then
            _log_info "Committing changes in $submodule..."
            if ! (cd "$submodule" && _has_unstaged_changes "." && _safe_git "commit -m '$message'"); then
                if ! _has_unstaged_changes "$submodule"; then
                    _log_info "No changes to commit in $submodule"
                else
                    failed_submodules+=("$submodule")
                fi
            fi
        fi
    done
    
    if [[ ${#failed_submodules[@]} -gt 0 ]]; then
        _log_warning "Failed to commit in: ${failed_submodules[*]}"
        return 1
    fi
    
    _log_success "Changes committed in all repositories"
}

# Enhanced push with better upstream handling
push_all() {
    _validate_git_repo || return 1
    
    _log_info "Pushing base repository..."
    local current_branch upstream_branch
    current_branch=$(_get_current_branch)
    upstream_branch=$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null)
    
    if [[ -z "$upstream_branch" ]]; then
        _log_warning "No upstream set for '$current_branch'. Setting upstream to origin/$current_branch..."
        _safe_git "push --set-upstream origin '$current_branch'" || return 1
    else
        _safe_git "push" || return 1
    fi
    
    _log_info "Pushing submodules..."
    local submodules
    submodules=($(_get_submodule_paths))
    
    if [[ ${#submodules[@]} -eq 0 ]]; then
        _log_info "No submodules found"
        return 0
    fi
    
    local failed_submodules=()
    for submodule in "${submodules[@]}"; do
        if _validate_directory "$submodule"; then
            _log_info "Processing submodule: $submodule"
            local original_dir="$(pwd)"
            _safe_cd "$submodule" || continue
            
            local sub_branch sub_upstream
            sub_branch=$(_get_current_branch)
            
            if [[ -z "$sub_branch" ]]; then
                _log_warning "Submodule $submodule is in detached HEAD. Skipping..."
                cd "$original_dir"
                continue
            fi
            
            sub_upstream=$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null)
            if [[ -z "$sub_upstream" ]]; then
                _log_warning "No upstream for $sub_branch in $submodule. Setting upstream to origin/$sub_branch..."
                if ! _safe_git "push --set-upstream origin '$sub_branch'"; then
                    failed_submodules+=("$submodule")
                fi
            else
                _log_info "Pushing $sub_branch in $submodule..."
                if ! _safe_git "push"; then
                    failed_submodules+=("$submodule")
                fi
            fi
            
            cd "$original_dir"
        fi
    done
    
    if [[ ${#failed_submodules[@]} -gt 0 ]]; then
        _log_warning "Failed to push: ${failed_submodules[*]}"
        return 1
    fi
    
    _log_success "All repositories pushed successfully"
}

# Enhanced status with better formatting
status_all() {
    _validate_git_repo || return 1
    
    echo "=== Base Repository Status ==="
    git status --short --branch
    
    local submodules
    submodules=($(_get_submodule_paths))
    
    if [[ ${#submodules[@]} -eq 0 ]]; then
        _log_info "No submodules found"
        return 0
    fi
    
    for submodule in "${submodules[@]}"; do
        if _validate_directory "$submodule"; then
            echo "\n=== Submodule: $submodule ==="
            (cd "$submodule" && git status --short --branch)
        fi
    done
}

#=============================================================================
# Interactive Branch Management
#=============================================================================

create_branch_interactive() {
    local branch_type="$1"
    local branch_name scope
    local -a folder_paths
    
    _validate_git_repo || return 1
    
    if [[ -z "$branch_type" ]]; then
        echo -n "Enter branch name: "
    else
        echo -n "Enter $branch_type branch name: "
    fi
    read branch_name
    
    _validate_branch_name "$branch_name" || return 1
    
    echo "Where do you want to create the '$branch_name' branch?"
    echo "1) Base repository"
    echo "2) Submodule repositories"
    echo "3) Specific folders"
    echo "4) All (Base + Submodules)"
    echo -n "Enter your choice (1/2/3/4): "
    read scope
    
    case "$scope" in
        1)
            _log_info "Creating branch '$branch_name' in base repository..."
            _safe_git "checkout -b '$branch_name'" && _safe_git "push -u origin '$branch_name'"
            ;;
        2)
            _log_info "Creating branch '$branch_name' in submodules..."
            local submodules
            submodules=($(_get_submodule_paths))
            
            if [[ ${#submodules[@]} -eq 0 ]]; then
                _log_warning "No submodules found"
                return 1
            fi
            
            local failed_submodules=()
            for submodule in "${submodules[@]}"; do
                if _validate_directory "$submodule"; then
                    if ! (cd "$submodule" && _safe_git "checkout -b '$branch_name'" && _safe_git "push -u origin '$branch_name'"); then
                        failed_submodules+=("$submodule")
                    fi
                fi
            done
            
            if [[ ${#failed_submodules[@]} -gt 0 ]]; then
                _log_warning "Failed in submodules: ${failed_submodules[*]}"
                return 1
            fi
            ;;
        3)
            echo -n "Enter folder paths (separated by spaces): "
            read -r folder_input
            folder_paths=(${=folder_input})
            
            if [[ ${#folder_paths[@]} -eq 0 ]]; then
                _log_error "No valid folders provided!"
                return 1
            fi
            
            _log_info "Processing the following folders: ${folder_paths[*]}"
            local failed_folders=()
            for folder in "${folder_paths[@]}"; do
                if _validate_directory "$folder"; then
                    _log_info "Creating branch '$branch_name' in $folder..."
                    if ! (cd "$folder" && _safe_git "checkout -b '$branch_name'"); then
                        failed_folders+=("$folder")
                    fi
                else
                    failed_folders+=("$folder")
                fi
            done
            
            if [[ ${#failed_folders[@]} -gt 0 ]]; then
                _log_warning "Failed in folders: ${failed_folders[*]}"
                return 1
            fi
            ;;
        4)
            _log_info "Creating branch '$branch_name' in base repository and submodules..."
            _safe_git "checkout -b '$branch_name'" && _safe_git "push -u origin '$branch_name'" || return 1
            
            local submodules
            submodules=($(_get_submodule_paths))
            
            local failed_submodules=()
            for submodule in "${submodules[@]}"; do
                if _validate_directory "$submodule"; then
                    if ! (cd "$submodule" && _safe_git "checkout -b '$branch_name'"); then
                        failed_submodules+=("$submodule")
                    fi
                fi
            done
            
            if [[ ${#failed_submodules[@]} -gt 0 ]]; then
                _log_warning "Failed in submodules: ${failed_submodules[*]}"
                return 1
            fi
            ;;
        *)
            _log_error "Invalid choice! Please enter 1, 2, 3, or 4."
            return 1
            ;;
    esac
    
    _log_success "Branch '$branch_name' created successfully!"
}

#=============================================================================
# Merge Operations
#=============================================================================

merge_all() {
    local base_branch current_branch scope
    
    _validate_git_repo || return 1
    
    echo -n "Enter the base branch to merge from: "
    read base_branch
    
    _validate_branch_name "$base_branch" || return 1
    
    current_branch=$(_get_current_branch)
    
    if [[ "$base_branch" == "$current_branch" ]]; then
        _log_error "Cannot merge branch into itself"
        return 1
    fi
    
    echo "Where do you want to merge '$base_branch' into '$current_branch'?"
    echo "1) Base repository"
    echo "2) Submodule repositories"
    echo "3) Both (Base + Submodules)"
    echo "4) Both (Base + Submodules) with Stash Handling"
    echo -n "Enter your choice (1/2/3/4): "
    read scope
    
    # Fetch the base branch first
    _safe_git "fetch origin '$base_branch'" || return 1
    
    case "$scope" in
        1)
            _log_info "Merging base repository..."
            _safe_git "merge origin/'$base_branch'"
            ;;
        2)
            local submodules
            submodules=($(_get_submodule_paths))
            
            if [[ ${#submodules[@]} -eq 0 ]]; then
                _log_warning "No submodules found"
                return 1
            fi
            
            echo "Which submodule(s) do you want to merge into?"
            for i in "${!submodules[@]}"; do
                echo "$((i+1))) ${submodules[i]}"
            done
            echo "$((${#submodules[@]}+1))) All submodules"
            echo -n "Enter your choice: "
            read submodule_choice
            
            if [[ "$submodule_choice" -eq $((${#submodules[@]}+1)) ]]; then
                # Merge all submodules
                local failed_submodules=()
                for submodule in "${submodules[@]}"; do
                    if _validate_directory "$submodule"; then
                        _log_info "Merging into $submodule..."
                        if ! (cd "$submodule" && _safe_git "fetch origin '$base_branch'" && _safe_git "merge origin/'$base_branch'"); then
                            failed_submodules+=("$submodule")
                        fi
                    fi
                done
                
                if [[ ${#failed_submodules[@]} -gt 0 ]]; then
                    _log_warning "Failed to merge in: ${failed_submodules[*]}"
                    return 1
                fi
            elif [[ "$submodule_choice" -ge 1 && "$submodule_choice" -le ${#submodules[@]} ]]; then
                # Merge specific submodule
                local selected_submodule="${submodules[$((submodule_choice-1))]}"
                if _validate_directory "$selected_submodule"; then
                    _log_info "Merging into $selected_submodule..."
                    (cd "$selected_submodule" && _safe_git "fetch origin '$base_branch'" && _safe_git "merge origin/'$base_branch'")
                fi
            else
                _log_error "Invalid submodule choice"
                return 1
            fi
            ;;
        3)
            _log_info "Merging base repository..."
            _safe_git "merge origin/'$base_branch'" || return 1
            
            local submodules
            submodules=($(_get_submodule_paths))
            
            local failed_submodules=()
            for submodule in "${submodules[@]}"; do
                if _validate_directory "$submodule"; then
                    _log_info "Merging into $submodule..."
                    if ! (cd "$submodule" && _safe_git "fetch origin '$base_branch'" && _safe_git "merge origin/'$base_branch'"); then
                        failed_submodules+=("$submodule")
                    fi
                fi
            done
            
            if [[ ${#failed_submodules[@]} -gt 0 ]]; then
                _log_warning "Failed to merge in: ${failed_submodules[*]}"
                return 1
            fi
            ;;
        4)
            _log_info "Stashing changes before merge..."
            _stash_changes "." "$current_branch"
            
            local submodules
            submodules=($(_get_submodule_paths))
            
            for submodule in "${submodules[@]}"; do
                _stash_changes "$submodule" "$current_branch"
            done
            
            _log_info "Merging base repository..."
            _safe_git "merge origin/'$base_branch'" || return 1
            
            local failed_submodules=()
            for submodule in "${submodules[@]}"; do
                if _validate_directory "$submodule"; then
                    _log_info "Merging into $submodule..."
                    if ! (cd "$submodule" && _safe_git "fetch origin '$base_branch'" && _safe_git "merge origin/'$base_branch'"); then
                        failed_submodules+=("$submodule")
                    fi
                fi
            done
            
            _log_info "Applying stashes after merge..."
            _apply_stash "." "$base_branch"
            for submodule in "${submodules[@]}"; do
                _apply_stash "$submodule" "$base_branch"
            done
            
            if [[ ${#failed_submodules[@]} -gt 0 ]]; then
                _log_warning "Failed to merge in: ${failed_submodules[*]}"
                return 1
            fi
            ;;
        *)
            _log_error "Invalid choice! Please enter 1, 2, 3, or 4."
            return 1
            ;;
    esac
    
    _log_success "Merge from '$base_branch' completed!"
}

#=============================================================================
# Plugin Management
#=============================================================================

update_git_submodules_plugin() {
    local original_dir="$(pwd)"
    local plugin_dir="$GIT_SUBMODULES_PLUGIN_DIR"
    
    _log_info "Checking for updates for git-submodules plugin..."
    
    if ! _validate_directory "$plugin_dir"; then
        _log_error "Plugin directory not found: $plugin_dir"
        return 1
    fi
    
    _safe_cd "$plugin_dir" || return 1
    
    if ! _validate_git_repo; then
        _log_error "Plugin directory is not a git repository"
        cd "$original_dir"
        return 1
    fi
    
    _safe_git "fetch origin main --quiet" || {
        _log_error "Failed to fetch updates"
        cd "$original_dir"
        return 1
    }
    
    if ! git diff --quiet HEAD origin/main; then
        _log_info "A new update is available for git-submodules plugin."
        
        echo -n "Do you want to update? (y/N): "
        read RESPONSE
        
        if [[ "$RESPONSE" =~ ^[Yy]$ ]]; then
            _log_info "Updating git-submodules plugin..."
            _safe_git "reset --hard origin/main --quiet" &&
            _safe_git "pull origin main --quiet" || {
                _log_error "Update failed"
                cd "$original_dir"
                return 1
            }
            
            _log_success "Update complete!"
            
            echo -n "Would you like to reload Zsh now? (y/N): "
            read RELOAD
            
            if [[ "$RELOAD" =~ ^[Yy]$ ]]; then
                _log_info "Reloading Zsh..."
                export PREV_DIR="$original_dir"
                exec zsh -c 'cd "$PREV_DIR"; exec zsh'
            else
                _log_info "You can reload manually by running: source ~/.zshrc"
            fi
        else
            _log_info "Skipping update."
        fi
    else
        _log_success "You're already using the latest version of git-submodules plugin."
    fi
    
    cd "$original_dir"
}

#=============================================================================
# Wrapper Functions and Aliases
#=============================================================================

# Wrapper function
checkout_all() { checkout_interactive; }

# Interactive wrapper functions
start_feature() { create_branch_interactive "feature"; }
start_hotfix() { create_branch_interactive "hotfix"; }
start_release() { create_branch_interactive "release"; }
start_sprint() { create_branch_interactive "sprint"; }
start_branch() { create_branch_interactive ""; }

#=============================================================================
# Utility Commands
#=============================================================================

# Toggle dry run mode
toggle_dry_run() {
    if [[ "$GIT_SUBMODULES_DRY_RUN" == "true" ]]; then
        export GIT_SUBMODULES_DRY_RUN=false
        _log_success "Dry run mode disabled"
    else
        export GIT_SUBMODULES_DRY_RUN=true
        _log_success "Dry run mode enabled"
    fi
}

# Toggle verbose mode
toggle_verbose() {
    if [[ "$GIT_SUBMODULES_VERBOSE" == "true" ]]; then
        export GIT_SUBMODULES_VERBOSE=false
        echo "Verbose mode disabled"
    else
        export GIT_SUBMODULES_VERBOSE=true
        _log_success "Verbose mode enabled"
    fi
}

# Show plugin status
git_submodules_status() {
    echo "=== Git Submodules Plugin Status ==="
    echo "Plugin Directory: $GIT_SUBMODULES_PLUGIN_DIR"
    echo "Dry Run Mode: $GIT_SUBMODULES_DRY_RUN"
    echo "Verbose Mode: $GIT_SUBMODULES_VERBOSE"
    
    if _validate_git_repo 2>/dev/null; then
        echo "Current Repository: ✅ Valid Git Repository"
        local submodules
        submodules=($(_get_submodule_paths))
        echo "Submodules Found: ${#submodules[@]}"
        for submodule in "${submodules[@]}"; do
            echo "  - $submodule"
        done
    else
        echo "Current Repository: ❌ Not a Git Repository"
    fi
}