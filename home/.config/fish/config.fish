if status is-interactive
    set fish_greeting

    function starship_transient_prompt_func
        starship module character
    end
    if test "$TERM" != linux
        starship init fish | source
        enable_transience
    end

    if test -f ~/.local/state/proscenio/generated/terminal/sequences.txt
        cat ~/.local/state/proscenio/generated/terminal/sequences.txt
    end

    fish_add_path $HOME/.local/bin
    fish_add_path $HOME/.cargo/bin

    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias celar "printf '\033[2J\033[3J\033[1;1H'"
    alias claer "printf '\033[2J\033[3J\033[1;1H'"
    alias c clear

    alias up 'paru -Syu'
    alias un 'paru -Rns'

    if test "$TERM" != linux
        alias ls 'eza --icons=auto'
    end
    if test "$TERM" = xterm-kitty
        alias ssh 'kitten ssh'
    end

    function last_history_item
        echo $history[1]
    end
    abbr -a !! --position anywhere --function last_history_item
end
