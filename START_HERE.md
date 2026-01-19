# **Testing Summary - Where to Start**

## **📚 Documentation Files Created**

1. **QUICK_TEST.md** ⭐ **START HERE**
   - Fastest way to test (30 seconds)
   - Step-by-step commands
   - What to expect at each stage

2. **SCRIBE_TESTING_GUIDE.md**
   - Comprehensive testing for each step
   - Troubleshooting by symptom
   - Debugging strategies

3. **VISUAL_FLOW_DIAGRAMS.md**
   - Visual diagrams of data flow
   - Timeline view
   - UI state diagrams

4. **LEARNING_GUIDE.md** (already exists)
   - Complete architecture explanation
   - How everything works together

---

## **🚀 Quick Start (3 Steps)**

### **1. Run this command:**
```bash
cd /home/shailendra/Dev/MediTranscribe/meditranscribe_flutter
flutter run
```

### **2. In the app:**
- Tap mic button
- Tap "Start Recording"
- Say "Hello, I am the doctor"
- Wait 3 seconds
- Look at screen

### **3. You should see:**
```
[DOCTOR]: Hello, I am the doctor
```

**✅ If you see this, it's working!**

---

## **📊 What the Logs Mean**

When you run the app, you'll see logs like this:

```
🔗 [STEP 2.1] Connecting...     ← WebSocket connecting
✅ WebSocket connected           ← Connection successful
📤 [STEP 2.2] Config sent       ← Sent settings to API
🔊 Sending audio chunk          ← Audio streaming
📨 RAW MESSAGE RECEIVED         ← Transcript coming back
💬 RAW TEXT: "hello"            ← What you said
🏷️ MAPPED: DOCTOR              ← Who said it
```

Each emoji tells you **what stage** you're at!

---

## **🔍 Testing Each Stage**

### **STEP 1: Environment (before app runs)**
```bash
cat .env
```
Look for your API key.

### **STEP 2.1: Connection**
When you tap "Start Recording", look for:
```
🔗 [STEP 2.1] Connecting to Scribe v2...
```

### **STEP 2.2: Configuration**
Look for:
```
📤 [STEP 2.2] Sending configuration:
   - Speaker Diarization: true
```

### **STEP 2.3: Listening**
Look for:
```
👂 [STEP 2.3] Listening for WebSocket messages...
```

### **STEP 3: Audio Streaming**
While recording, look for (repeating):
```
🔊 [STEP 3.3] Sending audio chunk: 3200 bytes
```

### **STEP 4.1: Message Received**
When you speak, look for:
```
📨 [STEP 4] RAW MESSAGE RECEIVED
📋 [STEP 4.1] Message type: transcript
```

### **STEP 4.2: Text Extraction**
Look for:
```
📝 [STEP 4.2] RAW TEXT: "hello doctor"
🆔 SPEAKER_ID: 0
```

### **STEP 4.3: Speaker Mapping**
Look for:
```
🏷️ [STEP 4.3] MAPPED LABEL: DOCTOR (ID: 0)
```

### **STEP 4.4: UI Update**
Look at the **screen** - should show:
```
[DOCTOR]: hello doctor
```

---

## **❓ Common Questions**

### **Q: Where do I see the logs?**
**A:** In your terminal/console where you ran `flutter run`

### **Q: Nothing appears in console?**
**A:** Try:
```bash
flutter run -v
```

### **Q: How do I know my API key loaded?**
**A:** Add this to `main.dart` temporarily:
```dart
print('API Key: ${Environment.elevenLabsApiKey.substring(0, 10)}...');
```

### **Q: No transcript appearing?**
**A:** Check:
1. Microphone permission granted?
2. Speaking clearly into mic?
3. Console shows "Sending audio chunk"?
4. Console shows "RAW MESSAGE RECEIVED"?

---

## **📂 File Structure**

```
meditranscribe_flutter/
├── .env                          ← API keys (check this first!)
├── QUICK_TEST.md                 ← Start here
├── SCRIBE_TESTING_GUIDE.md       ← Detailed testing
├── VISUAL_FLOW_DIAGRAMS.md       ← Visual diagrams
├── LEARNING_GUIDE.md             ← How it works
└── lib/
    ├── services/
    │   └── scribe_service.dart   ← Implementation (with debug logs)
    ├── screens/
    │   └── recording_screen.dart ← UI
    └── utils/
        └── debug_helpers.dart    ← Testing utilities
```

---

## **🎯 Success Checklist**

Copy and check off as you test:

```
[ ] .env file has API key
[ ] App runs without errors
[ ] Can tap "Start Recording"
[ ] See "🔗 Connecting..." in console
[ ] See "✅ Connected" in console
[ ] See "LIVE ●" in app
[ ] Timer increments (00:01, 00:02...)
[ ] Audio chunks sending in console
[ ] Speak into microphone
[ ] See "📨 MESSAGE RECEIVED" in console
[ ] See transcript appear in app
[ ] Speaker label shows (DOCTOR/PATIENT)
[ ] Can tap "Stop" without crash
```

**If all ✅ → You're done! Everything works! 🎉**

---

## **🐛 If Something Fails**

### **No API key loaded**
```bash
# Check file
cat .env

# Should show:
ELEVENLABS_API_KEY=sk_...
```

### **WebSocket won't connect**
- Check internet connection
- Verify API key is valid
- Check ElevenLabs account status

### **No transcript**
- Grant microphone permission
- Speak louder/clearer
- Check API quota

### **Wrong speaker labels**
- Need 2 different voices
- Speak longer phrases
- Wait for AI to detect patterns

---

## **📞 Next Steps**

1. ✅ Test basic connection (QUICK_TEST.md)
2. ✅ Test each stage (SCRIBE_TESTING_GUIDE.md)
3. ✅ Understand the flow (VISUAL_FLOW_DIAGRAMS.md)
4. ✅ Learn the architecture (LEARNING_GUIDE.md)

---

**Ready to test? Run this:**
```bash
flutter run
```

**Then follow QUICK_TEST.md!**

---

**Last Updated:** January 19, 2026
