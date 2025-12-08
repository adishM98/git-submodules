# Theme System with Terminal Capability Detection
# Part of git-submodules plugin CLI enhancements

# ============================================================================
# Terminal Capability Detection
# ============================================================================

# Detect if terminal supports colors
_detect_terminal_capabilities() {
    # Check if stdout is a terminal
    if [[ ! -t 1 ]]; then
        return 1
    fi

    # Check color mode setting
    case "$GIT_SUBMODULES_COLOR" in
        never)
            return 1
            ;;
        always)
            return 0
            ;;
        auto)
            # Auto-detect: check if tput is available and terminal supports colors
            if command -v tput >/dev/null 2>&1; then
                local colors=$(tput colors 2>/dev/null || echo 0)
                [[ $colors -ge 8 ]] && return 0
            fi
            return 1
            ;;
        *)
            return 1
            ;;
    esac
}

# Cache terminal capability result for performance
_TERMINAL_SUPPORTS_COLOR=""
_check_color_support() {
    if [[ -z "$_TERMINAL_SUPPORTS_COLOR" ]]; then
        if _detect_terminal_capabilities; then
            _TERMINAL_SUPPORTS_COLOR="yes"
        else
            _TERMINAL_SUPPORTS_COLOR="no"
        fi
    fi
    [[ "$_TERMINAL_SUPPORTS_COLOR" == "yes" ]]
}

# ============================================================================
# ANSI Color Codes
# ============================================================================

# Color definitions
_COLOR_RESET="\033[0m"
_COLOR_BOLD="\033[1m"
_COLOR_DIM="\033[2m"

# Foreground colors
_COLOR_BLACK="\033[30m"
_COLOR_RED="\033[31m"
_COLOR_GREEN="\033[32m"
_COLOR_YELLOW="\033[33m"
_COLOR_BLUE="\033[34m"
_COLOR_MAGENTA="\033[35m"
_COLOR_CYAN="\033[36m"
_COLOR_WHITE="\033[37m"

# Background colors
_COLOR_BG_BLACK="\033[40m"
_COLOR_BG_RED="\033[41m"
_COLOR_BG_GREEN="\033[42m"
_COLOR_BG_YELLOW="\033[43m"
_COLOR_BG_BLUE="\033[44m"
_COLOR_BG_MAGENTA="\033[45m"
_COLOR_BG_CYAN="\033[46m"
_COLOR_BG_WHITE="\033[47m"

# ============================================================================
# Theme Color Application
# ============================================================================

# Apply color to text based on current theme
_theme_color() {
    local color_type="$1"
    local text="$2"

    # Skip coloring if theme doesn't support it
    case "$GIT_SUBMODULES_THEME" in
        plain|minimal)
            echo "$text"
            return 0
            ;;
    esac

    # ANSI theme: apply colors if terminal supports it
    if [[ "$GIT_SUBMODULES_THEME" == "ansi" ]] && _check_color_support; then
        case "$color_type" in
            info)
                echo "${_COLOR_CYAN}${text}${_COLOR_RESET}"
                ;;
            success)
                echo "${_COLOR_GREEN}${text}${_COLOR_RESET}"
                ;;
            warning)
                echo "${_COLOR_YELLOW}${text}${_COLOR_RESET}"
                ;;
            error)
                echo "${_COLOR_RED}${text}${_COLOR_RESET}"
                ;;
            bold)
                echo "${_COLOR_BOLD}${text}${_COLOR_RESET}"
                ;;
            dim)
                echo "${_COLOR_DIM}${text}${_COLOR_RESET}"
                ;;
            header)
                echo "${_COLOR_BOLD}${_COLOR_BLUE}${text}${_COLOR_RESET}"
                ;;
            prompt)
                echo "${_COLOR_MAGENTA}${text}${_COLOR_RESET}"
                ;;
            *)
                echo "$text"
                ;;
        esac
    else
        # Emoji theme or no color support: return text as-is
        echo "$text"
    fi
}

# ============================================================================
# Theme Icon Mapping
# ============================================================================

# Get icon based on type and current theme
_theme_icon() {
    local icon_type="$1"

    case "$GIT_SUBMODULES_THEME" in
        emoji)
            # Rich emoji icons (default)
            case "$icon_type" in
                info)       echo "ℹ️ " ;;
                success)    echo "✅" ;;
                warning)    echo "⚠️ " ;;
                error)      echo "❌" ;;
                prompt)     echo "🤔" ;;
                header)     echo "🔧" ;;
                branch)     echo "🌿" ;;
                repo)       echo "🏠" ;;
                submodule)  echo "📦" ;;
                all)        echo "🌍" ;;
                stash)      echo "💾" ;;
                pull)       echo "📥" ;;
                push)       echo "📤" ;;
                commit)     echo "💬" ;;
                checkout)   echo "🔄" ;;
                merge)      echo "🔀" ;;
                conflict)   echo "⚠️ " ;;
                status)     echo "📊" ;;
                feature)    echo "✨" ;;
                hotfix)     echo "🔥" ;;
                release)    echo "🚀" ;;
                sprint)     echo "🏃" ;;
                help)       echo "💡" ;;
                tutorial)   echo "🎓" ;;
                config)     echo "⚙️ " ;;
                file)       echo "📄" ;;
                folder)     echo "📁" ;;
                bullet)     echo "🔸" ;;
                check)      echo "✓" ;;
                cross)      echo "✗" ;;
                arrow)      echo "→" ;;
                *)          echo "" ;;
            esac
            ;;

        ansi)
            # ASCII characters (for use with ANSI colors)
            case "$icon_type" in
                info)       echo "[i]" ;;
                success)    echo "[✓]" ;;
                warning)    echo "[!]" ;;
                error)      echo "[✗]" ;;
                prompt)     echo "[?]" ;;
                header)     echo "[#]" ;;
                branch)     echo "[b]" ;;
                repo)       echo "[r]" ;;
                submodule)  echo "[s]" ;;
                all)        echo "[*]" ;;
                stash)      echo "[S]" ;;
                pull)       echo "[↓]" ;;
                push)       echo "[↑]" ;;
                commit)     echo "[c]" ;;
                checkout)   echo "[→]" ;;
                merge)      echo "[M]" ;;
                conflict)   echo "[!]" ;;
                status)     echo "[=]" ;;
                feature)    echo "[F]" ;;
                hotfix)     echo "[H]" ;;
                release)    echo "[R]" ;;
                sprint)     echo "[P]" ;;
                help)       echo "[?]" ;;
                tutorial)   echo "[T]" ;;
                config)     echo "[C]" ;;
                file)       echo "[f]" ;;
                folder)     echo "[d]" ;;
                bullet)     echo " •" ;;
                check)      echo " ✓" ;;
                cross)      echo " ✗" ;;
                arrow)      echo " →" ;;
                *)          echo "" ;;
            esac
            ;;

        plain)
            # Plain text labels
            case "$icon_type" in
                info)       echo "INFO:" ;;
                success)    echo "SUCCESS:" ;;
                warning)    echo "WARNING:" ;;
                error)      echo "ERROR:" ;;
                prompt)     echo "?" ;;
                header)     echo "===" ;;
                branch)     echo "Branch:" ;;
                repo)       echo "Repo:" ;;
                submodule)  echo "Submodule:" ;;
                all)        echo "All:" ;;
                stash)      echo "Stash:" ;;
                pull)       echo "Pull:" ;;
                push)       echo "Push:" ;;
                commit)     echo "Commit:" ;;
                checkout)   echo "Checkout:" ;;
                merge)      echo "Merge:" ;;
                conflict)   echo "Conflict:" ;;
                status)     echo "Status:" ;;
                feature)    echo "Feature:" ;;
                hotfix)     echo "Hotfix:" ;;
                release)    echo "Release:" ;;
                sprint)     echo "Sprint:" ;;
                help)       echo "Help:" ;;
                tutorial)   echo "Tutorial:" ;;
                config)     echo "Config:" ;;
                file)       echo "File:" ;;
                folder)     echo "Folder:" ;;
                bullet)     echo " -" ;;
                check)      echo " OK" ;;
                cross)      echo " NO" ;;
                arrow)      echo " ->" ;;
                *)          echo "" ;;
            esac
            ;;

        minimal)
            # Ultra-minimal: no icons
            echo ""
            ;;

        *)
            # Default to emoji
            _theme_icon "$icon_type" "emoji"
            ;;
    esac
}

# ============================================================================
# Convenience Functions
# ============================================================================

# Format a header with theme-appropriate styling
_theme_header() {
    local text="$1"
    local icon=$(_theme_icon "header")
    local colored=$(_theme_color "header" "$text")

    echo ""
    echo "$icon === $colored ==="
    echo ""
}

# Format a section with theme-appropriate styling
_theme_section() {
    local text="$1"
    local colored=$(_theme_color "bold" "$text")
    echo ""
    echo "$colored"
}

# Format a bullet point
_theme_bullet() {
    local text="$1"
    local icon=$(_theme_icon "bullet")
    echo "$icon $text"
}

# Format a prompt
_theme_prompt() {
    local text="$1"
    local icon=$(_theme_icon "prompt")
    local colored=$(_theme_color "prompt" "$text")
    echo -n "$icon $colored"
}
