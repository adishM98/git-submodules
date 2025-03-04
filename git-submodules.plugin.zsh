#!/bin/zsh

# Checkout all repositories (including submodules)
checkout_all() {
    local branch="$1"
    if [ -z "$branch" ]; then
        echo "Branch name required! Usage: checkout_all <branch>"
        return 1
    fi
    git checkout "$branch" && git pull
    git submodule foreach --recursive " \
        if git show-ref --verify --quiet refs/heads/$branch; then \
            git checkout $branch && git pull; \
        elif git ls-remote --exit-code origin $branch >/dev/null; then \
            echo 'Tracking new remote branch $branch in submodule $(basename $PWD)'; \
            git checkout -t origin/$branch && git pull; \
        else \
            echo 'Skipping submodule $(basename $PWD), branch $branch not found.'; \
        fi"
}

# Pull changes for all repositories
pull_all() {
    git fetch --all
    git pull
    git submodule update --init --recursive
    git submodule foreach 'git fetch --all && git pull'
}

# Stage all changes
add_all() {
    git add -A
    git submodule foreach 'git add -A'
}

# Create a new branch across repositories
create_branch_all() {
    local branch_name="$1"
    if [ -z "$branch_name" ]; then
        echo "Branch name required! Usage: create_branch_all <branch_name>"
        return 1
    fi
    git checkout -b "$branch_name" && git push -u origin "$branch_name"
    git submodule foreach --quiet --recursive "git checkout -b $branch_name && git push -u origin $branch_name"
}

# Helper function to create prefixed branches
create_prefixed_branch() {
    local prefix="$1"
    local name="$2"
    if [ -z "$name" ]; then
        echo "Name required! Usage: create_${prefix}_all <name>"
        return 1
    fi
    local branch="$prefix/$name"
    git checkout -b "$branch" && git push -u origin "$branch"
    git submodule foreach --quiet --recursive "git checkout -b $branch && git push -u origin $branch"
}

create_feature_all() { create_prefixed_branch "feature" "$1"; }
create_hotfix_all() { create_prefixed_branch "hot-fix" "$1"; }
create_release_all() { create_prefixed_branch "release" "$1"; }
create_revamp_all() { create_prefixed_branch "revamp" "$1"; }
create_sprint_all() { create_prefixed_branch "sprint" "$1"; }

# Create a new tag across repositories
create_tag_all() {
    local tag_name="$1"
    if [ -z "$tag_name" ]; then
        echo "Tag name required! Usage: create_tag_all <tag_name>"
        return 1
    fi
    git tag "$tag_name" && git push origin "$tag_name"
    git submodule foreach --quiet --recursive "git tag $tag_name && git push origin $tag_name"
}

# Commit all changes with a message
commit_all() {
    local message="$1"
    if [ -z "$message" ]; then
        echo "Commit message required! Usage: commit_all <message>"
        return 1
    fi
    git commit -m "$message"
    git submodule foreach --quiet --recursive "git commit -m '$message'"
}

# Push all changes
push_all() {
    git push
    git submodule foreach --quiet --recursive "git push"
}

# Show status of all repositories
status_all() {
    git status
    git submodule foreach --quiet --recursive "git status"
}



# Define the plugin directory
GIT_SUBMODULES_PLUGIN_DIR="${0:A:h}"

# Function to update the plugin automatically
function update_git_submodules_plugin() {
    # Store the current directory
    local ORIGINAL_DIR="$(pwd)"

    echo "Checking for updates for git-submodules plugin..."
    cd "$GIT_SUBMODULES_PLUGIN_DIR"

    # Fetch latest changes from the main branch quietly
    git fetch origin main --quiet

    # Check if there are new updates
    if ! git diff --quiet HEAD origin/main; then
        echo "Updating git-submodules plugin..."
        git reset --hard origin/main --quiet
        git pull origin main --quiet
        echo "Update complete! Reloading Zsh..."
        
        # Automatically reload Zsh
        exec zsh
    fi

    # Restore the original directory
    cd "$ORIGINAL_DIR"
}

# Run the update function
update_git_submodules_plugin
