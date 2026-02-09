# Homebrew Config

This config is designed to be used with the included [`./brew_bundle_cleanup.sh`](./brew_bundle_cleanup.sh) script.

That will ensure only the specified features in the core + profiles are installed. Everything else managed by brew will be removed if not specified.

It is recommended to alias the script with your intended profiles for a given machine, e.g.

```sh
alias brew_bundle_cleanup="${HOME}/.config/brew/brew_bundle_cleanup.sh personal"
```

It is recommended to use the expanded path instead of `${HOME}`.

## Mac App Store CLI (mas)

You may get an error when installing apps via `mas`. This is most likely because you haven't downloaded the app through the App Store before from the configured App Store account.

Get a list of required App Store apps:

```sh
grep -R mas
```

Look for the apps in the relevant profiles and download them from the App Store. Subsequent updates should then work as expected.

This is a limitation of the App Store.

