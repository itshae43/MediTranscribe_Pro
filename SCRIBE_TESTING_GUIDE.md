# **ElevenLabs Scribe v2 - Visual Testing Guide**

This guide shows you **exactly what to see** at each stage of implementation.

---

## **STEP 1: Environment Configuration Testing**

### **Test 1.1: Check .env File Exists**

**Action:**
```bash
cat .env
```

**Expected Output:**
```
ELEVENLABS_API_KEY=sk_1f6640ba771099c658d0136bf3048b3ef39c7e8ec14ae9a1
SCRIBE_V2_ENDPOINT=wss://api.elevenlabs.io/v1/speech-to-text/stream
```

✅ **Success:** You see your API key and endpoint  
❌ **Fail:** File not found or empty

---

### **Test 1.2: Verify Environment Variables Load**

**Add to `lib/main.dart` (temporarily):**
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // TEST: Print environment variables
  print('🔑 API Key loaded: ${Environment.elevenLabsApiKey.isNotEmpty}');
  print('🌐 Endpoint: ${Environment.scribeEndpoint}');
  print('🔑 First 10 chars of key: ${Environment.elevenLabsApiKey.substring(0, 10)}...');
  
  runApp(const MyApp());
}
```

**Run app:**
```bash
flutter run
```

**Expected Console Output:**
```
🔑 API Key loaded: true
🌐 Endpoint: wss://api.elevenlabs.io/v1/speech-to-text/stream
🔑 First 10 chars of key: sk_1f6640b...
```

✅ **Success:** All three lines print correctly  
❌ **Fail:** "API Key loaded: false" or endpoint is empty

**REMOVE TEST CODE** after verification!

---

## **STEP 2: WebSocket Connection Testing**

### **Test 2.1: Connection Initialization**

**Add debug logs to `lib/services/scribe_service.dart`:**

Already added in the service! Look for these logs in console.

**Run the app and tap "Start Recording"**

**Expected Console Output:**
```
[INFO] Connecting to Scribe v2: wss://api.elevenlabs.io/v1/speech-to-text/stream
```

**Visual Indicators in App:**
- Recording button changes to "Stop"
- Timer starts counting (00:00, 00:01, 00:02...)
- "LIVE" indicator appears in app bar (red dot)

✅ **Success:** Log appears, UI updates  
❌ **Fail:** No log, or "Connection error" appears

---

### **Test 2.2: Configuration Message Sent**

**Expected Console Output (right after 2.1):**
```
[INFO] Scribe v2 config sent
```

**What this means:**
- WebSocket connected successfully
- Configuration JSON sent to ElevenLabs
- Server received: API key, language, speaker settings, medical terms

**Visual Check:**
- No error dialogs appear
- App doesn't crash
- Recording continues normally

✅ **Success:** "config sent" message appears  
❌ **Fail:** Error message or crash

---

### **Test 2.3: WebSocket Stream Listening**

**Enable detailed logging:**

Add to `scribe_service.dart` in `_connectWebSocket()`:

```dart
_channel!.stream.listen(
  (message) {
    print('📨 RAW MESSAGE RECEIVED: $message'); // ADD THIS LINE
    _handleMessage(message);
  },
  // ... rest of code
);
```

**Expected Console Output (while recording):**
```
📨 RAW MESSAGE RECEIVED: {"type":"transcript","text":"hello","speaker_id":0}
📨 RAW MESSAGE RECEIVED: {"type":"transcript","text":"how are you","speaker_id":1}
```

**Visual Check:**
- Messages appear every few seconds while speaking
- Different `speaker_id` values (0, 1)
- `text` contains your spoken words

✅ **Success:** Messages stream continuously  
❌ **Fail:** No messages after 5+ seconds of speaking

---

## **STEP 3: Audio Streaming Testing**

### **Test 3.1: Microphone Permission**

**Action:** Start app for first time

**Expected Visual:**
- Permission dialog pops up
- Text: "MediTranscribe wants to access your microphone"
- Two buttons: "Allow" / "Deny"

**Tap "Allow"**

**Console Output:**
```
[INFO] Microphone permission granted
```

✅ **Success:** Permission granted, no errors  
❌ **Fail:** Permission denied or no dialog

---

### **Test 3.2: Audio Capture Starts**

**Add to audio service (if not present):**

```dart
print('🎤 Audio recording started');
print('🎤 Sample rate: 16000 Hz');
print('🎤 Encoding: PCM 16-bit');
```

**Expected Console Output:**
```
🎤 Audio recording started
🎤 Sample rate: 16000 Hz
🎤 Encoding: PCM 16-bit
```

**Visual Indicators:**
- Waveform animation appears
- Audio visualizer shows movement
- Timer starts incrementing

✅ **Success:** Waveform animates, timer runs  
❌ **Fail:** Static waveform, timer stuck at 00:00

---

### **Test 3.3: Audio Chunks Streaming**

**Add to `scribe_service.dart` in `sendAudioChunk()`:**

```dart
void sendAudioChunk(Uint8List audioData) {
  try {
    if (_channel != null && _isConnected) {
      print('🔊 Sending audio chunk: ${audioData.length} bytes'); // ADD THIS
      _channel!.sink.add(audioData);
    } else {
      print('⚠️ WebSocket not connected!'); // ADD THIS
    }
  } catch (e) {
    _logger.e('Error sending audio: $e');
  }
}
```

**Expected Console Output (continuous):**
```
🔊 Sending audio chunk: 3200 bytes
🔊 Sending audio chunk: 3200 bytes
🔊 Sending audio chunk: 3200 bytes
[repeats every ~200ms while recording]
```

**Visual Check:**
- Chunks send continuously
- Byte count consistent (usually 1600-6400 bytes)
- No "not connected" warnings

✅ **Success:** Continuous stream of chunk logs  
❌ **Fail:** No chunks, or "not connected" errors

---

## **STEP 4: Receiving Transcription Testing**

### **Test 4.1: Message Type Detection**

**Already added in service!** Look for:

```
[DEBUG] Received message type: transcript
```

**Expected Console Output:**
```
[DEBUG] Received message type: transcript
[DEBUG] Received message type: transcript
[DEBUG] Received message type: final
```

**Different message types:**
- `transcript` - Partial/ongoing transcription
- `final` - Confirmed segment
- `error` - Something went wrong

✅ **Success:** See "transcript" messages while speaking  
❌ **Fail:** Only see "error" or "unknown" types

---

### **Test 4.2: Transcript Text Extraction**

**Add to `_handleTranscript()`:**

```dart
void _handleTranscript(Map<String, dynamic> data) {
  final text = data['text'] ?? '';
  final speaker = data['speaker']?.toString().toUpperCase() ?? 'UNKNOWN';
  
  print('💬 RAW TEXT: "$text"'); // ADD THIS
  print('👤 SPEAKER: $speaker'); // ADD THIS
  print('🆔 SPEAKER_ID: ${data['speaker_id']}'); // ADD THIS
  
  // ... rest of code
}
```

**Expected Console Output:**
```
💬 RAW TEXT: "hello doctor"
👤 SPEAKER: UNKNOWN
🆔 SPEAKER_ID: 0

💬 RAW TEXT: "I have a headache"
👤 SPEAKER: UNKNOWN
🆔 SPEAKER_ID: 1
```

**Visual Check:**
- Text matches what you said
- `speaker_id` alternates (0 for one person, 1 for another)

✅ **Success:** Accurate text, different speaker IDs  
❌ **Fail:** Gibberish text, always same speaker

---

### **Test 4.3: Speaker Label Mapping**

**Add to `_handleTranscript()`:**

```dart
if (data['speaker_id'] != null) {
  speakerLabel = data['speaker_id'] == 0 ? 'DOCTOR' : 'PATIENT';
}

print('🏷️ MAPPED LABEL: $speakerLabel'); // ADD THIS
```

**Expected Console Output:**
```
🏷️ MAPPED LABEL: DOCTOR
🏷️ MAPPED LABEL: PATIENT
🏷️ MAPPED LABEL: DOCTOR
```

**Visual Check in App:**
- Transcript shows `[DOCTOR]:` prefix
- Transcript shows `[PATIENT]:` prefix
- Labels match who's speaking

✅ **Success:** Correct labels in UI  
❌ **Fail:** All show "UNKNOWN" or wrong labels

---

### **Test 4.4: Live Transcript Update**

**Watch the Recording Screen UI**

**Expected Visual:**
```
Live Transcript
───────────────────────────────

[DOCTOR]: Hello, what brings you in today?
[PATIENT]: I've been experiencing headaches.
[DOCTOR]: How long have you had these headaches?
[PATIENT]: About a week now.
```

**Real-time behavior:**
- Text appears word by word as you speak
- New lines added continuously
- Speaker labels alternate
- Scrolls automatically to show latest text

✅ **Success:** Text appears in real-time with labels  
❌ **Fail:** Text doesn't appear or appears all at once at the end

---

## **COMPLETE VISUAL TEST SEQUENCE**

### **End-to-End Test**

**Steps:**

1. **Launch app**
   - See home screen
   - Tap mic button

2. **Permission Dialog**
   - Tap "Allow"

3. **Recording Screen Loads**
   - See "Ready to record" initially
   - See timer at 00:00

4. **Tap "Start Recording"**
   - Timer starts: 00:01, 00:02...
   - App bar turns red/green
   - "LIVE" indicator appears
   - Waveform animates

5. **Speak into microphone**
   - Say: "Hello, I am the doctor"
   - Wait 2-3 seconds
   - See text appear: `[DOCTOR]: Hello, I am the doctor`

6. **Speak again (different voice/person)**
   - Say: "Hi doctor, I'm not feeling well"
   - See text appear: `[PATIENT]: Hi doctor, I'm not feeling well`

7. **Continue conversation**
   - Alternate speakers
   - Watch labels switch between DOCTOR/PATIENT

8. **Tap "Stop Recording"**
   - Timer stops
   - "LIVE" indicator disappears
   - Transcript is complete

9. **Check Console Logs**

**Expected complete log sequence:**

```
🔑 API Key loaded: true
🌐 Endpoint: wss://api.elevenlabs.io/v1/speech-to-text/stream
[INFO] Connecting to Scribe v2: wss://api.elevenlabs.io/v1/speech-to-text/stream
[INFO] Scribe v2 config sent
🎤 Audio recording started
🔊 Sending audio chunk: 3200 bytes
🔊 Sending audio chunk: 3200 bytes
📨 RAW MESSAGE RECEIVED: {"type":"transcript","text":"hello","speaker_id":0}
[DEBUG] Received message type: transcript
💬 RAW TEXT: "hello"
👤 SPEAKER: UNKNOWN
🆔 SPEAKER_ID: 0
🏷️ MAPPED LABEL: DOCTOR
[DEBUG] Transcript updated: DOCTOR -> hello
📨 RAW MESSAGE RECEIVED: {"type":"transcript","text":"I am the doctor","speaker_id":0}
💬 RAW TEXT: "I am the doctor"
🏷️ MAPPED LABEL: DOCTOR
[DEBUG] Transcript updated: DOCTOR -> I am the doctor
📨 RAW MESSAGE RECEIVED: {"type":"transcript","text":"hi doctor","speaker_id":1}
💬 RAW TEXT: "hi doctor"
🆔 SPEAKER_ID: 1
🏷️ MAPPED LABEL: PATIENT
[DEBUG] Transcript updated: PATIENT -> hi doctor
[INFO] Transcription stopped
[INFO] WebSocket closed
```

---

## **DEBUGGING CHECKLIST**

### **Problem: No API key loaded**

**Check:**
```bash
# Verify .env file exists
ls -la .env

# Check contents
cat .env

# Verify it's loaded in pubspec.yaml
grep "flutter_dotenv" pubspec.yaml
```

**Fix:**
- Create `.env` file in project root
- Add API key
- Run `flutter clean && flutter pub get`

---

### **Problem: WebSocket won't connect**

**Console shows:**
```
[ERROR] WebSocket error: ...
```

**Check:**
1. API key is correct
2. Internet connection works
3. Endpoint URL is correct
4. Try in browser: https://elevenlabs.io

**Test connection manually:**
```dart
print('Testing connection to: ${Environment.scribeEndpoint}');
print('API key starts with: ${Environment.elevenLabsApiKey.substring(0, 3)}');
```

---

### **Problem: No audio chunks sending**

**Console shows:**
```
⚠️ WebSocket not connected!
```

**Check:**
1. Microphone permission granted
2. WebSocket connected first
3. Audio service initialized

**Add debug:**
```dart
print('_isConnected: $_isConnected');
print('_channel: ${_channel != null}');
```

---

### **Problem: No transcript appearing**

**Console shows messages but UI empty**

**Check:**
1. Stream controller initialized
2. UI watching correct provider
3. State updating

**Add debug:**
```dart
print('Stream controller null: ${_transcriptController == null}');
print('Adding to stream: $_currentTranscript');
```

---

### **Problem: All speakers show "UNKNOWN"**

**Check:**
1. `enable_speaker_diarization: true` in config
2. `num_speakers: 2` set
3. API response contains `speaker_id`

**Add debug:**
```dart
print('Full data object: ${jsonEncode(data)}');
```

---

## **PERFORMANCE BENCHMARKS**

### **Expected Metrics:**

**Connection:**
- WebSocket connect time: < 1 second
- Config acknowledgment: < 500ms

**Audio:**
- Chunk size: 1600-6400 bytes
- Chunk frequency: 5-10 per second
- Latency: 200-500ms

**Transcription:**
- First word appears: 1-3 seconds after speaking
- Update frequency: 1-2 times per second
- Accuracy: 95%+ for clear speech

**Memory:**
- Idle: ~50MB
- Recording: ~80-120MB
- Peak: < 200MB

---

## **TROUBLESHOOTING BY SYMPTOM**

### **Symptom: App crashes on start**

**Check:**
```
[ERROR] MissingPluginException
```

**Fix:**
```bash
flutter clean
flutter pub get
flutter run
```

---

### **Symptom: "Failed to start recording"**

**Red snackbar appears**

**Check:**
1. Microphone permission
2. Another app using mic
3. Audio service initialization

**Fix:**
```bash
# On Android
adb shell pm grant com.meditranscribe.app android.permission.RECORD_AUDIO

# On iOS - check Info.plist
```

---

### **Symptom: Transcript gibberish**

**Wrong language or encoding**

**Check config:**
```dart
'language_code': 'en',  // Correct for English
'text_encoding': 'utf-8',
```

---

### **Symptom: Lag/stuttering**

**Performance issue**

**Check:**
1. Audio chunk size (should be 1600-3200 bytes)
2. Network speed
3. Device CPU usage

**Optimize:**
```dart
// Reduce chunk frequency if needed
final chunkDuration = 200; // milliseconds
```

---

## **SUCCESS CRITERIA**

### **✅ FULLY WORKING:**

- [ ] API key loads correctly
- [ ] WebSocket connects within 1 second
- [ ] Config sent successfully
- [ ] Audio chunks stream continuously
- [ ] Transcripts appear in real-time (< 3 sec delay)
- [ ] Speaker labels correct (DOCTOR/PATIENT)
- [ ] UI updates smoothly
- [ ] Stop recording works cleanly
- [ ] Transcript saved to database
- [ ] No memory leaks (check with profiler)

### **🎯 PERFORMANCE TARGETS:**

- [ ] < 2 second delay from speech to text
- [ ] 95%+ transcription accuracy
- [ ] < 100MB memory usage
- [ ] No dropped audio chunks
- [ ] Smooth UI (60 FPS)

---

## **FINAL VERIFICATION TEST**

**Record a 2-minute conversation:**

1. Two people speak alternately
2. Use medical terms: "hypertension", "120/80", "metoprolol"
3. Include numbers: "20 milligrams", "twice daily"

**Verify:**
- All speech captured
- Speaker labels correct throughout
- Medical terms spelled correctly
- Numbers converted properly ("20" not "twenty")
- Transcript readable and accurate

**Expected Result:**
```
[DOCTOR]: What is your blood pressure normally?
[PATIENT]: Usually around 120 over 80.
[DOCTOR]: I'm prescribing metoprolol 20 milligrams twice daily.
[PATIENT]: How long should I take this medication?
```

✅ **Success:** Clean, accurate, labeled transcript  
❌ **Fail:** Missing speech, wrong labels, or poor accuracy

---

**Last Updated:** January 19, 2026
