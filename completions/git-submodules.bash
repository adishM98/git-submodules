#!/bin/bash

#=============================================================================
# Git Submodules Plugin - Bash Completion
# Provides tab completion for all commands and flags
#=============================================================================

_git_submodules_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    cmd="${COMP_WORDS[0]}"

    # Standard flags for all commands
    local standard_flags="--help -h --dry-run -n --quiet -q --verbose -v --json -j --parallel -p --jobs --force -f --yes -y --scope"

    # Branch completion helper
    _git_branches() {
        git branch -a 2>/dev/null | sed 's/^[* ]*//' | sed 's#^remotes/origin/##'
    }

    # Submodule completion helper
    _git_submodules() {
        git submodule status 2>/dev/null | awk '{print $2}'
    }

    case "${cmd}" in
        pull_all|push_all|add_all)
            if [[ ${cur} == -* ]]; then
                COMPREPLY=( $(compgen -W "${standard_flags}" -- ${cur}) )
            fi
            ;;

        commit_all)
            if [[ ${cur} == -* ]]; then
                COMPREPLY=( $(compgen -W "${standard_flags}" -- ${cur}) )
            fi
            ;;

        status_all)
            if [[ ${cur} == -* ]]; then
                COMPREPLY=( $(compgen -W "--help -h --json -j --quiet -q" -- ${cur}) )
            fi
            ;;

        checkout_all|merge_all)
            if [[ ${cur} == -* ]]; then
                COMPREPLY=( $(compgen -W "${standard_flags}" -- ${cur}) )
            elif [[ ${prev} == "--scope" ]]; then
                COMPREPLY=( $(compgen -W "base subs all" -- ${cur}) )
            else
                # Branch name completion
                COMPREPLY=( $(compgen -W "$(_git_branches)" -- ${cur}) )
            fi
            ;;

        create_branch_all|create_feature_all|create_hotfix_all|create_release_all|start_feature|start_hotfix|start_release)
            if [[ ${cur} == -* ]]; then
                COMPREPLY=( $(compgen -W "--help -h --scope" -- ${cur}) )
            elif [[ ${prev} == "--scope" ]]; then
                COMPREPLY=( $(compgen -W "base subs all" -- ${cur}) )
            fi
            ;;

        create_tag_all)
            if [[ ${cur} == -* ]]; then
                COMPREPLY=( $(compgen -W "--help -h" -- ${cur}) )
            fi
            ;;

        smart_commit_all)
            if [[ ${cur} == -* ]]; then
                COMPREPLY=( $(compgen -W "--help -h --dry-run -n --scope" -- ${cur}) )
            elif [[ ${prev} == "--scope" ]]; then
                COMPREPLY=( $(compgen -W "base subs all" -- ${cur}) )
            fi
            ;;

        configure_git_submodules|show_git_submodules_config|git_submodules_status|toggle_verbose|update_git_submodules_plugin|clear_submodule_cache|list_all_stashes|clear_all_stashes|generate_commit_message|resolve_submodule_conflicts)
            # No completion for these commands
            ;;

        *)
            if [[ ${cur} == -* ]]; then
                COMPREPLY=( $(compgen -W "${standard_flags}" -- ${cur}) )
            fi
            ;;
    esac

    # Special handling for --jobs and --scope
    if [[ ${prev} == "--jobs" ]]; then
        COMPREPLY=( $(compgen -W "2 4 8 16" -- ${cur}) )
    elif [[ ${prev} == "--scope" ]]; then
        COMPREPLY=( $(compgen -W "base subs all" -- ${cur}) )
    fi
}

# Register completion for each command
complete -F _git_submodules_completion pull_all
complete -F _git_submodules_completion push_all
complete -F _git_submodules_completion add_all
complete -F _git_submodules_completion commit_all
complete -F _git_submodules_completion status_all
complete -F _git_submodules_completion checkout_all
complete -F _git_submodules_completion merge_all
complete -F _git_submodules_completion create_branch_all
complete -F _git_submodules_completion create_feature_all
complete -F _git_submodules_completion create_hotfix_all
complete -F _git_submodules_completion create_release_all
complete -F _git_submodules_completion create_sprint_all
complete -F _git_submodules_completion create_revamp_all
complete -F _git_submodules_completion start_branch
complete -F _git_submodules_completion start_feature
complete -F _git_submodules_completion start_hotfix
complete -F _git_submodules_completion start_release
complete -F _git_submodules_completion start_sprint
complete -F _git_submodules_completion create_tag_all
complete -F _git_submodules_completion smart_commit_all
complete -F _git_submodules_completion generate_commit_message
complete -F _git_submodules_completion resolve_submodule_conflicts
complete -F _git_submodules_completion git_submodules_status
complete -F _git_submodules_completion toggle_verbose
complete -F _git_submodules_completion update_git_submodules_plugin
complete -F _git_submodules_completion configure_git_submodules
complete -F _git_submodules_completion show_git_submodules_config
complete -F _git_submodules_completion clear_submodule_cache
complete -F _git_submodules_completion list_all_stashes
complete -F _git_submodules_completion clear_all_stashes
