# zsh scripts for MacOS

# print and copy local IP to the system clipboard
localip() {
  ipconfig getifaddr en0 | tr -d '\n' | tee >(pbcopy)
}

# print and copy public IP to the system clipboard
publicip() {
  dig +short myip.opendns.com @resolver1.opendns.com | tr -d '\n' | tee >(pbcopy)
}

# print directory path of the topmost Finder window
pwdf() {
  osascript 2>/dev/null -e 'tell application "Finder" to if (count windows) > 0 then return POSIX path of (target of window 1 as alias)'
}

# change directory to the path of the topmost Finder window
cdf() {
  cd "$(pwdf)"
}

# Quick Look a given file
ql() {
  qlmanage -p "$1" >/dev/null 2>&1 &
}

