# Iris Analysis App - Android 17 Emulator Setup Guide

## Current Status
✅ Flutter project created with complete structure
✅ Dependencies configured (camera, image processing, Firebase, etc.)  
✅ Basic UI components implemented (splash screen, dashboard, camera interface)
✅ Camera capture functionality created
✅ Web version running at http://localhost:8080

## Next Steps for Android 17 Emulator

### 1. Install Android Studio (Manual Download)
Since automated installation had issues, please manually download Android Studio:
- Visit: https://developer.android.com/studio
- Download Android Studio for macOS (Apple Silicon)
- Install and launch Android Studio

### 2. Setup Android SDK
After installing Android Studio:
```bash
# Open Android Studio
# Go to Tools -> SDK Manager
# Install:
# - Android SDK Platform 35 (Android 17)  
# - Android SDK Build-Tools 35.0.0
# - Android NDK
# - Accept all licenses
```

### 3. Create Android 17 Emulator
```bash
# In Android Studio:
# Tools -> AVD Manager -> Create Virtual Device
# Choose: Phone -> Pixel 8 Pro
# System Image: Android 17 (API level 35)
# AVD Name: "Android_17_API_35"
# Finish and start emulator
```

### 4. Set Environment Variables
Add to ~/.zshrc:
```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
```

### 5. Build and Run
```bash
cd /Users/kunnath/Projects/doctorapp/iris_analysis_app
source ~/.zshrc
flutter devices  # Should show Android emulator
flutter run      # Will run on emulator
```

## Alternative: Run on Web (Currently Working)
The app is currently running on web at: http://localhost:8080
- All basic functionality works on web
- Camera interface implemented with fallback to file picker
- Modern UI with iris analysis simulation

## App Features Implemented
- ✅ Splash Screen with app branding
- ✅ Dashboard with feature cards
- ✅ Camera capture screen
- ✅ Iris analysis results display
- ✅ Modern Material Design UI
- ✅ Image processing pipeline structure
- ✅ Web compatibility

## Commands to Continue Development

### Hot Restart Web App
```bash
cd /Users/kunnath/Projects/doctorapp/iris_analysis_app
# Press 'R' in the terminal running flutter web server
```

### Build Android APK (after SDK setup)
```bash
./build_android.sh
```

### Check Flutter Environment
```bash
flutter doctor -v
```

## Recommended Next Development Steps
1. Complete Android emulator setup (manual Android Studio installation)
2. Implement Firebase authentication
3. Add real TensorFlow Lite model for iris analysis
4. Implement cloud storage integration
5. Add subscription/payment features
6. Enhance security and privacy features

The app foundation is solid and ready for Android 17 testing once the emulator is properly configured!