# zshrc -- loads after ~/.zprofile

# --- profiling ---
# zmodload zsh/zprof # uncomment this line to enable profiling
zmodload zsh/datetime; ZSH_START_TIME=$EPOCHREALTIME # capture start time for zsh_healthcheck

typeset -U path fpath # ensure unique path/fpath entries
path=($HOME/.local/bin(\N) $HOME/scripts/bin(\N) $BREW_PREFIX/bin(\N) $path)
fpath+=($ZDIR/functions(\N) $BREW_PREFIX/share/zsh/site-functions(\N))
autoload -Uz $ZDIR/functions/*(N.:t) # autoload all functions from $ZDIR/functions

# --- options & history ---
setopt APPEND_HISTORY EXTENDED_GLOB HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS HIST_VERIFY NUMERIC_GLOB_SORT SHARE_HISTORY
export HISTFILE=$ZCACHE/.zsh_history
export HISTSIZE=100000
export SAVEHIST=$HISTSIZE

# --- cached tools ---
_zcache() {
  # given a binary name $1, e.g. `zoxide`,
  # cache its init command $2, e.g. `zoxide init zsh`,
  # regenerating the cache if the binary is newer than it, i.e. it has been updated.
  # Usage: _zcache <binary_name> "<command_to_cache>"
  (( $+commands[$1] )) || return 0
  local t=$ZCACHE/$1.zsh m=$(command -v $1)
  [[ -n $t(#qN) && $t -nt $m ]] || { eval "$2" >| $t; zcompile $t }
    source $t
}

_zcache fzf    "fzf --zsh"
_zcache zoxide "zoxide init zsh"
_zcache mise   "mise activate zsh"

unfunction _zcache

# --- cached completions ---
autoload -U compinit
local zcd=$ZCACHE/.zcompdump

for dir in $HOME/.zsh/functions /opt/homebrew/share/zsh/site-functions; do
  [[ $dir -nt $zcd ]] && { rm -f "$zcd"; break; }
done

[[ -f $zcd ]] && compinit -C -d $zcd || compinit -d $zcd

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # case-insensitive completions
zstyle ':completion:*' menu select                      # navigate completions with tab or arrows
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # use colours in menu

# --- prompt ---
autoload -U promptinit; promptinit
prompt pure || prompt default

# --- bindings ---
bindkey -e
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# --- plugins ---
p="${HOME}/.local/share/nvim/site/pack/core/opt/tokyonight.nvim/extras/fzf/tokyonight_night.sh"; [[ -f $p ]] && source $p
p="${BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"; [[ -f $p ]] && source $p
p="${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; [[ -f $p ]] && source $p # syntax highlighting must be the last loaded plugin

# --- aliases ---
[[ -f ~/.zsh/aliases ]] && source ~/.zsh/aliases

# --- profiling ---
export ZSH_LOAD_DURATION=$(( (EPOCHREALTIME - ZSH_START_TIME) * 1000 )) # capture load time for zsh_healthcheck
# zprof # uncomment this line to enable profiling

