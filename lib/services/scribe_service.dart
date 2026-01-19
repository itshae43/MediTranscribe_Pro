import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:logger/logger.dart';
import '../config/environment.dart';

/// Scribe V2 Realtime Service
/// Handles real-time speech-to-text transcription using ElevenLabs Scribe v2 Realtime API
/// API Reference: https://elevenlabs.io/docs/api-reference/speech-to-text/v-1-speech-to-text-realtime

class ScribeService {
  final String apiKey;
  final Logger _logger = Logger();

  WebSocketChannel? _channel;
  StreamController<String>? _transcriptController;
  StreamController<String>? _partialTranscriptController;
  StreamController<List<Map<String, String>>>? _speakerLabelsController;
  
  bool _isConnected = false;
  bool _isConnecting = false;
  Completer<void>? _connectionCompleter;
  String _currentTranscript = '';
  final List<Map<String, String>> _allSpeakerLabels = [];

  ScribeService({String? apiKey}) : apiKey = apiKey ?? Environment.elevenLabsApiKey;

  /// Check if service is connected
  bool get isConnected => _isConnected;
  
  /// Get current full transcript
  String get currentTranscript => _currentTranscript;
  
  /// Get all speaker labels
  List<Map<String, String>> get allSpeakerLabels => List.unmodifiable(_allSpeakerLabels);

  /// Start real-time transcription stream
  /// Returns: Map with 'transcript', 'partialTranscript' and 'speakerLabels' streams
  /// NOTE: This is now async and must be awaited before sending audio
  Future<Map<String, Stream>> startTranscription({
    List<String> keyTerms = const [],
    String languageCode = 'en',
  }) async {
    _transcriptController = StreamController<String>.broadcast();
    _partialTranscriptController = StreamController<String>.broadcast();
    _speakerLabelsController = StreamController<List<Map<String, String>>>.broadcast();
    _currentTranscript = '';
    _allSpeakerLabels.clear();

    await _connectWebSocket(keyTerms, languageCode);

    return {
      'transcript': _transcriptController!.stream,
      'partialTranscript': _partialTranscriptController!.stream,
      'speakerLabels': _speakerLabelsController!.stream,
    };
  }

  Future<void> _connectWebSocket(List<String> keyTerms, String languageCode) async {
    if (_isConnecting) {
      print('⚠️ Already connecting, waiting...');
      await _connectionCompleter?.future;
      return;
    }

    _isConnecting = true;
    _connectionCompleter = Completer<void>();

    try {
      // ElevenLabs Realtime STT WebSocket endpoint
      // Docs: https://elevenlabs.io/docs/api-reference/speech-to-text/v-1-speech-to-text-realtime
      const baseEndpoint = 'wss://api.elevenlabs.io/v1/speech-to-text/realtime';
      
      // Build WebSocket URL with query parameters
      final uri = Uri.parse(baseEndpoint).replace(queryParameters: {
        'model_id': 'scribe_v2_realtime',
        'language_code': languageCode,
        'audio_format': 'pcm_16000', // PCM 16-bit, 16kHz
        'commit_strategy': 'vad', // Voice Activity Detection for auto-commit
        'vad_silence_threshold_secs': '1.5',
        'vad_threshold': '0.4',
        'include_timestamps': 'true',
      });

      print('🔗 [STEP 2.1] Connecting to Scribe v2 Realtime: $baseEndpoint');
      print('🔗 WebSocket URI: $uri');
      _logger.i('Connecting to Scribe v2 Realtime: $uri');

      // Connect with API key in header (server-side authentication)
      _channel = IOWebSocketChannel.connect(
        uri,
        headers: {
          'xi-api-key': apiKey,
        },
      );

      // Wait for the WebSocket to be ready
      print('⏳ Waiting for WebSocket connection...');
      await _channel!.ready;
      
      _isConnected = true;
      print('✅ WebSocket connected successfully');
      _logger.i('WebSocket connected successfully');

      // Listen for messages
      print('👂 [STEP 2.3] Listening for WebSocket messages...');
      _channel!.stream.listen(
        (message) {
          print('📨 [STEP 4] RAW MESSAGE RECEIVED');
          _handleMessage(message);
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          _logger.e('WebSocket error: $error');
          _transcriptController?.addError(error);
          _speakerLabelsController?.addError(error);
          _isConnected = false;
          _isConnecting = false;
          if (!_connectionCompleter!.isCompleted) {
            _connectionCompleter!.completeError(error);
          }
        },
        onDone: () {
          print('🔌 WebSocket closed');
          _logger.i('WebSocket closed');
          _isConnected = false;
          _isConnecting = false;
        },
      );

      _isConnecting = false;
      _connectionCompleter!.complete();
      
    } catch (e) {
      print('❌ Connection error: $e');
      _logger.e('Connection error: $e');
      _isConnected = false;
      _isConnecting = false;
      if (!_connectionCompleter!.isCompleted) {
        _connectionCompleter!.completeError(e);
      }
      rethrow;
    }
  }

  void _handleMessage(dynamic message) {
    try {
      if (message is String) {
        final data = jsonDecode(message);
        final messageType = data['message_type'] ?? data['type'];
        print('📋 [STEP 4.1] Message type: $messageType');
        _logger.d('Received message type: $messageType');

        // Handle different message types based on ElevenLabs Realtime API
        // Docs: https://elevenlabs.io/docs/api-reference/speech-to-text/v-1-speech-to-text-realtime
        switch (messageType) {
          case 'session_started':
            print('✅ Session started: ${data['session_id']}');
            print('   Config: ${data['config']}');
            _logger.i('Session started: ${data['session_id']}');
            break;
          case 'partial_transcript':
            print('💬 Processing partial transcript...');
            _handlePartialTranscript(data);
            break;
          case 'committed_transcript':
            print('✅ Processing committed transcript...');
            _handleCommittedTranscript(data);
            break;
          case 'committed_transcript_with_timestamps':
            print('✅ Processing committed transcript with timestamps...');
            _handleCommittedTranscriptWithTimestamps(data);
            break;
          case 'scribe_error':
          case 'scribe_auth_error':
          case 'scribe_quota_exceeded_error':
          case 'scribe_throttled_error':
          case 'scribe_rate_limited_error':
            print('❌ Processing error message...');
            _handleError(data);
            break;
          default:
            print('❓ Unknown message type: $messageType');
            print('   Full message: $data');
            _logger.d('Unknown message type: $messageType');
        }
      }
    } catch (e) {
      print('❌ Message handling error: $e');
      _logger.e('Message handling error: $e');
    }
  }

  void _handlePartialTranscript(Map<String, dynamic> data) {
    final text = data['text'] ?? '';
    print('📝 [STEP 4.2] PARTIAL TEXT: "$text"');
    
    // Partial transcripts are temporary, don't add to final transcript yet
    // But we can show them in the UI as "typing indicator"
    if (text.toString().isNotEmpty) {
      // Emit partial for UI display
      _partialTranscriptController?.add(text.toString());
      _logger.d('Partial transcript: $text');
    }
  }

  void _handleCommittedTranscript(Map<String, dynamic> data) {
    final text = data['text'] ?? '';
    print('📝 [STEP 4.2] COMMITTED TEXT: "$text"');
    
    if (text.toString().isNotEmpty) {
      _currentTranscript += '$text ';
      _transcriptController?.add(_currentTranscript.trim());
      
      print('📄 [STEP 4.4] Updated transcript (${_currentTranscript.length} chars)');
      
      final labelEntry = {
        'speaker': 'SPEAKER',
        'text': text.toString(),
      };
      _allSpeakerLabels.add(labelEntry);
      _speakerLabelsController?.add(List<Map<String, String>>.from(_allSpeakerLabels));
      
      _logger.d('Committed transcript: $text');
    }
  }

  void _handleCommittedTranscriptWithTimestamps(Map<String, dynamic> data) {
    final text = data['text'] ?? '';
    final words = data['words'] as List?;
    
    print('📝 [STEP 4.2] COMMITTED TEXT WITH TIMESTAMPS: "$text"');
    if (words != null) {
      print('   Words count: ${words.length}');
    }
    
    if (text.toString().isNotEmpty) {
      _currentTranscript += '$text ';
      _transcriptController?.add(_currentTranscript.trim());
      
      print('📄 [STEP 4.4] Updated transcript (${_currentTranscript.length} chars)');
      
      final labelEntry = {
        'speaker': 'SPEAKER',
        'text': text.toString(),
      };
      _allSpeakerLabels.add(labelEntry);
      _speakerLabelsController?.add(List<Map<String, String>>.from(_allSpeakerLabels));
      
      _logger.d('Committed transcript with timestamps: $text');
    }
  }

  void _handleError(Map<String, dynamic> data) {
    final message = data['message'] ?? data['error'] ?? 'Unknown error';
    final messageType = data['message_type'] ?? 'error';
    print('❌ Scribe error ($messageType): $message');
    _logger.e('Scribe error ($messageType): $message');
    _transcriptController?.addError(Exception('$messageType: $message'));
  }

  /// Send audio chunk (PCM 16-bit, 16kHz)
  /// Audio is sent as JSON with base64-encoded audio data
  /// Docs: https://elevenlabs.io/docs/api-reference/speech-to-text/v-1-speech-to-text-realtime
  void sendAudioChunk(Uint8List audioData) {
    try {
      if (_channel != null && _isConnected) {
        // ElevenLabs Realtime API expects audio as base64 in JSON message
        final audioBase64 = base64Encode(audioData);
        final message = {
          'message_type': 'input_audio_chunk',
          'audio_base_64': audioBase64,
        };
        
        print('🔊 [STEP 3.3] Sending audio chunk: ${audioData.length} bytes (base64: ${audioBase64.length} chars)');
        _channel!.sink.add(jsonEncode(message));
      } else {
        print('⚠️  WebSocket not connected! Cannot send audio.');
        print('   _channel: ${_channel != null}, _isConnected: $_isConnected');
        _logger.w('WebSocket not connected, cannot send audio');
      }
    } catch (e) {
      print('❌ Error sending audio: $e');
      _logger.e('Error sending audio: $e');
    }
  }

  /// Manually commit the current transcript (if using manual commit strategy)
  void commitTranscript() {
    if (_channel != null && _isConnected) {
      final message = {
        'message_type': 'commit',
      };
      _channel!.sink.add(jsonEncode(message));
      print('📤 Sent commit signal');
    }
  }

  /// Stop transcription and close connection
  Future<void> stopTranscription() async {
    try {
      print('🛑 Stopping transcription...');
      // Send end-of-stream signal
      if (_channel != null && _isConnected) {
        print('📤 Sending end-of-stream signal');
        _channel!.sink.add(jsonEncode({'type': 'end'}));
      }
      
      await _channel?.sink.close();
      await _transcriptController?.close();
      await _partialTranscriptController?.close();
      await _speakerLabelsController?.close();
      _isConnected = false;
      print('✅ Transcription stopped successfully');
      print('📊 Final stats:');
      print('   - Total transcript length: ${_currentTranscript.length} chars');
      print('   - Speaker segments: ${_allSpeakerLabels.length}');
      _logger.i('Transcription stopped');
    } catch (e) {
      print('❌ Error stopping transcription: $e');
      _logger.e('Error stopping transcription: $e');
    }
  }

  /// Get the final transcript text
  String getFinalTranscript() {
    return _currentTranscript;
  }

  /// Get speaker labels for API submission
  List<Map<String, String>> getSpeakerLabels() {
    return List<Map<String, String>>.from(_allSpeakerLabels);
  }

  // Medical keywords for Scribe v2 keyterm boosting
  static const List<String> _medicalKeyterms = [
    // Diagnoses
    'hypertension', 'diabetes', 'asthma', 'pneumonia', 'covid', 'covid-19',
    'arrhythmia', 'fibrillation', 'bronchitis', 'sinusitis', 'migraine',
    'arthritis', 'osteoporosis', 'anemia', 'thyroid', 'cholesterol',

    // Medications
    'metoprolol', 'lisinopril', 'metformin', 'amoxicillin', 'azithromycin',
    'ibuprofen', 'aspirin', 'atorvastatin', 'omeprazole', 'amlodipine',
    'gabapentin', 'prednisone', 'albuterol', 'losartan', 'hydrochlorothiazide',

    // Procedures
    'ct scan', 'mri', 'x-ray', 'ultrasound', 'ecg', 'ekg',
    'cardiac catheterization', 'endoscopy', 'colonoscopy', 'biopsy',
    'blood test', 'urinalysis', 'chest x-ray',

    // Symptoms
    'fever', 'cough', 'headache', 'fatigue', 'shortness of breath',
    'dyspnea', 'palpitations', 'nausea', 'dizziness', 'chest pain',
    'abdominal pain', 'back pain', 'joint pain', 'swelling',

    // Vital Signs
    'blood pressure', 'heart rate', 'temperature', 'oxygen saturation',
    'respiratory rate', 'pulse', 'weight', 'height', 'bmi',

    // Units
    'milligram', 'milligrams', 'mg', 'mmhg', 'beats per minute', 'bpm',
    'milliliter', 'ml', 'percent', 'degrees', 'celsius', 'fahrenheit',
  ];
}
