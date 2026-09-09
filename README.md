# Dotfiles

This repository keeps shell, editor, terminal, file-manager, and agent configuration in Git so the same setup can be reused across machines. The files remain in the repository, while links expose them at the paths where each program expects to find them.

The repository only manages configuration. Install the programs referenced by the configuration separately, such as Git, GNU Stow, PowerShell, Neovim, Vim, tmux, Kitty, lf, fzf, eza, zoxide, and direnv as needed on each machine.

## Linux setup

Clone the repository and use GNU Stow to create symbolic links in the home directory:

```sh
cd ~/Projects
git clone git@github.com:triet228/.dotfiles.git
cd .dotfiles
stow . --target "$HOME"
```

Stow does not overwrite existing files. Back up or reconcile any reported conflicts before running it again.

## Windows setup

Clone the repository anywhere, then run the PowerShell installer from the repository root:

```powershell
git clone git@github.com:triet228/.dotfiles.git "$HOME\Projects\.dotfiles"
cd "$HOME\Projects\.dotfiles"
.\setup-windows-symlinks.ps1
```

The installer derives the repository location from its own path. It creates directory junctions for configuration directories and hard links for individual files. It also links the Neovim configuration into both `~/.config/nvim` and `%LOCALAPPDATA%\nvim`, and installs the PowerShell profile in the locations used by PowerShell and Windows PowerShell.

The installer can be run repeatedly. Existing correct links are left alone, identical regular files are replaced with links, dangling links are repaired, and conflicting files are reported without being overwritten. Resolve reported conflicts deliberately and rerun the script.

## Updating

Because the active configuration paths link back to this repository, changes made through either path normally appear in the Git working tree:

```sh
git status
git add <files>
git commit -m "Describe the configuration change"
git pull --rebase
git push
```

After pulling on another machine, rerun the appropriate linking command if new configuration files were added.

## Main contents

- `.config/powershell/`: PowerShell profile, key bindings, navigation, prompt, and helper functions.
- `.zshrc`: Zsh configuration for Linux.
- `.config/nvim/` and `.vimrc`: Neovim and Vim configuration.
- `.config/kitty/`, `.config/lf/`, `.config/fastfetch/`, and `.config/sxhkd/`: application configuration.
- `.tmux.conf` and `.tmux/`: tmux configuration and vendored plugins.
- `.local/bin/`: personal helper commands.
- `.codex/AGENTS.md` and `.claude/`: coding-agent instructions and settings.

The `clean` helper intentionally performs system package/cache cleanup and clears the contents of `Downloads` and `Pictures`. Review it before using it on a new machine.
