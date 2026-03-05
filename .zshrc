eval "$(starship init zsh)"

load-env() {
  local env_file="${1:-$HOME/.env}"
  if [ -f "$env_file" ]; then
    set -a
    source "$env_file"
    set +a
  else
    echo "Error: $env_file not found."
    return 1
  fi
}

[[ -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt ]] && cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt

load-env ~/.env

typeset -U path

path=(
  $HOME/.local/share/mise/shims
  $HOME/.local/share/pnpm
  $HOME/.local/bin
  $HOME/.cargo/bin
  $HOME/go/bin
  $path
)
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

alias ls='eza --icons'