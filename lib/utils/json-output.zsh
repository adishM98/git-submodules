#!/bin/zsh

#=============================================================================
# JSON Output Module
# Provides JSON formatting for CI/CD and scripting integration
# Falls back to manual JSON if jq not available
#=============================================================================

#=============================================================================
# JSON Helpers
#=============================================================================

_json_escape() {
    local str="$1"
    # Escape quotes, backslashes, newlines, tabs
    echo "$str" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | tr '\n' '\\n'
}

_json_string() {
    local key="$1"
    local value="$2"
    echo "\"$key\": \"$(_json_escape "$value")\""
}

_json_number() {
    local key="$1"
    local value="$2"
    echo "\"$key\": $value"
}

_json_boolean() {
    local key="$1"
    local value="$2"
    if [[ "$value" == "true" ]] || [[ "$value" == "1" ]]; then
        echo "\"$key\": true"
    else
        echo "\"$key\": false"
    fi
}

_json_array_start() {
    echo "["
}

_json_array_end() {
    echo "]"
}

_json_object_start() {
    echo "{"
}

_json_object_end() {
    echo "}"
}

#=============================================================================
# Status JSON
#=============================================================================

json_status_all() {
    local base_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    local base_status=$(git status --porcelain 2>/dev/null || echo "")
    local base_ahead=$(git rev-list @{upstream}..HEAD 2>/dev/null | wc -l | tr -d ' ')
    local base_behind=$(git rev-list HEAD..@{upstream} 2>/dev/null | wc -l | tr -d ' ')

    echo "{"
    echo "  \"base\": {"
    echo "    $(_json_string "branch" "$base_branch"),"
    echo "    $(_json_string "status" "$base_status"),"
    echo "    $(_json_number "ahead" "$base_ahead"),"
    echo "    $(_json_number "behind" "$base_behind")"
    echo "  },"

    echo "  \"submodules\": ["

    local submodules=$(_get_all_submodules)
    local first=true

    if [[ -n "$submodules" ]]; then
        echo "$submodules" | while IFS= read -r submodule; do
            if [[ -n "$submodule" ]]; then
                [[ "$first" == "false" ]] && echo ","

                local sub_branch=$(cd "$submodule" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
                local sub_status=$(cd "$submodule" && git status --porcelain 2>/dev/null || echo "")
                local sub_ahead=$(cd "$submodule" && git rev-list @{upstream}..HEAD 2>/dev/null | wc -l | tr -d ' ')
                local sub_behind=$(cd "$submodule" && git rev-list HEAD..@{upstream} 2>/dev/null | wc -l | tr -d ' ')

                echo "    {"
                echo "      $(_json_string "path" "$submodule"),"
                echo "      $(_json_string "branch" "$sub_branch"),"
                echo "      $(_json_string "status" "$sub_status"),"
                echo "      $(_json_number "ahead" "$sub_ahead"),"
                echo "      $(_json_number "behind" "$sub_behind")"
                echo "    }"

                first=false
            fi
        done
    fi

    echo "  ]"
    echo "}"
}

#=============================================================================
# Operation Result JSON
#=============================================================================

json_result() {
    local success="$1"
    local message="$2"
    shift 2
    local data=("$@")

    echo "{"
    echo "  $(_json_boolean "success" "$success"),"
    echo "  $(_json_string "message" "$message")"

    if [[ ${#data[@]} -gt 0 ]]; then
        echo "  ,"
        echo "  \"data\": {"
        local first=true
        for item in "${data[@]}"; do
            [[ "$first" == "false" ]] && echo ","
            echo "    $item"
            first=false
        done
        echo "  }"
    fi

    echo "}"
}

#=============================================================================
# Pull Result JSON
#=============================================================================

json_pull_result() {
    local repos_updated="$1"
    local errors="$2"

    echo "{"
    echo "  $(_json_boolean "success" "$([ -z "$errors" ] && echo true || echo false)"),"
    echo "  $(_json_number "repositories_updated" "$repos_updated")"

    if [[ -n "$errors" ]]; then
        echo "  ,"
        echo "  \"errors\": ["
        echo "    $(_json_string "message" "$errors")"
        echo "  ]"
    else
        echo "  ,"
        echo "  \"errors\": []"
    fi

    echo "}"
}

#=============================================================================
# Push Result JSON
#=============================================================================

json_push_result() {
    local repos_pushed="$1"
    local commits_pushed="$2"
    local errors="$3"

    echo "{"
    echo "  $(_json_boolean "success" "$([ -z "$errors" ] && echo true || echo false)"),"
    echo "  $(_json_number "repositories_pushed" "$repos_pushed"),"
    echo "  $(_json_number "commits_pushed" "$commits_pushed")"

    if [[ -n "$errors" ]]; then
        echo "  ,"
        echo "  \"errors\": ["
        echo "    $(_json_string "message" "$errors")"
        echo "  ]"
    else
        echo "  ,"
        echo "  \"errors\": []"
    fi

    echo "}"
}

#=============================================================================
# Commit Result JSON
#=============================================================================

json_commit_result() {
    local message="$1"
    local repos_committed="$2"
    local files_changed="$3"

    echo "{"
    echo "  $(_json_boolean "success" "true"),"
    echo "  $(_json_string "commit_message" "$message"),"
    echo "  $(_json_number "repositories_committed" "$repos_committed"),"
    echo "  $(_json_number "files_changed" "$files_changed")"
    echo "}"
}

#=============================================================================
# Submodule List JSON
#=============================================================================

json_submodules_list() {
    echo "{"
    echo "  \"submodules\": ["

    local submodules=$(_get_all_submodules)
    local first=true

    if [[ -n "$submodules" ]]; then
        echo "$submodules" | while IFS= read -r submodule; do
            if [[ -n "$submodule" ]]; then
                [[ "$first" == "false" ]] && echo ","

                local url=$(_get_submodule_url "$submodule")
                local branch=$(_get_submodule_branch "$submodule")
                local status=$(_get_submodule_status "$submodule")

                echo "    {"
                echo "      $(_json_string "path" "$submodule"),"
                echo "      $(_json_string "url" "$url"),"
                echo "      $(_json_string "branch" "$branch"),"
                echo "      $(_json_string "status" "$status")"
                echo "    }"

                first=false
            fi
        done
    fi

    echo "  ],"
    echo "  $(_json_number "count" "$(_get_submodule_count)")"
    echo "}"
}

#=============================================================================
# Config JSON
#=============================================================================

json_config() {
    echo "{"
    echo "  \"config\": {"
    echo "    $(_json_string "parallel_enabled" "$(_get_config parallel_enabled)"),"
    echo "    $(_json_number "parallel_jobs" "$(_get_config parallel_jobs)"),"
    echo "    $(_json_string "menu_style" "$(_get_config menu_style)"),"
    echo "    $(_json_string "progress_style" "$(_get_config progress_style)"),"
    echo "    $(_json_boolean "emoji_enabled" "$(_get_config emoji_enabled)"),"
    echo "    $(_json_boolean "atomic_commits" "$(_get_config atomic_commits)"),"
    echo "    $(_json_boolean "dry_run_default" "$(_get_config dry_run_default)"),"
    echo "    $(_json_boolean "confirm_destructive" "$(_get_config confirm_destructive)"),"
    echo "    $(_json_boolean "cache_enabled" "$(_get_config cache_enabled)"),"
    echo "    $(_json_number "cache_ttl" "$(_get_config cache_ttl)"),"
    echo "    $(_json_boolean "verbose_mode" "$(_get_config verbose_mode)"),"
    echo "    $(_json_boolean "quiet_mode" "$(_get_config quiet_mode)"),"
    echo "    $(_json_boolean "auto_stash" "$(_get_config auto_stash)")"
    echo "  }"
    echo "}"
}

#=============================================================================
# Export Functions
#=============================================================================

# Available functions:
# - json_status_all()                              - Full status JSON
# - json_result(success, message, [data...])       - Generic result
# - json_pull_result(updated, errors)              - Pull operation result
# - json_push_result(pushed, commits, errors)      - Push operation result
# - json_commit_result(message, repos, files)      - Commit operation result
# - json_submodules_list()                         - List submodules
# - json_config()                                  - Configuration
#
# Low-level helpers:
# - _json_string(key, value)
# - _json_number(key, value)
# - _json_boolean(key, value)
# - _json_escape(string)
