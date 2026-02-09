# zshrc

# --- Profiling ---
# zmodload zsh/zprof # uncomment this line to enable profiling
zmodload zsh/datetime; export ZSH_START_TIME=$EPOCHREALTIME # Capture start time for zsh_healthcheck

# --- Environment & Paths ---
ZDIR=$HOME/.zsh; ZCACHE=$ZDIR/cache; [[ -d $ZCACHE ]] || mkdir -p $ZCACHE
[[ -d /opt/homebrew ]] && export BREW_PREFIX="/opt/homebrew" || export BREW_PREFIX="/usr/local"

typeset -U path fpath # ensure unique entries
# path=($path $HOME/bin)
fpath+=($BREW_PREFIX/share/zsh/site-functions(\N) $ZDIR/functions(\N))

# --- Options & History ---
setopt EXTENDED_GLOB SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY APPEND_HISTORY
export HISTFILE=$ZCACHE/.zsh_history HISTSIZE=10000 SAVEHIST=$HISTSIZE

# --- Editor ---
(( $+commands[nvim] )) && export EDITOR="nvim" && alias vim="nvim" || export EDITOR="vim"

# --- Cached Completions ---
autoload -U compinit; ZCOMPDUMP=$ZCACHE/.zcompdump
[[ -n $ZCOMPDUMP(#qN.mh-12) ]] && compinit -C -d $ZCOMPDUMP || compinit -d $ZCOMPDUMP

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # case-insensitive completions
zstyle ':completion:*' menu select                      # navigate completions with tab or arrows
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # use colours in menu

# --- Tools & Aliases ---
(( $+commands[eza] )) && alias ls="eza --group-directories-first"; alias la="ls -la"

(( $+commands[zoxide] )) && {
  [[ -n $ZCACHE/zoxide.zsh(#qN.mh-12) ]] || zoxide init zsh >| $ZCACHE/zoxide.zsh
  source $ZCACHE/zoxide.zsh
}

(( $+commands[fzf] )) && {
  [[ -n $ZCACHE/fzf.zsh(#qN.mh-12) ]] || fzf --zsh >| $ZCACHE/fzf.zsh
  source $ZCACHE/fzf.zsh
}

# Autoload functions (from $ZDIR/functions)
autoload -Uz zsh_healthcheck nvim_clear_cache

# --- Prompt ---
autoload -U promptinit; promptinit
(( $+functions[prompt_pure_setup] || $fpath[(I)*/pure] )) && prompt pure || prompt default

# --- Bindings ---
bindkey -e; autoload -U edit-command-line; zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# --- External Plugins ---
[[ -f "${BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "${BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Syntax highlighting must be the last loaded plugin
[[ -f "${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# --- Profiling ---
export ZSH_LOAD_DURATION=$(( (EPOCHREALTIME - ZSH_START_TIME) * 1000 )) # Capture load time for zsh_healthcheck
# zprof # uncomment this line to enable profiling

