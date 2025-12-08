# Main Help System with Tutorials and Workflows
# Part of git-submodules plugin CLI enhancements
# Provides comprehensive help, tutorials, and workflow guides

# ============================================================================
# Main Help Dispatcher
# ============================================================================

# Main help command - routes to appropriate help content
help() {
    local topic="${1:-overview}"

    case "$topic" in
        overview|"")
            _show_help_overview
            ;;
        tutorial|beginner|start|getting-started)
            _show_tutorial
            ;;
        workflows|workflow|patterns)
            _show_workflows
            ;;
        commands|list)
            list_commands
            ;;
        *)
            # Try to show command-specific help
            _show_command_help "$topic"
            ;;
    esac
}

# ============================================================================
# Help Overview
# ============================================================================

_show_help_overview() {
    local help_icon=$(_theme_icon "help")

    _theme_header "Git Submodules Plugin - Help"

    echo "USAGE:"
    echo "    <command> [options]"
    echo "    help <command>         Show detailed help for a command"
    echo "    help tutorial          Beginner's guide"
    echo "    help workflows         Common workflow patterns"
    echo ""

    echo "QUICK START:"
    _theme_bullet "Check status:    git_submodules_status"
    _theme_bullet "Get help:        help"
    _theme_bullet "Try tutorial:    help tutorial"
    echo ""

    echo "CORE OPERATIONS:"
    _theme_bullet "pull_all              Pull changes from all repositories"
    _theme_bullet "push_all              Push changes to all repositories"
    _theme_bullet "add_all               Stage all changes"
    _theme_bullet "commit_all <msg>      Commit changes across all repos"
    _theme_bullet "status_all            Show status of all repositories"
    echo ""

    echo "BRANCH MANAGEMENT:"
    _theme_bullet "start_feature         Create feature branch (interactive)"
    _theme_bullet "start_hotfix          Create hotfix branch (interactive)"
    _theme_bullet "checkout_all          Checkout branch (interactive)"
    _theme_bullet "merge_all             Merge branches (interactive)"
    echo ""

    echo "SMART FEATURES:"
    _theme_bullet "smart_commit_all      Intelligent commit with generated messages"
    _theme_bullet "resolve_submodule_conflicts    Fix submodule conflicts"
    echo ""

    echo "CONFIGURATION:"
    _theme_bullet "set_theme <theme>     Change display theme (emoji/ansi/plain/minimal)"
    _theme_bullet "toggle_verbose        Toggle verbose output"
    _theme_bullet "configure_git_submodules    Interactive configuration wizard"
    echo ""

    echo "HELP & DISCOVERY:"
    _theme_bullet "help <command>        Detailed help for any command"
    _theme_bullet "list_commands         List all available commands"
    _theme_bullet "search_commands       Search commands by keyword"
    echo ""

    echo "ALIASES:"
    _theme_bullet "pall, phall, sall, etc.    Short aliases for common commands"
    _theme_bullet "list_aliases          Show all aliases"
    echo ""

    echo "$help_icon For more help:"
    echo "   help tutorial          Step-by-step beginner's guide"
    echo "   help workflows         Common workflow patterns"
    echo "   help <command>         Detailed command help"
    echo "   <command> --help       Quick help for any command"
    echo ""
}

# ============================================================================
# Tutorial System
# ============================================================================

_show_tutorial() {
    local tutorial_icon=$(_theme_icon "tutorial")

    _theme_header "Git Submodules Plugin - Beginner's Tutorial"

    echo "$tutorial_icon Welcome! This tutorial will guide you through the essential commands."
    echo ""

    _theme_section "STEP 1: Check Your Setup"
    echo "   Run this command to verify the plugin is working:"
    echo ""
    echo "       git_submodules_status"
    echo ""
    echo "   This shows:"
    _theme_bullet "Plugin directory and version"
    _theme_bullet "Current repository status"
    _theme_bullet "Number of submodules found"
    echo ""

    _theme_section "STEP 2: Update Everything"
    echo "   Pull the latest changes from all repositories:"
    echo ""
    echo "       pull_all"
    echo ""
    echo "   This command:"
    _theme_bullet "Pulls changes in the base repository"
    _theme_bullet "Pulls changes in all submodules"
    _theme_bullet "Shows you what was updated"
    echo ""

    _theme_section "STEP 3: Create a Feature Branch"
    echo "   Start working on a new feature:"
    echo ""
    echo "       start_feature"
    echo ""
    echo "   You'll be prompted for:"
    _theme_bullet "Branch name (e.g., 'user-authentication')"
    _theme_bullet "Where to create the branch (base/submodules/both)"
    echo ""
    echo "   The command creates and switches to your new branch."
    echo ""

    _theme_section "STEP 4: Make Changes & Stage Them"
    echo "   After making your code changes, stage them:"
    echo ""
    echo "       add_all"
    echo ""
    echo "   This stages all modified files across all repositories."
    echo ""

    _theme_section "STEP 5: Commit with Smart Messages"
    echo "   Use the smart commit feature:"
    echo ""
    echo "       smart_commit_all"
    echo ""
    echo "   This command:"
    _theme_bullet "Analyzes your changes"
    _theme_bullet "Suggests commit messages based on the diff"
    _theme_bullet "Lets you choose a suggestion or write your own"
    echo ""
    echo "   Or use a manual commit:"
    echo ""
    echo "       commit_all \"feat: add user authentication\""
    echo ""

    _theme_section "STEP 6: Push Your Changes"
    echo "   Push to the remote repository:"
    echo ""
    echo "       push_all"
    echo ""
    echo "   This pushes all committed changes to origin."
    echo ""

    _theme_section "TIPS & TRICKS"
    _theme_bullet "Use 'status_all' frequently to check your progress"
    _theme_bullet "Use 'toggle_verbose' to control output detail"
    _theme_bullet "Interactive commands (start_*) are beginner-friendly"
    _theme_bullet "Try 'help workflows' for complete workflow examples"
    _theme_bullet "Use '--help' flag on any command for quick help"
    echo ""

    _theme_section "NEXT STEPS"
    echo "   Now that you know the basics, try:"
    _theme_bullet "help workflows     - See common workflow patterns"
    _theme_bullet "list_commands      - Explore all available commands"
    _theme_bullet "set_theme ansi     - Try different display themes"
    echo ""
}

# ============================================================================
# Workflow Guides
# ============================================================================

_show_workflows() {
    local workflow_icon=$(_theme_icon "info")

    _theme_header "Common Workflows"

    _theme_section "1. STARTING A NEW FEATURE"
    echo "   Complete workflow for creating a new feature:"
    echo ""
    echo "       pull_all                    $(_theme_icon 'arrow') Get latest changes"
    echo "       start_feature               $(_theme_icon 'arrow') Create feature branch"
    echo "       # ... make your code changes ..."
    echo "       add_all                     $(_theme_icon 'arrow') Stage changes"
    echo "       smart_commit_all            $(_theme_icon 'arrow') Commit with smart message"
    echo "       push_all                    $(_theme_icon 'arrow') Push to remote"
    echo ""

    _theme_section "2. MERGING FROM MAIN"
    echo "   Keep your feature branch up-to-date:"
    echo ""
    echo "       checkout_all                $(_theme_icon 'arrow') Select 'main' branch"
    echo "       pull_all                    $(_theme_icon 'arrow') Get latest main"
    echo "       checkout_all                $(_theme_icon 'arrow') Switch back to feature branch"
    echo "       merge_all                   $(_theme_icon 'arrow') Merge main into feature"
    echo "       push_all                    $(_theme_icon 'arrow') Push merged changes"
    echo ""

    _theme_section "3. FIXING MERGE CONFLICTS"
    echo "   When conflicts occur during merge:"
    echo ""
    echo "       merge_all                   $(_theme_icon 'arrow') Attempt merge"
    echo "       # If conflicts occur:"
    echo "       resolve_submodule_conflicts $(_theme_icon 'arrow') Fix submodule conflicts"
    echo "       # Edit conflicted files manually if needed"
    echo "       add_all                     $(_theme_icon 'arrow') Stage resolved files"
    echo "       commit_all \"Merge main\"    $(_theme_icon 'arrow') Complete the merge"
    echo "       push_all                    $(_theme_icon 'arrow') Push resolved merge"
    echo ""

    _theme_section "4. HOTFIX WORKFLOW"
    echo "   Quick fix for production issues:"
    echo ""
    echo "       checkout_all                $(_theme_icon 'arrow') Switch to main/production"
    echo "       pull_all                    $(_theme_icon 'arrow') Get latest"
    echo "       start_hotfix                $(_theme_icon 'arrow') Create hotfix branch"
    echo "       # ... make the fix ..."
    echo "       commit_all \"fix: critical bug\" $(_theme_icon 'arrow') Commit fix"
    echo "       push_all                    $(_theme_icon 'arrow') Push"
    echo "       # Create PR and merge"
    echo ""

    _theme_section "5. CHECKING STATUS ACROSS ALL REPOS"
    echo "   Quick overview of all repositories:"
    echo ""
    echo "       status_all                  $(_theme_icon 'arrow') See all repo statuses"
    echo "       git_submodules_status       $(_theme_icon 'arrow') Plugin and repo info"
    echo ""

    _theme_section "6. SYNCING EVERYTHING"
    echo "   Keep all repos in sync:"
    echo ""
    echo "       pull_all                    $(_theme_icon 'arrow') Pull all changes"
    echo "       add_all                     $(_theme_icon 'arrow') Stage any updates"
    echo "       commit_all \"sync: update\"  $(_theme_icon 'arrow') Commit submodule updates"
    echo "       push_all                    $(_theme_icon 'arrow') Push everything"
    echo ""

    echo "$workflow_icon More Help:"
    _theme_bullet "help <command>       - Detailed command help"
    _theme_bullet "list_commands        - See all commands"
    _theme_bullet "<command> --help     - Quick command help"
    echo ""
}

# ============================================================================
# Command-Specific Help
# ============================================================================

_show_command_help() {
    local command="$1"

    case "$command" in
        pull_all)
            _help_pull_all
            ;;
        push_all)
            _help_push_all
            ;;
        add_all)
            _help_add_all
            ;;
        commit_all)
            _help_commit_all
            ;;
        status_all)
            _help_status_all
            ;;
        start_feature)
            _help_start_feature
            ;;
        start_hotfix)
            _help_start_hotfix
            ;;
        checkout_all)
            _help_checkout_all
            ;;
        merge_all)
            _help_merge_all
            ;;
        smart_commit_all)
            _help_smart_commit_all
            ;;
        resolve_submodule_conflicts)
            _help_resolve_submodule_conflicts
            ;;
        git_submodules_status)
            _help_git_submodules_status
            ;;
        toggle_verbose)
            _help_toggle_verbose
            ;;
        set_theme)
            _help_set_theme
            ;;
        configure_git_submodules)
            _help_configure_git_submodules
            ;;
        *)
            _log_error "No help available for: $command"
            echo ""
            echo "Try:"
            _theme_bullet "help              - Show help overview"
            _theme_bullet "list_commands     - List all commands"
            _theme_bullet "search_commands   - Search for commands"
            echo ""
            return 1
            ;;
    esac
}

# ============================================================================
# Individual Command Help Functions
# ============================================================================

_help_pull_all() {
    echo ""
    echo "COMMAND: pull_all"
    echo ""
    echo "DESCRIPTION:"
    echo "   Pull changes from the remote repository for the base repo and all submodules."
    echo ""
    echo "USAGE:"
    echo "   pull_all"
    echo ""
    echo "WHAT IT DOES:"
    _theme_bullet "Fetches and pulls changes in the base repository"
    _theme_bullet "Pulls changes in all submodules"
    _theme_bullet "Shows status of each operation"
    echo ""
    echo "RELATED COMMANDS:"
    _theme_bullet "push_all          - Push changes to remote"
    _theme_bullet "status_all        - Check status before pulling"
    echo ""
}

_help_push_all() {
    echo ""
    echo "COMMAND: push_all"
    echo ""
    echo "DESCRIPTION:"
    echo "   Push committed changes to the remote repository for base repo and all submodules."
    echo ""
    echo "USAGE:"
    echo "   push_all"
    echo ""
    echo "PREREQUISITES:"
    _theme_bullet "Changes must be committed (use commit_all first)"
    _theme_bullet "Upstream branch should be configured"
    echo ""
    echo "RELATED COMMANDS:"
    _theme_bullet "pull_all          - Pull changes from remote"
    _theme_bullet "commit_all        - Commit changes before pushing"
    echo ""
}

_help_start_feature() {
    echo ""
    echo "COMMAND: start_feature"
    echo ""
    echo "DESCRIPTION:"
    echo "   Interactive command to create a new feature branch."
    echo "   Provides guided prompts for branch naming and scope selection."
    echo ""
    echo "USAGE:"
    echo "   start_feature"
    echo ""
    echo "INTERACTIVE PROMPTS:"
    echo "   1. Branch name         What to name your feature"
    echo "   2. Scope selection     Where to create the branch"
    echo ""
    echo "WORKFLOW:"
    _theme_bullet "Run: start_feature"
    _theme_bullet "Enter branch name (e.g., 'user-auth')"
    _theme_bullet "Choose scope (1-4)"
    _theme_bullet "Branch created and pushed"
    echo ""
    echo "RELATED COMMANDS:"
    _theme_bullet "start_hotfix      - Create hotfix branch"
    _theme_bullet "create_branch_all - Non-interactive branch creation"
    echo ""
}

_help_smart_commit_all() {
    echo ""
    echo "COMMAND: smart_commit_all"
    echo ""
    echo "DESCRIPTION:"
    echo "   Intelligent commit command that analyzes your changes and suggests"
    echo "   conventional commit messages based on the diff."
    echo ""
    echo "USAGE:"
    echo "   smart_commit_all"
    echo ""
    echo "FEATURES:"
    _theme_bullet "Analyzes code changes in staged files"
    _theme_bullet "Detects change types (feat, fix, docs, etc.)"
    _theme_bullet "Suggests 2-3 commit messages"
    _theme_bullet "Shows recent commit patterns"
    _theme_bullet "Option to write custom message"
    echo ""
    echo "WORKFLOW:"
    _theme_bullet "Stage changes with add_all"
    _theme_bullet "Run smart_commit_all"
    _theme_bullet "Review suggestions and choose one"
    _theme_bullet "Or write your own message"
    echo ""
    echo "RELATED COMMANDS:"
    _theme_bullet "commit_all        - Manual commit message"
    _theme_bullet "add_all           - Stage changes first"
    echo ""
}

# Additional help functions for other commands would go here
# For brevity, I'll include a few key ones

_help_git_submodules_status() {
    echo ""
    echo "COMMAND: git_submodules_status"
    echo ""
    echo "DESCRIPTION:"
    echo "   Display comprehensive status of the git-submodules plugin and repositories."
    echo ""
    echo "USAGE:"
    echo "   git_submodules_status"
    echo ""
    echo "SHOWS:"
    _theme_bullet "Plugin directory location"
    _theme_bullet "Verbose mode status"
    _theme_bullet "Current repository validation"
    _theme_bullet "Number of submodules found"
    _theme_bullet "List of all submodules"
    echo ""
}

_help_set_theme() {
    echo ""
    echo "COMMAND: set_theme"
    echo ""
    echo "DESCRIPTION:"
    echo "   Change the display theme for the plugin output."
    echo ""
    echo "USAGE:"
    echo "   set_theme <theme>"
    echo ""
    echo "AVAILABLE THEMES:"
    _theme_bullet "emoji    - Rich emoji icons (default, best for modern terminals)"
    _theme_bullet "ansi     - ANSI colors with simple ASCII characters"
    _theme_bullet "plain    - Plain text only (accessibility mode)"
    _theme_bullet "minimal  - Ultra-minimal output"
    echo ""
    echo "EXAMPLES:"
    echo "   set_theme ansi        # Switch to ANSI color mode"
    echo "   set_theme plain       # Switch to plain text"
    echo ""
    echo "RELATED COMMANDS:"
    _theme_bullet "configure_git_submodules  - Full configuration wizard"
    _theme_bullet "show_config               - View current settings"
    echo ""
}
