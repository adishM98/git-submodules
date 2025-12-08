# Tab Completion for Git Submodules Plugin
# Part of git-submodules plugin CLI enhancements
# Provides intelligent tab completion for commands, themes, and help topics

# ============================================================================
# Completion for set_theme Command
# ============================================================================

# Complete theme names
_git_submodules_theme_completion() {
    local themes=(emoji ansi plain minimal)
    _describe 'theme' themes
}

# Register completion for set_theme
if command -v compdef >/dev/null 2>&1; then
    compdef _git_submodules_theme_completion set_theme
    compdef _git_submodules_theme_completion gsmtheme
fi

# ============================================================================
# Completion for help Command
# ============================================================================

# Complete help topics
_git_submodules_help_completion() {
    local topics=(
        'overview:Main help overview'
        'tutorial:Beginner tutorial'
        'workflows:Common workflow patterns'
        'commands:List all commands'
        'pull_all:Pull all repositories'
        'push_all:Push all repositories'
        'add_all:Stage all changes'
        'commit_all:Commit changes'
        'status_all:Show status'
        'start_feature:Create feature branch'
        'start_hotfix:Create hotfix branch'
        'checkout_all:Checkout branch'
        'merge_all:Merge branches'
        'smart_commit_all:Smart commit'
        'resolve_submodule_conflicts:Fix conflicts'
        'git_submodules_status:Plugin status'
        'set_theme:Change theme'
        'configure_git_submodules:Configuration wizard'
    )
    _describe 'help topic' topics
}

# Register completion for help
if command -v compdef >/dev/null 2>&1; then
    compdef _git_submodules_help_completion help
    compdef _git_submodules_help_completion gsmhelp
fi

# ============================================================================
# Completion for search_commands
# ============================================================================

# Complete keywords for search_commands
_git_submodules_search_completion() {
    local keywords=(
        'pull:Pull operations'
        'push:Push operations'
        'commit:Commit operations'
        'branch:Branch operations'
        'feature:Feature branches'
        'hotfix:Hotfix branches'
        'merge:Merge operations'
        'status:Status commands'
        'smart:Smart features'
        'config:Configuration'
    )
    _describe 'keyword' keywords
}

# Register completion for search_commands
if command -v compdef >/dev/null 2>&1; then
    compdef _git_submodules_search_completion search_commands
    compdef _git_submodules_search_completion findcmd
fi

# ============================================================================
# Completion for Main Commands
# ============================================================================

# Generic completion for all git-submodules commands
_git_submodules_completions() {
    local -a commands
    commands=(
        'pull_all:Pull changes from all repositories'
        'push_all:Push changes to all repositories'
        'add_all:Stage all changes'
        'commit_all:Commit changes with message'
        'status_all:Show status of all repositories'
        'checkout_all:Checkout branch interactively'
        'merge_all:Merge branches interactively'
        'start_feature:Create feature branch'
        'start_hotfix:Create hotfix branch'
        'smart_commit_all:Smart commit with generated messages'
        'help:Show help system'
        'list_commands:List all commands'
        'set_theme:Change display theme'
    )

    _describe 'git-submodules commands' commands
}

# ============================================================================
# Git Branch Name Completion
# ============================================================================

# Complete git branch names for checkout/merge commands
_git_branch_completion() {
    local -a branches
    branches=(${(f)"$(git branch --format='%(refname:short)' 2>/dev/null)"})

    if [[ ${#branches[@]} -gt 0 ]]; then
        _describe 'branch' branches
    fi
}

# Register completion for commands that need branch names
if command -v compdef >/dev/null 2>&1; then
    compdef _git_branch_completion checkout_all
    compdef _git_branch_completion merge_all
    compdef _git_branch_completion coall
    compdef _git_branch_completion mrgall
fi

# ============================================================================
# Completion Helper Functions
# ============================================================================

# Enable tab completion in zsh
_enable_git_submodules_completion() {
    # Load zsh completion system if not already loaded
    if command -v compinit >/dev/null 2>&1; then
        autoload -Uz compinit
        compinit -C  # -C to skip security check for speed
    fi
}

# Initialize completion on module load
_enable_git_submodules_completion
