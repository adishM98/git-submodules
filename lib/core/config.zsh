#!/bin/zsh

#=============================================================================
# Configuration System Module
# Provides centralized configuration management
# Supports user customization without code edits
#=============================================================================

# Configuration file locations (in priority order)
GIT_SUBMODULES_CONFIG_LOCATIONS=(
    "$HOME/.config/git-submodules/config"
    "$HOME/.git-submodules.conf"
    "./.git-submodules.conf"
)

# Default configuration values
typeset -A GIT_SUBMODULES_CONFIG_DEFAULTS
GIT_SUBMODULES_CONFIG_DEFAULTS=(
    # Parallel execution
    parallel_enabled "false"
    parallel_jobs "4"

    # UI preferences
    menu_style "numbered"           # numbered, arrow, keyboard, both
    progress_style "bar"            # bar, spinner, dots, none
    emoji_enabled "true"

    # Safety
    atomic_commits "false"
    dry_run_default "false"
    confirm_destructive "true"

    # Performance
    cache_enabled "true"
    cache_ttl "60"

    # Verbosity
    verbose_mode "true"
    quiet_mode "false"

    # Stash behavior
    auto_stash "false"
    stash_include_untracked "false"
)

# Current configuration (loaded from file + defaults)
typeset -A GIT_SUBMODULES_CONFIG

#=============================================================================
# Configuration Loading
#=============================================================================

_config_init() {
    # Initialize with defaults
    for key value in ${(kv)GIT_SUBMODULES_CONFIG_DEFAULTS}; do
        GIT_SUBMODULES_CONFIG[$key]=$value
    done
}

_config_find_file() {
    # Find the first existing config file
    for config_file in "${GIT_SUBMODULES_CONFIG_LOCATIONS[@]}"; do
        if [[ -f "$config_file" ]]; then
            echo "$config_file"
            return 0
        fi
    done
    return 1
}

_config_load() {
    # Initialize with defaults first
    _config_init

    # Find and load config file
    local config_file=$(_config_find_file)
    if [[ -z "$config_file" ]]; then
        # No config file found, use defaults
        return 0
    fi

    # Parse config file (simple key=value format)
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue

        # Trim whitespace
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)

        # Remove quotes from value if present
        value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")

        # Set in config
        if [[ -n "$key" && -n "$value" ]]; then
            GIT_SUBMODULES_CONFIG[$key]=$value
        fi
    done < "$config_file"
}

#=============================================================================
# Configuration Access
#=============================================================================

_get_config() {
    local key="$1"
    local default="${2:-}"

    # Return config value or default
    echo "${GIT_SUBMODULES_CONFIG[$key]:-$default}"
}

_set_config() {
    local key="$1"
    local value="$2"

    # Set in memory
    GIT_SUBMODULES_CONFIG[$key]=$value
}

_config_exists() {
    local key="$1"
    [[ -n "${GIT_SUBMODULES_CONFIG[$key]}" ]]
}

#=============================================================================
# Configuration Persistence
#=============================================================================

_config_save() {
    local config_file="${1:-$HOME/.config/git-submodules/config}"

    # Create directory if needed
    local config_dir=$(dirname "$config_file")
    [[ ! -d "$config_dir" ]] && mkdir -p "$config_dir"

    # Write config file
    {
        echo "# Git Submodules Plugin Configuration"
        echo "# Generated: $(date)"
        echo ""
        echo "# Parallel execution"
        echo "parallel_enabled=$(_get_config parallel_enabled)"
        echo "parallel_jobs=$(_get_config parallel_jobs)"
        echo ""
        echo "# UI preferences"
        echo "menu_style=$(_get_config menu_style)"
        echo "progress_style=$(_get_config progress_style)"
        echo "emoji_enabled=$(_get_config emoji_enabled)"
        echo ""
        echo "# Safety"
        echo "atomic_commits=$(_get_config atomic_commits)"
        echo "dry_run_default=$(_get_config dry_run_default)"
        echo "confirm_destructive=$(_get_config confirm_destructive)"
        echo ""
        echo "# Performance"
        echo "cache_enabled=$(_get_config cache_enabled)"
        echo "cache_ttl=$(_get_config cache_ttl)"
        echo ""
        echo "# Verbosity"
        echo "verbose_mode=$(_get_config verbose_mode)"
        echo "quiet_mode=$(_get_config quiet_mode)"
        echo ""
        echo "# Stash behavior"
        echo "auto_stash=$(_get_config auto_stash)"
        echo "stash_include_untracked=$(_get_config stash_include_untracked)"
    } > "$config_file"

    _log_success "Configuration saved to $config_file"
}

_config_reset() {
    _config_init
    _log_success "Configuration reset to defaults"
}

#=============================================================================
# Configuration Helpers
#=============================================================================

_is_parallel_enabled() {
    [[ "$(_get_config parallel_enabled)" == "true" ]]
}

_get_parallel_jobs() {
    echo "$(_get_config parallel_jobs)"
}

_is_emoji_enabled() {
    [[ "$(_get_config emoji_enabled)" == "true" ]]
}

_is_atomic_commits_enabled() {
    [[ "$(_get_config atomic_commits)" == "true" ]]
}

_is_dry_run_default() {
    [[ "$(_get_config dry_run_default)" == "true" ]]
}

_should_confirm_destructive() {
    [[ "$(_get_config confirm_destructive)" == "true" ]]
}

_is_cache_enabled() {
    [[ "$(_get_config cache_enabled)" == "true" ]]
}

_get_menu_style() {
    echo "$(_get_config menu_style)"
}

_get_progress_style() {
    echo "$(_get_config progress_style)"
}

_is_auto_stash_enabled() {
    [[ "$(_get_config auto_stash)" == "true" ]]
}

#=============================================================================
# Interactive Configuration
#=============================================================================

configure_git_submodules() {
    echo "\n⚙️  === Git Submodules Configuration === ⚙️\n"

    # Parallel execution
    echo "🔀 Enable parallel execution? (current: $(_get_config parallel_enabled))"
    echo -n "   (true/false): "
    read parallel_enabled
    [[ -n "$parallel_enabled" ]] && _set_config parallel_enabled "$parallel_enabled"

    if [[ "$(_get_config parallel_enabled)" == "true" ]]; then
        echo "   Number of parallel jobs? (current: $(_get_config parallel_jobs))"
        echo -n "   (1-16): "
        read parallel_jobs
        [[ -n "$parallel_jobs" ]] && _set_config parallel_jobs "$parallel_jobs"
    fi

    # Menu style
    echo "\n📋 Menu style? (current: $(_get_config menu_style))"
    echo "   1) numbered  - Number-based selection (default)"
    echo "   2) arrow     - Arrow key navigation"
    echo "   3) keyboard  - Letter shortcuts"
    echo "   4) both      - Arrow keys + letter shortcuts"
    echo -n "   Choice (1-4): "
    read menu_choice
    case "$menu_choice" in
        1) _set_config menu_style "numbered" ;;
        2) _set_config menu_style "arrow" ;;
        3) _set_config menu_style "keyboard" ;;
        4) _set_config menu_style "both" ;;
    esac

    # Progress style
    echo "\n📊 Progress indicator style? (current: $(_get_config progress_style))"
    echo "   1) bar     - Progress bar [████░░]"
    echo "   2) spinner - Spinner ⠹"
    echo "   3) dots    - Dots ●●●○○"
    echo "   4) none    - No progress indicators"
    echo -n "   Choice (1-4): "
    read progress_choice
    case "$progress_choice" in
        1) _set_config progress_style "bar" ;;
        2) _set_config progress_style "spinner" ;;
        3) _set_config progress_style "dots" ;;
        4) _set_config progress_style "none" ;;
    esac

    # Safety options
    echo "\n🛡️  Safety Options"
    echo "   Enable atomic commits? (current: $(_get_config atomic_commits))"
    echo -n "   (true/false): "
    read atomic_commits
    [[ -n "$atomic_commits" ]] && _set_config atomic_commits "$atomic_commits"

    echo "   Confirm destructive operations? (current: $(_get_config confirm_destructive))"
    echo -n "   (true/false): "
    read confirm_destructive
    [[ -n "$confirm_destructive" ]] && _set_config confirm_destructive "$confirm_destructive"

    # Auto-stash
    echo "\n💾 Auto-stash before operations? (current: $(_get_config auto_stash))"
    echo -n "   (true/false): "
    read auto_stash
    [[ -n "$auto_stash" ]] && _set_config auto_stash "$auto_stash"

    # Save configuration
    echo "\n💾 Save configuration?"
    echo -n "   (y/N): "
    read save_choice

    if [[ "$save_choice" == "y" ]]; then
        _config_save
        echo "\n✅ Configuration saved!"
        echo "   Location: $HOME/.config/git-submodules/config"
    else
        echo "\n✅ Configuration updated (in-memory only)"
        echo "   Run 'configure_git_submodules' again to save"
    fi
}

#=============================================================================
# Show Configuration
#=============================================================================

show_git_submodules_config() {
    echo "\n⚙️  === Current Configuration === ⚙️\n"

    local config_file=$(_config_find_file)
    if [[ -n "$config_file" ]]; then
        echo "📄 Config file: $config_file\n"
    else
        echo "📄 Config file: None (using defaults)\n"
    fi

    echo "🔀 Parallel Execution:"
    echo "   Enabled:      $(_get_config parallel_enabled)"
    echo "   Jobs:         $(_get_config parallel_jobs)"

    echo "\n📋 UI Preferences:"
    echo "   Menu style:   $(_get_config menu_style)"
    echo "   Progress:     $(_get_config progress_style)"
    echo "   Emoji:        $(_get_config emoji_enabled)"

    echo "\n🛡️  Safety:"
    echo "   Atomic commits:    $(_get_config atomic_commits)"
    echo "   Dry-run default:   $(_get_config dry_run_default)"
    echo "   Confirm destroy:   $(_get_config confirm_destructive)"

    echo "\n⚡ Performance:"
    echo "   Cache enabled:     $(_get_config cache_enabled)"
    echo "   Cache TTL:         $(_get_config cache_ttl)s"

    echo "\n🔊 Verbosity:"
    echo "   Verbose:      $(_get_config verbose_mode)"
    echo "   Quiet:        $(_get_config quiet_mode)"

    echo "\n💾 Stash:"
    echo "   Auto-stash:   $(_get_config auto_stash)"
    echo "   Include untracked: $(_get_config stash_include_untracked)"

    echo ""
}

#=============================================================================
# Initialize on load
#=============================================================================

_config_load

#=============================================================================
# Export Functions
#=============================================================================

# Available functions:
# - _get_config(key, default)
# - _set_config(key, value)
# - _config_save([file])
# - _config_reset()
# - configure_git_submodules()  (interactive config)
# - show_git_submodules_config()
#
# Helper functions:
# - _is_parallel_enabled()
# - _get_parallel_jobs()
# - _is_emoji_enabled()
# - _is_atomic_commits_enabled()
# - _is_dry_run_default()
# - _should_confirm_destructive()
# - _is_cache_enabled()
# - _get_menu_style()
# - _get_progress_style()
# - _is_auto_stash_enabled()
