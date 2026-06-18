# zprofile -- loads before ~/.zshrc
export ZDIR=$HOME/.zsh
export ZCACHE=$ZDIR/cache; [[ -d $ZCACHE ]] || mkdir -p $ZCACHE
export BREW_PREFIX="/opt/homebrew"
export XDG_CONFIG_HOME="$HOME/.config"
export EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza"
export MANPAGER="less -R --use-color -Dd+r -Du+b"

