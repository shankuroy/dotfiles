# zshrc

# --- profiling ---
# zmodload zsh/zprof # uncomment this line to enable profiling
zmodload zsh/datetime; ZSH_START_TIME=$EPOCHREALTIME # capture start time for zsh_healthcheck

# --- environment & paths ---
ZDIR=$HOME/.zsh; ZCACHE=$ZDIR/cache; [[ -d $ZCACHE ]] || mkdir -p $ZCACHE
[[ -d /opt/homebrew ]] && export BREW_PREFIX="/opt/homebrew"

typeset -U path fpath # ensure unique entries
path=($HOME/scripts/bin(\N) $BREW_PREFIX/bin(\N) $path)
fpath+=($BREW_PREFIX/share/zsh/site-functions(\N) $ZDIR/functions(\N))

# --- options & history ---
setopt EXTENDED_GLOB SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY APPEND_HISTORY HIST_IGNORE_SPACE
export HISTFILE=$ZCACHE/.zsh_history HISTSIZE=10000 SAVEHIST=$HISTSIZE

# --- cached completions --- (rebuild if >12 hours old)
autoload -U compinit; z=$ZCACHE/.zcompdump; [[ -n $z(#qN.mh-12) ]] && compinit -C -d $z || compinit -d $z

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # case-insensitive completions
zstyle ':completion:*' menu select                      # navigate completions with tab or arrows
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # use colours in menu

# --- tool overrides & aliases ---
(( $+commands[eza] )) && alias ls="eza --icons"; alias la="ls -la"
(( $+commands[nvim] )) && export EDITOR="nvim" && alias vim="nvim" || export EDITOR="vim"

# --- cached tools --- (rebuild if >12 hours old)
(( $+commands[fzf] )) && { t=$ZCACHE/fzf.zsh; [[ -n $t(#qN.mh-12) ]] || fzf --zsh >| $t; source $t }
(( $+commands[zoxide] )) && { t=$ZCACHE/zoxide.zsh; [[ -n $t(#qN.mh-12) ]] || zoxide init zsh >| $t; source $t }

autoload -Uz $ZDIR/functions/*(.:t) # autoload all functions from $ZDIR/functions

# --- prompt ---
autoload -U promptinit; promptinit
(( $+functions[prompt_pure_setup] || $fpath[(I)*/pure] )) && prompt pure || prompt default

# --- bindings ---
bindkey -e; autoload -U edit-command-line; zle -N edit-command-line; bindkey '^x^e' edit-command-line

# --- plugins ---
p="${BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"; [[ -f $p ]] && source $p
p="${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; [[ -f $p ]] && source $p # syntax highlighting must be the last loaded plugin

# --- profiling ---
export ZSH_LOAD_DURATION=$(( (EPOCHREALTIME - ZSH_START_TIME) * 1000 )) # capture load time for zsh_healthcheck
# zprof # uncomment this line to enable profiling

