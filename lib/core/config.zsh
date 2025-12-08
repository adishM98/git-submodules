# Configuration Management System
# Part of git-submodules plugin CLI enhancements

# ============================================================================
# Configuration Variables with Defaults
# ============================================================================

# Default values (maintain backward compatibility)
: ${GIT_SUBMODULES_THEME:="emoji"}        # emoji, ansi, plain, minimal
: ${GIT_SUBMODULES_VERBOSE:="true"}       # true, false
: ${GIT_SUBMODULES_COLOR:="auto"}         # auto, always, never

# Configuration file locations (checked in order)
GIT_SUBMODULES_CONFIG_LOCATIONS=(
    "${HOME}/.config/git-submodules/config"
    "${HOME}/.git-submodules.conf"
    "${GIT_SUBMODULES_PLUGIN_DIR}/config/git-submodules.conf"
)

# ============================================================================
# Configuration Loading
# ============================================================================

# Load user configuration from file
_load_config() {
    for config_file in "${GIT_SUBMODULES_CONFIG_LOCATIONS[@]}"; do
        if [[ -f "$config_file" ]]; then
            source "$config_file"
            [[ "$GIT_SUBMODULES_VERBOSE" == "true" ]] && echo "ℹ️  Config loaded from: $config_file"
            return 0
        fi
    done

    # No config file found - use defaults
    return 0
}

# ============================================================================
# Configuration Saving
# ============================================================================

# Save configuration to file
save_config() {
    local key="$1"
    local value="$2"

    if [[ -z "$key" ]] || [[ -z "$value" ]]; then
        echo "❌ Usage: save_config <key> <value>"
        return 1
    fi

    local config_file="${HOME}/.config/git-submodules/config"
    local config_dir="$(dirname "$config_file")"

    # Create config directory if it doesn't exist
    if [[ ! -d "$config_dir" ]]; then
        mkdir -p "$config_dir"
    fi

    # Update or append configuration
    if [[ -f "$config_file" ]] && grep -q "^export ${key}=" "$config_file"; then
        # Update existing key
        sed -i.bak "s|^export ${key}=.*|export ${key}=\"${value}\"|" "$config_file"
        rm -f "${config_file}.bak"
    else
        # Append new key
        echo "export ${key}=\"${value}\"" >> "$config_file"
    fi

    # Update current session
    export "${key}=${value}"

    echo "✅ Saved: ${key}=${value}"
    echo "   Config file: $config_file"

    return 0
}

# ============================================================================
# Configuration Display
# ============================================================================

# Show current configuration
show_config() {
    echo ""
    echo "🔧 === Git Submodules Plugin Configuration ==="
    echo ""
    echo "📋 Current Settings:"
    echo "   Theme:           $GIT_SUBMODULES_THEME"
    echo "   Verbose:         $GIT_SUBMODULES_VERBOSE"
    echo "   Color Mode:      $GIT_SUBMODULES_COLOR"
    echo ""

    # Show config file location
    for config_file in "${GIT_SUBMODULES_CONFIG_LOCATIONS[@]}"; do
        if [[ -f "$config_file" ]]; then
            echo "📁 Config File: $config_file"
            return 0
        fi
    done

    echo "📁 Config File: None (using defaults)"
    echo ""
    echo "💡 Tip: Use 'save_config KEY VALUE' to persist settings"
    echo "   Example: save_config GIT_SUBMODULES_THEME ansi"
    echo ""
}

# Alias for convenience
show_git_submodules_config() {
    show_config
}

# ============================================================================
# Theme Management
# ============================================================================

# Set theme and persist
set_theme() {
    local theme="$1"

    if [[ -z "$theme" ]]; then
        echo "❌ Usage: set_theme <theme>"
        echo "   Available themes: emoji, ansi, plain, minimal"
        return 1
    fi

    # Validate theme
    case "$theme" in
        emoji|ansi|plain|minimal)
            save_config "GIT_SUBMODULES_THEME" "$theme"
            echo "✅ Theme changed to: $theme"
            echo "   Reload your shell or run: source ${GIT_SUBMODULES_PLUGIN_DIR}/git-submodules.plugin.zsh"
            return 0
            ;;
        *)
            echo "❌ Invalid theme: $theme"
            echo "   Available: emoji, ansi, plain, minimal"
            return 1
            ;;
    esac
}

# ============================================================================
# Interactive Configuration Wizard (Optional Future Enhancement)
# ============================================================================

# Interactive configuration wizard
configure_git_submodules() {
    echo ""
    echo "⚙️  === Git Submodules Plugin Configuration Wizard ==="
    echo ""

    # Theme selection
    echo "🎨 Select Display Theme:"
    echo "   1) emoji    - Rich emoji icons (default, best for modern terminals)"
    echo "   2) ansi     - ANSI colors with simple ASCII characters"
    echo "   3) plain    - Plain text only (accessibility mode)"
    echo "   4) minimal  - Ultra-minimal output"
    echo ""
    echo -n "Choice (1-4) [1]: "
    read -r theme_choice

    case "${theme_choice:-1}" in
        1) save_config "GIT_SUBMODULES_THEME" "emoji" ;;
        2) save_config "GIT_SUBMODULES_THEME" "ansi" ;;
        3) save_config "GIT_SUBMODULES_THEME" "plain" ;;
        4) save_config "GIT_SUBMODULES_THEME" "minimal" ;;
        *) echo "⚠️  Invalid choice, keeping current theme" ;;
    esac

    echo ""

    # Verbose mode
    echo "🔊 Verbose Output:"
    echo "   1) On  - Detailed output (default)"
    echo "   2) Off - Minimal output"
    echo ""
    echo -n "Choice (1-2) [1]: "
    read -r verbose_choice

    case "${verbose_choice:-1}" in
        1) save_config "GIT_SUBMODULES_VERBOSE" "true" ;;
        2) save_config "GIT_SUBMODULES_VERBOSE" "false" ;;
        *) echo "⚠️  Invalid choice, keeping current setting" ;;
    esac

    echo ""

    # Color mode
    echo "🌈 Color Mode:"
    echo "   1) auto   - Detect terminal capabilities (default)"
    echo "   2) always - Force color output"
    echo "   3) never  - Disable all colors"
    echo ""
    echo -n "Choice (1-3) [1]: "
    read -r color_choice

    case "${color_choice:-1}" in
        1) save_config "GIT_SUBMODULES_COLOR" "auto" ;;
        2) save_config "GIT_SUBMODULES_COLOR" "always" ;;
        3) save_config "GIT_SUBMODULES_COLOR" "never" ;;
        *) echo "⚠️  Invalid choice, keeping current setting" ;;
    esac

    echo ""
    echo "✅ Configuration complete!"
    echo ""
    echo "💡 To apply changes, reload your shell or run:"
    echo "   source ${GIT_SUBMODULES_PLUGIN_DIR}/git-submodules.plugin.zsh"
    echo ""
}
