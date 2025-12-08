#!/bin/zsh

#=============================================================================
# CLI Flag Parsing Module
# Provides modern command-line flag parsing
# Enables --help, --dry-run, --quiet, --verbose, --parallel, --json, etc.
#=============================================================================

# Global flag state
typeset -A CLI_FLAGS
typeset -a CLI_POSITIONAL_ARGS

#=============================================================================
# Flag Definitions
#=============================================================================

# Standard flags supported by all commands
typeset -A STANDARD_FLAGS
STANDARD_FLAGS=(
    # Help
    "-h|--help" "Show help for command"

    # Dry-run
    "-n|--dry-run" "Preview without executing"

    # Output control
    "-q|--quiet" "Minimal output (errors only)"
    "-v|--verbose" "Detailed output"
    "-j|--json" "JSON output format"

    # Parallel execution
    "-p|--parallel" "Use parallel execution"
    "--jobs" "Number of parallel jobs (requires value)"

    # Safety
    "-f|--force" "Skip confirmations"
    "-y|--yes" "Auto-confirm prompts"

    # Scope
    "--scope" "Target repositories: base, subs, all (requires value)"
)

#=============================================================================
# Flag Parsing
#=============================================================================

parse_flags() {
    # Reset state
    CLI_FLAGS=()
    CLI_POSITIONAL_ARGS=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            # Help flags
            -h|--help)
                CLI_FLAGS[help]=true
                shift
                ;;

            # Dry-run
            -n|--dry-run)
                CLI_FLAGS[dry-run]=true
                GIT_SUBMODULES_DRY_RUN=true
                shift
                ;;

            # Output control
            -q|--quiet)
                CLI_FLAGS[quiet]=true
                GIT_SUBMODULES_VERBOSE=false
                shift
                ;;

            -v|--verbose)
                CLI_FLAGS[verbose]=true
                GIT_SUBMODULES_VERBOSE=true
                shift
                ;;

            -j|--json)
                CLI_FLAGS[json]=true
                shift
                ;;

            # Parallel execution
            -p|--parallel)
                CLI_FLAGS[parallel]=true
                shift
                ;;

            --jobs)
                if [[ -n "$2" ]] && [[ "$2" =~ ^[0-9]+$ ]]; then
                    CLI_FLAGS[jobs]="$2"
                    shift 2
                else
                    _log_error "--jobs requires a numeric value"
                    return 1
                fi
                ;;

            --jobs=*)
                local value="${1#*=}"
                if [[ "$value" =~ ^[0-9]+$ ]]; then
                    CLI_FLAGS[jobs]="$value"
                    shift
                else
                    _log_error "--jobs requires a numeric value"
                    return 1
                fi
                ;;

            # Safety
            -f|--force)
                CLI_FLAGS[force]=true
                shift
                ;;

            -y|--yes)
                CLI_FLAGS[yes]=true
                shift
                ;;

            # Scope
            --scope)
                if [[ -n "$2" ]]; then
                    CLI_FLAGS[scope]="$2"
                    shift 2
                else
                    _log_error "--scope requires a value (base, subs, all)"
                    return 1
                fi
                ;;

            --scope=*)
                local value="${1#*=}"
                CLI_FLAGS[scope]="$value"
                shift
                ;;

            # Unknown flag
            -*)
                _log_error "Unknown flag: $1"
                _log_info "Use --help to see available flags"
                return 1
                ;;

            # Positional argument
            *)
                CLI_POSITIONAL_ARGS+=("$1")
                shift
                ;;
        esac
    done

    return 0
}

#=============================================================================
# Flag Accessors
#=============================================================================

has_flag() {
    local flag="$1"
    [[ -n "${CLI_FLAGS[$flag]}" ]]
}

get_flag() {
    local flag="$1"
    local default="${2:-}"
    echo "${CLI_FLAGS[$flag]:-$default}"
}

get_positional_args() {
    echo "${CLI_POSITIONAL_ARGS[@]}"
}

get_positional_arg() {
    local index="$1"
    local default="${2:-}"
    echo "${CLI_POSITIONAL_ARGS[$index]:-$default}"
}

#=============================================================================
# Help Generation
#=============================================================================

show_command_help() {
    local command="$1"
    local synopsis="$2"
    local description="$3"
    shift 3
    local examples=("$@")

    echo "\n📖 $command - $description\n"

    echo "SYNOPSIS"
    echo "    $synopsis\n"

    echo "DESCRIPTION"
    echo "    $description\n"

    echo "STANDARD OPTIONS"
    echo "    -h, --help          Show this help message"
    echo "    -n, --dry-run       Preview without executing"
    echo "    -q, --quiet         Minimal output (errors only)"
    echo "    -v, --verbose       Detailed output"
    echo "    -j, --json          JSON output format"
    echo "    -p, --parallel      Use parallel execution"
    echo "    --jobs=N            Number of parallel jobs (default: 4)"
    echo "    -f, --force         Skip confirmations"
    echo "    -y, --yes           Auto-confirm prompts"
    echo "    --scope=SCOPE       Target: base, subs, all\n"

    if [[ ${#examples[@]} -gt 0 ]]; then
        echo "EXAMPLES"
        for example in "${examples[@]}"; do
            echo "    $example"
        done
        echo ""
    fi

    echo "NOTES"
    echo "    - Configuration: ~/.config/git-submodules/config"
    echo "    - Use 'configure_git_submodules' for interactive setup"
    echo "    - Use 'show_git_submodules_config' to view current config\n"
}

#=============================================================================
# Command Wrapper
#=============================================================================

with_flags() {
    local command_name="$1"
    local command_func="$2"
    shift 2
    local args=("$@")

    # Parse flags
    if ! parse_flags "${args[@]}"; then
        return 1
    fi

    # Check for help flag
    if has_flag "help"; then
        show_help_for_command "$command_name"
        return 0
    fi

    # Check for dry-run
    if has_flag "dry-run"; then
        GIT_SUBMODULES_DRY_RUN=true
    fi

    # Set quiet/verbose mode
    if has_flag "quiet"; then
        GIT_SUBMODULES_VERBOSE=false
    elif has_flag "verbose"; then
        GIT_SUBMODULES_VERBOSE=true
    fi

    # Execute command with parsed arguments
    eval "$command_func"
}

#=============================================================================
# Help Text Database
#=============================================================================

show_help_for_command() {
    local command="$1"

    case "$command" in
        pull_all)
            show_command_help \
                "pull_all" \
                "pull_all [OPTIONS]" \
                "Pull changes from remote repositories for base and all submodules" \
                "pull_all" \
                "pull_all --parallel --jobs=8" \
                "pull_all --dry-run" \
                "pull_all --quiet --json | jq ."
            ;;

        push_all)
            show_command_help \
                "push_all" \
                "push_all [OPTIONS]" \
                "Push changes to remote repositories for base and all submodules" \
                "push_all" \
                "push_all --parallel" \
                "push_all --dry-run" \
                "push_all --force"
            ;;

        commit_all)
            show_command_help \
                "commit_all" \
                "commit_all [OPTIONS] <message>" \
                "Commit changes across all repositories with the same message" \
                "commit_all \"feat: add new feature\"" \
                "commit_all --dry-run \"test commit\"" \
                "commit_all --scope=subs \"fix: submodule update\""
            ;;

        status_all)
            show_command_help \
                "status_all" \
                "status_all [OPTIONS]" \
                "Show git status for all repositories" \
                "status_all" \
                "status_all --json" \
                "status_all --quiet"
            ;;

        checkout_all)
            show_command_help \
                "checkout_all" \
                "checkout_all [OPTIONS]" \
                "Interactively checkout branch across repositories" \
                "checkout_all" \
                "checkout_all --scope=all" \
                "checkout_all --yes"
            ;;

        merge_all)
            show_command_help \
                "merge_all" \
                "merge_all [OPTIONS]" \
                "Interactively merge branch across repositories" \
                "merge_all" \
                "merge_all --dry-run" \
                "merge_all --scope=subs"
            ;;

        smart_commit_all)
            show_command_help \
                "smart_commit_all" \
                "smart_commit_all [OPTIONS]" \
                "Generate smart commit messages with AI-like analysis" \
                "smart_commit_all" \
                "smart_commit_all --scope=base"
            ;;

        *)
            _log_error "No help available for command: $command"
            return 1
            ;;
    esac
}

#=============================================================================
# Flag Validation
#=============================================================================

validate_scope_flag() {
    local scope=$(get_flag "scope" "all")

    case "$scope" in
        base|subs|submodules|all)
            return 0
            ;;
        *)
            _log_error "Invalid scope: $scope (must be base, subs, or all)"
            return 1
            ;;
    esac
}

validate_jobs_flag() {
    local jobs=$(get_flag "jobs" "4")

    if [[ ! "$jobs" =~ ^[0-9]+$ ]]; then
        _log_error "Invalid jobs value: $jobs (must be a number)"
        return 1
    fi

    if [[ $jobs -lt 1 ]] || [[ $jobs -gt 32 ]]; then
        _log_error "Invalid jobs value: $jobs (must be between 1 and 32)"
        return 1
    fi

    return 0
}

#=============================================================================
# Quick Flag Checks
#=============================================================================

is_quiet_mode() {
    has_flag "quiet"
}

is_verbose_mode() {
    has_flag "verbose"
}

is_dry_run_mode() {
    has_flag "dry-run" || [[ "$GIT_SUBMODULES_DRY_RUN" == "true" ]]
}

is_parallel_mode() {
    has_flag "parallel" || _is_parallel_enabled
}

is_json_output() {
    has_flag "json"
}

should_auto_confirm() {
    has_flag "yes" || has_flag "force"
}

get_parallel_jobs_count() {
    if has_flag "jobs"; then
        get_flag "jobs"
    else
        _get_parallel_jobs
    fi
}

get_target_scope() {
    get_flag "scope" "all"
}

#=============================================================================
# Export Functions
#=============================================================================

# Main functions:
# - parse_flags(args...)          - Parse command-line flags
# - has_flag(name)                - Check if flag is set
# - get_flag(name, [default])     - Get flag value
# - get_positional_args()         - Get non-flag arguments
# - get_positional_arg(index, [default]) - Get specific argument
#
# Help:
# - show_command_help(cmd, synopsis, desc, examples...)
# - show_help_for_command(command_name)
#
# Validation:
# - validate_scope_flag()
# - validate_jobs_flag()
#
# Quick checks:
# - is_quiet_mode()
# - is_verbose_mode()
# - is_dry_run_mode()
# - is_parallel_mode()
# - is_json_output()
# - should_auto_confirm()
# - get_parallel_jobs_count()
# - get_target_scope()
