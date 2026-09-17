# Dotfiles

This repository keeps shell, editor, terminal, file-manager, and agent configuration in Git so the same setup can be reused across machines. The files remain in the repository, while links expose them at the paths where each program expects to find them.

The repository includes an Arch Linux installer for the desktop and command-line dependencies used by the configuration. Windows linking remains available for older machines.

## Linux setup

On Arch Linux, clone the repository and run the setup script:

```sh
cd ~/Projects
git clone git@github.com:triet228/.dotfiles.git
cd .dotfiles
./setup-arch.sh
```

The script installs required official and AUR packages, applies the Firefox policy that always restores the previous session, links the managed files, creates XDG user directories, and installs Neovim plugins. It is safe to rerun and refuses to overwrite conflicting files. Application state under `~/.codex`, `~/.claude`, and `~/.local/bin` remains outside the repository.

Start the desktop from a TTY with `startx`, or select the dwm X11 session in the login manager. The X session starts sxhkd, dunst, picom, CopyQ, KeePassXC, Kitty, GitHub Desktop, and Firefox when available.

## Windows setup

Clone the repository anywhere, then run the PowerShell installer from the repository root:

```powershell
git clone git@github.com:triet228/.dotfiles.git "$HOME\Projects\.dotfiles"
cd "$HOME\Projects\.dotfiles"
.\setup-windows-symlinks.ps1
```

The installer derives the repository location from its own path. It creates directory junctions for configuration directories and symbolic links for individual files, so Git updates cannot leave file links pointing at replaced files. Creating file symbolic links requires Windows Developer Mode or an elevated PowerShell session. It also links the Neovim configuration into both `~/.config/nvim` and `%LOCALAPPDATA%\nvim`, and installs the PowerShell profile in the locations used by PowerShell and Windows PowerShell.

The installer can be run repeatedly. Existing correct links are left alone, identical regular files are replaced with links, and dangling links are repaired. Existing hard links are migrated to symbolic links; if their content differs from the repository, the installer preserves the old content in a timestamped backup beside the link. Other conflicting files are reported without being overwritten. Resolve reported conflicts deliberately and rerun the script.

## Updating

Because the active configuration paths link back to this repository, changes made through either path normally appear in the Git working tree:

```sh
git status
git add <files>
git commit -m "Describe the configuration change"
git pull --rebase
git push
```

After pulling on another machine, rerun the appropriate setup command if new configuration files or dependencies were added.

## Main contents

- `.config/powershell/`: PowerShell profile, key bindings, navigation, prompt, and helper functions.
- `.gitconfig`: Git configuration, including Delta output for `git diff`.
- `.zshrc`: Zsh configuration for Linux.
- `.config/nvim/` and `.vimrc`: Neovim and Vim configuration.
- `.xinitrc` and `.config/sxhkd/`: dwm session startup and desktop shortcuts.
- `.config/kitty/`, `.config/lf/`, and `.config/fastfetch/`: application configuration.
- `firefox/policies.json`: Firefox startup policy that always restores the previous session.
- `.tmux.conf` and `.tmux/`: tmux configuration and vendored plugins.
- `.local/bin/`: personal helper commands.
- `.codex/AGENTS.md` and `.claude/`: coding-agent instructions and settings.
- `setup-arch.sh`: repeatable Arch package installation and dotfile linking.

The `clean` helper intentionally performs system package/cache cleanup and clears the contents of `Downloads` and `Pictures`. Review it before using it on a new machine.
