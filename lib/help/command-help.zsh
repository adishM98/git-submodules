# Command --help Flag Support
# Part of git-submodules plugin CLI enhancements
# Enables --help and -h flags for all commands

# ============================================================================
# --help Flag Handler
# ============================================================================

# Check if user is requesting help and display it
# Returns 0 if help was shown, 1 if not
_with_help() {
    local command_name="$1"
    shift

    # Check all arguments for --help or -h flag
    for arg in "$@"; do
        if [[ "$arg" == "--help" ]] || [[ "$arg" == "-h" ]]; then
            help "$command_name"
            return 0
        fi
    done

    # No help requested
    return 1
}

# ============================================================================
# Quick Help Snippets
# ============================================================================

# Show brief usage for a command (one-liner)
_quick_help() {
    local command="$1"

    case "$command" in
        pull_all)
            echo "Usage: pull_all - Pull changes from all repositories"
            ;;
        push_all)
            echo "Usage: push_all - Push changes to all repositories"
            ;;
        add_all)
            echo "Usage: add_all - Stage all changes across all repositories"
            ;;
        commit_all)
            echo "Usage: commit_all <message> - Commit changes with message"
            ;;
        status_all)
            echo "Usage: status_all - Show status of all repositories"
            ;;
        start_feature)
            echo "Usage: start_feature - Create feature branch (interactive)"
            ;;
        start_hotfix)
            echo "Usage: start_hotfix - Create hotfix branch (interactive)"
            ;;
        checkout_all)
            echo "Usage: checkout_all - Checkout branch (interactive)"
            ;;
        merge_all)
            echo "Usage: merge_all - Merge branches (interactive)"
            ;;
        smart_commit_all)
            echo "Usage: smart_commit_all - Smart commit with AI-like suggestions"
            ;;
        *)
            echo "Usage: $command - Run '$command --help' for details"
            ;;
    esac
}
