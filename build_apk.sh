#!/bin/bash

echo "🚀 Building Nightlife APK..."
cd /Users/sriharsha/Downloads/Nightlife-APP-11SEP2025

echo "📦 Getting dependencies..."
flutter pub get

echo "🔨 Building APK..."
flutter build apk --debug

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📁 APK location: build/app/outputs/flutter-apk/app-debug.apk"
    open build/app/outputs/flutter-apk/
else
    echo "❌ Build failed!"
fi
