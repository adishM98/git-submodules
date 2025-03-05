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

create_branch_interactive() {
    local branch_type="$1"
    local branch_name scope
    local -a folder_paths  # Declare as an array explicitly for zsh

    # Prompt for branch name
    echo -n "Enter $branch_type name: "
    read branch_name

    if [ -z "$branch_name" ]; then
        echo "$branch_type name is required!"
        return 1
    fi

    # Prompt for scope
    echo "Where do you want to create the $branch_type branch?"
    echo "1) Base repository"
    echo "2) Submodule repositories"
    echo "3) Specific folders"
    echo "4) All (Base + Submodules)"
    echo -n "Enter your choice (1/2/3/4): "
    read scope

    case "$scope" in
        1)
            echo "Creating $branch_type branch in base repository..."
            git checkout -b "$branch_type/$branch_name" && git push -u origin "$branch_type/$branch_name"
            ;;
        2)
            echo "Creating $branch_type branch in submodules..."
            git submodule foreach --quiet --recursive "git checkout -b $branch_type/$branch_name && git push -u origin $branch_type/$branch_name"
            ;;
        3)
            echo -n "Enter folder paths (separated by spaces): "
            read -r folder_input  # Read input as a single string
            folder_paths=(${=folder_input})  # Split string into array using zsh syntax

            if [ ${#folder_paths[@]} -eq 0 ]; then
                echo "No valid folders provided!"
                return 1
            fi

            echo "Processing the following folders: ${folder_paths[@]}"
            for folder in "${folder_paths[@]}"; do
                if [ -d "$folder" ]; then
                    echo "Creating $branch_type branch in $folder..."
                    (cd "$folder" && git checkout -b "$branch_type/$branch_name" && git push -u origin "$branch_type/$branch_name")
                else
                    echo "Error: Folder '$folder' does not exist. Skipping..."
                fi
            done
            ;;
        4)
            echo "Creating $branch_type branch in base repository and submodules..."
            git checkout -b "$branch_type/$branch_name" && git push -u origin "$branch_type/$branch_name"
            git submodule foreach --quiet --recursive "git checkout -b $branch_type/$branch_name && git push -u origin $branch_type/$branch_name"
            ;;
        *)
            echo "Invalid choice! Please enter 1, 2, 3, or 4."
            return 1
            ;;
    esac

    echo "$branch_type branch '$branch_type/$branch_name' created successfully!"
}

# Wrapper functions for different branch types
start_feature() { create_branch_interactive "feature"; }
start_hotfix() { create_branch_interactive "hotfix"; }
start_release() { create_branch_interactive "release"; }
start_sprint() { create_branch_interactive "sprint"; }



# Define the plugin directory
GIT_SUBMODULES_PLUGIN_DIR="${0:A:h}"

# Function to update the plugin manually
function update_git_submodules_plugin() {
    # Store the current directory
    local ORIGINAL_DIR="$(pwd)"

    echo "Checking for updates for git-submodules plugin..."
    cd "$GIT_SUBMODULES_PLUGIN_DIR"

    # Fetch latest changes from the main branch quietly
    git fetch origin main --quiet

    # Check if there are new updates
    if ! git diff --quiet HEAD origin/main; then
        echo "A new update is available for git-submodules plugin."

        # Ask user if they want to update
        read "RESPONSE?Do you want to update? (y/N): "

        if [[ "$RESPONSE" =~ ^[Yy]$ ]]; then
            echo "Updating git-submodules plugin..."
            git reset --hard origin/main --quiet
            git pull origin main --quiet
            echo "Update complete!"

            # Ask if they want to reload Zsh
            read "RELOAD?Would you like to reload Zsh now? (y/N): "

            if [[ "$RELOAD" =~ ^[Yy]$ ]]; then
                echo "Reloading Zsh..."

                # Store the current directory in an environment variable
                export PREV_DIR="$ORIGINAL_DIR"

                # Reload Zsh and restore the working directory
                exec zsh -c 'cd "$PREV_DIR"; exec zsh'
            else
                echo "You can reload manually by running: source ~/.zshrc"
            fi
        else
            echo "Skipping update."
        fi
    else
        echo "You're already using the latest version of git-submodules plugin."
    fi

    # Restore the original directory
    cd "$ORIGINAL_DIR"
}
