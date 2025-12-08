#!/bin/zsh

#=============================================================================
# Validation & Dry-Run Module
# Provides pre-flight validation and operation preview
# Critical safety feature for production use
#=============================================================================

# Dry-run mode flag (can be set by CLI flags)
GIT_SUBMODULES_DRY_RUN=${GIT_SUBMODULES_DRY_RUN:-false}

#=============================================================================
# Validation Functions
#=============================================================================

_validate_git_repository() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        _log_error "Not a git repository"
        return 1
    fi
    return 0
}

_validate_branch_exists() {
    local branch="$1"
    git rev-parse --verify "$branch" >/dev/null 2>&1
}

_validate_branch_name() {
    local branch="$1"

    if [[ -z "$branch" ]]; then
        _log_error "Branch name cannot be empty"
        return 1
    fi

    # Check for invalid characters
    if [[ "$branch" =~ [[:space:]~^:\\?*\[] ]]; then
        _log_error "Branch name contains invalid characters"
        return 1
    fi

    return 0
}

_validate_clean_working_tree() {
    local repo_path="${1:-.}"

    (
        cd "$repo_path" || return 1
        if [[ -n "$(git status --porcelain)" ]]; then
            return 1
        fi
    )
}

_validate_no_merge_conflicts() {
    local repo_path="${1:-.}"

    (
        cd "$repo_path" || return 1
        # Check if there are unmerged files
        git ls-files -u | grep -q .
        # Return opposite (0 = no conflicts, 1 = has conflicts)
        [[ $? -ne 0 ]]
    )
}

_validate_upstream_exists() {
    local branch="${1:-$(git rev-parse --abbrev-ref HEAD)}"

    git rev-parse --verify "@{upstream}" >/dev/null 2>&1
}

_validate_commit_message() {
    local message="$1"

    if [[ -z "$message" ]]; then
        _log_error "Commit message cannot be empty"
        return 1
    fi

    # Check minimum length (at least 5 characters for meaningful commits)
    if [[ ${#message} -lt 5 ]]; then
        _log_warning "Commit message is very short (less than 5 characters)"
        return 1
    fi

    return 0
}

#=============================================================================
# Pre-flight Checks
#=============================================================================

_preflight_commit() {
    local message="$1"

    _validate_git_repository || return 1
    _validate_commit_message "$message" || return 1

    # Check if there are staged changes
    if [[ -z "$(git diff --cached --name-only)" ]]; then
        _log_warning "No staged changes to commit"
        return 1
    fi

    return 0
}

_preflight_push() {
    _validate_git_repository || return 1

    # Check if upstream exists
    if ! _validate_upstream_exists; then
        _log_warning "No upstream branch configured"
    fi

    # Check if there are commits to push
    local ahead=$(git rev-list @{upstream}..HEAD 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$ahead" -eq 0 ]]; then
        _log_info "No commits to push (already up to date)"
        return 1
    fi

    return 0
}

_preflight_merge() {
    local branch="$1"

    _validate_git_repository || return 1
    _validate_branch_exists "$branch" || {
        _log_error "Branch '$branch' does not exist"
        return 1
    }

    # Check for merge conflicts
    if ! _validate_no_merge_conflicts; then
        _log_error "There are unresolved merge conflicts"
        return 1
    fi

    return 0
}

_preflight_checkout() {
    local branch="$1"

    _validate_git_repository || return 1
    _validate_branch_name "$branch" || return 1

    # Optionally check for uncommitted changes
    if [[ "$(_get_config auto_stash)" != "true" ]]; then
        if ! _validate_clean_working_tree; then
            _log_warning "Working tree has uncommitted changes"
            _log_info "Use --auto-stash or commit/stash changes first"
            return 1
        fi
    fi

    return 0
}

#=============================================================================
# Preview/Dry-Run Functions
#=============================================================================

_preview_header() {
    local operation="$1"
    echo "\n╭─────────────────────────────────────╮"
    echo "│  🔍  DRY-RUN PREVIEW: $operation"
    echo "╰─────────────────────────────────────╯\n"
}

_preview_footer() {
    echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "💡 This is a preview only. No changes were made."
    echo "   Remove --dry-run flag to execute."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
}

_preview_commit() {
    local message="$1"

    _preview_header "commit_all"

    echo "📝 Commit Message:"
    echo "   \"$message\"\n"

    # Check base repository
    if [[ -n "$(git diff --cached --name-only)" ]]; then
        echo "🏠 Base Repository:"
        echo "   Branch: $(git rev-parse --abbrev-ref HEAD)"
        echo "   Files:"
        git diff --cached --name-status | while read status file; do
            case "$status" in
                A) echo "     ✅ $file (added)" ;;
                M) echo "     🔄 $file (modified)" ;;
                D) echo "     ❌ $file (deleted)" ;;
                *) echo "     📄 $file ($status)" ;;
            esac
        done
        echo ""
    fi

    # Check submodules
    local submodules=$(_get_all_submodules)
    if [[ -n "$submodules" ]]; then
        echo "$submodules" | while IFS= read -r submodule; do
            if [[ -n "$submodule" ]]; then
                (
                    cd "$submodule" || return
                    if [[ -n "$(git diff --cached --name-only)" ]]; then
                        echo "📦 $submodule:"
                        echo "   Branch: $(git rev-parse --abbrev-ref HEAD)"
                        echo "   Files:"
                        git diff --cached --name-status | while read status file; do
                            case "$status" in
                                A) echo "     ✅ $file (added)" ;;
                                M) echo "     🔄 $file (modified)" ;;
                                D) echo "     ❌ $file (deleted)" ;;
                                *) echo "     📄 $file ($status)" ;;
                            esac
                        done
                        echo ""
                    fi
                )
            fi
        done
    fi

    _preview_footer
}

_preview_push() {
    _preview_header "push_all"

    # Base repository
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    local ahead=$(git rev-list @{upstream}..HEAD 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$ahead" -gt 0 ]]; then
        echo "🏠 Base Repository:"
        echo "   Branch: $current_branch"
        echo "   Commits to push: $ahead"
        echo "   Commits:"
        git log --oneline @{upstream}..HEAD | head -5 | while read line; do
            echo "     • $line"
        done
        echo ""
    fi

    # Submodules
    local submodules=$(_get_all_submodules)
    if [[ -n "$submodules" ]]; then
        echo "$submodules" | while IFS= read -r submodule; do
            if [[ -n "$submodule" ]]; then
                (
                    cd "$submodule" || return
                    local sub_branch=$(git rev-parse --abbrev-ref HEAD)
                    local sub_ahead=$(git rev-list @{upstream}..HEAD 2>/dev/null | wc -l | tr -d ' ')

                    if [[ "$sub_ahead" -gt 0 ]]; then
                        echo "📦 $submodule:"
                        echo "   Branch: $sub_branch"
                        echo "   Commits to push: $sub_ahead"
                        echo "   Commits:"
                        git log --oneline @{upstream}..HEAD | head -5 | while read line; do
                            echo "     • $line"
                        done
                        echo ""
                    fi
                )
            fi
        done
    fi

    _preview_footer
}

_preview_pull() {
    _preview_header "pull_all"

    echo "🔄 Will pull from remote for:"
    echo "   🏠 Base repository"

    local submodules=$(_get_all_submodules)
    if [[ -n "$submodules" ]]; then
        local count=$(_get_submodule_count)
        echo "   📦 $count submodules"
        echo ""
        echo "Submodules:"
        echo "$submodules" | while IFS= read -r submodule; do
            [[ -n "$submodule" ]] && echo "     • $submodule"
        done
    fi

    echo ""
    _preview_footer
}

_preview_merge() {
    local base_branch="$1"
    local scope="${2:-all}"

    _preview_header "merge_all"

    echo "🔀 Merge Details:"
    echo "   From: $base_branch"
    echo "   Scope: $scope\n"

    if [[ "$scope" == "base" ]] || [[ "$scope" == "all" ]]; then
        echo "🏠 Base Repository:"
        echo "   Current: $(git rev-parse --abbrev-ref HEAD)"
        echo "   Target: $base_branch"
        echo ""
    fi

    if [[ "$scope" == "submodules" ]] || [[ "$scope" == "all" ]]; then
        local submodules=$(_get_all_submodules)
        if [[ -n "$submodules" ]]; then
            echo "📦 Submodules:"
            echo "$submodules" | while IFS= read -r submodule; do
                if [[ -n "$submodule" ]]; then
                    local sub_branch=$(cd "$submodule" && git rev-parse --abbrev-ref HEAD)
                    echo "   • $submodule (on $sub_branch)"
                fi
            done
            echo ""
        fi
    fi

    _preview_footer
}

#=============================================================================
# Dry-Run Wrapper
#=============================================================================

_is_dry_run() {
    [[ "$GIT_SUBMODULES_DRY_RUN" == "true" ]] || [[ "$(_is_dry_run_default)" == "true" ]]
}

_check_dry_run_and_preview() {
    local operation="$1"
    shift
    local args="$@"

    if _is_dry_run; then
        case "$operation" in
            commit)
                _preview_commit "$args"
                return 1
                ;;
            push)
                _preview_push
                return 1
                ;;
            pull)
                _preview_pull
                return 1
                ;;
            merge)
                _preview_merge "$args"
                return 1
                ;;
            *)
                _log_info "🔍 Dry-run mode active for: $operation"
                _preview_footer
                return 1
                ;;
        esac
    fi

    return 0
}

#=============================================================================
# Confirmation Prompts
#=============================================================================

_confirm_destructive_operation() {
    local operation="$1"
    local details="${2:-}"

    if ! _should_confirm_destructive; then
        return 0
    fi

    echo "\n⚠️  Destructive Operation: $operation"
    if [[ -n "$details" ]]; then
        echo "   $details"
    fi
    echo -n "   Continue? (y/N): "
    read -q
    echo ""

    [[ "$REPLY" == "y" ]]
}

#=============================================================================
# Export Functions
#=============================================================================

# Available functions:
#
# Validation:
# - _validate_git_repository()
# - _validate_branch_exists(branch)
# - _validate_branch_name(branch)
# - _validate_clean_working_tree([path])
# - _validate_no_merge_conflicts([path])
# - _validate_upstream_exists([branch])
# - _validate_commit_message(message)
#
# Pre-flight checks:
# - _preflight_commit(message)
# - _preflight_push()
# - _preflight_merge(branch)
# - _preflight_checkout(branch)
#
# Preview/dry-run:
# - _preview_commit(message)
# - _preview_push()
# - _preview_pull()
# - _preview_merge(branch, scope)
# - _is_dry_run()
# - _check_dry_run_and_preview(operation, args...)
#
# Confirmation:
# - _confirm_destructive_operation(operation, [details])
