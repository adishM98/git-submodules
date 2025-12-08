#!/bin/zsh

#=============================================================================
# Unified Stash Management Module
# Eliminates code duplication for stash operations
# Provides consistent stash naming and recovery
#=============================================================================

#=============================================================================
# Stash Naming Convention
#=============================================================================
# Format: stash-{context}-{branch}-{timestamp}
# Example: stash-checkout-feature-branch-1234567890
#
# This prevents stash name collisions and makes it easy to find the right stash

_generate_stash_name() {
    local context="$1"   # e.g., "checkout", "merge"
    local branch="$2"    # e.g., "main", "feature-branch"
    local timestamp=$(date +%s)

    echo "stash-${context}-${branch}-${timestamp}"
}

_find_stash_by_pattern() {
    local pattern="$1"
    git stash list | grep "$pattern" | head -1 | cut -d: -f1
}

#=============================================================================
# Base Repository Stash Operations
#=============================================================================

stash_base_repo() {
    local branch="${1:-$(git rev-parse --abbrev-ref HEAD)}"
    local context="${2:-checkout}"

    if [ -n "$(git status --porcelain)" ]; then
        local stash_name=$(_generate_stash_name "$context" "$branch")
        _log_info "💾 Stashing changes in base repository: $stash_name"
        git stash push -m "$stash_name"
    else
        _log_info "👤 No changes to stash in base repository"
    fi
}

apply_stash_base_repo() {
    local branch="${1:-$(git rev-parse --abbrev-ref HEAD)}"
    local context="${2:-checkout}"

    local pattern="stash-${context}-${branch}"
    local stash_entry=$(_find_stash_by_pattern "$pattern")

    if [ -n "$stash_entry" ]; then
        _log_info "🎯 Applying stash $stash_entry in base repository"
        git stash pop "$stash_entry"
    else
        _log_info "ℹ️  No stash found for pattern: $pattern"
    fi
}

#=============================================================================
# Submodule Stash Operations
#=============================================================================

stash_submodule() {
    local submodule_path="$1"
    local branch="${2:-$(cd "$submodule_path" && git rev-parse --abbrev-ref HEAD)}"
    local context="${3:-checkout}"

    if [ ! -d "$submodule_path" ]; then
        _log_error "Submodule not found: $submodule_path"
        return 1
    fi

    (
        cd "$submodule_path" || return 1

        if [ -n "$(git status --porcelain)" ]; then
            local stash_name=$(_generate_stash_name "$context" "$branch")
            _log_info "💾 Stashing changes in $submodule_path: $stash_name"
            git stash push -m "$stash_name"
        else
            _log_info "👤 No changes to stash in $submodule_path"
        fi
    )
}

apply_stash() {
    local submodule_path="$1"
    local branch="${2:-$(cd "$submodule_path" && git rev-parse --abbrev-ref HEAD)}"
    local context="${3:-checkout}"

    if [ ! -d "$submodule_path" ]; then
        _log_error "Submodule not found: $submodule_path"
        return 1
    fi

    (
        cd "$submodule_path" || return 1

        local pattern="stash-${context}-${branch}"
        local stash_entry=$(_find_stash_by_pattern "$pattern")

        if [ -n "$stash_entry" ]; then
            _log_info "🎯 Applying stash $stash_entry in $submodule_path"
            git stash pop "$stash_entry"
        else
            _log_info "ℹ️  No stash found in $submodule_path for pattern: $pattern"
        fi
    )
}

# Backward compatibility alias
apply_stash_submodule() {
    apply_stash "$@"
}

#=============================================================================
# Bulk Stash Operations
#=============================================================================

stash_all_repos() {
    local branch="${1:-$(git rev-parse --abbrev-ref HEAD)}"
    local context="${2:-checkout}"

    _log_info "💾 Stashing all repositories..."

    # Stash base repo
    stash_base_repo "$branch" "$context"

    # Stash all submodules
    local submodules=$(_get_all_submodules)
    if [[ -n "$submodules" ]]; then
        echo "$submodules" | while IFS= read -r submodule; do
            if [[ -n "$submodule" ]]; then
                stash_submodule "$submodule" "$branch" "$context"
            fi
        done
    fi
}

apply_stash_all_repos() {
    local branch="${1:-$(git rev-parse --abbrev-ref HEAD)}"
    local context="${2:-checkout}"

    _log_info "🎯 Applying stashes to all repositories..."

    # Apply stash to base repo
    apply_stash_base_repo "$branch" "$context"

    # Apply stash to all submodules
    local submodules=$(_get_all_submodules)
    if [[ -n "$submodules" ]]; then
        echo "$submodules" | while IFS= read -r submodule; do
            if [[ -n "$submodule" ]]; then
                apply_stash "$submodule" "$branch" "$context"
            fi
        done
    fi
}

#=============================================================================
# Utility Functions
#=============================================================================

# List all stashes across all repos
list_all_stashes() {
    echo "\n🏠 === Base Repository Stashes ==="
    git stash list

    local submodules=$(_get_all_submodules)
    if [[ -n "$submodules" ]]; then
        echo "$submodules" | while IFS= read -r submodule; do
            if [[ -n "$submodule" ]]; then
                echo "\n📦 === $submodule Stashes ==="
                (cd "$submodule" && git stash list)
            fi
        done
    fi
}

# Clear all stashes across all repos (with confirmation)
clear_all_stashes() {
    echo -n "⚠️  This will clear ALL stashes in base repo and submodules. Continue? (y/N): "
    read confirm

    if [[ "$confirm" != "y" ]]; then
        _log_warning "Stash clear cancelled"
        return 0
    fi

    _log_info "🗑️  Clearing stashes in base repository..."
    git stash clear

    local submodules=$(_get_all_submodules)
    if [[ -n "$submodules" ]]; then
        echo "$submodules" | while IFS= read -r submodule; do
            if [[ -n "$submodule" ]]; then
                _log_info "🗑️  Clearing stashes in $submodule..."
                (cd "$submodule" && git stash clear)
            fi
        done
    fi

    _log_success "All stashes cleared"
}

#=============================================================================
# Export Functions
#=============================================================================

# These functions are available to the plugin:
# - stash_base_repo
# - apply_stash_base_repo
# - stash_submodule
# - apply_stash
# - apply_stash_submodule (backward compatibility)
# - stash_all_repos
# - apply_stash_all_repos
# - list_all_stashes
# - clear_all_stashes
