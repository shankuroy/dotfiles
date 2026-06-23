#!/usr/bin/env sh

# Set MacOS preferences using `defaults`
# https://macos-defaults.com
# https://github.com/yannbertrand/macos-defaults
#
# Note this will restart the following apps:
# Dock, Finder
#
# It's best to go to the Settings panel for most other settings.
# Things change between OS versions, or require system restarts
# if done via `defaults`.

# Exit if not on MacOS
if [ "$(uname)" != "Darwin" ]; then
  exit 1
fi

# Accessibility > Pointer Control > Trackpad Options > Use trackpad for dragging
defaults write 'com.apple.AppleMultitouchTrackpad' 'Dragging' -bool 'true'

# Accessibility > Pointer Control > Trackpad Options > Dragging style
defaults write 'com.apple.AppleMultitouchTrackpad' 'DragLock' -bool 'false'

# Appearance > Appearance
defaults write 'Apple Global Domain' 'AppleInterfaceStyle' -string 'Dark'

# Dock
# Autohide the Dock when the mouse is out
defaults write com.apple.dock 'autohide' -bool 'true'

# Set Dock autohide delay (default 0.2)
defaults write com.apple.dock 'autohide-delay' -float '0'

# Remove all persistent apps in the Dock
defaults write com.apple.dock 'persistent-apps' -array

# Only show active apps in the Dock
defaults write com.apple.dock 'static-only' -bool 'true'

# Scroll to Exposé app
defaults write com.apple.dock 'scroll-to-open' -bool 'true'

# Group windows by application in Exposé
defaults write com.apple.dock "expose-group-apps" -bool "true"

# Finder
# Show file extensions
defaults write NSGlobalDomain 'AppleShowAllExtensions' -bool 'true'

# Show path bar in the bottom of the Finder windows
defaults write com.apple.finder 'ShowPathbar' -bool 'true'

# Set default view style to list view
defaults write com.apple.finder 'FXPreferredViewStyle' -string 'Nlsv'

# Set the default search scope to the current folder
defaults write com.apple.finder 'FXDefaultSearchScope' -string 'SCcf'

# Don't display a warning when changing file extension
defaults write com.apple.finder 'FXEnableExtensionChangeWarning' -bool 'false'

# Set home directory as default for saving new documents (instead of iCloud)
defaults write NSGlobalDomain 'NSDocumentSaveNewDocumentsToCloud' -bool 'false'

# Trackpad > Point & Click > Tracking speed
defaults write 'Apple Global Domain' 'com.apple.trackpad.scaling' -float '2.5'
# Trackpad > Point & Click > Tap to click
defaults write 'com.apple.AppleMultitouchTrackpad' 'Clicking' -bool 'true'

# Restart services for the above changes to take effect
killall Dock
killall Finder

