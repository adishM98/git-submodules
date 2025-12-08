# Error Handling & Validation System
# Part of git-submodules plugin CLI enhancements
# Provides contextual errors, recovery suggestions, and validation

# ============================================================================
# Error Codes
# ============================================================================

# Define error codes for consistent error handling
ERR_NOT_GIT_REPO=1        # Not in a git repository
ERR_NO_BRANCH=2           # Branch name missing
ERR_NO_SUBMODULES=3       # No submodules found
ERR_MERGE_CONFLICT=4      # Merge conflict detected
ERR_DETACHED_HEAD=5       # In detached HEAD state
ERR_NO_UPSTREAM=6         # No upstream tracking branch
ERR_INVALID_INPUT=7       # Invalid user input
ERR_OPERATION_FAILED=8    # General operation failure

# ============================================================================
# Enhanced Error Reporting
# ============================================================================

# Display error with contextual help and recovery suggestions
_error_with_help() {
    local error_code="$1"
    local error_message="$2"
    local context="${3:-}"

    # Display error message
    _log_error "$error_message"

    # Show context if provided
    if [[ -n "$context" ]]; then
        echo ""
        echo "Context: $context"
    fi

    # Show help based on error code
    local help_icon=$(_theme_icon "help")
    echo ""
    echo "$help_icon Help:"

    case "$error_code" in
        $ERR_NOT_GIT_REPO)
            echo "   This command requires a Git repository."
            echo "   $(_theme_bullet 'Run: cd /path/to/your/repo')"
            echo "   $(_theme_bullet 'Or initialize: git init')"
            echo "   $(_theme_bullet 'Check status: git_submodules_status')"
            ;;

        $ERR_NO_BRANCH)
            echo "   Branch name is required for this operation."
            echo "   $(_theme_bullet 'Usage: <command> <branch-name>')"
            echo "   $(_theme_bullet 'Example: start_feature user-authentication')"
            echo "   $(_theme_bullet 'Tip: Use descriptive branch names')"
            ;;

        $ERR_NO_SUBMODULES)
            echo "   No submodules found in this repository."
            echo "   $(_theme_bullet 'Add submodule: git submodule add <url> <path>')"
            echo "   $(_theme_bullet 'Initialize: git submodule update --init')"
            echo "   $(_theme_bullet 'Check: git submodule status')"
            ;;

        $ERR_MERGE_CONFLICT)
            echo "   Merge conflicts must be resolved before continuing."
            echo "   $(_theme_bullet 'View conflicts: git status')"
            echo "   $(_theme_bullet 'Resolve: edit conflicted files')"
            echo "   $(_theme_bullet 'For submodules: resolve_submodule_conflicts')"
            echo "   $(_theme_bullet 'After resolving: git add . && commit_all')"
            ;;

        $ERR_DETACHED_HEAD)
            echo "   Repository is in detached HEAD state."
            echo "   $(_theme_bullet 'Create branch: git checkout -b <branch-name>')"
            echo "   $(_theme_bullet 'Return to branch: git checkout <branch-name>')"
            echo "   $(_theme_bullet 'Check status: git_submodules_status')"
            ;;

        $ERR_NO_UPSTREAM)
            echo "   No upstream tracking branch configured."
            echo "   $(_theme_bullet 'Set upstream: git branch --set-upstream-to=origin/<branch>')"
            echo "   $(_theme_bullet 'Push with upstream: git push -u origin <branch>')"
            ;;

        $ERR_INVALID_INPUT)
            echo "   Invalid input provided."
            echo "   $(_theme_bullet 'Check command usage: <command> --help')"
            echo "   $(_theme_bullet 'See all commands: list_commands')"
            ;;

        $ERR_OPERATION_FAILED)
            echo "   Operation failed. Check the error message above."
            echo "   $(_theme_bullet 'Try again with: toggle_verbose (for more details)')"
            echo "   $(_theme_bullet 'Get help: help <command>')"
            ;;

        *)
            echo "   An error occurred. See message above for details."
            echo "   $(_theme_bullet 'Get help: help')"
            ;;
    esac

    echo ""
    return "$error_code"
}

# ============================================================================
# Validation Functions
# ============================================================================

# Validate that we're in a git repository
_validate_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        _error_with_help $ERR_NOT_GIT_REPO "Not a Git repository"
        return $ERR_NOT_GIT_REPO
    fi
    return 0
}

# Validate branch name is provided
_validate_branch_name() {
    local branch_name="$1"
    local command_context="${2:-command}"

    if [[ -z "$branch_name" ]]; then
        _error_with_help $ERR_NO_BRANCH "Branch name is required" "$command_context"
        return $ERR_NO_BRANCH
    fi

    # Check if branch name is valid (no spaces, special chars, etc.)
    if [[ ! "$branch_name" =~ ^[a-zA-Z0-9/_-]+$ ]]; then
        _log_error "Invalid branch name: '$branch_name'"
        echo ""
        local help_icon=$(_theme_icon "help")
        echo "$help_icon Valid branch names:"
        echo "   $(_theme_bullet 'Use letters, numbers, hyphens, underscores, slashes')"
        echo "   $(_theme_bullet 'Example: feature/user-auth')"
        echo "   $(_theme_bullet 'Example: hotfix/fix-login-bug')"
        echo ""
        return $ERR_INVALID_INPUT
    fi

    return 0
}

# Validate that submodules exist
_validate_has_submodules() {
    if ! git submodule status > /dev/null 2>&1 || [[ $(git submodule status | wc -l) -eq 0 ]]; then
        _error_with_help $ERR_NO_SUBMODULES "No submodules found in repository"
        return $ERR_NO_SUBMODULES
    fi
    return 0
}

# Validate no merge conflicts exist
_validate_no_conflicts() {
    if git ls-files -u | grep -q .; then
        _error_with_help $ERR_MERGE_CONFLICT "Merge conflicts detected"
        return $ERR_MERGE_CONFLICT
    fi
    return 0
}

# ============================================================================
# Pre-Flight Checks
# ============================================================================

# Run pre-operation checks and display status
_pre_operation_check() {
    local operation="$1"

    if [[ "$GIT_SUBMODULES_VERBOSE" != "true" ]]; then
        return 0
    fi

    local check_icon=$(_theme_icon "info")
    echo ""
    echo "$check_icon Pre-flight check for: $operation"
    echo ""

    # Check git repo
    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo "   $(_theme_icon 'check') Git repository detected"
    else
        echo "   $(_theme_icon 'cross') Not a Git repository"
        return 1
    fi

    # Check for uncommitted changes
    if [[ -n "$(git status --porcelain)" ]]; then
        local warning_icon=$(_theme_icon "warning")
        echo "   $warning_icon Uncommitted changes detected"
        echo "      Tip: Use 'add_all' and 'commit_all' to save changes"
    else
        echo "   $(_theme_icon 'check') Working directory clean"
    fi

    # Check for submodules
    local submodule_count=$(git submodule status 2>/dev/null | wc -l | tr -d ' ')
    if [[ $submodule_count -gt 0 ]]; then
        echo "   $(_theme_icon 'check') Submodules found: $submodule_count"
    else
        echo "   $(_theme_icon 'info') No submodules found"
    fi

    # Check current branch
    local current_branch=$(git branch --show-current 2>/dev/null)
    if [[ -n "$current_branch" ]]; then
        echo "   $(_theme_icon 'check') Current branch: $current_branch"
    else
        local warning_icon=$(_theme_icon "warning")
        echo "   $warning_icon Detached HEAD state"
    fi

    echo ""
    return 0
}

# ============================================================================
# "Did You Mean?" Suggestions
# ============================================================================

# Suggest similar commands when user makes a typo
_suggest_similar_commands() {
    local input="$1"
    local min_similarity=3  # Minimum number of matching characters

    # List of all available commands
    local commands=(
        "pull_all" "push_all" "add_all" "commit_all" "status_all"
        "checkout_all" "merge_all" "create_branch_all"
        "start_feature" "start_hotfix" "start_release" "start_sprint"
        "create_feature_all" "create_hotfix_all" "create_release_all"
        "smart_commit_all" "generate_commit_message"
        "resolve_submodule_conflicts"
        "git_submodules_status" "toggle_verbose"
        "help" "list_commands" "search_commands"
        "set_theme" "configure_git_submodules"
    )

    local suggestions=()

    # Simple fuzzy matching: check if input is substring or close match
    for cmd in "${commands[@]}"; do
        # Check if input is a substring of command
        if [[ "$cmd" == *"$input"* ]]; then
            suggestions+=("$cmd")
        # Check if command starts with input
        elif [[ "$cmd" == "$input"* ]]; then
            suggestions+=("$cmd")
        fi
    done

    # Display suggestions if found
    if [[ ${#suggestions[@]} -gt 0 ]]; then
        local help_icon=$(_theme_icon "help")
        echo ""
        echo "$help_icon Did you mean:"
        for suggestion in "${suggestions[@]}"; do
            echo "   $(_theme_bullet "$suggestion")"
        done
        echo ""
        return 0
    fi

    return 1
}

# ============================================================================
# Input Validation Helpers
# ============================================================================

# Validate choice from menu
_validate_choice() {
    local choice="$1"
    local min="$2"
    local max="$3"

    if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
        _log_error "Invalid input: '$choice' is not a number"
        echo ""
        echo "   $(_theme_bullet 'Please enter a number between $min and $max')"
        echo ""
        return $ERR_INVALID_INPUT
    fi

    if [[ $choice -lt $min ]] || [[ $choice -gt $max ]]; then
        _log_error "Invalid choice: $choice"
        echo ""
        echo "   $(_theme_bullet 'Please enter a number between $min and $max')"
        echo ""
        return $ERR_INVALID_INPUT
    fi

    return 0
}

# Validate yes/no input
_validate_yes_no() {
    local input="$1"

    case "$input" in
        y|Y|yes|Yes|YES)
            return 0
            ;;
        n|N|no|No|NO)
            return 1
            ;;
        *)
            _log_warning "Invalid input: '$input'"
            echo "   $(_theme_bullet 'Please enter y or n')"
            return 2
            ;;
    esac
}
