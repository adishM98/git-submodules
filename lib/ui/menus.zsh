#!/bin/zsh

#=============================================================================
# Enhanced Menu System Module
# Provides multiple menu interaction modes:
# - Numbered selection (default, backward compatible)
# - Arrow key navigation (modern, interactive)
# - Keyboard shortcuts (fast, power users)
# - Combined mode (arrow keys + shortcuts)
#=============================================================================

#=============================================================================
# Menu Rendering
#=============================================================================

_menu_render_numbered() {
    local title="$1"
    shift
    local options=("$@")

    echo "\n$title"
    echo "════════════════════════════════════"

    local i=1
    for option in "${options[@]}"; do
        echo "$i️⃣  $option"
        ((i++))
    done
    echo ""
}

_menu_render_arrow() {
    local title="$1"
    local selected="$2"
    shift 2
    local options=("$@")

    # Clear screen for better UX (optional)
    # tput clear

    echo "\n$title"
    echo "════════════════════════════════════"

    local i=1
    for option in "${options[@]}"; do
        if [[ $i -eq $selected ]]; then
            echo "→ $option  ← "
        else
            echo "  $option"
        fi
        ((i++))
    done

    echo ""
    echo "Use ↑/↓ arrows, Enter to select, 'q' to cancel"
}

_menu_render_keyboard() {
    local title="$1"
    shift
    local options=("$@")

    echo "\n$title"
    echo "════════════════════════════════════"

    # Extract shortcuts from options (first letter of first word)
    local i=1
    for option in "${options[@]}"; do
        # Get first word and extract first letter
        local first_word=$(echo "$option" | awk '{print $1}')
        local shortcut=$(echo "$first_word" | cut -c1 | tr '[:upper:]' '[:lower:]')

        echo "[$shortcut] $option"
        ((i++))
    done

    echo "\n[q] Quit"
    echo ""
}

_menu_render_both() {
    local title="$1"
    local selected="$2"
    shift 2
    local options=("$@")

    echo "\n$title"
    echo "════════════════════════════════════"

    local i=1
    for option in "${options[@]}"; do
        local first_word=$(echo "$option" | awk '{print $1}')
        local shortcut=$(echo "$first_word" | cut -c1 | tr '[:upper:]' '[:lower:]')

        if [[ $i -eq $selected ]]; then
            echo "→ [$shortcut] $option  ← "
        else
            echo "  [$shortcut] $option"
        fi
        ((i++))
    done

    echo ""
    echo "Use ↑/↓ arrows or letters, Enter to select, 'q' to cancel"
}

#=============================================================================
# Arrow Key Navigation
#=============================================================================

_menu_read_arrow_key() {
    local key
    read -k key

    case "$key" in
        $'\e')  # Escape sequence
            read -k key
            if [[ "$key" == "[" ]]; then
                read -k key
                case "$key" in
                    A) echo "up" ;;
                    B) echo "down" ;;
                    *) echo "unknown" ;;
                esac
            else
                echo "escape"
            fi
            ;;
        $'\n') echo "enter" ;;
        q|Q) echo "quit" ;;
        *) echo "$key" ;;
    esac
}

_menu_arrow_navigation() {
    local title="$1"
    shift
    local options=("$@")
    local selected=1
    local max=${#options[@]}

    while true; do
        _menu_render_arrow "$title" "$selected" "${options[@]}"

        local key=$(_menu_read_arrow_key)

        case "$key" in
            up)
                ((selected--))
                [[ $selected -lt 1 ]] && selected=$max
                ;;
            down)
                ((selected++))
                [[ $selected -gt $max ]] && selected=1
                ;;
            enter)
                echo "$selected"
                return 0
                ;;
            quit|escape)
                return 1
                ;;
        esac

        # Clear previous render (move cursor up)
        local lines_to_clear=$((max + 5))
        for ((i=0; i<lines_to_clear; i++)); do
            tput cuu1  # Move cursor up
            tput el    # Clear line
        done
    done
}

#=============================================================================
# Keyboard Shortcuts
#=============================================================================

_menu_keyboard_shortcuts() {
    local title="$1"
    shift
    local options=("$@")

    _menu_render_keyboard "$title" "${options[@]}"

    # Build shortcut map
    typeset -A shortcut_map
    local i=1
    for option in "${options[@]}"; do
        local first_word=$(echo "$option" | awk '{print $1}')
        local shortcut=$(echo "$first_word" | cut -c1 | tr '[:upper:]' '[:lower:]')
        shortcut_map[$shortcut]=$i
        ((i++))
    done

    echo -n "Enter choice: "
    read -k choice
    echo ""

    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

    if [[ "$choice" == "q" ]]; then
        return 1
    fi

    local selected=${shortcut_map[$choice]}
    if [[ -n "$selected" ]]; then
        echo "$selected"
        return 0
    else
        _log_error "Invalid choice: $choice"
        return 1
    fi
}

#=============================================================================
# Combined Mode (Arrow + Keyboard)
#=============================================================================

_menu_combined_navigation() {
    local title="$1"
    shift
    local options=("$@")
    local selected=1
    local max=${#options[@]}

    # Build shortcut map
    typeset -A shortcut_map
    local i=1
    for option in "${options[@]}"; do
        local first_word=$(echo "$option" | awk '{print $1}')
        local shortcut=$(echo "$first_word" | cut -c1 | tr '[:upper:]' '[:lower:]')
        shortcut_map[$shortcut]=$i
        ((i++))
    done

    while true; do
        _menu_render_both "$title" "$selected" "${options[@]}"

        local key=$(_menu_read_arrow_key)

        case "$key" in
            up)
                ((selected--))
                [[ $selected -lt 1 ]] && selected=$max
                ;;
            down)
                ((selected++))
                [[ $selected -gt $max ]] && selected=1
                ;;
            enter)
                echo "$selected"
                return 0
                ;;
            quit|escape)
                return 1
                ;;
            *)
                # Check if it's a keyboard shortcut
                local key_lower=$(echo "$key" | tr '[:upper:]' '[:lower:]')
                if [[ -n "${shortcut_map[$key_lower]}" ]]; then
                    echo "${shortcut_map[$key_lower]}"
                    return 0
                fi
                ;;
        esac

        # Clear previous render
        local lines_to_clear=$((max + 6))
        for ((i=0; i<lines_to_clear; i++)); do
            tput cuu1
            tput el
        done
    done
}

#=============================================================================
# Numbered Selection (Default/Backward Compatible)
#=============================================================================

_menu_numbered_selection() {
    local title="$1"
    shift
    local options=("$@")
    local max=${#options[@]}

    _menu_render_numbered "$title" "${options[@]}"

    echo -n "🤔 Enter your choice (1-$max): "
    read choice

    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "$max" ]]; then
        echo "$choice"
        return 0
    else
        _log_error "Invalid choice. Please enter a number between 1 and $max."
        return 1
    fi
}

#=============================================================================
# Main Menu Function
#=============================================================================

show_menu() {
    local title="$1"
    shift
    local options=("$@")

    # Get menu style from config (default: numbered for backward compatibility)
    local menu_style=$(_get_menu_style)

    case "$menu_style" in
        arrow)
            _menu_arrow_navigation "$title" "${options[@]}"
            ;;
        keyboard)
            _menu_keyboard_shortcuts "$title" "${options[@]}"
            ;;
        both|combined)
            _menu_combined_navigation "$title" "${options[@]}"
            ;;
        numbered|*)
            _menu_numbered_selection "$title" "${options[@]}"
            ;;
    esac
}

#=============================================================================
# Simple Yes/No Prompts
#=============================================================================

prompt_yes_no() {
    local question="$1"
    local default="${2:-N}"

    if [[ "$default" == "y" ]] || [[ "$default" == "Y" ]]; then
        echo -n "$question (Y/n): "
    else
        echo -n "$question (y/N): "
    fi

    read -k response
    echo ""

    response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

    if [[ -z "$response" ]]; then
        [[ "$default" == "y" ]] || [[ "$default" == "Y" ]]
    else
        [[ "$response" == "y" ]]
    fi
}

#=============================================================================
# Multi-Select Menu
#=============================================================================

show_multi_select_menu() {
    local title="$1"
    shift
    local options=("$@")
    local max=${#options[@]}

    typeset -A selected
    local current=1

    while true; do
        echo "\n$title"
        echo "════════════════════════════════════"
        echo "(Use ↑/↓ to navigate, Space to select, Enter to confirm)\n"

        local i=1
        for option in "${options[@]}"; do
            local marker=" "
            [[ -n "${selected[$i]}" ]] && marker="✓"

            if [[ $i -eq $current ]]; then
                echo "→ [$marker] $option"
            else
                echo "  [$marker] $option"
            fi
            ((i++))
        done

        echo ""

        local key=$(_menu_read_arrow_key)

        case "$key" in
            up)
                ((current--))
                [[ $current -lt 1 ]] && current=$max
                ;;
            down)
                ((current++))
                [[ $current -gt $max ]] && current=1
                ;;
            ' ')  # Space to toggle
                if [[ -n "${selected[$current]}" ]]; then
                    unset "selected[$current]"
                else
                    selected[$current]=1
                fi
                ;;
            enter)
                # Return selected indices
                for i in "${(@k)selected}"; do
                    echo "$i"
                done
                return 0
                ;;
            quit|escape)
                return 1
                ;;
        esac

        # Clear previous render
        local lines_to_clear=$((max + 6))
        for ((i=0; i<lines_to_clear; i++)); do
            tput cuu1
            tput el
        done
    done
}

#=============================================================================
# Helper Functions
#=============================================================================

# Get option text by index
_menu_get_option() {
    local index="$1"
    shift
    local options=("$@")
    echo "${options[$index]}"
}

# Validate menu choice
_menu_validate_choice() {
    local choice="$1"
    local max="$2"

    if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
        return 1
    fi

    if [[ "$choice" -lt 1 ]] || [[ "$choice" -gt "$max" ]]; then
        return 1
    fi

    return 0
}

#=============================================================================
# Export Functions
#=============================================================================

# Main functions:
# - show_menu(title, options...)          - Show menu with configured style
# - prompt_yes_no(question, [default])    - Simple yes/no prompt
# - show_multi_select_menu(title, opts)   - Multi-select with checkboxes
#
# Style-specific functions:
# - _menu_numbered_selection()
# - _menu_arrow_navigation()
# - _menu_keyboard_shortcuts()
# - _menu_combined_navigation()
