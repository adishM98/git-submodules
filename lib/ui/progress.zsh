#!/bin/zsh

#=============================================================================
# Progress Indicators Module
# Provides visual feedback for long-running operations
# Supports multiple styles: bar, spinner, dots, percentage
#=============================================================================

# Progress state
typeset -g PROGRESS_TOTAL=0
typeset -g PROGRESS_CURRENT=0
typeset -g PROGRESS_LABEL=""
typeset -g PROGRESS_STYLE="bar"
typeset -g PROGRESS_WIDTH=40
typeset -g PROGRESS_START_TIME=0

#=============================================================================
# Spinner Animation
#=============================================================================

SPINNER_FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
SPINNER_INDEX=0

_spinner_next_frame() {
    echo "${SPINNER_FRAMES[$SPINNER_INDEX]}"
    SPINNER_INDEX=$(( (SPINNER_INDEX + 1) % ${#SPINNER_FRAMES[@]} ))
}

#=============================================================================
# Progress Bar
#=============================================================================

_progress_bar_render() {
    local current="$1"
    local total="$2"
    local label="${3:-Processing}"
    local width="${4:-$PROGRESS_WIDTH}"

    if [[ $total -eq 0 ]]; then
        return
    fi

    local percent=$(( current * 100 / total ))
    local filled=$(( current * width / total ))
    local empty=$(( width - filled ))

    # Build progress bar
    local bar="["
    for ((i=0; i<filled; i++)); do
        bar+="█"
    done
    for ((i=0; i<empty; i++)); do
        bar+="░"
    done
    bar+="]"

    # Print progress
    printf "\r⏳ %s %s %3d%% (%d/%d)" "$label" "$bar" "$percent" "$current" "$total"
}

#=============================================================================
# Spinner Progress
#=============================================================================

_progress_spinner_render() {
    local current="$1"
    local total="$2"
    local label="${3:-Processing}"

    local spinner=$(_spinner_next_frame)
    printf "\r%s %s... (%d/%d)" "$spinner" "$label" "$current" "$total"
}

#=============================================================================
# Dots Progress
#=============================================================================

_progress_dots_render() {
    local current="$1"
    local total="$2"
    local label="${3:-Processing}"

    # Show filled and empty dots
    local filled=$current
    local empty=$(( total - current ))

    printf "\r"
    for ((i=0; i<filled && i<10; i++)); do
        printf "●"
    done
    for ((i=0; i<empty && i<10; i++)); do
        printf "○"
    done
    printf "  %s (%d/%d)" "$label" "$current" "$total"
}

#=============================================================================
# Percentage Only
#=============================================================================

_progress_percentage_render() {
    local current="$1"
    local total="$2"
    local label="${3:-Processing}"

    if [[ $total -eq 0 ]]; then
        return
    fi

    local percent=$(( current * 100 / total ))
    printf "\r📊 %s: %3d%% (%d/%d)" "$label" "$percent" "$current" "$total"
}

#=============================================================================
# Main Progress Functions
#=============================================================================

progress_start() {
    local total="$1"
    local label="${2:-Processing}"
    local style="${3:-$(_get_progress_style)}"

    PROGRESS_TOTAL=$total
    PROGRESS_CURRENT=0
    PROGRESS_LABEL="$label"
    PROGRESS_STYLE="$style"
    PROGRESS_START_TIME=$(date +%s)

    # Initial render
    _progress_render
}

progress_update() {
    local current="$1"
    local label="${2:-$PROGRESS_LABEL}"

    PROGRESS_CURRENT=$current
    PROGRESS_LABEL="$label"

    _progress_render
}

progress_increment() {
    local label="${1:-$PROGRESS_LABEL}"

    PROGRESS_CURRENT=$((PROGRESS_CURRENT + 1))
    PROGRESS_LABEL="$label"

    _progress_render
}

progress_finish() {
    local status="${1:-success}"

    # Final render
    PROGRESS_CURRENT=$PROGRESS_TOTAL
    _progress_render

    echo ""  # New line after progress

    # Show completion message
    if [[ "$status" == "success" ]]; then
        local duration=$(( $(date +%s) - PROGRESS_START_TIME ))
        _log_success "Completed in ${duration}s"
    elif [[ "$status" == "error" ]]; then
        _log_error "Failed"
    fi

    # Reset state
    PROGRESS_TOTAL=0
    PROGRESS_CURRENT=0
    PROGRESS_LABEL=""
}

_progress_render() {
    # Skip if progress style is "none"
    if [[ "$PROGRESS_STYLE" == "none" ]]; then
        return
    fi

    case "$PROGRESS_STYLE" in
        bar)
            _progress_bar_render "$PROGRESS_CURRENT" "$PROGRESS_TOTAL" "$PROGRESS_LABEL"
            ;;
        spinner)
            _progress_spinner_render "$PROGRESS_CURRENT" "$PROGRESS_TOTAL" "$PROGRESS_LABEL"
            ;;
        dots)
            _progress_dots_render "$PROGRESS_CURRENT" "$PROGRESS_TOTAL" "$PROGRESS_LABEL"
            ;;
        percentage|percent)
            _progress_percentage_render "$PROGRESS_CURRENT" "$PROGRESS_TOTAL" "$PROGRESS_LABEL"
            ;;
        *)
            _progress_bar_render "$PROGRESS_CURRENT" "$PROGRESS_TOTAL" "$PROGRESS_LABEL"
            ;;
    esac
}

#=============================================================================
# Simplified Progress (No State)
#=============================================================================

show_progress() {
    local current="$1"
    local total="$2"
    local label="${3:-Processing}"
    local style="${4:-$(_get_progress_style)}"

    case "$style" in
        bar)
            _progress_bar_render "$current" "$total" "$label"
            ;;
        spinner)
            _progress_spinner_render "$current" "$total" "$label"
            ;;
        dots)
            _progress_dots_render "$current" "$total" "$label"
            ;;
        percentage|percent)
            _progress_percentage_render "$current" "$total" "$label"
            ;;
        none)
            # Silent
            ;;
        *)
            _progress_bar_render "$current" "$total" "$label"
            ;;
    esac
}

#=============================================================================
# Task Progress Wrapper
#=============================================================================

with_progress() {
    local total="$1"
    local label="$2"
    shift 2
    local tasks=("$@")

    progress_start "$total" "$label"

    local i=1
    for task in "${tasks[@]}"; do
        eval "$task"
        progress_update "$i"
        ((i++))
    done

    progress_finish "success"
}

#=============================================================================
# Indeterminate Progress (Unknown Duration)
#=============================================================================

progress_indeterminate_start() {
    local label="${1:-Processing}"

    PROGRESS_LABEL="$label"
    SPINNER_INDEX=0

    printf "%s %s..." "$(_spinner_next_frame)" "$label"
}

progress_indeterminate_update() {
    local label="${1:-$PROGRESS_LABEL}"

    PROGRESS_LABEL="$label"

    # Move cursor back and update
    printf "\r%s %s..." "$(_spinner_next_frame)" "$label"
}

progress_indeterminate_finish() {
    echo ""  # New line
    _log_success "Complete"
}

#=============================================================================
# Submodule Operation Progress
#=============================================================================

progress_submodules() {
    local operation="$1"
    local callback="$2"

    local submodules=$(_get_all_submodules)
    local count=$(_get_submodule_count)

    if [[ $count -eq 0 ]]; then
        _log_info "No submodules to process"
        return 0
    fi

    progress_start "$count" "$operation"

    local i=1
    echo "$submodules" | while IFS= read -r submodule; do
        if [[ -n "$submodule" ]]; then
            local submodule_name=$(_get_submodule_name "$submodule")
            progress_update "$i" "$operation $submodule_name"

            # Execute callback for this submodule
            eval "$callback \"$submodule\""

            ((i++))
        fi
    done

    progress_finish "success"
}

#=============================================================================
# File Operation Progress
#=============================================================================

progress_files() {
    local operation="$1"
    shift
    local files=("$@")
    local total=${#files[@]}

    progress_start "$total" "$operation"

    local i=1
    for file in "${files[@]}"; do
        local filename=$(basename "$file")
        progress_update "$i" "$operation $filename"
        ((i++))
        sleep 0.1  # Small delay for visibility
    done

    progress_finish "success"
}

#=============================================================================
# Multi-Stage Progress
#=============================================================================

progress_stages_start() {
    local stages="$1"
    PROGRESS_TOTAL=$stages
    PROGRESS_CURRENT=0
}

progress_stage_complete() {
    local stage_name="$1"
    PROGRESS_CURRENT=$((PROGRESS_CURRENT + 1))
    _log_success "$stage_name [$PROGRESS_CURRENT/$PROGRESS_TOTAL]"
}

#=============================================================================
# Time Estimation
#=============================================================================

_estimate_remaining_time() {
    local current="$1"
    local total="$2"
    local start_time="$3"

    if [[ $current -eq 0 ]]; then
        echo "estimating..."
        return
    fi

    local elapsed=$(( $(date +%s) - start_time ))
    local rate=$(( current / elapsed ))

    if [[ $rate -eq 0 ]]; then
        echo "calculating..."
        return
    fi

    local remaining=$(( (total - current) / rate ))

    if [[ $remaining -lt 60 ]]; then
        echo "${remaining}s remaining"
    else
        local minutes=$(( remaining / 60 ))
        echo "${minutes}m remaining"
    fi
}

#=============================================================================
# Export Functions
#=============================================================================

# Main functions:
# - progress_start(total, label, [style])
# - progress_update(current, [label])
# - progress_increment([label])
# - progress_finish([status])
# - show_progress(current, total, label, [style])
#
# Task wrappers:
# - with_progress(total, label, tasks...)
# - progress_submodules(operation, callback)
# - progress_files(operation, files...)
#
# Indeterminate:
# - progress_indeterminate_start(label)
# - progress_indeterminate_update([label])
# - progress_indeterminate_finish()
#
# Multi-stage:
# - progress_stages_start(stages)
# - progress_stage_complete(stage_name)
