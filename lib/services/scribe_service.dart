import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logger/logger.dart';
import '../config/environment.dart';

/// Scribe V2 Service
/// Handles real-time speech-to-text transcription using ElevenLabs Scribe v2 API

class ScribeService {
  final String apiKey;
  final Logger _logger = Logger();

  WebSocketChannel? _channel;
  StreamController<String>? _transcriptController;
  StreamController<List<Map<String, String>>>? _speakerLabelsController;
  
  bool _isConnected = false;
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
  /// Returns: Map with 'transcript' and 'speakerLabels' streams
  Map<String, Stream> startTranscription({
    List<String> keyTerms = const [],
    String languageCode = 'en',
  }) {
    _transcriptController = StreamController<String>.broadcast();
    _speakerLabelsController = StreamController<List<Map<String, String>>>.broadcast();
    _currentTranscript = '';
    _allSpeakerLabels.clear();

    _connectWebSocket(keyTerms, languageCode);

    return {
      'transcript': _transcriptController!.stream,
      'speakerLabels': _speakerLabelsController!.stream,
    };
  }

  void _connectWebSocket(List<String> keyTerms, String languageCode) {
    try {
      final endpoint = Environment.scribeEndpoint;
      _logger.i('Connecting to Scribe v2: $endpoint');

      // Build WebSocket URL with query parameters
      final uri = Uri.parse(endpoint).replace(queryParameters: {
        'model': 'scribe_v1',
        'language_code': languageCode,
      });

      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      // Send initialization config
      final config = {
        'type': 'config',
        'api_key': apiKey,
        'text_encoding': 'utf-8',
        'try_numerals': true,
        'language_code': languageCode,
        'enable_voice_activity_detection': true,
        'enable_speaker_diarization': true,
        'num_speakers': 2, // Doctor and Patient
        if (keyTerms.isNotEmpty) 'keyterm_boost': keyTerms else 'keyterm_boost': _medicalKeyterms,
      };

      _channel!.sink.add(jsonEncode(config));
      _logger.i('Scribe v2 config sent');

      // Listen for messages
      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          _logger.e('WebSocket error: $error');
          _transcriptController?.addError(error);
          _speakerLabelsController?.addError(error);
          _isConnected = false;
        },
        onDone: () {
          _logger.i('WebSocket closed');
          _isConnected = false;
        },
      );
    } catch (e) {
      _logger.e('Connection error: $e');
      _transcriptController?.addError(e);
      _speakerLabelsController?.addError(e);
      _isConnected = false;
    }
  }

  void _handleMessage(dynamic message) {
    try {
      if (message is String) {
        final data = jsonDecode(message);
        _logger.d('Received message type: ${data['type']}');

        // Handle different message types
        switch (data['type']) {
          case 'transcript':
          case 'transcription':
            _handleTranscript(data);
            break;
          case 'final':
            _handleFinalTranscript(data);
            break;
          case 'error':
            _handleError(data);
            break;
          default:
            _logger.d('Unknown message type: ${data['type']}');
        }
      }
    } catch (e) {
      _logger.e('Message handling error: $e');
    }
  }

  void _handleTranscript(Map<String, dynamic> data) {
    final text = data['text'] ?? data['transcription'] ?? '';
    final speaker = data['speaker']?.toString().toUpperCase() ?? 'UNKNOWN';
    
    if (text.toString().isNotEmpty) {
      // Determine speaker based on index if available
      String speakerLabel = speaker;
      if (data['speaker_id'] != null) {
        speakerLabel = data['speaker_id'] == 0 ? 'DOCTOR' : 'PATIENT';
      }
      
      _currentTranscript += '[$speakerLabel]: $text\n';
      _transcriptController?.add(_currentTranscript);
      
      final labelEntry = {
        'speaker': speakerLabel,
        'text': text.toString(),
      };
      _allSpeakerLabels.add(labelEntry);
      _speakerLabelsController?.add(List<Map<String, String>>.from(_allSpeakerLabels));
      
      _logger.d('Transcript updated: $speakerLabel -> $text');
    }
  }

  void _handleFinalTranscript(Map<String, dynamic> data) {
    final text = data['text'] ?? data['transcription'] ?? '';
    if (text.toString().isNotEmpty) {
      _logger.i('Final transcript received: ${text.toString().length} chars');
    }
  }

  void _handleError(Map<String, dynamic> data) {
    final error = data['message'] ?? data['error'] ?? 'Unknown error';
    _logger.e('Scribe v2 error: $error');
    _transcriptController?.addError(Exception(error));
  }

  /// Send audio chunk (PCM 16-bit, 16kHz)
  void sendAudioChunk(Uint8List audioData) {
    try {
      if (_channel != null && _isConnected) {
        _channel!.sink.add(audioData);
      } else {
        _logger.w('WebSocket not connected, cannot send audio');
      }
    } catch (e) {
      _logger.e('Error sending audio: $e');
    }
  }

  /// Send audio bytes as base64 (alternative method)
  void sendAudioBase64(String base64Audio) {
    try {
      if (_channel != null && _isConnected) {
        final message = jsonEncode({
          'type': 'audio',
          'audio': base64Audio,
        });
        _channel!.sink.add(message);
      }
    } catch (e) {
      _logger.e('Error sending base64 audio: $e');
    }
  }

  /// Stop transcription and close connection
  Future<void> stopTranscription() async {
    try {
      // Send end-of-stream signal
      if (_channel != null && _isConnected) {
        _channel!.sink.add(jsonEncode({'type': 'end'}));
      }
      
      await _channel?.sink.close();
      await _transcriptController?.close();
      await _speakerLabelsController?.close();
      _isConnected = false;
      _logger.i('Transcription stopped');
    } catch (e) {
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
