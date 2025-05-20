if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias v "nvim"
alias cd "z"

set -U fish_user_paths $fish_user_paths $HOME/.config/composer/vendor/bin

zoxide init fish | source
