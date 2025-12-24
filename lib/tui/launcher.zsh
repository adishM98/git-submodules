#!/usr/bin/env zsh

#=============================================================================
# TUI Launcher
#
# Launches the Ink-based TUI for git-submodules
#=============================================================================

# Launch the TUI
gsm-tui() {
    # Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        _log_error "Node.js is required to run the TUI"
        echo ""
        echo "📦 Install Node.js from: https://nodejs.org/"
        echo ""
        echo "Alternatively, use the CLI commands:"
        echo "  • status_all"
        echo "  • pull_all  "
        echo "  • checkout_all"
        echo "  • commit_all"
        return 1
    fi

    # Check Node.js version (require 14+)
    local node_version=$(node --version | sed 's/v//' | cut -d'.' -f1)
    if [[ $node_version -lt 14 ]]; then
        _log_warning "Node.js 14+ recommended (you have: $(node --version))"
        _log_warning "TUI may not work correctly with older versions"
    fi

    # Set environment variables
    export GIT_SUBMODULES_PLUGIN_DIR="${GIT_SUBMODULES_PLUGIN_DIR:-$(dirname $(dirname $(dirname ${(%):-%x})))}"

    # Check if TUI directory exists
    local tui_dir="$GIT_SUBMODULES_PLUGIN_DIR/tui"
    if [[ ! -d "$tui_dir" ]]; then
        _log_error "TUI directory not found: $tui_dir"
        return 1
    fi

    # Check if node_modules exists (dependencies installed)
    if [[ ! -d "$tui_dir/node_modules" ]]; then
        _log_warning "TUI dependencies not installed. Installing..."
        echo ""
        (cd "$tui_dir" && npm install)
        echo ""
    fi

    # Launch TUI in development mode with tsx
    local tui_bin="$tui_dir/bin/gsm-tui.js"
    if [[ ! -f "$tui_bin" ]]; then
        _log_error "TUI binary not found: $tui_bin"
        return 1
    fi

    # Run the TUI
    NODE_ENV=development node "$tui_bin"
}

# Aliases
alias gsmui='gsm-tui'
alias git-submodules-ui='gsm-tui'
