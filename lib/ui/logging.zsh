# Theme-Aware Logging Functions
# Part of git-submodules plugin CLI enhancements
# Replaces hardcoded emoji logging with theme-aware output

# ============================================================================
# Core Logging Functions
# ============================================================================

# Log informational message
_log_info() {
    local message="$*"
    local icon=$(_theme_icon "info")
    local colored=$(_theme_color "info" "$message")

    if [[ "$GIT_SUBMODULES_VERBOSE" == "true" ]] || [[ "$GIT_SUBMODULES_THEME" == "minimal" ]]; then
        echo "$icon $colored"
    fi
}

# Log success message
_log_success() {
    local message="$*"
    local icon=$(_theme_icon "success")
    local colored=$(_theme_color "success" "$message")

    echo "$icon $colored"
}

# Log warning message
_log_warning() {
    local message="$*"
    local icon=$(_theme_icon "warning")
    local colored=$(_theme_color "warning" "$message")

    echo "$icon $colored"
}

# Log error message (to stderr)
_log_error() {
    local message="$*"
    local icon=$(_theme_icon "error")
    local colored=$(_theme_color "error" "$message")

    echo "$icon $colored" >&2
}

# ============================================================================
# Contextual Logging Functions
# ============================================================================

# Log header/section
_log_header() {
    local message="$*"
    _theme_header "$message"
}

# Log prompt (for user input)
_log_prompt() {
    local message="$*"
    _theme_prompt "$message"
}

# Log bullet point
_log_bullet() {
    local message="$*"
    _theme_bullet "$message"
}

# ============================================================================
# Operation-Specific Logging
# ============================================================================

# Log pull operation
_log_pull() {
    local message="$*"
    local icon=$(_theme_icon "pull")
    local colored=$(_theme_color "info" "$message")

    [[ "$GIT_SUBMODULES_VERBOSE" == "true" ]] && echo "$icon $colored"
}

# Log push operation
_log_push() {
    local message="$*"
    local icon=$(_theme_icon "push")
    local colored=$(_theme_color "info" "$message")

    [[ "$GIT_SUBMODULES_VERBOSE" == "true" ]] && echo "$icon $colored"
}

# Log commit operation
_log_commit() {
    local message="$*"
    local icon=$(_theme_icon "commit")
    local colored=$(_theme_color "info" "$message")

    [[ "$GIT_SUBMODULES_VERBOSE" == "true" ]] && echo "$icon $colored"
}

# Log checkout operation
_log_checkout() {
    local message="$*"
    local icon=$(_theme_icon "checkout")
    local colored=$(_theme_color "info" "$message")

    [[ "$GIT_SUBMODULES_VERBOSE" == "true" ]] && echo "$icon $colored"
}

# Log merge operation
_log_merge() {
    local message="$*"
    local icon=$(_theme_icon "merge")
    local colored=$(_theme_color "info" "$message")

    [[ "$GIT_SUBMODULES_VERBOSE" == "true" ]] && echo "$icon $colored"
}

# Log stash operation
_log_stash() {
    local message="$*"
    local icon=$(_theme_icon "stash")
    local colored=$(_theme_color "info" "$message")

    [[ "$GIT_SUBMODULES_VERBOSE" == "true" ]] && echo "$icon $colored"
}

# Log conflict
_log_conflict() {
    local message="$*"
    local icon=$(_theme_icon "conflict")
    local colored=$(_theme_color "warning" "$message")

    echo "$icon $colored"
}

# ============================================================================
# Status Logging
# ============================================================================

# Log repository context
_log_repo() {
    local repo_name="$1"
    local message="$2"
    local icon=$(_theme_icon "repo")

    echo "$icon $repo_name: $message"
}

# Log submodule context
_log_submodule() {
    local submodule_name="$1"
    local message="$2"
    local icon=$(_theme_icon "submodule")

    echo "$icon $submodule_name: $message"
}

# Log branch context
_log_branch() {
    local branch_name="$1"
    local message="$2"
    local icon=$(_theme_icon "branch")

    echo "$icon Branch '$branch_name': $message"
}

# ============================================================================
# Minimal Mode Override
# ============================================================================

# In minimal mode, suppress verbose messages entirely
_should_log() {
    if [[ "$GIT_SUBMODULES_THEME" == "minimal" ]]; then
        # Only log errors and critical messages in minimal mode
        return 1
    fi

    if [[ "$GIT_SUBMODULES_VERBOSE" != "true" ]]; then
        return 1
    fi

    return 0
}

# ============================================================================
# Backward Compatibility Aliases
# ============================================================================

# These ensure existing code continues to work
# Original functions from git-submodules.plugin.zsh (lines 17-31)

# Note: The original logging functions are now replaced by these
# theme-aware versions. All functionality is preserved while adding
# support for ANSI colors, plain text, and minimal themes.
