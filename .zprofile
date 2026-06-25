# zprofile -- loads before ~/.zshrc

# --- profiling (see bottom of ~/.zshrc) ---
# zmodload zsh/zprof # uncomment this line to enable profiling
#
# capture start time for zsh_healthcheck
zmodload zsh/datetime
ZSH_START_TIME=$EPOCHREALTIME

# zsh dirs
export ZDIR=$HOME/.zsh
export ZCACHE=$ZDIR/cache
mkdir -p $ZCACHE

# XDG base dirs (https://specifications.freedesktop.org/basedir/latest/)
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

# homebrew
export BREW_PREFIX=/opt/homebrew

