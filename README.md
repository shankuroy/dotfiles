# dotfiles

## Getting started

Set up SSH and Git profiles by downloading the [bootstrap.sh](./scripts/bootstrap/bootstrap.sh) file, making it executable with

```bash
chmod +x bootstrap.sh
```

then executing it with profile names as arguments, e.g.

```bash
./bootstrap personal work
```

The profile names relate to separate git usernames or SSH keys.
Follow the instructions in the bootstrap script output to save the generated keys to the relevant Github accounts, and edit the gitconfig name/email fields.

Install the Homebrew package manager (https://brew.sh/):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Confirm brew is available by installing [stow](https://www.gnu.org/software/stow/manual/) (which we'll use again after cloning these dotfiles):

```bash
brew install stow
```

Clone these dotfiles to the relevant repo location (e.g. in `~/repo/personal`):

```bash
git clone git@github.com-personal:shankuroy/dotfiles.git
```

Note the `-personal` at the end of host. Each profile is configured to use a different key as defined earlier.

Navigate inside the cloned repo and execute `stow`:

```bash
cd dotfiles
stow .
```

Verify there are symlinks to the dotfiles repos in your home folder:

```bash
ls -lah ~
```

Restart the terminal session so the zprofile/zshrc runs.
You may see some errors for missing files/config.
We'll fix that by installing packages with brew.
Navigate to the brew config folder:

```bash
cd ~/.config/brew
```

There should be some profile-specific Brewfiles in here, e.g. `Brewfile-personal`.
Note these profiles have no real dependency on the SSH/git profiles set up earlier, but it's a good idea to keep them consistent.

Install the packages for the relevant profiles, e.g.

```bash
./brew_bundle_cleanup.sh personal
```

That will install everything in `Brewfile-core` and `Brewfile-personal`.

Note some files are installed by neovim plugins, so run `nvim` which will install the plugins defined in [init.lua](./.config/nvim/init.lua).

Some symlinks need to be created (e.g. themes that reference plugins installed via nvim), so run:

```bash
rebuild_symlinks
```

That function lives in [.zsh/functions](./.zsh/functions).

After that completes, restart the terminal session and run `zsh_healthcheck` to see if everything is set up correctly.

Next, run the mac preferences script:

```bash
./scripts/macos/macos_defaults.sh
```

Restart your computer and enjoy!

