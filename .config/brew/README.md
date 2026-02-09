# Homebrew Config

This config is designed to be used with the included [`./brew_bundle_cleanup.sh`](./brew_bundle_cleanup.sh) script.

It uses [brew bundle cleanup](https://docs.brew.sh/Brew-Bundle-and-Brewfile#brew-bundle-cleanup) to ensure only the specified apps are installed, removing everything else managed by brew.

Populate the relevant profile-specific `Brewfile`s and run the script with a list of profiles. The `core` profile will always be included.

```sh
./brew_bundle_cleanup.sh personal
```

## Mac App Store CLI (mas)

You may get an error when installing apps via `mas`, which is likely from a limitation of the App Store requiring the app to have previously been downloaded with your App Store account.

Get a list of required App Store apps for the relevant profiles and download them from the App Store. Subsequent updates should then work as expected.

```sh
grep '^mas' Brewfile-*
```

