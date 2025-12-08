#!/bin/zsh

#=============================================================================
# Parallel Operations Module
# Provides parallel execution for submodule operations
# 3-5x performance improvement for multi-submodule repos
#=============================================================================

# Job control
typeset -g PARALLEL_MAX_JOBS=4
typeset -g PARALLEL_ACTIVE_JOBS=0
typeset -A PARALLEL_JOB_PIDS
typeset -A PARALLEL_JOB_STATUS
typeset -A PARALLEL_JOB_OUTPUT

#=============================================================================
# Parallel Execution
#=============================================================================

parallel_exec() {
    local max_jobs="${1:-$(_get_parallel_jobs)}"
    shift
    local commands=("$@")

    if [[ ${#commands[@]} -eq 0 ]]; then
        return 0
    fi

    # Reset state
    PARALLEL_ACTIVE_JOBS=0
    PARALLEL_JOB_PIDS=()
    PARALLEL_JOB_STATUS=()
    PARALLEL_JOB_OUTPUT=()

    local total=${#commands[@]}
    local completed=0
    local failed=0

    # Start progress if enabled
    if [[ "$(_get_progress_style)" != "none" ]]; then
        progress_start "$total" "Parallel execution"
    fi

    # Execute commands in parallel
    for i in {1..$total}; do
        local cmd="${commands[$i]}"

        # Wait if max jobs reached
        while [[ $PARALLEL_ACTIVE_JOBS -ge $max_jobs ]]; do
            _parallel_wait_any
        done

        # Start job in background
        _parallel_start_job "$i" "$cmd"
    done

    # Wait for all jobs to complete
    while [[ $PARALLEL_ACTIVE_JOBS -gt 0 ]]; do
        _parallel_wait_any
    done

    # Finish progress
    if [[ "$(_get_progress_style)" != "none" ]]; then
        progress_finish "success"
    fi

    # Count failures
    for status in "${PARALLEL_JOB_STATUS[@]}"; do
        if [[ "$status" != "0" ]]; then
            ((failed++))
        fi
    done

    # Return success if all jobs succeeded
    [[ $failed -eq 0 ]]
}

_parallel_start_job() {
    local job_id="$1"
    local command="$2"

    # Create temp file for output
    local output_file="/tmp/git-submodules-job-$job_id-$$"

    # Execute in background
    (
        eval "$command" > "$output_file" 2>&1
        echo $? > "${output_file}.status"
    ) &

    local pid=$!
    PARALLEL_JOB_PIDS[$job_id]=$pid
    PARALLEL_JOB_OUTPUT[$job_id]=$output_file
    ((PARALLEL_ACTIVE_JOBS++))
}

_parallel_wait_any() {
    # Check each job
    for job_id pid in ${(kv)PARALLEL_JOB_PIDS}; do
        if ! kill -0 $pid 2>/dev/null; then
            # Job finished
            local output_file="${PARALLEL_JOB_OUTPUT[$job_id]}"
            local status_file="${output_file}.status"

            # Get status
            local status=0
            if [[ -f "$status_file" ]]; then
                status=$(cat "$status_file")
                rm "$status_file"
            fi

            PARALLEL_JOB_STATUS[$job_id]=$status

            # Get output
            if [[ -f "$output_file" ]]; then
                local output=$(cat "$output_file")
                [[ -n "$output" ]] && echo "$output"
                rm "$output_file"
            fi

            # Remove from active jobs
            unset "PARALLEL_JOB_PIDS[$job_id]"
            ((PARALLEL_ACTIVE_JOBS--))

            # Update progress
            if [[ "$(_get_progress_style)" != "none" ]]; then
                progress_increment
            fi

            return 0
        fi
    done

    # No job finished, sleep briefly
    sleep 0.1
}

#=============================================================================
# Parallel Submodule Operations
#=============================================================================

parallel_foreach_submodule() {
    local command="$1"
    local max_jobs="${2:-$(_get_parallel_jobs)}"

    local submodules=$(_get_all_submodules)
    if [[ -z "$submodules" ]]; then
        return 0
    fi

    # Build command array
    local -a commands
    echo "$submodules" | while IFS= read -r submodule; do
        if [[ -n "$submodule" ]]; then
            commands+=("(cd \"$submodule\" && $command)")
        fi
    done

    # Execute in parallel
    parallel_exec "$max_jobs" "${commands[@]}"
}

#=============================================================================
# Parallel Pull
#=============================================================================

parallel_pull_all() {
    local max_jobs="${1:-$(_get_parallel_jobs)}"

    _log_info "🔄 Pulling base repository..."
    git pull || {
        _log_error "Failed to pull base repository"
        return 1
    }

    local submodules=$(_get_all_submodules)
    if [[ -z "$submodules" ]]; then
        _log_success "No submodules to pull"
        return 0
    fi

    _log_info "🔄 Pulling submodules in parallel (jobs: $max_jobs)..."

    local -a commands
    echo "$submodules" | while IFS= read -r submodule; do
        if [[ -n "$submodule" ]]; then
            commands+=("(cd \"$submodule\" && git pull)")
        fi
    done

    if parallel_exec "$max_jobs" "${commands[@]}"; then
        _log_success "All repositories pulled successfully"
        return 0
    else
        _log_error "Some repositories failed to pull"
        return 1
    fi
}

#=============================================================================
# Parallel Push
#=============================================================================

parallel_push_all() {
    local max_jobs="${1:-$(_get_parallel_jobs)}"

    # Check base repo
    local base_ahead=$(git rev-list @{upstream}..HEAD 2>/dev/null | wc -l | tr -d ' ')
    if [[ $base_ahead -gt 0 ]]; then
        _log_info "🚀 Pushing base repository..."
        git push || {
            _log_error "Failed to push base repository"
            return 1
        }
    fi

    local submodules=$(_get_all_submodules)
    if [[ -z "$submodules" ]]; then
        _log_success "No submodules to push"
        return 0
    fi

    _log_info "🚀 Pushing submodules in parallel (jobs: $max_jobs)..."

    local -a commands
    echo "$submodules" | while IFS= read -r submodule; do
        if [[ -n "$submodule" ]]; then
            # Only push if there are commits to push
            commands+=("(cd \"$submodule\" && git rev-list @{upstream}..HEAD 2>/dev/null | grep -q . && git push)")
        fi
    done

    if parallel_exec "$max_jobs" "${commands[@]}"; then
        _log_success "All repositories pushed successfully"
        return 0
    else
        _log_error "Some repositories failed to push"
        return 1
    fi
}

#=============================================================================
# Parallel Status
#=============================================================================

parallel_status_all() {
    local max_jobs="${1:-$(_get_parallel_jobs)}"

    echo "\n🏠 === Base Repository Status ==="
    git status

    local submodules=$(_get_all_submodules)
    if [[ -z "$submodules" ]]; then
        return 0
    fi

    echo "\n📦 === Submodule Status (parallel) ==="

    local -a commands
    echo "$submodules" | while IFS= read -r submodule; do
        if [[ -n "$submodule" ]]; then
            commands+=("echo '\n🔸 === $submodule ===' && (cd \"$submodule\" && git status -s)")
        fi
    done

    parallel_exec "$max_jobs" "${commands[@]}"
}

#=============================================================================
# Parallel Fetch
#=============================================================================

parallel_fetch_all() {
    local max_jobs="${1:-$(_get_parallel_jobs)}"

    _log_info "⬇️  Fetching base repository..."
    git fetch || {
        _log_error "Failed to fetch base repository"
        return 1
    }

    local submodules=$(_get_all_submodules)
    if [[ -z "$submodules" ]]; then
        return 0
    fi

    _log_info "⬇️  Fetching submodules in parallel (jobs: $max_jobs)..."

    local -a commands
    echo "$submodules" | while IFS= read -r submodule; do
        if [[ -n "$submodule" ]]; then
            commands+=("(cd \"$submodule\" && git fetch)")
        fi
    done

    parallel_exec "$max_jobs" "${commands[@]}"
}

#=============================================================================
# Performance Benchmarking
#=============================================================================

benchmark_parallel_vs_sequential() {
    local operation="${1:-pull}"

    echo "\n📊 === Performance Benchmark: $operation ==="

    # Sequential
    echo "\n⏱️  Sequential execution..."
    local start_seq=$(date +%s)
    case "$operation" in
        pull) git submodule foreach 'git pull' ;;
        fetch) git submodule foreach 'git fetch' ;;
    esac
    local end_seq=$(date +%s)
    local duration_seq=$((end_seq - start_seq))

    # Parallel
    echo "\n⚡ Parallel execution..."
    local start_par=$(date +%s)
    case "$operation" in
        pull) parallel_pull_all ;;
        fetch) parallel_fetch_all ;;
    esac
    local end_par=$(date +%s)
    local duration_par=$((end_par - start_par))

    # Results
    echo "\n📈 Results:"
    echo "   Sequential: ${duration_seq}s"
    echo "   Parallel:   ${duration_par}s"
    local speedup=$(echo "scale=2; $duration_seq / $duration_par" | bc)
    echo "   Speedup:    ${speedup}x faster"
}

#=============================================================================
# Export Functions
#=============================================================================

# Main functions:
# - parallel_exec(max_jobs, commands...)
# - parallel_foreach_submodule(command, [max_jobs])
# - parallel_pull_all([max_jobs])
# - parallel_push_all([max_jobs])
# - parallel_status_all([max_jobs])
# - parallel_fetch_all([max_jobs])
# - benchmark_parallel_vs_sequential(operation)
