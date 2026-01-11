if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_user_key_bindings
    # Binds Alt-p to project launcher script 
    bind \ep "$HOME/Scripts/terminal/terminal_project_launcher.sh"
end

alias v "nvim"
alias cd "z"

set -Ux VISUAL nvim
set -Ux EDITOR nvim

set -U fish_user_paths $fish_user_paths $HOME/.config/composer/vendor/bin

zoxide init fish | source

# opencode
fish_add_path /home/bp/.opencode/bin
fish_add_path /home/bp/.local/bin
