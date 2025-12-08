#!/bin/zsh

#=============================================================================
# Atomic Operations Module
# Provides all-or-nothing operations across base repository and submodules
# Ensures consistency by rolling back on failure
#=============================================================================

# Checkpoint storage
typeset -g ATOMIC_CHECKPOINT_DIR="$HOME/.local/share/git-submodules/checkpoints"
typeset -g ATOMIC_CURRENT_CHECKPOINT=""
typeset -A ATOMIC_REPO_STATES

#=============================================================================
# Checkpoint Management
#=============================================================================

_atomic_create_checkpoint() {
    local operation="$1"
    local timestamp=$(date +%s)
    local checkpoint_id="${operation}-${timestamp}"
    local checkpoint_path="$ATOMIC_CHECKPOINT_DIR/$checkpoint_id"

    # Create checkpoint directory
    mkdir -p "$checkpoint_path"

    # Save base repository state
    local base_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "none")
    local base_commit=$(git rev-parse HEAD 2>/dev/null || echo "none")
    local base_has_changes=$([[ -n "$(git status --porcelain)" ]] && echo "true" || echo "false")

    echo "branch=$base_branch" > "$checkpoint_path/base.state"
    echo "commit=$base_commit" >> "$checkpoint_path/base.state"
    echo "has_changes=$base_has_changes" >> "$checkpoint_path/base.state"

    # Save stash if there are uncommitted changes
    if [[ "$base_has_changes" == "true" ]]; then
        git stash push -m "atomic-checkpoint-$checkpoint_id" >/dev/null 2>&1
        echo "stash=true" >> "$checkpoint_path/base.state"
    else
        echo "stash=false" >> "$checkpoint_path/base.state"
    fi

    # Save submodule states
    local submodules=$(_get_all_submodules)
    local sub_index=0
    if [[ -n "$submodules" ]]; then
        echo "$submodules" | while IFS= read -r submodule; do
            if [[ -n "$submodule" ]]; then
                local sub_branch=$(cd "$submodule" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "none")
                local sub_commit=$(cd "$submodule" && git rev-parse HEAD 2>/dev/null || echo "none")
                local sub_has_changes=$([[ -n "$(cd "$submodule" && git status --porcelain)" ]] && echo "true" || echo "false")

                echo "path=$submodule" > "$checkpoint_path/sub-${sub_index}.state"
                echo "branch=$sub_branch" >> "$checkpoint_path/sub-${sub_index}.state"
                echo "commit=$sub_commit" >> "$checkpoint_path/sub-${sub_index}.state"
                echo "has_changes=$sub_has_changes" >> "$checkpoint_path/sub-${sub_index}.state"

                # Save stash if there are uncommitted changes
                if [[ "$sub_has_changes" == "true" ]]; then
                    (cd "$submodule" && git stash push -m "atomic-checkpoint-$checkpoint_id" >/dev/null 2>&1)
                    echo "stash=true" >> "$checkpoint_path/sub-${sub_index}.state"
                else
                    echo "stash=false" >> "$checkpoint_path/sub-${sub_index}.state"
                fi

                ((sub_index++))
            fi
        done
    fi

    # Save metadata
    echo "operation=$operation" > "$checkpoint_path/metadata"
    echo "timestamp=$timestamp" >> "$checkpoint_path/metadata"
    echo "submodule_count=$sub_index" >> "$checkpoint_path/metadata"

    ATOMIC_CURRENT_CHECKPOINT="$checkpoint_id"
    echo "$checkpoint_id"
}

_atomic_restore_checkpoint() {
    local checkpoint_id="${1:-$ATOMIC_CURRENT_CHECKPOINT}"
    local checkpoint_path="$ATOMIC_CHECKPOINT_DIR/$checkpoint_id"

    if [[ ! -d "$checkpoint_path" ]]; then
        _log_error "Checkpoint not found: $checkpoint_id"
        return 1
    fi

    echo "\n🔙 === Restoring Checkpoint: $checkpoint_id ==="

    # Restore base repository
    if [[ -f "$checkpoint_path/base.state" ]]; then
        local base_branch=$(grep "^branch=" "$checkpoint_path/base.state" | cut -d'=' -f2)
        local base_commit=$(grep "^commit=" "$checkpoint_path/base.state" | cut -d'=' -f2)
        local base_stash=$(grep "^stash=" "$checkpoint_path/base.state" | cut -d'=' -f2)

        _log_info "🏠 Restoring base repository to $base_branch @ $base_commit"

        # Reset to checkpoint commit
        git reset --hard "$base_commit" >/dev/null 2>&1
        git checkout "$base_branch" >/dev/null 2>&1

        # Restore stash if needed
        if [[ "$base_stash" == "true" ]]; then
            local stash_entry=$(git stash list | grep "atomic-checkpoint-$checkpoint_id" | head -1 | cut -d: -f1)
            if [[ -n "$stash_entry" ]]; then
                git stash pop "$stash_entry" >/dev/null 2>&1
            fi
        fi
    fi

    # Restore submodules
    local sub_count=$(grep "^submodule_count=" "$checkpoint_path/metadata" | cut -d'=' -f2)
    for ((i=0; i<sub_count; i++)); do
        if [[ -f "$checkpoint_path/sub-${i}.state" ]]; then
            local sub_path=$(grep "^path=" "$checkpoint_path/sub-${i}.state" | cut -d'=' -f2)
            local sub_branch=$(grep "^branch=" "$checkpoint_path/sub-${i}.state" | cut -d'=' -f2)
            local sub_commit=$(grep "^commit=" "$checkpoint_path/sub-${i}.state" | cut -d'=' -f2)
            local sub_stash=$(grep "^stash=" "$checkpoint_path/sub-${i}.state" | cut -d'=' -f2)

            if [[ -d "$sub_path" ]]; then
                _log_info "📦 Restoring $sub_path to $sub_branch @ $sub_commit"

                (
                    cd "$sub_path" || return
                    git reset --hard "$sub_commit" >/dev/null 2>&1
                    git checkout "$sub_branch" >/dev/null 2>&1

                    # Restore stash if needed
                    if [[ "$sub_stash" == "true" ]]; then
                        local stash_entry=$(git stash list | grep "atomic-checkpoint-$checkpoint_id" | head -1 | cut -d: -f1)
                        if [[ -n "$stash_entry" ]]; then
                            git stash pop "$stash_entry" >/dev/null 2>&1
                        fi
                    fi
                )
            fi
        fi
    done

    _log_success "Checkpoint restored successfully"
}

_atomic_remove_checkpoint() {
    local checkpoint_id="${1:-$ATOMIC_CURRENT_CHECKPOINT}"
    local checkpoint_path="$ATOMIC_CHECKPOINT_DIR/$checkpoint_id"

    if [[ -d "$checkpoint_path" ]]; then
        rm -rf "$checkpoint_path"
    fi

    ATOMIC_CURRENT_CHECKPOINT=""
}

_atomic_list_checkpoints() {
    if [[ ! -d "$ATOMIC_CHECKPOINT_DIR" ]]; then
        _log_info "No checkpoints found"
        return 0
    fi

    echo "\n📋 === Available Checkpoints ==="
    local count=0

    for checkpoint in "$ATOMIC_CHECKPOINT_DIR"/*; do
        if [[ -d "$checkpoint" ]] && [[ -f "$checkpoint/metadata" ]]; then
            local cp_id=$(basename "$checkpoint")
            local operation=$(grep "^operation=" "$checkpoint/metadata" | cut -d'=' -f2)
            local timestamp=$(grep "^timestamp=" "$checkpoint/metadata" | cut -d'=' -f2)
            local time_str=$(date -r "$timestamp" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "$timestamp")

            echo "  $((++count)). [$time_str] $operation (ID: $cp_id)"
        fi
    done

    if [[ $count -eq 0 ]]; then
        _log_info "No checkpoints found"
    fi
}

#=============================================================================
# Atomic Commit
#=============================================================================

atomic_commit_all() {
    local message="$1"

    if [[ -z "$message" ]]; then
        _log_error "Commit message required! Usage: atomic_commit_all \"<message>\""
        return 1
    fi

    # Check if atomic commits are enabled
    if [[ "$(_get_config atomic_commits)" != "true" ]]; then
        _log_warning "Atomic commits not enabled. Use regular commit_all or enable in config."
        echo -n "🤔 Enable atomic commits for this operation? (y/N): "
        read -q enable_atomic
        echo ""
        if [[ "$enable_atomic" != "y" ]]; then
            return 1
        fi
    fi

    echo "\n⚛️  === Atomic Commit (All-or-Nothing) ==="

    # Create checkpoint
    _log_info "📸 Creating checkpoint..."
    local checkpoint=$(_atomic_create_checkpoint "commit_all")

    # Track success
    local base_success=true
    local sub_failures=()

    # Commit base repository
    _log_info "💾 Committing base repository..."
    if ! git commit -m "$message" 2>/dev/null; then
        base_success=false
        _log_warning "Base repository commit failed (no changes or error)"
    fi

    # Commit submodules
    local submodules=$(_get_all_submodules)
    if [[ -n "$submodules" ]]; then
        _log_info "📦 Committing submodules..."

        echo "$submodules" | while IFS= read -r submodule; do
            if [[ -n "$submodule" ]]; then
                (
                    cd "$submodule" || exit 1
                    if ! git commit -m "$message" 2>/dev/null; then
                        echo "$submodule" >> /tmp/atomic-commit-failures-$$
                    fi
                )
            fi
        done

        # Check for failures
        if [[ -f /tmp/atomic-commit-failures-$$ ]]; then
            sub_failures=($(cat /tmp/atomic-commit-failures-$$))
            rm /tmp/atomic-commit-failures-$$
        fi
    fi

    # Evaluate overall success
    if [[ "$base_success" == "false" ]] || [[ ${#sub_failures[@]} -gt 0 ]]; then
        echo "\n❌ === Atomic Commit Failed ==="
        [[ "$base_success" == "false" ]] && echo "   🏠 Base repository: Failed"
        for failed_sub in "${sub_failures[@]}"; do
            echo "   📦 $failed_sub: Failed"
        done

        echo "\n🔙 Rolling back all changes..."
        _atomic_restore_checkpoint "$checkpoint"
        _atomic_remove_checkpoint "$checkpoint"

        _log_error "Atomic commit failed and rolled back"
        return 1
    else
        # Success!
        _log_success "✅ All repositories committed successfully"
        _atomic_remove_checkpoint "$checkpoint"

        # Record in history
        if type history_record >/dev/null 2>&1; then
            history_record "commit_all" "$message" "success"
        fi

        return 0
    fi
}

#=============================================================================
# Atomic Merge
#=============================================================================

atomic_merge_all() {
    local branch="$1"

    if [[ -z "$branch" ]]; then
        _log_error "Branch required! Usage: atomic_merge_all <branch>"
        return 1
    fi

    echo "\n⚛️  === Atomic Merge (All-or-Nothing) ==="

    # Create checkpoint
    _log_info "📸 Creating checkpoint..."
    local checkpoint=$(_atomic_create_checkpoint "merge_all")

    # Track success
    local base_success=true
    local sub_failures=()

    # Merge base repository
    _log_info "🔀 Merging base repository from $branch..."
    git fetch origin "$branch" >/dev/null 2>&1
    if ! git merge "origin/$branch" 2>/dev/null; then
        base_success=false
        _log_warning "Base repository merge failed (conflicts or error)"
    fi

    # Merge submodules
    local submodules=$(_get_all_submodules)
    if [[ -n "$submodules" ]]; then
        _log_info "📦 Merging submodules from $branch..."

        echo "$submodules" | while IFS= read -r submodule; do
            if [[ -n "$submodule" ]]; then
                (
                    cd "$submodule" || exit 1
                    git fetch origin "$branch" >/dev/null 2>&1
                    if ! git merge "origin/$branch" 2>/dev/null; then
                        echo "$submodule" >> /tmp/atomic-merge-failures-$$
                    fi
                )
            fi
        done

        # Check for failures
        if [[ -f /tmp/atomic-merge-failures-$$ ]]; then
            sub_failures=($(cat /tmp/atomic-merge-failures-$$))
            rm /tmp/atomic-merge-failures-$$
        fi
    fi

    # Evaluate overall success
    if [[ "$base_success" == "false" ]] || [[ ${#sub_failures[@]} -gt 0 ]]; then
        echo "\n❌ === Atomic Merge Failed ==="
        [[ "$base_success" == "false" ]] && echo "   🏠 Base repository: Failed"
        for failed_sub in "${sub_failures[@]}"; do
            echo "   📦 $failed_sub: Failed"
        done

        echo "\n🔙 Rolling back all changes..."
        _atomic_restore_checkpoint "$checkpoint"
        _atomic_remove_checkpoint "$checkpoint"

        _log_error "Atomic merge failed and rolled back"
        return 1
    else
        # Success!
        _log_success "✅ All repositories merged successfully"
        _atomic_remove_checkpoint "$checkpoint"

        # Record in history
        if type history_record >/dev/null 2>&1; then
            history_record "merge_all" "$branch" "success"
        fi

        return 0
    fi
}

#=============================================================================
# Atomic Checkout
#=============================================================================

atomic_checkout_all() {
    local branch="$1"

    if [[ -z "$branch" ]]; then
        _log_error "Branch required! Usage: atomic_checkout_all <branch>"
        return 1
    fi

    echo "\n⚛️  === Atomic Checkout (All-or-Nothing) ==="

    # Create checkpoint
    _log_info "📸 Creating checkpoint..."
    local checkpoint=$(_atomic_create_checkpoint "checkout_all")

    # Track success
    local base_success=true
    local sub_failures=()

    # Checkout base repository
    _log_info "🔀 Checking out base repository to $branch..."
    if ! git checkout "$branch" 2>/dev/null; then
        base_success=false
        _log_warning "Base repository checkout failed"
    fi

    # Checkout submodules
    local submodules=$(_get_all_submodules)
    if [[ -n "$submodules" ]]; then
        _log_info "📦 Checking out submodules to $branch..."

        echo "$submodules" | while IFS= read -r submodule; do
            if [[ -n "$submodule" ]]; then
                (
                    cd "$submodule" || exit 1
                    if ! git checkout "$branch" 2>/dev/null; then
                        echo "$submodule" >> /tmp/atomic-checkout-failures-$$
                    fi
                )
            fi
        done

        # Check for failures
        if [[ -f /tmp/atomic-checkout-failures-$$ ]]; then
            sub_failures=($(cat /tmp/atomic-checkout-failures-$$))
            rm /tmp/atomic-checkout-failures-$$
        fi
    fi

    # Evaluate overall success
    if [[ "$base_success" == "false" ]] || [[ ${#sub_failures[@]} -gt 0 ]]; then
        echo "\n❌ === Atomic Checkout Failed ==="
        [[ "$base_success" == "false" ]] && echo "   🏠 Base repository: Failed"
        for failed_sub in "${sub_failures[@]}"; do
            echo "   📦 $failed_sub: Failed"
        done

        echo "\n🔙 Rolling back all changes..."
        _atomic_restore_checkpoint "$checkpoint"
        _atomic_remove_checkpoint "$checkpoint"

        _log_error "Atomic checkout failed and rolled back"
        return 1
    else
        # Success!
        _log_success "✅ All repositories checked out successfully"
        _atomic_remove_checkpoint "$checkpoint"

        # Record in history
        if type history_record >/dev/null 2>&1; then
            history_record "checkout_all" "$branch" "success"
        fi

        return 0
    fi
}

#=============================================================================
# Manual Checkpoint Management
#=============================================================================

git_submodules_checkpoint() {
    local operation="${1:-manual}"
    _atomic_create_checkpoint "$operation"
    _log_success "Checkpoint created: $ATOMIC_CURRENT_CHECKPOINT"
}

git_submodules_restore() {
    local checkpoint="${1:-$ATOMIC_CURRENT_CHECKPOINT}"
    _atomic_restore_checkpoint "$checkpoint"
}

git_submodules_checkpoints() {
    _atomic_list_checkpoints
}

#=============================================================================
# Export Functions
#=============================================================================

# Atomic operations:
# - atomic_commit_all(message)
# - atomic_merge_all(branch)
# - atomic_checkout_all(branch)
#
# Manual checkpoint management:
# - git_submodules_checkpoint([operation])  - Create checkpoint
# - git_submodules_restore([checkpoint_id]) - Restore checkpoint
# - git_submodules_checkpoints()            - List checkpoints
