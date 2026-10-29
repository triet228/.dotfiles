fish_add_path ~/.local/bin

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx EZA_COLORS "di=1;36:fi=0:ex=1;32:*.kdbx=1;37:da=38;5;250"
set -gx PYTHONWARNINGS "ignore:OpenSSL 3's legacy provider failed to load"
set -gx OLLAMA_HOST http://127.0.0.1:11434

if status is-interactive
    fish_vi_key_bindings
    set -g fish_greeting

    command -q starship; and starship init fish | source
    command -q zoxide; and zoxide init fish | source
    command -q direnv; and direnv hook fish | source

    alias ll='eza -la --sort=ext --icons --group-directories-first --time-style=long-iso --git'
    alias ls='eza -l --sort=ext --icons --group-directories-first --time-style=long-iso --git --no-permissions --no-user'
    for level in (seq 2 9)
        alias ls(string repeat -n $level s) "eza --icons --tree --level=$level --group-directories-first"
    end
    alias vim nvim
    alias d 'cd ~/Downloads'
    alias p 'cd ~/Projects/'
    alias bin 'cd ~/.local/bin'
    alias h 'z ~ && ll'
    alias cpd 'cp -t ~/Downloads'
    alias icat 'kitty +kitten icat'
    alias convert magick
    alias math qalc
    alias update 'sudo apt update && sudo apt upgrade -y'

    function cd
        z $argv; and ls
    end

    function open
        xdg-open $argv >/dev/null 2>&1 &
    end

    function lff
        set tmp (mktemp)
        lf -last-dir-path=$tmp $argv
        if test -f $tmp
            set dir (cat $tmp)
            rm -f $tmp
            test -d "$dir"; and cd $dir
        end
    end

    function cptd
        if test (count $argv) -eq 0
            cp -riv * ~/Downloads/
        else
            cp -riv $argv ~/Downloads/
        end
    end

    function mvfd
        mv ~/Downloads/* .
    end

    function mvtd
        mv $argv ~/Downloads/
    end

    function compress
        if test (count $argv) -eq 0
            echo "Usage: compress <file1.pdf> [file2.pdf] ..."
            return 1
        end
        for input in $argv
            if not test -f $input
                echo "Skipping '$input': File not found."
                continue
            end
            set output (string replace -r '\.pdf$' '' $input)_compressed.pdf
            echo "Compressing '$input' -> '$output'..."
            ps2pdf -dPDFSETTINGS=/ebook $input $output
        end
    end

    function fish_user_key_bindings
        fish_vi_key_bindings
        bind -M insert \t accept-autosuggestion
    end

    test -f ~/.config/fish/local.fish; and source ~/.config/fish/local.fish
    command -q fastfetch; and fastfetch
end

# >>> conda initialize >>>
if test -f $HOME/miniforge3/bin/conda
    eval $HOME/miniforge3/bin/conda "shell.fish" "hook" $argv | source
end
# <<< conda initialize <<<
