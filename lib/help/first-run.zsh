# First-Run Experience
# Part of git-submodules plugin CLI enhancements
# Shows welcome message on first use (optional feature)

# ============================================================================
# First Run Detection
# ============================================================================

# Marker file to track first run
_FIRST_RUN_MARKER="${HOME}/.config/git-submodules/.first_run_complete"

# Check if this is the first run
_is_first_run() {
    [[ ! -f "$_FIRST_RUN_MARKER" ]]
}

# Mark first run as complete
_mark_first_run_complete() {
    local marker_dir="$(dirname "$_FIRST_RUN_MARKER")"
    mkdir -p "$marker_dir"
    touch "$_FIRST_RUN_MARKER"
}

# ============================================================================
# Welcome Message
# ============================================================================

# Show welcome message for first-time users
_show_welcome() {
    local welcome_icon=$(_theme_icon "info")

    echo ""
    echo "✨ ================================================== ✨"
    echo "   Welcome to Git Submodules Plugin!"
    echo "✨ ================================================== ✨"
    echo ""

    echo "QUICK START:"
    echo "   1. Check status:    git_submodules_status"
    echo "   2. Get help:        help"
    echo "   3. Try tutorial:    help tutorial"
    echo ""

    echo "ESSENTIAL COMMANDS:"
    _theme_bullet "pull_all            Update all repositories"
    _theme_bullet "start_feature       Create a feature branch"
    _theme_bullet "smart_commit_all    Intelligent commits"
    _theme_bullet "status_all          Check all repo statuses"
    echo ""

    echo "CUSTOMIZATION:"
    _theme_bullet "set_theme <theme>   Change display (emoji/ansi/plain/minimal)"
    _theme_bullet "toggle_verbose      Control output detail"
    _theme_bullet "configure_git_submodules    Interactive setup"
    echo ""

    echo "HELP & DISCOVERY:"
    _theme_bullet "help                Main help menu"
    _theme_bullet "help tutorial       Step-by-step guide"
    _theme_bullet "list_commands       Show all commands"
    _theme_bullet "<command> --help    Quick help for any command"
    echo ""

    echo "$welcome_icon Tip: This message won't show again. Run 'help' anytime for assistance."
    echo ""
}

# ============================================================================
# First Run Check (called from plugin initialization)
# ============================================================================

# Check and show welcome if first run
# This function should be called from the main plugin file
_check_first_run() {
    # Skip if GIT_SUBMODULES_NO_WELCOME is set
    if [[ -n "$GIT_SUBMODULES_NO_WELCOME" ]]; then
        return 0
    fi

    if _is_first_run; then
        _show_welcome
        _mark_first_run_complete
    fi
}

# ============================================================================
# Manual Functions
# ============================================================================

# Force show welcome message
show_welcome() {
    _show_welcome
}

# Reset first-run status (for testing or re-showing welcome)
reset_first_run() {
    rm -f "$_FIRST_RUN_MARKER"
    _log_success "First-run status reset"
    echo "   Run 'source ${GIT_SUBMODULES_PLUGIN_DIR}/git-submodules.plugin.zsh' to see welcome message"
}
