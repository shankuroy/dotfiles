# zprofile -- loads before ~/.zshrc
export ZDIR=$HOME/.zsh
export ZCACHE=$ZDIR/cache
mkdir -p $ZCACHE

export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

export BREW_PREFIX=/opt/homebrew
export MANPAGER='less -R --use-color -Dd+r -Du+b'
export EZA_CONFIG_DIR=$XDG_CONFIG_HOME/eza
