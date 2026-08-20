#!/usr/bin/env bash

VM_NAME="${1:-debian-base}"

cat <<EOF
curl -fL -o ~/.cache/iso/debian-13-genericcloud-arm64.qcow2 'https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-arm64.qcow2'
limactl create -y --log-level debug --name $VM_NAME lima-debian.yml
time limactl start --log-level debug $VM_NAME
TERM=xterm-256color limactl shell $VM_NAME
limactl copy ~/.vimrc ~/.tmux.conf .bashrc-debian $VM_NAME:~
EOF
