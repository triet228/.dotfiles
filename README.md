# Dotfiles

This repository keeps shell, editor, terminal, file-manager, and agent configuration in Git so the same setup can be reused across machines. The files remain in the repository, while links expose them at the paths where each program expects to find them.

The repository includes Linux installers and a Windows setup for native PowerShell, Git, Neovim, and lf.

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

## Ubuntu setup

On Ubuntu, run `./setup-ubuntu.sh` instead. It installs the command-line tools with apt, adds upstream builds of Neovim and fastfetch, links the managed files (including `.config/fish/config.fish`), and installs Neovim plugins. Conflicting files are moved into `~/.dotfiles-backup/` instead of being overwritten. The dwm desktop files are skipped.

## Windows setup

Clone the repository anywhere, then run the PowerShell installer from the repository root:

```powershell
git clone git@github.com:triet228/.dotfiles.git "$HOME\Projects\.dotfiles"
cd "$HOME\Projects\.dotfiles"
.\setup-windows-symlinks.ps1
```

When adopting this configuration on a computer with existing files, use:

```powershell
.\setup-windows-symlinks.ps1 -BackupExisting
```

Conflicting configurations are then moved into `~/.dotfiles-backup/windows/<timestamp>/`, retaining their paths relative to the home directory. Without this option, conflicts are reported and left alone. Existing correct links are left alone, identical regular files are replaced with links, and dangling links are repaired. Old hard links with different content are always backed up before migration.

The installer derives the repository location from its own path. It creates directory junctions for configuration directories and, when Windows Developer Mode or elevation allows it, symbolic links for individual files. Otherwise it creates loader files for PowerShell, Vim, and lf, and copies the remaining settings. Loaders read directly from the checkout, so Git updates take effect without reinstalling. Copies are tracked in `~/.local/state/dotfiles/windows-copies.json` and refreshed on subsequent setup runs; locally edited copies are treated as conflicts. No administrator access is required for this fallback.

It installs the profile for both PowerShell and Windows PowerShell, links Neovim's native configuration directory, and installs Windows-specific lf settings and previews under `%LOCALAPPDATA%\lf` without moving lf history or selection state. Linux desktop settings are not installed on Windows.

Alacritty reads the managed configuration through `%APPDATA%\alacritty`, using PowerShell 7 and the installed JetBrainsMono Nerd Font Mono. The existing Windows Terminal settings can remain local. SSH receives a managed copy of `.ssh/config` in `~/.ssh`, where it inherits the directory's private permissions; OpenSSH rejects direct links into this checkout because its inherited permissions are broader. The configuration uses the existing `~/.ssh/id_ed25519` key; private keys remain outside Git. Rerun setup after changing the shared SSH configuration.

For existing Firefox profiles listed in `profiles.ini`, setup adds a managed session-restore block to each `user.js`, preserving other preferences and backing up existing files before changing them. Values come from `firefox/policies.json`. This uses Firefox's [user preference file](https://firefox-source-docs.mozilla.org/modules/libpref/index.html), so setup does not need to write into Program Files or protected policy registry keys. Restart Firefox to apply the preferences. They are reapplied at startup rather than locked by an administrator policy.

Git retains its existing local configuration, including Overleaf and safe-directory settings. The installer backs it up before adding includes for the shared settings and `.config/git/windows.gitconfig`. The Windows overrides use Neovim, Delta, long paths, and Git Credential Manager instead of the Linux credential helper.

When the existing GitHub CLI login is stored under `%APPDATA%\GitHub CLI`, the profile keeps using that location instead of letting `XDG_CONFIG_HOME` hide it. Authentication state remains outside the repository.

The profile detects Conda in common user and system locations, uses the installed Starship prompt in interactive terminals, and keeps redirected/background shell startup quiet. Fuzzy file lookup uses `fd` when available and otherwise uses `rg`. The `lf` command returns to the directory selected on exit; `DD` moves selected files to the Windows Recycle Bin. Its open, editor, viewer, shell, and help commands use PowerShell syntax. Neovim can reuse an existing `~/.vim/plugged` installation through a junction in `%LOCALAPPDATA%\nvim-data\plugged`. Vim creates its persistent undo directory under `~/.vim/undodir` when needed.

The linker configures existing Windows applications. The profile supports Git for Windows, Neovim, Conda, lf, eza, fzf, zoxide, ripgrep, Delta, and Starship. Install the additional system-info, preview, fuzzy-search, and image-conversion tools for the current user with WinGet:

```powershell
foreach ($id in 'Fastfetch-cli.Fastfetch', 'sharkdp.bat', 'sharkdp.fd', 'ImageMagick.Q16-HDRI') {
    winget install --id $id --exact --source winget --scope user --silent --no-upgrade --accept-package-agreements --accept-source-agreements
}
```

The profile picks up newly added user PATH entries even when its parent terminal app is already running. Run `tools` to inspect command discovery. Fastfetch, bat, fd, and ImageMagick are used when available; previews and fuzzy file lookup still have fallbacks. Open a new terminal after setup to load the profile. After pulling, rerun setup to refresh any managed copies.

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

The `clean` helper intentionally performs system package/cache cleanup and clears the contents of `Downloads` and `Pictures`. On Windows, personal files go to the Recycle Bin, and cleanup preserves runtime installations and downloaded models in `~/.cache` by clearing only named disposable caches. Review it before using it on a new machine.
