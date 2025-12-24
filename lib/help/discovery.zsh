# Command Discovery System
# Part of git-submodules plugin CLI enhancements
# Helps users discover and search for commands

# ============================================================================
# Command Registry
# ============================================================================

# All available commands organized by category
_GIT_SUBMODULES_COMMANDS=(
    # Core Operations
    "pull_all:Pull changes from all repositories:core"
    "push_all:Push changes to all repositories:core"
    "add_all:Stage all changes:core"
    "commit_all:Commit changes with message:core"
    "status_all:Show status of all repositories:core"

    # Branch Management
    "checkout_all:Checkout branch interactively:branch"
    "merge_all:Merge branches interactively:branch"
    "create_branch_all:Create branch non-interactively:branch"
    "start_feature:Create feature branch:branch"
    "start_hotfix:Create hotfix branch:branch"
    "start_release:Create release branch:branch"
    "start_sprint:Create sprint branch:branch"
    "create_feature_all:Create feature branch in all repos:branch"
    "create_hotfix_all:Create hotfix branch in all repos:branch"
    "create_release_all:Create release branch in all repos:branch"

    # Smart Features
    "smart_commit_all:Smart commit with generated messages:smart"
    "generate_commit_message:Generate commit message suggestions:smart"
    "resolve_submodule_conflicts:Resolve submodule conflicts:smart"

    # Configuration
    "git_submodules_status:Show plugin and repo status:config"
    "toggle_verbose:Toggle verbose output mode:config"
    "set_theme:Change display theme:config"
    "configure_git_submodules:Interactive configuration wizard:config"
    "show_config:Show current configuration:config"
    "save_config:Save configuration setting:config"

    # Help & Discovery
    "help:Show help system:help"
    "list_commands:List all commands by category:help"
    "search_commands:Search commands by keyword:help"

    # Aliases
    "add_alias:Add custom command alias:aliases"
    "remove_alias:Remove custom alias:aliases"
    "list_aliases:Show all aliases:aliases"
)

# ============================================================================
# List Commands
# ============================================================================

# List all commands organized by category
list_commands() {
    local list_icon=$(_theme_icon "info")

    _theme_header "Available Commands"

    # Core Operations
    _theme_section "CORE OPERATIONS"
    for entry in "${_GIT_SUBMODULES_COMMANDS[@]}"; do
        local cmd="${entry%%:*}"
        local desc="${entry#*:}"; desc="${desc%%:*}"
        local category="${entry##*:}"

        if [[ "$category" == "core" ]]; then
            printf "   %-25s %s\n" "$cmd" "$desc"
        fi
    done
    echo ""

    # Branch Management
    _theme_section "BRANCH MANAGEMENT"
    for entry in "${_GIT_SUBMODULES_COMMANDS[@]}"; do
        local cmd="${entry%%:*}"
        local desc="${entry#*:}"; desc="${desc%%:*}"
        local category="${entry##*:}"

        if [[ "$category" == "branch" ]]; then
            printf "   %-25s %s\n" "$cmd" "$desc"
        fi
    done
    echo ""

    # Smart Features
    _theme_section "SMART FEATURES"
    for entry in "${_GIT_SUBMODULES_COMMANDS[@]}"; do
        local cmd="${entry%%:*}"
        local desc="${entry#*:}"; desc="${desc%%:*}"
        local category="${entry##*:}"

        if [[ "$category" == "smart" ]]; then
            printf "   %-25s %s\n" "$cmd" "$desc"
        fi
    done
    echo ""

    # Configuration
    _theme_section "CONFIGURATION"
    for entry in "${_GIT_SUBMODULES_COMMANDS[@]}"; do
        local cmd="${entry%%:*}"
        local desc="${entry#*:}"; desc="${desc%%:*}"
        local category="${entry##*:}"

        if [[ "$category" == "config" ]]; then
            printf "   %-25s %s\n" "$cmd" "$desc"
        fi
    done
    echo ""

    # Help & Discovery
    _theme_section "HELP & DISCOVERY"
    for entry in "${_GIT_SUBMODULES_COMMANDS[@]}"; do
        local cmd="${entry%%:*}"
        local desc="${entry#*:}"; desc="${desc%%:*}"
        local category="${entry##*:}"

        if [[ "$category" == "help" ]]; then
            printf "   %-25s %s\n" "$cmd" "$desc"
        fi
    done
    echo ""

    # Aliases
    _theme_section "ALIAS MANAGEMENT"
    for entry in "${_GIT_SUBMODULES_COMMANDS[@]}"; do
        local cmd="${entry%%:*}"
        local desc="${entry#*:}"; desc="${desc%%:*}"
        local category="${entry##*:}"

        if [[ "$category" == "aliases" ]]; then
            printf "   %-25s %s\n" "$cmd" "$desc"
        fi
    done
    echo ""

    local help_icon=$(_theme_icon "help")
    echo "$help_icon For detailed help on any command:"
    echo "   help <command>        Comprehensive help"
    echo "   <command> --help      Quick help"
    echo ""
}

# ============================================================================
# Search Commands
# ============================================================================

# Search for commands by keyword
search_commands() {
    local keyword="$1"

    if [[ -z "$keyword" ]]; then
        _log_error "Usage: search_commands <keyword>"
        echo ""
        echo "Example: search_commands commit"
        echo "         search_commands branch"
        echo ""
        return 1
    fi

    local search_icon=$(_theme_icon "info")
    local found=0

    echo ""
    echo "$search_icon Commands matching '$keyword':"
    echo ""

    # Convert keyword to lowercase for case-insensitive search
    keyword="${keyword:l}"

    for entry in "${_GIT_SUBMODULES_COMMANDS[@]}"; do
        local cmd="${entry%%:*}"
        local desc="${entry#*:}"; desc="${desc%%:*}"

        # Check if keyword matches command name or description (case-insensitive)
        if [[ "${cmd:l}" == *"$keyword"* ]] || [[ "${desc:l}" == *"$keyword"* ]]; then
            printf "   %-25s %s\n" "$cmd" "$desc"
            found=1
        fi
    done

    if [[ $found -eq 0 ]]; then
        echo "   No commands found matching '$keyword'"
        echo ""
        echo "   Try:"
        _theme_bullet "list_commands        - See all commands"
        _theme_bullet "help                 - Main help menu"
    fi

    echo ""

    local help_icon=$(_theme_icon "help")
    echo "$help_icon For detailed help:"
    echo "   help <command>"
    echo "   <command> --help"
    echo ""
}

# ============================================================================
# Command Completion Helpers
# ============================================================================

# Get list of all command names (for completion)
_get_all_command_names() {
    for entry in "${_GIT_SUBMODULES_COMMANDS[@]}"; do
        echo "${entry%%:*}"
    done
}

# Get commands by category (for completion)
_get_commands_by_category() {
    local category="$1"

    for entry in "${_GIT_SUBMODULES_COMMANDS[@]}"; do
        local cmd="${entry%%:*}"
        local cat="${entry##*:}"

        if [[ "$cat" == "$category" ]]; then
            echo "$cmd"
        fi
    done
}
