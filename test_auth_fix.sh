#!/bin/bash

echo "🚀 Testing Firebase Authentication Fix"
echo "======================================"

# Launch the app
echo "📱 Launching app..."
adb shell am start -n com.irishealth.app.iris_analysis_app/.MainActivity

echo "⏳ Waiting for app to initialize..."
sleep 3

echo "📊 Monitoring Firebase Authentication logs..."
echo "============================================="
echo "✅ Look for successful authentication instead of 'empty reCAPTCHA token'"
echo "❌ If you still see 'empty reCAPTCHA token', the SHA fingerprints need to be added to Firebase Console"
echo ""
echo "Press Ctrl+C to stop monitoring..."
echo ""

# Monitor Firebase authentication logs
adb logcat -s FirebaseAuth,flutter | grep -E "(Creating user|Logging in|ERROR|Exception|reCAPTCHA|SHA|fingerprint)" --line-buffered