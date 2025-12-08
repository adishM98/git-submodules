#!/bin/zsh

#=============================================================================
# Operation History Module
# Tracks operations for undo/redo capability
# Provides safety net for mistakes
#=============================================================================

# History file location
HISTORY_FILE="$HOME/.local/share/git-submodules/history.log"
HISTORY_MAX_ENTRIES=100

#=============================================================================
# History Recording
#=============================================================================

history_record() {
    local operation="$1"
    local args="$2"
    local result="${3:-success}"
    local timestamp=$(date +%s)
    local git_hash=$(git rev-parse HEAD 2>/dev/null || echo "none")

    # Create history directory if needed
    local history_dir=$(dirname "$HISTORY_FILE")
    [[ ! -d "$history_dir" ]] && mkdir -p "$history_dir"

    # Record entry
    echo "$timestamp|$operation|$args|$result|$git_hash" >> "$HISTORY_FILE"

    # Trim to max entries
    if [[ $(wc -l < "$HISTORY_FILE") -gt $HISTORY_MAX_ENTRIES ]]; then
        tail -n $HISTORY_MAX_ENTRIES "$HISTORY_FILE" > "${HISTORY_FILE}.tmp"
        mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
    fi
}

#=============================================================================
# History Display
#=============================================================================

git_submodules_history() {
    local count="${1:-10}"

    if [[ ! -f "$HISTORY_FILE" ]]; then
        _log_info "No operation history found"
        return 0
    fi

    echo "\n📜 === Recent Operations (last $count) ===\n"

    tail -n "$count" "$HISTORY_FILE" | nl -v 1 | while IFS='|' read -r num timestamp operation args result git_hash; do
        # Parse timestamp
        local num=$(echo "$num" | xargs)
        local timestamp=$(echo "$timestamp" | xargs)
        local time_str=$(date -r "$timestamp" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "$timestamp")

        # Format result
        local status_icon="✅"
        [[ "$result" != "success" ]] && status_icon="❌"

        # Display
        echo "  $num. [$time_str] $status_icon $operation $args"
    done

    echo ""
}

#=============================================================================
# Undo Operations
#=============================================================================

git_submodules_undo() {
    local entry_num="${1:-1}"

    if [[ ! -f "$HISTORY_FILE" ]]; then
        _log_error "No operation history found"
        return 1
    fi

    # Get the entry
    local entry=$(tail -n "$HISTORY_MAX_ENTRIES" "$HISTORY_FILE" | tail -n "$entry_num" | head -1)

    if [[ -z "$entry" ]]; then
        _log_error "Invalid entry number: $entry_num"
        return 1
    fi

    # Parse entry
    local timestamp operation args result git_hash
    IFS='|' read -r timestamp operation args result git_hash <<< "$entry"

    echo "\n⚠️  Undo Operation"
    echo "   Operation: $operation $args"
    echo "   Time: $(date -r "$timestamp" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)"
    echo ""

    # Confirm
    if ! prompt_yes_no "   Continue with undo?"; then
        _log_warning "Undo cancelled"
        return 0
    fi

    # Perform undo based on operation type
    case "$operation" in
        commit_all)
            _undo_commit
            ;;
        push_all)
            _log_warning "Cannot undo push - commits are on remote"
            _log_info "Use 'git revert' manually if needed"
            return 1
            ;;
        merge_all)
            _undo_merge
            ;;
        checkout_all)
            _log_info "Checkout operations are reversible - just checkout previous branch"
            return 0
            ;;
        *)
            _log_error "Undo not supported for operation: $operation"
            return 1
            ;;
    esac
}

_undo_commit() {
    echo "\n🔙 Undoing last commit..."
    echo "   This will reset to previous commit (changes kept staged)"

    # Base repo
    if git rev-parse HEAD~1 >/dev/null 2>&1; then
        git reset --soft HEAD~1
        _log_success "Base repository commit undone"
    fi

    # Submodules
    local submodules=$(_get_all_submodules)
    if [[ -n "$submodules" ]]; then
        echo "$submodules" | while IFS= read -r submodule; do
            if [[ -n "$submodule" ]]; then
                (
                    cd "$submodule" || return
                    if git rev-parse HEAD~1 >/dev/null 2>&1; then
                        git reset --soft HEAD~1
                        echo "  ✅ $submodule commit undone"
                    fi
                )
            fi
        done
    fi

    _log_success "Commit undone in all repositories"
}

_undo_merge() {
    echo "\n🔙 Undoing merge..."
    echo "   This will abort the merge if in progress, or reset to pre-merge state"

    # Check if merge in progress
    if [[ -f ".git/MERGE_HEAD" ]]; then
        git merge --abort
        _log_success "Merge aborted"
    else
        _log_warning "No active merge to undo"
        _log_info "Use 'git reset --hard ORIG_HEAD' manually if needed"
    fi
}

#=============================================================================
# Clear History
#=============================================================================

git_submodules_clear_history() {
    if [[ ! -f "$HISTORY_FILE" ]]; then
        _log_info "No history to clear"
        return 0
    fi

    echo -n "⚠️  Clear all operation history? (y/N): "
    read -q confirm
    echo ""

    if [[ "$confirm" == "y" ]]; then
        rm "$HISTORY_FILE"
        _log_success "History cleared"
    else
        _log_info "Cancelled"
    fi
}

#=============================================================================
# Export Functions
#=============================================================================

# Available functions:
# - history_record(operation, args, [result])
# - git_submodules_history([count])
# - git_submodules_undo([entry_num])
# - git_submodules_clear_history()
