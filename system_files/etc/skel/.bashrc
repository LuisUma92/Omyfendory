# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ─── Prompt ─────────────────────────────────────────────────
eval "$(starship init bash)"

# ─── Shell integrations ─────────────────────────────────────
eval "$(zoxide init bash)"
eval "$(fzf --bash)"
eval "$(mise activate bash)"

# ─── Aliases ────────────────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias lt='eza -T --icons --group-directories-first'
alias cat='bat --style=plain'
alias grep='grep --color=auto'
alias df='duf'
alias du='dust'
alias find='fd'
alias top='btop'
alias set432fm='sh ~/.local/share/umas/set432fm.sh'
alias lg='lazygit'
alias ldk='lazydocker'

# ─── Environment ────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim
export TERMINAL=foot
export MANPAGER='nvim +Man!'
