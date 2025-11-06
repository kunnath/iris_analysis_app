#!/bin/bash

echo "=== Firebase SHA Fingerprint Generator ==="
echo "This script will help you get the SHA fingerprints needed for Firebase Console"
echo

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo "❌ keytool is not installed or not in PATH"
    echo "Make sure Java JDK is installed and keytool is accessible"
    exit 1
fi

echo "🔍 Getting Debug SHA Fingerprints..."
echo "----------------------------------------"

# Debug keystore location
DEBUG_KEYSTORE="$HOME/.android/debug.keystore"

if [ -f "$DEBUG_KEYSTORE" ]; then
    echo "✅ Debug keystore found at: $DEBUG_KEYSTORE"
    echo
    echo "📋 DEBUG SHA FINGERPRINTS (Add these to Firebase Console):"
    echo "=========================================================="
    
    # Get SHA-1 and SHA-256
    keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android | grep -E "(SHA1|SHA256)"
    
    echo
    echo "🔥 Copy the SHA-1 and SHA-256 values above and add them to:"
    echo "   Firebase Console → Project Settings → Your Apps → Android App → SHA certificate fingerprints"
    echo
else
    echo "❌ Debug keystore not found at: $DEBUG_KEYSTORE"
    echo "Run your Flutter app once to generate the debug keystore"
    echo "Command: flutter run"
fi

echo
echo "📝 INSTRUCTIONS:"
echo "1. Copy the SHA-1 and SHA-256 fingerprints from above"
echo "2. Go to Firebase Console → Project Settings"
echo "3. Select your Android app"
echo "4. Add the fingerprints in 'SHA certificate fingerprints' section"
echo "5. Download the updated google-services.json file"
echo "6. Replace the existing google-services.json in android/app/"
echo
echo "⚠️  For PRODUCTION builds, generate a release keystore and add those fingerprints too!"
echo

# Check if release keystore exists
if [ -f "android/app/release-key.keystore" ]; then
    echo "🔍 Found release keystore. Getting release fingerprints..."
    echo "📋 RELEASE SHA FINGERPRINTS:"
    echo "============================"
    read -p "Enter release keystore password: " -s RELEASE_PASS
    echo
    keytool -list -v -keystore android/app/release-key.keystore -alias release -storepass "$RELEASE_PASS" | grep -E "(SHA1|SHA256)"
fi

echo
echo "✅ Setup complete! Build and test your app now."