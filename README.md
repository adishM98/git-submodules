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

Available Commands:

| Command                          | Description |
|----------------------------------|-------------|
| `checkout_all <branch>`          | Checkout a branch and pull updates for submodules |
| `pull_all`                       | Pull changes for the main repository and submodules |
| `add_all`                        | Stage changes for the main repository and submodules |
| `create_branch_all <branch>`     | Create a new branch in all repositories |
| `create_feature_all <feature_name>` | Create a `feature/` branch in all repositories |
| `create_hotfix_all <hotfix_name>`   | Create a `hot-fix/` branch in all repositories |
| `create_release_all <release_name>` | Create a `release/` branch in all repositories |
| `create_sprint_all <sprint_name>`   | Create a `sprint/` branch in all repositories |
| `create_tag_all <tag_name>`         | Create and push a new tag |
| `commit_all "<message>"`            | Commit changes across repositories |
| `push_all`                          | Push changes across repositories |
| `status_all`                        | Show Git status for all repositories |


## Auto-Update
This plugin automatically updates itself whenever a new version is available.  

To manually force an update, run:
```sh
cd ~/.oh-my-zsh/custom/plugins/git-submodules && git pull && source ~/.zshrc && cd
```


#### Note:
All commands should be executed from the **base repository** (the main Git repository that contains submodules).

Running them from a submodule directory may result in unexpected behavior.
