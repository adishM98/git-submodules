## Git Submodules - Oh My Zsh Plugin

This plugin provides useful Git commands for managing submodules easily.

### Installation

1. Clone this repository:

   ```sh
   git clone https://github.com/adishM98/git-submodules.git ~/.oh-my-zsh/custom/plugins/git-submodules
   ```

2. Edit `~/.zshrc` and add it to plugins:

   ```sh
   plugins=(git-submodules)
   ```

3. Reload Zsh:

   ```sh
   source ~/.zshrc
   ```

### Available Commands

| Command                             | Description                                          |
| ----------------------------------- | ---------------------------------------------------- |
| `checkout_all <branch>`             | Checkout a branch and pull updates for submodules    |
| `pull_all`                          | Pull changes for the main repository and submodules  |
| `add_all`                           | Stage changes for the main repository and submodules |
| `create_branch_all <branch>`        | Create a new branch in all repositories              |
| `create_feature_all <feature_name>` | Create a `feature/` branch in all repositories       |
| `create_hotfix_all <hotfix_name>`   | Create a `hot-fix/` branch in all repositories       |
| `create_release_all <release_name>` | Create a `release/` branch in all repositories       |
| `create_sprint_all <sprint_name>`   | Create a `sprint/` branch in all repositories        |
| `create_tag_all <tag_name>`         | Create and push a new tag                            |
| `commit_all "<message>"`            | Commit changes across repositories                   |
| `push_all`                          | Push changes across repositories                     |
| `status_all`                        | Show Git status for all repositories                 |
| `merge_all`                         | Merge changes from base branch into base/submodule branches 
| `update_git_submodules_plugin`      | Check for updates and update the plugin              |
| `start_branch`                      | Create a branch interactively in base, submodules, or folders |
| `start_feature`                     | Create a `feature/` branch interactively            |
| `start_hotfix`                      | Create a `hotfix/` branch interactively             |
| `start_release`                     | Create a `release/` branch interactively            |
| `start_sprint`                      | Create a `sprint/` branch interactively             |

### `merge_all` Usage

This command lets you merge changes from a base branch (e.g., `main` or `develop`) into your current working branch across the main repo and submodules. It replaces any use of `git rebase` with `git merge` and supports optional stash handling to preserve local changes.

You'll be prompted to:

- Enter the base branch to merge from
- Choose whether to merge into:
  - Base repository
  - Submodules (`frontend/ee`, `server/ee`, or both)
  - Both base and submodules
  - Both with stash handling (recommended when you have local changes)

Merge conflicts (if any) will need to be resolved manually by the developer.



### Updating the Plugin

Can manually check for updates and install them by running:

```sh
update_git_submodules_plugin
```

### Uninstallation

To remove the plugin, follow these steps:

1. Remove it from your `.zshrc` plugins list:

   ```sh
   plugins=( ... )  # Remove 'git-submodules' from the list
   ```

2. Delete the plugin directory:

   ```sh
   rm -rf ~/.oh-my-zsh/custom/plugins/git-submodules
   ```

3. Reload Zsh:

   ```sh
   source ~/.zshrc
   ```

#### Note:

All commands should be executed from the **base repository** (the main Git repository that contains submodules). Running them from a submodule directory may result in unexpected behavior.