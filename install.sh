#!/bin/bash

# Clone the Flutter repo to build the app
git clone https://github.com/flutter/flutter.git -b stable

# Add flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Build the web app
flutter build web
