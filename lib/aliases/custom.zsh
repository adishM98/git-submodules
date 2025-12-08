# Custom Alias Management System
# Part of git-submodules plugin CLI enhancements
# Allows users to create and manage their own command aliases

# ============================================================================
# Configuration
# ============================================================================

# Custom aliases file location
_CUSTOM_ALIASES_FILE="${HOME}/.config/git-submodules/aliases"

# ============================================================================
# Load Custom Aliases
# ============================================================================

# Load custom aliases from file
_load_custom_aliases() {
    if [[ -f "$_CUSTOM_ALIASES_FILE" ]]; then
        source "$_CUSTOM_ALIASES_FILE"
        [[ "$GIT_SUBMODULES_VERBOSE" == "true" ]] && \
            _log_info "Custom aliases loaded from: $_CUSTOM_ALIASES_FILE"
    fi
}

# ============================================================================
# Add Custom Alias
# ============================================================================

# Add a custom alias and persist it
add_alias() {
    local alias_name="$1"
    local alias_command="$2"

    if [[ -z "$alias_name" ]] || [[ -z "$alias_command" ]]; then
        _log_error "Usage: add_alias <name> <command>"
        echo ""
        echo "Examples:"
        _theme_bullet "add_alias mywork \"start_feature && echo 'Ready to code!'\""
        _theme_bullet "add_alias sync \"pull_all && push_all\""
        _theme_bullet "add_alias quickcommit \"add_all && smart_commit_all\""
        echo ""
        return 1
    fi

    # Validate alias name (alphanumeric, hyphen, underscore only)
    if [[ ! "$alias_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        _log_error "Invalid alias name: '$alias_name'"
        echo ""
        echo "   Alias names must contain only letters, numbers, hyphens, and underscores"
        echo ""
        return 1
    fi

    # Create aliases directory if it doesn't exist
    local aliases_dir="$(dirname "$_CUSTOM_ALIASES_FILE")"
    if [[ ! -d "$aliases_dir" ]]; then
        mkdir -p "$aliases_dir"
    fi

    # Check if alias already exists
    if [[ -f "$_CUSTOM_ALIASES_FILE" ]] && grep -q "^alias ${alias_name}=" "$_CUSTOM_ALIASES_FILE"; then
        local warning_icon=$(_theme_icon "warning")
        echo "$warning_icon Alias '$alias_name' already exists"
        echo ""
        echo -n "Overwrite? (y/n): "
        read -r response

        case "$response" in
            y|Y|yes|Yes|YES)
                # Remove old alias definition
                sed -i.bak "/^alias ${alias_name}=/d" "$_CUSTOM_ALIASES_FILE"
                rm -f "${_CUSTOM_ALIASES_FILE}.bak"
                ;;
            *)
                echo "Cancelled."
                return 0
                ;;
        esac
    fi

    # Add alias to file
    echo "alias ${alias_name}='${alias_command}'" >> "$_CUSTOM_ALIASES_FILE"

    # Load the new alias in current session
    alias "${alias_name}=${alias_command}"

    _log_success "Alias added: $alias_name → $alias_command"
    echo "   File: $_CUSTOM_ALIASES_FILE"
    echo ""
}

# ============================================================================
# Remove Custom Alias
# ============================================================================

# Remove a custom alias
remove_alias() {
    local alias_name="$1"

    if [[ -z "$alias_name" ]]; then
        _log_error "Usage: remove_alias <name>"
        echo ""
        echo "To see your custom aliases, run: list_aliases"
        echo ""
        return 1
    fi

    if [[ ! -f "$_CUSTOM_ALIASES_FILE" ]]; then
        _log_error "No custom aliases file found"
        echo "   File: $_CUSTOM_ALIASES_FILE"
        return 1
    fi

    # Check if alias exists
    if ! grep -q "^alias ${alias_name}=" "$_CUSTOM_ALIASES_FILE"; then
        _log_error "Alias not found: $alias_name"
        echo ""
        echo "To see your custom aliases, run: list_aliases"
        echo ""
        return 1
    fi

    # Remove alias from file
    sed -i.bak "/^alias ${alias_name}=/d" "$_CUSTOM_ALIASES_FILE"
    rm -f "${_CUSTOM_ALIASES_FILE}.bak"

    # Unalias in current session
    unalias "$alias_name" 2>/dev/null

    _log_success "Alias removed: $alias_name"
    echo "   Reload your shell to apply changes"
    echo ""
}

# ============================================================================
# List All Aliases
# ============================================================================

# List both built-in and custom aliases
list_aliases() {
    _theme_header "Git Submodules Plugin Aliases"

    # Show built-in aliases
    _list_builtin_aliases

    # Show custom aliases if they exist
    if [[ -f "$_CUSTOM_ALIASES_FILE" ]] && [[ -s "$_CUSTOM_ALIASES_FILE" ]]; then
        _theme_section "CUSTOM ALIASES"

        local count=0
        while IFS= read -r line; do
            # Skip comments and empty lines
            [[ "$line" =~ ^#.*  ]] && continue
            [[ -z "$line" ]] && continue

            # Parse alias line: alias name='command'
            if [[ "$line" =~ ^alias\ ([^=]+)=\'(.*)\'$ ]] || [[ "$line" =~ ^alias\ ([^=]+)=\"(.*)\"$ ]]; then
                local name="${match[1]}"
                local cmd="${match[2]}"
                printf "   %-15s → %s\n" "$name" "$cmd"
                ((count++))
            fi
        done < "$_CUSTOM_ALIASES_FILE"

        if [[ $count -eq 0 ]]; then
            echo "   No custom aliases defined"
        fi
        echo ""
    else
        _theme_section "CUSTOM ALIASES"
        echo "   No custom aliases defined"
        echo ""
        echo "   Create one with:"
        _theme_bullet "add_alias <name> <command>"
        echo ""
    fi

    local help_icon=$(_theme_icon "help")
    echo "$help_icon Alias Management:"
    _theme_bullet "add_alias <name> <cmd>     - Add custom alias"
    _theme_bullet "remove_alias <name>        - Remove custom alias"
    _theme_bullet "list_aliases               - Show this list"
    echo ""
}

# ============================================================================
# Alias File Management
# ============================================================================

# Edit custom aliases file directly
edit_aliases() {
    local editor="${EDITOR:-vi}"

    if [[ ! -f "$_CUSTOM_ALIASES_FILE" ]]; then
        local aliases_dir="$(dirname "$_CUSTOM_ALIASES_FILE")"
        mkdir -p "$aliases_dir"
        touch "$_CUSTOM_ALIASES_FILE"

        # Add header comment
        cat > "$_CUSTOM_ALIASES_FILE" << 'EOF'
# Custom Git Submodules Plugin Aliases
# Add your aliases here in the format:
# alias name='command'
#
# Examples:
# alias mywork='start_feature && echo "Ready to code!"'
# alias sync='pull_all && push_all'
# alias quickcommit='add_all && smart_commit_all'

EOF
    fi

    $editor "$_CUSTOM_ALIASES_FILE"

    _log_success "Aliases file edited"
    echo "   Reload your shell to apply changes:"
    echo "   source ${GIT_SUBMODULES_PLUGIN_DIR}/git-submodules.plugin.zsh"
    echo ""
}

# Clear all custom aliases
clear_aliases() {
    if [[ ! -f "$_CUSTOM_ALIASES_FILE" ]]; then
        _log_info "No custom aliases to clear"
        return 0
    fi

    local warning_icon=$(_theme_icon "warning")
    echo "$warning_icon This will delete ALL custom aliases"
    echo ""
    echo -n "Are you sure? (y/n): "
    read -r response

    case "$response" in
        y|Y|yes|Yes|YES)
            rm -f "$_CUSTOM_ALIASES_FILE"
            _log_success "All custom aliases cleared"
            echo "   Reload your shell to apply changes"
            echo ""
            ;;
        *)
            echo "Cancelled."
            ;;
    esac
}
