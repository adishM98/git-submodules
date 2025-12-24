# Built-in Command Aliases
# Part of git-submodules plugin CLI enhancements
# Provides short, memorable aliases for common commands

# ============================================================================
# Core Operation Aliases (all -> all pattern)
# ============================================================================

# Pull/Push/Add/Status operations
alias pall='pull_all'           # Pull all repositories
alias phall='push_all'          # Push all repositories (ph to avoid conflict with pushd)
alias aall='add_all'            # Add/stage all changes
alias call='commit_all'         # Commit all repositories
alias sall='status_all'         # Status all repositories

# ============================================================================
# Branch Management Aliases
# ============================================================================

# Branch operations
alias coall='checkout_all'      # Checkout all
alias brall='create_branch_all' # Create branch all
alias mrgall='merge_all'        # Merge all

# ============================================================================
# Interactive Command Aliases (g- prefix = git)
# ============================================================================

# Feature/Hotfix/Release workflows
alias gfeat='start_feature'     # Start feature branch
alias gfix='start_hotfix'       # Start hotfix branch
alias grel='start_release'      # Start release branch
alias gspr='start_sprint'       # Start sprint branch

# ============================================================================
# Smart Feature Aliases (s = smart, gen = generate)
# ============================================================================

alias scommit='smart_commit_all'          # Smart commit
alias genmsg='generate_commit_message'    # Generate commit message
alias fixsub='resolve_submodule_conflicts' # Fix submodule conflicts

# ============================================================================
# Utility Aliases (gsm = git submodules)
# ============================================================================

alias gsmstatus='git_submodules_status'   # Plugin status
alias gsmhelp='help'                      # Help system
alias gsmtheme='set_theme'                # Change theme
alias gsmconfig='configure_git_submodules' # Configuration wizard

# ============================================================================
# Quick Shortcuts (g- prefix for git operations)
# ============================================================================

alias g-pull='pull_all'          # Quick pull
alias g-push='push_all'          # Quick push
alias g-status='status_all'      # Quick status
alias g-add='add_all'            # Quick add
alias g-commit='commit_all'      # Quick commit

# ============================================================================
# Help & Discovery Aliases
# ============================================================================

alias commands='list_commands'   # List all commands
alias cmds='list_commands'       # Short form
alias findcmd='search_commands'  # Search commands

# ============================================================================
# List Built-in Aliases
# ============================================================================

# Show all built-in aliases with descriptions
_list_builtin_aliases() {
    local alias_icon=$(_theme_icon "info")

    echo ""
    echo "$alias_icon Built-in Aliases:"
    echo ""

    _theme_section "CORE OPERATIONS"
    echo "   pall          → pull_all           (Pull all repositories)"
    echo "   phall         → push_all           (Push all repositories)"
    echo "   aall          → add_all            (Add/stage all changes)"
    echo "   call          → commit_all         (Commit all repositories)"
    echo "   sall          → status_all         (Status all repositories)"
    echo ""

    _theme_section "BRANCH MANAGEMENT"
    echo "   coall         → checkout_all       (Checkout branch)"
    echo "   brall         → create_branch_all  (Create branch)"
    echo "   mrgall        → merge_all          (Merge branches)"
    echo ""

    _theme_section "INTERACTIVE WORKFLOWS"
    echo "   gfeat         → start_feature      (Start feature branch)"
    echo "   gfix          → start_hotfix       (Start hotfix branch)"
    echo "   grel          → start_release      (Start release branch)"
    echo "   gspr          → start_sprint       (Start sprint branch)"
    echo ""

    _theme_section "SMART FEATURES"
    echo "   scommit       → smart_commit_all   (Smart commit)"
    echo "   genmsg        → generate_commit_message"
    echo "   fixsub        → resolve_submodule_conflicts"
    echo ""

    _theme_section "UTILITY"
    echo "   gsmstatus     → git_submodules_status"
    echo "   gsmhelp       → help"
    echo "   gsmtheme      → set_theme"
    echo "   gsmconfig     → configure_git_submodules"
    echo ""

    _theme_section "QUICK SHORTCUTS"
    echo "   g-pull        → pull_all"
    echo "   g-push        → push_all"
    echo "   g-status      → status_all"
    echo "   g-add         → add_all"
    echo "   g-commit      → commit_all"
    echo ""

    _theme_section "HELP & DISCOVERY"
    echo "   commands      → list_commands"
    echo "   cmds          → list_commands"
    echo "   findcmd       → search_commands"
    echo ""
}
