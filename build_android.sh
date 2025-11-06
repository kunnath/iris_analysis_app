#!/bin/bash

# Android Build and Run Script for Iris Analysis App
# This script builds and runs the app on Android emulator with latest SDK

echo "🚀 Building and Running Iris Analysis App on Android Emulator..."

# Ensure we're in the right directory
cd /Users/kunnath/Projects/doctorapp/iris_analysis_app
echo "📁 Working directory: $(pwd)"

# Set environment variables for latest Android SDK
export ANDROID_HOME=/Users/kunnath/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"

echo "🔧 Environment configured:"
echo "  ANDROID_HOME: $ANDROID_HOME"
echo "  JAVA_HOME: $JAVA_HOME"

# Check if emulator is running
echo "📱 Checking for Android emulator..."
if flutter devices | grep -q "emulator"; then
    echo "✅ Android emulator is running"
else
    echo "� Starting Android emulator..."
    flutter emulators --launch Medium_Phone_API_36.1 &
    echo "⏳ Waiting for emulator to boot..."
    sleep 15
fi

# Clean and get dependencies
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Run the app on emulator
echo "� Running app on Android emulator..."
flutter run -d emulator-5554

echo "✅ App should now be running on the Android emulator!"