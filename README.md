# What are dotfiles?
Dotfiles are files start with dot (example: .zshrc). 


# Why dotfiles?
Dotfiles are used to change configuration of program. For example, my original terminal has no colors, just black and white. To change this to colorful terminal, I go to my dotfiles (.zshrc) and add a few lines to add colors. There is no point in a centralized folder for dotfiles if I only run one machine. However, I run multiple machines and I want to sync the configuration across my machines. Therefore, having this dotfiles centralized into a git repo is more conveient to manage. I could've used syncthing to sync this dotfiles too but a git repo offer a very good backup of previous version just in case something happen and I lost my dotfiles.

# How to use this repo on Linux
I manage my dotfiles with stow. Stow is a program that ultilize symlink. Symlink links files between different directories so that if one file is changed, the linked file is also changed. Instead of manually write symlink for all dotfiles, stow automatically does it with ```stow . -t ~/``` This command symlinks all the dotfiles in this repo to my home directory instead of me doing symlink one by one.

Go to home directory
```
cd ~
```

Clone the repo
```
git clone https://github.com/triet228/.dotfiles.git
```

Go inside the repo
```
cd ~/.dotfiles
```

Back up the original files. Delete dotfiles you want to symlink.  
Run command stow
```
stow . -t ~/
```


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

Back up the original files. Delete dotfiles you want to symlink.  
Run PowerShell as Administrator to create the symlink for AGENTS.md:

```powershell
New-Item -ItemType SymbolicLink -Path "$HOME\.codex\AGENTS.md" -Target "$HOME\Projects\.dotfiles\.codex\AGENTS.md"

New-Item -ItemType SymbolicLink -Path "$HOME\.vimrc" -Target "$HOME\Projects\.dotfiles\.vimrc"

$projectRoot = "$HOME\Projects\.dotfiles\Projects"
Get-ChildItem $projectRoot -Recurse -Filter AGENTS.md -File | ForEach-Object {
    $relativePath = $_.FullName.Substring($projectRoot.Length).TrimStart("\")
    $path = Join-Path "$HOME\Projects" $relativePath
    New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
    New-Item -ItemType SymbolicLink -Path $path -Target $_.FullName
}
```
