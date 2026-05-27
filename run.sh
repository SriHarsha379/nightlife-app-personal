#!/bin/bash

echo "🚀 Starting Nightlife App..."

# Navigate to project directory
cd /Users/sriharsha/Downloads/Nightlife-APP-11SEP2025

# Check if simulator is booted, if not boot it
echo "📱 Checking iOS Simulator..."
BOOTED=$(xcrun simctl list devices | grep "Booted")
if [ -z "$BOOTED" ]; then
    echo "📱 Booting iOS Simulator..."
    flutter emulators --launch apple_ios_simulator
    sleep 5
else
    echo "✅ Simulator already running"
fi

# Get flutter dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run the app
echo "▶️  Running app..."
flutter run

