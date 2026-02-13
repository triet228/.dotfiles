# ~/.zshrc

# ------------------------------------------------------------------------------
# ENVIRONMENT & EXPORTS
# ------------------------------------------------------------------------------

# Set default editor
export EDITOR=vim
export VISUAL=vim

# Add local binaries to the path
export PATH="$HOME/.local/bin:$PATH"

# Custom colors for eza/ls
export EZA_COLORS="di=1;36:fi=0:ex=1;32:*.kdbx=1;37:da=38;5;250"

# Supress warning for conda env
export PYTHONWARNINGS="ignore:OpenSSL 3's legacy provider failed to load"

# ------------------------------------------------------------------------------
# SHELL OPTIONS (setopt)
# ------------------------------------------------------------------------------

# Vim mode in terminal
bindkey -v

# Navigate directories by just typing their name
setopt autocd

# Allow comments in the interactive shell
setopt interactivecomments

# Make globbing (e.g. `ls *.txt`) case-insensitive
setopt nocaseglob

# Required for the prompt to display git info correctly
setopt PROMPT_SUBST

# ------------------------------------------------------------------------------
# HISTORY CONFIGURATION
# ------------------------------------------------------------------------------

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY       # Append to history file
setopt INC_APPEND_HISTORY   # Add commands to history immediately
setopt SHARE_HISTORY        # Share history between all sessions
setopt HIST_IGNORE_ALL_DUPS # Remove older duplicate entries
setopt HIST_REDUCE_BLANKS   # Remove blank lines from history


# ------------------------------------------------------------------------------
# PROMPT CONFIGURATION
# ------------------------------------------------------------------------------

# Load version control system info and colors
autoload -Uz vcs_info colors && colors

precmd() {
  # Get git info
  vcs_info

  # --- Conditional Prompt Logic ---
  # Set a character limit for the path length
  local path_len_threshold=20

  # Check the length of the displayed path (%~)
  if [[ ${#${(%):-%~}} -gt $path_len_threshold ]]; then
    # If the path is LONG, use a two-line prompt
    PROMPT="$CONDA_PROMPT_MODIFIER"$'%F{yellow}[%F{green}%n@%m %F{cyan}%~%F{yellow}]%f\n>> '
  else
    # If the path is SHORT, use a single-line prompt
    PROMPT="$CONDA_PROMPT_MODIFIER"$'%F{yellow}[%F{green}%n@%m %F{cyan}%~%F{yellow}]%f$ '
  fi

  # Add blank line before prompt
  echo
}

# Format for the git branch info (e.g., "on main")
zstyle ':vcs_info:git:*' formats '%F{magenta}on %b%f'

# Right side of the prompt: git branch info
RPROMPT='${vcs_info_msg_0_}'


# ------------------------------------------------------------------------------
# PLUGINS & EXTERNAL TOOLS INITIALIZATION
# ------------------------------------------------------------------------------

# Load zsh-autosuggestions
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Load zsh-syntax-highlighting
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# -- fzf (Fuzzy Finder) --
# Load fzf keybindings and completion
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh

# Alt + C to fuzzy find a file
bindkey -r '^[c' # unbind alt-c
bindkey '^[c' fzf-file-widget

# Ctrl+H to find a file starting from home
fzf_file_from_home() {
  local orig_cmd="$FZF_CTRL_T_COMMAND"
  FZF_CTRL_T_COMMAND="find ~ -type f" fzf-file-widget
  FZF_CTRL_T_COMMAND="$orig_cmd"
}
zle -N fzf_file_from_home
bindkey '^H' fzf_file_from_home

# -- Other Tools --
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Load local/private configs if they exist
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ------------------------------------------------------------------------------
# COMPLETION & KEYBINDINGS
# ------------------------------------------------------------------------------

# Initialize the tab completion system
autoload -Uz compinit
compinit

# Make tab completion case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Keybindings
bindkey '^F' complete-word      # Ctrl+F to complete word
bindkey '^I' autosuggest-accept # Tab to accept suggestion
setxkbmap -option caps:swapescape # Swap Caps Lock and Escape

# ------------------------------------------------------------------------------
# ALIASES
# ------------------------------------------------------------------------------

# Navigation & Listing
alias ll='eza -la --sort=ext --icons --group-directories-first --time-style=long-iso --git'
alias ls='eza -l --sort=ext --icons --group-directories-first --time-style=long-iso --git --no-permissions --no-user'
alias lss='eza --icons --tree --level=2 --group-directories-first'
alias lsss='eza --icons --tree --level=3 --group-directories-first'
alias lssss='eza --icons --tree --level=4 --group-directories-first'
alias lsssss='eza --icons --tree --level=5 --group-directories-first'
alias lssssss='eza --icons --tree --level=6 --group-directories-first'
alias lsssssss='eza --icons --tree --level=7 --group-directories-first'
alias lssssssss='eza --icons --tree --level=8 --group-directories-first'
alias lsssssssss='eza --icons --tree --level=9 --group-directories-first'
alias d='cd ~/Downloads'
alias p='cd ~/Projects/'
alias bin='cd ~/.local/bin'
alias h='z ~ && ll'
alias da='z ~/Data/ && ls'
alias c='z ~/Data/CLASSES && ls'

# System & Utilities
alias update='yay -Syu --noconfirm'
alias sleepp='slock & systemctl suspend'
alias math='qalc'
alias icat='kitty +kitten icat'
alias convert='magick'
alias youtube='scrapetubefzf'
alias matlab='docker run -it --rm -p 8888:8888 -v ~/Projects/FAST:/home/matlab/FAST -v ~/Data/CLASSES/AEROSP_568/:/home/matlab/AEROSP_568-v matlab_config:/home/matlab/.matlab --shm-size=2g --name matlab_container matlab -browser'

# File operations
alias cpd='cp -t ~/Downloads'
alias yy='pwd | tr -d "\n" | xclip -selection clipboard'

# ------------------------------------------------------------------------------
# FUNCTIONS
# ------------------------------------------------------------------------------

# General function to open a file with the default application
open() {
  xdg-open "$@" >/dev/null 2>&1 &
}

# Open lf and cd to the last directory on exit
lff() {
  local tmp="$(mktemp)"
  lf -last-dir-path="$tmp" "$@"
  if [[ -f "$tmp" ]]; then
    local dir="$(< "$tmp")"
    rm -f "$tmp"
    [[ -d "$dir" ]] && cd "$dir"
  fi
}

# Override 'cd' to use zoxide and then list directory contents
cd() {
  z "$@" && ls
}

# Copy contents of current directory to Downloads
cptd() {
  cp -r -- ./* ~/Downloads/
}

# Move contents of Downloads to current directory
mvfd() {
  mv ~/Downloads/* .
}

# Clean system caches and packages
clean() {
  yay -Scc --noconfirm
  yay -Yc --noconfirm
  sudo pacman -Rns $(pacman -Qtdq --quiet) --noconfirm
  sudo pacman -Scc --noconfirm
  sudo journalctl --vacuum-size=50M
  sudo paccache -rk1
  sudo rm -rf ~/Downloads/*
  sudo rm -rf ~/Pictures/*
  bash -O extglob -c 'rm -rf ~/.cache/!(keepassxc|Tectonic|mozilla|pre-commit|hugo_cache)'
  sudo rm -rf /tmp/*
  git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles pull
  clear
  neofetch
}

# If a command is not found, try to open it as a file
command_not_found_handler() {
  if [[ -f "$1" ]]; then
    xdg-open "$1"
  else
    echo "zsh: command not found: $1" >&2 # Send error to stderr
    return 127
  fi
}

# Function to compress one or more PDFs
# Usage: compress <file1.pdf> [file2.pdf] ...
compress() {
  # Check if at least one argument is given
  if [ -z "$1" ]; then
    echo "Usage: compress <file1.pdf> [file2.pdf] ..."
    return 1
  fi

  local input_file
  # Loop through ALL arguments provided ($@)
  for input_file in "$@"; do
    # Check if the file actually exists
    if [ ! -f "$input_file" ]; then
      echo "Skipping '$input_file': File not found."
      continue # Skip to the next file
    fi

    # Generate the output filename
    local output_file="${input_file%.pdf}_compressed.pdf"

    echo "Compressing '$input_file' -> '$output_file'..."
    ps2pdf -dPDFSETTINGS=/ebook "$input_file" "$output_file"
    echo "Compression complete for '$input_file'."
  done
}

# Print out cat at the start of shell
neofetch
