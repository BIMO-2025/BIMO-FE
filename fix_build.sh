#!/bin/bash

echo "🛠️  Starting deep clean and repair process..."

# 1. Clean Flutter artifacts
echo "🧹  Cleaning Flutter..."
flutter clean
rm -rf build
rm -rf .dart_tool

# 2. Clean iOS artifacts
echo "🧹  Cleaning iOS Pods..."
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf Flutter/Flutter.framework
rm -rf Flutter/App.framework

# 3. Clean Xcode DerivedData (Crucial step for persistent errors)
echo "🧹  Cleaning Xcode DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*

# 4. Re-install dependencies
echo "mV  Installing Flutter dependencies..."
cd ..
flutter pub get

# 5. Re-install Pods
echo "mV  Installing iOS Pods..."
cd ios
pod install --repo-update

# 6. Open Xcode
echo "🚀  Opening Xcode..."
open Runner.xcworkspace

echo "✅  Repair complete!"
echo "👉  Please click the Play (▶️) button in Xcode to run the app."
