# What are dotfiles?
Dotfiles are files start with dot (example: .zshrc). 


# Why dotfiles?
Dotfiles are used to change configuration of program. For example, my original terminal has no colors, just black and white. To change this to colorful terminal, I go to my dotfiles (.zshrc) and add a few lines to add colors. There is no point in a centralized folder for dotfiles if I only run one machine. However, I run multiple machines and I want to sync the configuration across my machines. Therefore, having this dotfiles centralized into a git repo is more conveient to manage. I could've used syncthing to sync this dotfiles too but a git repo offer a very good backup of previous version just in case something happen and I lost my dotfiles.


# How to use this repo on Windows OS

On Windows, I only need `/.codex` and `./Projects/*/AGENTS.md`. Windows does not come with stow, so I use PowerShell symlinks.

Go to home directory
```powershell
cd $HOME\Projects
```

Clone the repo
```powershell
git clone https://github.com/triet228/.dotfiles.git
```

Go inside the repo
```powershell
cd $HOME\Projects\.dotfiles
```

Back up the original files. 
Run PowerShell as Administrator to create the symlink for:

Codex `AGENTS.md`
```powershell
New-Item -ItemType SymbolicLink -Path "$HOME\.codex\AGENTS.md" -Target "$HOME\Projects\.dotfiles\.codex\AGENTS.md"
```

Codex config
```powershell
New-Item -ItemType SymbolicLink -Path "$HOME\.codex\config.toml" -Target "$HOME\Projects\.dotfiles\.codex\config.toml"
```

Local `AGENTS.md`
```powershell
New-Item -ItemType SymbolicLink -Path "$HOME\Projects\ASTRA\AGENTS.md" -Target "$HOME\Projects\.dotfiles\Projects\ASTRA\AGENTS.md"
```