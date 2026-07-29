# zshrc

# --- profiling ---
# zmodload zsh/zprof # uncomment this line to enable profiling
zmodload zsh/datetime
ZSH_START_TIME=$EPOCHREALTIME # capture start time for ~/.zsh/functions/zsh_healthcheck

# --- env vars ---
export ZDIR=$HOME/.zsh
export ZCACHE=$ZDIR/cache
[[ -d $ZCACHE ]] || mkdir -p $ZCACHE

export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

export BREW_PREFIX=/opt/homebrew
export MANPAGER='less -R --use-color -Dd+r -Du+b' # use colours in man pager

# --- paths ---
typeset -U path fpath # ensure unique path/fpath entries
path=($HOME/.local/bin(N) $HOME/scripts/bin(N) $BREW_PREFIX/bin(N) $path)
fpath+=($ZDIR/functions(N) $BREW_PREFIX/share/zsh/site-functions(N))
autoload -Uz $ZDIR/functions/*(N.:t) # autoload all functions from $ZDIR/functions

# --- options & history ---
setopt APPEND_HISTORY EXTENDED_GLOB HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS HIST_VERIFY NUMERIC_GLOB_SORT SHARE_HISTORY
HISTFILE=$ZCACHE/.zsh_history
HISTSIZE=100000
SAVEHIST=$HISTSIZE

# --- cached tools ---
_zcache() {
  # Cache the output of an init command, keyed to the binary's mtime.
  # Regenerates if the cache is missing or the binary has been updated.
  # Usage: _zcache <binary> "<init command>"
  (( $+commands[$1] )) || return
  local cache=$ZCACHE/$1.zsh bin=$commands[$1]
  [[ $cache -nt $bin ]] || { eval "$2" >| $cache; zcompile $cache }
  source $cache
}

_zcache fzf    "fzf --zsh"
_zcache zoxide "zoxide init zsh"
_zcache mise   "mise activate zsh"

unfunction _zcache

# --- cached completions ---
autoload -Uz compinit
zcd=$ZCACHE/.zcompdump

for dir in $ZDIR/functions $BREW_PREFIX/share/zsh/site-functions; do
  [[ $dir -nt $zcd ]] && { rm -f "$zcd"; break; }
done

[[ -f $zcd ]] && compinit -C -d $zcd || compinit -d $zcd
[[ -f $zcd.zwc && $zcd.zwc -nt $zcd ]] || zcompile $zcd

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # case-insensitive completions
zstyle ':completion:*' menu select                      # navigate completions with tab or arrows
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # use colours in menu

# --- aliases ---
if (( $+commands[eza] )); then
  export EZA_CONFIG_DIR=$XDG_CONFIG_HOME/eza
  alias ls='eza --icons'
  alias la='eza -la --icons --git'
else
  alias la='ls -lah'
fi

if (( $+commands[nvim] )); then
  export EDITOR='nvim'
  alias vim='nvim'
else
  export EDITOR='vim'
fi

alias tmuxx='tmux new -As "$(hostname | tr "." "-")"' # attach to existing or create new session
alias git_root='cd "$(git rev-parse --show-toplevel)"' # Jump to git root directory

# --- prompt ---
autoload -U promptinit; promptinit
prompt pure || prompt default

# --- bindings ---
bindkey -e
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# --- plugins ---
source ~/.local/share/nvim/site/pack/core/opt/tokyonight.nvim/extras/fzf/tokyonight_night.sh
source $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# syntax highlighting must be sourced last
source $BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- profiling ---
export ZSH_LOAD_DURATION=$(( (EPOCHREALTIME - ZSH_START_TIME) * 1000 )) # capture load time for ~/.zsh/functions/zsh_healthcheck
# zprof # uncomment this line to enable profiling

