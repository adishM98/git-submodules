#!/usr/bin/env zsh

#=============================================================================
# TUI Data Bridge
#
# This module provides JSON data for the TUI by wrapping and enhancing
# the existing json-output.zsh functions.
#=============================================================================

# Export full status as JSON for TUI
# Enhances json_status_all() with additional fields needed by TUI
gsm_tui_status_json() {
    # Get base repo status
    local base_json=$(gsm_tui_repo_status ".")

    # Get all submodules
    local submodules=$(git submodule status 2>/dev/null | awk '{print $2}')

    # Build submodules array
    echo "{"
    echo "  \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\","
    echo "  \"base\": $base_json,"
    echo "  \"submodules\": ["

    local first=true
    if [[ -n "$submodules" ]]; then
        while IFS= read -r submodule; do
            if [[ -n "$submodule" ]]; then
                if $first; then first=false; else echo ","; fi
                gsm_tui_repo_status "$submodule"
            fi
        done <<< "$submodules"
    fi

    echo "  ]"
    echo "}"
}

# Export single repository status as JSON
gsm_tui_repo_status() {
    local repo_path="$1"

    if [[ -z "$repo_path" ]]; then
        echo '{"error": "repo_path required"}' >&2
        return 1
    fi

    # Change to repo directory
    if [[ ! -d "$repo_path" ]]; then
        echo '{"error": "directory not found"}' >&2
        return 1
    fi

    local original_dir=$(pwd)
    cd "$repo_path" || return 1

    # Check if it's a git repo
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo '{"error": "not a git repository"}' >&2
        cd "$original_dir"
        return 1
    fi

    # Get repo info
    local branch=$(git branch --show-current 2>/dev/null || echo "detached")
    local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
    local behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")

    # Count changes
    local staged=$(git diff --cached --numstat | wc -l | tr -d ' ')
    local unstaged=$(git diff --numstat | wc -l | tr -d ' ')
    local untracked=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')
    local conflicts=$(git diff --name-only --diff-filter=U | wc -l | tr -d ' ')

    # Stash count
    local stash_count=$(git stash list | wc -l | tr -d ' ')

    # Last commit
    local last_hash=$(git log -1 --format='%h' 2>/dev/null || echo "")
    local last_message=$(git log -1 --format='%s' 2>/dev/null || echo "")
    local last_author=$(git log -1 --format='%an' 2>/dev/null || echo "")
    local last_date=$(git log -1 --format='%ci' 2>/dev/null || echo "")

    # Status (clean or dirty)
    local repo_status="clean"
    if [[ $staged -gt 0 ]] || [[ $unstaged -gt 0 ]] || [[ $untracked -gt 0 ]]; then
        repo_status="dirty"
    fi

    # Build JSON
    cat <<EOF
{
  "name": "$(basename "$repo_path")",
  "path": "$repo_path",
  "branch": "$branch",
  "status": "$repo_status",
  "ahead": $ahead,
  "behind": $behind,
  "staged": $staged,
  "unstaged": $unstaged,
  "untracked": $untracked,
  "conflicts": $conflicts,
  "stashCount": $stash_count,
  "lastCommit": {
    "hash": "$last_hash",
    "message": "$last_message",
    "author": "$last_author",
    "date": "$last_date"
  }
}
EOF

    cd "$original_dir"
}

# Export file list for a repository
gsm_tui_file_list() {
    local repo_path="$1"

    if [[ -z "$repo_path" ]]; then
        echo '{"error": "repo_path required"}' >&2
        return 1
    fi

    local original_dir=$(pwd)
    cd "$repo_path" || return 1

    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo '{"error": "not a git repository"}' >&2
        cd "$original_dir"
        return 1
    fi

    # Get file lists
    local staged_files=($(git diff --cached --name-status | awk '{print $1":"$2}'))
    local unstaged_files=($(git diff --name-status | awk '{print $1":"$2}'))
    local untracked_files=($(git ls-files --others --exclude-standard))

    # Build JSON array
    echo '{'
    echo '  "staged": ['
    local first=true
    for file in "${staged_files[@]}"; do
        local status="${file%%:*}"
        local path="${file#*:}"
        if $first; then first=false; else echo ','; fi
        echo -n "    {\"path\": \"$path\", \"status\": \"$status\"}"
    done
    echo -e '\n  ],'

    echo '  "unstaged": ['
    first=true
    for file in "${unstaged_files[@]}"; do
        local status="${file%%:*}"
        local path="${file#*:}"
        if $first; then first=false; else echo ','; fi
        echo -n "    {\"path\": \"$path\", \"status\": \"$status\"}"
    done
    echo -e '\n  ],'

    echo '  "untracked": ['
    first=true
    for file in "${untracked_files[@]}"; do
        if $first; then first=false; else echo ','; fi
        echo -n "    {\"path\": \"$file\", \"status\": \"untracked\"}"
    done
    echo -e '\n  ]'
    echo '}'

    cd "$original_dir"
}
