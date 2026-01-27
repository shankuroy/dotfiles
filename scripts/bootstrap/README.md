# SSH & Git Bootstrap

This directory contains a small bootstrap script to set up profile-based SSH keys and Git configuration on a brand-new machine, plus a teardown script to clean everything up if needed.

The intended flow is:

1. Download and run the bootstrap script directly (no repo clone required yet)
2. Use the generated SSH setup to clone this dotfiles repo
3. Continue with the rest of your machine setup from there

---

## Quick start (new machine)

### 1. Download the bootstrap script

Download the bootstrap script directly from GitHub:

```sh
curl -fsSL https://raw.githubusercontent.com/shankuroy/dotfiles/main/bootstrap.sh -o bootstrap.sh
```

### 2. Make it executable

```sh
chmod +x bootstrap.sh
```

### 3. Run the bootstrap script

Run with default profiles (personal work):

```sh
./bootstrap.sh
```

Or specify profiles explicitly:

```sh
./bootstrap.sh personal work
```

Or via environment variable:

```sh
PROFILES="personal work" ./bootstrap.sh
```

The script will:
- Ensure an SSH agent is running
- Generate ED25519 SSH keys per profile (if missing)
- Configure SSH host aliases like `github.com-personal`
- Create per-profile Git configs
- Set up repo directories under `~/repo/<profile>`
- Print public SSH keys to add to GitHub

### 4. Add SSH keys to GitHub

For each profile, copy the printed public key and add it here:

https://github.com/settings/ssh/new

### 5. Clone this dotfiles repo

Use the profile-specific SSH host when cloning:

```sh
cd ~/repo/personal
git clone git@github.com-personal:shankuroy/dotfiles.git
```

This ensures Git uses the correct SSH key and Git identity.

### 6. Continue setup

Once the repo is cloned, follow the instructions in the [bootstrap_homebrew_stow.md](./bootstrap_homebrew_stow.md) file.

## Teardown/cleanup

If you want to undo what the bootstrap script created, use the teardown script:

```sh
./bootstrap_teardown.sh
```

It will:
- Remove profile-specific SSH keys
- Remove profile-specific SSH config snippets
- Remove profile-specific Git config files
- Optionally remove repo directories (with confirmation)

It does not delete:
- `~/.ssh/config`
- `~/.gitconfig`

## Notes
- Scripts are written for POSIX sh
- Safe to re-run (idempotent)
- Designed to work before any dotfiles repo is cloned
- Supports multiple GitHub identities cleanly

⭐ Happy bootstrapping!

