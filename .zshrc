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

# --- cached completions --- (rebuild if >12 hours old)
autoload -U compinit; z=$ZCACHE/.zcompdump; [[ -n $z(#qN.mh-12) ]] && compinit -C -d $z || compinit -d $z

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # case-insensitive completions
zstyle ':completion:*' menu select                      # navigate completions with tab or arrows
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # use colours in menu

# --- cached tools ---
cache_tool() {
    local cmd="$1"
    local init_script="$2"
    local cached_script="$ZCACHE/$cmd.zsh"

    (( $+commands[$cmd] )) || return 0

    # If cache is >12h old or missing, regenerate and compile it
    [[ -n $cached_script(#qN.mh-12) ]] || { eval "$init_script" >| "$cached_script" && zcompile "$cached_script" }

    source "$cached_script"
}

cache_tool "fzf"    "fzf --zsh"
cache_tool "zoxide" "zoxide init zsh"
cache_tool "mise"   "mise activate zsh"

# --- prompt ---
autoload -U promptinit; promptinit
(( $+functions[prompt_pure_setup] || $fpath[(I)*/pure] )) && prompt pure || prompt default

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

