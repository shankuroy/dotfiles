# Homebrew Config

This config is designed to be used with the included [`./brew_bundle_cleanup.sh`](./brew_bundle_cleanup.sh) script.

That will ensure only the specified features in the core + profiles are installed. Everything else managed by brew will be removed if not specified.

It is recommended to alias the script with your intended profiles for a given machine, e.g.

```sh
alias brew_bundle_cleanup="${HOME}/.config/brew/brew_bundle_cleanup.sh personal"
```

It is recommended to use the expanded path instead of `${HOME}`.

