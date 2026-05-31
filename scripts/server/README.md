# server scripts

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

