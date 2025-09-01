# 🎤 Voice Commands Guide - ELARABY Food App

## 🚀 Overview
Your ELARABY Food app now supports voice commands! Simply tap the microphone button and speak your commands naturally.

## 🎯 Available Voice Commands

### 🍽️ Food Reheating Commands
```
"Reheat salmon bowl"
"Warm up spring bowl"
"Reheat avocado bowl"
"Reheat berry bowl"
```

### ➕ Adding New Items
```
"Add new food item"
"Add food"
"Create new item"
```

### 🌡️ Temperature Control
```
"Set temperature to 180 degrees"
"Temperature 200"
"Set temp to 175"
```

### ⏰ Cooking Time
```
"Set time to 30 minutes"
"Cook for 45 minutes"
"Set cooking time to 20 mins"
```

### 🍳 Cooking Control
```
"Start cooking"
"Stop cooking"
"What's cooking?"
```

### 📋 Information Commands
```
"List my food items"
"What food do I have?"
"Show my custom items"
```

### ❓ Help Commands
```
"Help"
"What can you do?"
"Show available commands"
```

## 🎮 How to Use

### 1. **Access Voice Commands**
- Look for the microphone button (🎤) in the bottom-right corner
- Tap it to start listening

### 2. **Speak Your Command**
- The button will turn red when listening
- Speak clearly and naturally
- Wait for the response

### 3. **Visual Feedback**
- "Listening..." indicator appears while active
- Last command is displayed for reference
- Voice responses confirm your actions

## 🔧 Technical Features

### **Speech Recognition**
- Real-time voice-to-text conversion
- Supports English language
- Automatic command processing

### **Text-to-Speech**
- Voice responses for all actions
- Natural language feedback
- Confirmation of commands

### **Smart Command Processing**
- Context-aware responses
- Handles variations in speech
- Graceful error handling

## 🛠️ Setup Requirements

### **Android Permissions**
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

### **iOS Permissions**
Add to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice commands</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition for voice commands</string>
```

## 🎨 Customization

### **Adding New Commands**
Edit `lib/services/voice_assistant_service.dart`:
```dart
// Add new command patterns
else if (command.contains('your_new_command')) {
  _speakResponse('Your response');
  // Your action here
}
```

### **Changing Voice Settings**
```dart
await _flutterTts.setLanguage("en-US");  // Language
await _flutterTts.setSpeechRate(0.5);    // Speed (0.1-1.0)
await _flutterTts.setVolume(1.0);        // Volume (0.0-1.0)
await _flutterTts.setPitch(1.0);         // Pitch (0.5-2.0)
```

## 🔮 Future Enhancements

### **Planned Features**
- [ ] Arabic language support
- [ ] Custom wake word ("Hey ELARABY")
- [ ] Bluetooth device voice control
- [ ] Recipe voice instructions
- [ ] Cooking timer voice alerts

### **Advanced Integration**
- [ ] Google Assistant Actions
- [ ] Amazon Alexa Skills
- [ ] Apple Siri Shortcuts
- [ ] Smart home integration

## 🐛 Troubleshooting

### **Common Issues**

1. **Microphone not working**
   - Check app permissions
   - Restart the app
   - Ensure microphone is not used by other apps

2. **Commands not recognized**
   - Speak clearly and slowly
   - Check internet connection
   - Try different command variations

3. **No voice response**
   - Check device volume
   - Verify TTS is enabled
   - Restart the app

### **Debug Mode**
Enable debug logging in `voice_assistant_service.dart`:
```dart
print('Voice command: $command');
print('Speech recognition status: $status');
```

## 📱 Supported Devices

### **Minimum Requirements**
- Android 6.0+ (API 23)
- iOS 12.0+
- Microphone access
- Internet connection

### **Recommended**
- Android 8.0+ (API 26)
- iOS 14.0+
- Good microphone quality
- Stable internet connection

## 🎉 Tips for Best Experience

1. **Speak Clearly**: Enunciate your words properly
2. **Use Natural Language**: "Reheat salmon bowl" works better than "reheat salmon"
3. **Wait for Response**: Don't interrupt the voice feedback
4. **Check Permissions**: Ensure microphone access is granted
5. **Update Regularly**: Keep the app updated for best performance

---

**Happy Voice Cooking! 🎤👨‍🍳**
