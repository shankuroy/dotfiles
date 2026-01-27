# Bootstrap Homebrew

Install the [Homebrew](https://brew.sh) package manager:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Restart your terminal and install some base packages:

```sh
brew update && brew upgrade
brew install mas stow
```

This installs:
- [`mas`](https://github.com/mas-cli/mas): The Mac App Store CLI
- [`stow`](https://www.gnu.org/software/stow/manual/stow.html): dotfile/symlink manager

After this, brew package management will be done using Brewfiles.
First, we need to set up `stow` to manage dotfiles in our home directory.

First ensure any existing `~/.config` has been backed up and removed.

Navigate to the dotfiles repo folder and run:

```sh
stow .
```

Then verify the relevant dotfiles have been symlinked in the home folder.

