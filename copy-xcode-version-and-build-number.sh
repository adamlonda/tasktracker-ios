#!/bin/bash

# Retrieve current Xcode version and build number
xcode_version=$(xcodebuild -version | awk 'NR==1 {print $2}')
xcode_build=$(xcodebuild -version | awk 'NR==2 {print $3}')

# Copy the current Xcode version & build to clipboard
echo "Xcode $xcode_version ($xcode_build)" | pbcopy