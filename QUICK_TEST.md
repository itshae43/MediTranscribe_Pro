# **Quick Start Testing Guide**

Follow these steps **in order** to visually verify each stage of Scribe v2 implementation.

---

## **🚀 QUICK TEST SEQUENCE**

### **Test 1: Verify Environment (Before Running App)**

```bash
cd /home/shailendra/Dev/MediTranscribe/meditranscribe_flutter

# Check .env file exists
ls -la .env

# View contents (should show API key and endpoint)
cat .env
```

**Expected Output:**
```
ELEVENLABS_API_KEY=sk_your_api_key_here
SCRIBE_V2_ENDPOINT=wss://api.elevenlabs.io/v1/speech-to-text/stream
```

✅ If you see both lines, proceed to Test 2  
❌ If missing, create `.env` file with these values

---

### **Test 2: Run App and Check Startup Logs**

```bash
flutter run
```

**Watch Console Output - Look for:**

```
🔗 [STEP 2.1] Connecting to Scribe v2: wss://api.elevenlabs.io/v1/speech-to-text/stream
```

This appears **when you tap "Start Recording"** button.

---

### **Test 3: Visual UI Check**

**Step-by-step:**

1. **App launches** → You see Home Screen
   - ✅ See list of consultations (or "No consultations")
   - ✅ See floating mic button (bottom-right)

2. **Tap mic button** → Recording Screen opens
   - ✅ See timer at 00:00
   - ✅ See "Start Recording" button
   - ✅ See empty transcript area

3. **Tap "Start Recording"** → Recording begins
   - ✅ Timer starts: 00:01, 00:02, 00:03...
   - ✅ App bar changes color (red/green)
   - ✅ "LIVE" indicator appears
   - ✅ Waveform animates (if implemented)

---

### **Test 4: Monitor Console During Recording**

**Start speaking and watch console logs appear in this order:**

```
🔗 [STEP 2.1] Connecting to Scribe v2: wss://...
✅ WebSocket connected successfully

📤 [STEP 2.2] Sending configuration:
   - Language: en
   - Speaker Diarization: true
   - Number of Speakers: 2
   - Medical Terms: 47 terms
✅ [STEP 2.2] Configuration sent successfully

👂 [STEP 2.3] Listening for WebSocket messages...

🔊 [STEP 3.3] Sending audio chunk: 3200 bytes
🔊 [STEP 3.3] Sending audio chunk: 3200 bytes
🔊 [STEP 3.3] Sending audio chunk: 3200 bytes
[... repeats continuously while recording ...]

📨 [STEP 4] RAW MESSAGE RECEIVED
📋 [STEP 4.1] Message type: transcript
💬 Processing transcript message...
📝 [STEP 4.2] RAW TEXT: "hello doctor"
👤 RAW SPEAKER: UNKNOWN
🆔 SPEAKER_ID: 0
🏷️  [STEP 4.3] MAPPED LABEL: DOCTOR (ID: 0)
📄 [STEP 4.4] Updated transcript (14 chars)
   Latest: [DOCTOR]: hello doctor
```

---

### **Test 5: Check UI Updates**

**While recording, look at the screen:**

**Transcript Area should show:**
```
[DOCTOR]: hello doctor
[PATIENT]: hi I'm not feeling well
[DOCTOR]: what seems to be the problem
```

**Visual checks:**
- ✅ Text appears within 1-3 seconds of speaking
- ✅ Speaker labels are correct (DOCTOR/PATIENT)
- ✅ New lines appear automatically
- ✅ Transcript scrolls to show latest text

---

### **Test 6: Stop Recording**

**Tap "Stop Recording"**

**Console should show:**
```
🛑 Stopping transcription...
📤 Sending end-of-stream signal
✅ Transcription stopped successfully
📊 Final stats:
   - Total transcript length: 145 chars
   - Speaker segments: 8
🔌 WebSocket closed
```

**UI checks:**
- ✅ Timer stops
- ✅ "LIVE" indicator disappears
- ✅ Button changes back to "Start Recording"

---

## **📊 VISUAL CHECKLIST**

Copy this and check off each item:

```
STEP 1: ENVIRONMENT
[ ] .env file exists
[ ] API key is present (starts with 'sk_')
[ ] Endpoint URL is correct

STEP 2: CONNECTION
[ ] "Connecting to Scribe v2" log appears
[ ] "WebSocket connected" message
[ ] "Configuration sent" message
[ ] No connection errors

STEP 3: AUDIO
[ ] Audio chunks sending (3200 bytes typical)
[ ] Chunks send continuously (5-10 per second)
[ ] No "WebSocket not connected" warnings

STEP 4: TRANSCRIPTION
[ ] Messages received from server
[ ] Message type is "transcript"
[ ] Text matches spoken words
[ ] Speaker ID present (0 or 1)
[ ] Speaker label maps correctly (DOCTOR/PATIENT)
[ ] UI shows transcript updates

STEP 5: UI BEHAVIOR
[ ] Timer increments every second
[ ] LIVE indicator shows during recording
[ ] Transcript appears in real-time
[ ] Speaker labels visible
[ ] Smooth updates (no lag/freeze)

STEP 6: CLEANUP
[ ] Stop works without errors
[ ] WebSocket closes cleanly
[ ] Stats printed correctly
```

---

## **🐛 TROUBLESHOOTING QUICK REFERENCE**

### **Problem: No logs appear**

**Check:**
```bash
# Make sure you're watching the console
flutter run -v
```

---

### **Problem: "API Key loaded: false"**

**Fix:**
```bash
# Check if .env is in correct location
pwd
# Should show: /home/shailendra/Dev/MediTranscribe/meditranscribe_flutter

# Verify file
cat .env

# If missing, create it:
echo 'ELEVENLABS_API_KEY=sk_your_api_key_here' > .env
echo 'SCRIBE_V2_ENDPOINT=wss://api.elevenlabs.io/v1/speech-to-text/stream' >> .env

# Restart app
flutter run
```

---

### **Problem: "WebSocket not connected"**

**Check console for:**
```
❌ WebSocket error: [error message]
```

**Common causes:**
- Invalid API key
- No internet connection
- Endpoint URL typo

**Test internet:**
```bash
ping google.com
```

---

### **Problem: No transcript appearing**

**Check:**
1. Microphone permission granted?
2. Actually speaking into mic?
3. Console shows "Sending audio chunk"?
4. Console shows "RAW MESSAGE RECEIVED"?

**If chunks sending but no messages:**
- API key might be invalid
- Check ElevenLabs account status
- Verify API quota not exceeded

---

### **Problem: Wrong speaker labels**

**Check console:**
```
🆔 SPEAKER_ID: null
```

If `speaker_id` is always null:
- Speaker diarization may not be enabled in API
- Need to speak longer for detection
- Two distinct voices needed

---

## **⚡ FASTEST TEST (30 seconds)**

**Just want to verify it works?**

1. Open app
2. Tap mic → Start Recording
3. Say: "Hello, I am the doctor"
4. Wait 3 seconds
5. Look at console - should see:
   - ✅ Connection logs
   - ✅ Audio chunks
   - ✅ Message received
   - ✅ Transcript: "hello I am the doctor"
6. Look at UI - should see:
   - ✅ `[DOCTOR]: hello I am the doctor`
7. Tap Stop

**If all ✅ appear, Scribe v2 is working!**

---

## **📹 RECORDING YOUR TEST**

**To save console output to file:**

```bash
flutter run 2>&1 | tee test-output.log
```

Now all console logs save to `test-output.log` file.

**To search logs later:**
```bash
# Find all STEP logs
grep "STEP" test-output.log

# Find all errors
grep "ERROR\|❌" test-output.log

# Find transcript updates
grep "Updated transcript" test-output.log
```

---

## **🎯 SUCCESS CRITERIA**

### **Minimal Working Test:**
- [ ] Environment loads
- [ ] WebSocket connects
- [ ] Audio sends
- [ ] Transcript received
- [ ] UI updates

### **Full Feature Test:**
- [ ] All above +
- [ ] Speaker diarization works
- [ ] Medical terms recognized
- [ ] Numbers converted ("20" not "twenty")
- [ ] Stop/cleanup works
- [ ] No memory leaks

---

## **📞 NEED HELP?**

**Check these files for details:**
1. `SCRIBE_TESTING_GUIDE.md` - Comprehensive testing guide
2. `LEARNING_GUIDE.md` - Architecture explanation
3. `lib/services/scribe_service.dart` - Implementation with debug logs

**Console commands:**
```bash
# Clear cache and rebuild
flutter clean && flutter pub get && flutter run

# Check for errors
flutter analyze

# View dependencies
flutter pub deps
```

---

**Last Updated:** January 19, 2026
