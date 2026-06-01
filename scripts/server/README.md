# server scripts

## quickstart: setup fresh ubuntu server

On the server:

```bash
curl -fsSL https://raw.githubusercontent.com/shankuroy/dotfiles/refs/heads/main/scripts/server/import-ssh-keys.py | python3 -
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo reboot
```

```bash
curl -fsSL https://raw.githubusercontent.com/shankuroy/dotfiles/refs/heads/main/scripts/server/init-ubuntu-dev.sh | bash
curl -fsSL https://raw.githubusercontent.com/shankuroy/dotfiles/refs/heads/main/scripts/server/init-ubuntu-docker.sh | bash
sudo reboot
```

On your local computer:

```bash
SERVER_HOST=server-hostname;
scp -i ~/.ssh/id_ed25519_personal ~/.tmux.conf ~/.vimrc ubuntu@$SERVER_HOST:~
TERM=xterm-256color ssh -i ~/.ssh/id_ed25519_personal -t ubuntu@$SERVER_HOST
```


## setting a local hostname for a remote server

In `~/.ssh/config`:

```conf
Host preferred-hostname
  HostName actual-hostname
  User ubuntu
  IdentityFile ~/.ssh/id_ed25519
  SetEnv TERM=xterm-256color
```

Now you can simply `ssh` or `scp` with:

```bash
ssh preferred-hostname
scp /path/to/local/file preferred-hostname:/path/to/remote/file
```

instead of having to explicitly write everything out:

```bash
TERM=xterm-256color ssh -i ~/.ssh/id_ed25519 -t ubuntu@actual-hostname
scp -i ~/.ssh/id_ed25519 /path/to/local/file ubuntu@actual-hostname:/path/to/remote/file
```

