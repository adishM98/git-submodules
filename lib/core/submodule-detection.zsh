#!/bin/zsh

#=============================================================================
# Submodule Detection Module
# Provides dynamic submodule discovery with caching
# Replaces all hardcoded submodule paths
#=============================================================================

# Cache directory
SUBMODULE_CACHE_DIR="${TMPDIR:-/tmp}/git-submodules-$$"
SUBMODULE_CACHE_TTL=60  # 60 seconds

#=============================================================================
# Cache Functions
#=============================================================================

_cache_init() {
    [[ ! -d "$SUBMODULE_CACHE_DIR" ]] && mkdir -p "$SUBMODULE_CACHE_DIR"
}

_cache_get() {
    local key="$1"
    local cache_file="$SUBMODULE_CACHE_DIR/$key"

    # Check if cache exists and is still valid
    if [[ -f "$cache_file" ]]; then
        local age=$(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null)))
        if [[ $age -lt $SUBMODULE_CACHE_TTL ]]; then
            cat "$cache_file"
            return 0
        fi
    fi

    return 1
}

_cache_set() {
    local key="$1"
    local value="$2"
    local cache_file="$SUBMODULE_CACHE_DIR/$key"

    _cache_init
    echo "$value" > "$cache_file"
}

_cache_clear() {
    [[ -d "$SUBMODULE_CACHE_DIR" ]] && rm -rf "$SUBMODULE_CACHE_DIR"
}

#=============================================================================
# Submodule Detection Functions
#=============================================================================

# Get all submodule paths
_get_all_submodules() {
    local cached

    # Try cache first
    if cached=$(_cache_get "submodules_list"); then
        echo "$cached"
        return 0
    fi

    # Not in cache, query git
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        _log_error "Not a git repository"
        return 1
    fi

    local submodules
    submodules=($(git submodule status --recursive 2>/dev/null | awk '{print $2}'))

    if [[ ${#submodules[@]} -eq 0 ]]; then
        # No submodules found
        _cache_set "submodules_list" ""
        return 0
    fi

    # Cache the result
    local result="${(j:\n:)submodules}"
    _cache_set "submodules_list" "$result"

    echo "$result"
    return 0
}

# Get submodule count
_get_submodule_count() {
    local submodules
    submodules=$(_get_all_submodules)

    if [[ -z "$submodules" ]]; then
        echo "0"
    else
        echo "$submodules" | wc -l | tr -d ' '
    fi
}

# Get current branch for a submodule
_get_submodule_branch() {
    local submodule_path="$1"

    if [[ ! -d "$submodule_path" ]]; then
        return 1
    fi

    (
        cd "$submodule_path" || return 1
        git rev-parse --abbrev-ref HEAD 2>/dev/null
    )
}

# Validate submodule path exists
_validate_submodule_path() {
    local path="$1"
    local submodules
    submodules=$(_get_all_submodules)

    echo "$submodules" | grep -q "^${path}$"
}

# Check if repository has submodules
_has_submodules() {
    local count=$(_get_submodule_count)
    [[ "$count" -gt 0 ]]
}

# Get submodule status (clean, dirty, etc.)
_get_submodule_status() {
    local submodule_path="$1"

    if [[ ! -d "$submodule_path" ]]; then
        echo "not_found"
        return 1
    fi

    (
        cd "$submodule_path" || return 1
        if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
            echo "dirty"
        else
            echo "clean"
        fi
    )
}

# Execute command for each submodule
_foreach_submodule() {
    local command="$1"
    local submodules
    submodules=$(_get_all_submodules)

    if [[ -z "$submodules" ]]; then
        return 0
    fi

    echo "$submodules" | while IFS= read -r submodule; do
        if [[ -n "$submodule" ]]; then
            (
                cd "$submodule" || {
                    _log_error "Failed to enter submodule: $submodule"
                    return 1
                }
                eval "$command"
            )
        fi
    done
}

# Get submodule URL
_get_submodule_url() {
    local submodule_path="$1"
    git config --file .gitmodules --get "submodule.${submodule_path}.url"
}

# Check if path is a submodule
_is_submodule() {
    local path="$1"
    _validate_submodule_path "$path"
}

# Get submodule name from path
_get_submodule_name() {
    local path="$1"
    basename "$path"
}

# Clear all caches
clear_submodule_cache() {
    _cache_clear
    _log_success "Submodule cache cleared"
}

#=============================================================================
# Interactive Submodule Selection
#=============================================================================

# Show submodules with numbers for selection
_select_submodules_interactive() {
    local submodules
    submodules=$(_get_all_submodules)

    if [[ -z "$submodules" ]]; then
        _log_warning "No submodules found in this repository"
        return 1
    fi

    echo "\n📦 Available submodules:"
    local i=1
    echo "$submodules" | while IFS= read -r submodule; do
        if [[ -n "$submodule" ]]; then
            echo "  $i️⃣  🔹 $submodule"
            ((i++))
        fi
    done

    echo "  $i️⃣  🌍 All submodules"

    echo -n "\n🤔 Enter your choice (1-$i): "
    read choice

    local count=$(echo "$submodules" | wc -l | tr -d ' ')

    if [[ "$choice" == "$((count + 1))" ]]; then
        echo "$submodules"
    elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "$count" ]]; then
        echo "$submodules" | sed -n "${choice}p"
    else
        _log_error "Invalid choice"
        return 1
    fi
}

#=============================================================================
# Export Functions
#=============================================================================

# These functions are available to the plugin
# _get_all_submodules
# _get_submodule_count
# _get_submodule_branch
# _validate_submodule_path
# _has_submodules
# _get_submodule_status
# _foreach_submodule
# _get_submodule_url
# _is_submodule
# _get_submodule_name
# _select_submodules_interactive
# clear_submodule_cache
