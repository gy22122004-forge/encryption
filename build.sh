#!/bin/bash
# Vercel specifies Amazon Linux 2 or a similar environment. We need to install Flutter.
echo "Downloading Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Add flutter to path
export PATH="$PATH:`pwd`/flutter/bin"

# Check flutter installation
flutter doctor -v

# Build the web application
echo "Building Flutter Web App..."
flutter build web --release
