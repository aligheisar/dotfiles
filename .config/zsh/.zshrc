unsetopt beep
bindkey -e

# history
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=2000
export SAVEHIST=2000

# antidote
antidote_path='/usr/share/zsh-antidote'
source "$antidote_path/antidote.zsh"
antidote load

zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

eww_comp=${ZDOTDIR}/completions

fpath=($antidote_path $eww_comp $fpath)
autoload -Uz antidote
autoload -Uz _eww

if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi

source ${zsh_plugins}.zsh


# colors
typeset -A ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[command]='fg=green'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=blue'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[path]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'

# fzf
source <(fzf --zsh)

# Prompt
export PS1="%F{blue}%~ %f\$ "

# Completion
autoload -Uz compinit
compinit -d ~/.cache/zsh/zcompdump

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh

# Key bindings
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word
bindkey "^H" backward-kill-word

# Aliases
source "$ZDOTDIR/aliases.zsh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun
export BUN_INSTALL="$HOME/.bun"
case ":$PATH:" in
  *":$BUN_INSTALL/bin:"*) ;;
  *) export PATH="$BUN_INSTALL/bin:$PATH" ;;
esac

# bun completions
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# rust
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
source "$CARGO_HOME/env"

# qt
export QT_QPA_PLATFORMTHEME=qt6ct

# atac
# export ATAC_KEY_BINDINGS="$XDG_CONFIG_HOME/atac/vim_key_bindings.toml"
