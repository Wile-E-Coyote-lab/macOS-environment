# Show hidden files by default in Finder
defaults write com.apple.finder AppleShowAllFiles -bool true

# Set screenshot save location to the Desktop
defaults write com.apple.screencapture location ~/Desktop

# Require password immediately after screen saver starts
defaults write com.apple.screensaver askForPassword -int 1

# Restart Finder to apply changes
killall Finder
