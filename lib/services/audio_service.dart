import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

/// Audio Recording Service
/// Handles microphone recording with optimal settings for medical transcription

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final Logger _logger = Logger();

  String? _recordingPath;
  final List<int> _audioBuffer = [];
  bool _isRecording = false;
  DateTime? _recordingStartTime;
  
  StreamController<Uint8List>? _audioStreamController;
  Timer? _audioChunkTimer;

  /// Check if currently recording
  bool get isRecording => _isRecording;
  
  /// Get recording path
  String? get recordingPath => _recordingPath;
  
  /// Get audio stream for real-time processing
  Stream<Uint8List>? get audioStream => _audioStreamController?.stream;

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      _logger.i('Microphone permission: $status');
      return status.isGranted;
    } catch (e) {
      _logger.e('Permission request error: $e');
      return false;
    }
  }

  /// Check if microphone permission is granted
  Future<bool> hasMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Start audio recording with optimal settings for speech
  Future<bool> startRecording({Function(Uint8List)? onAudioChunk}) async {
    try {
      // Check permission first
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) {
        _logger.w('Microphone permission not granted');
        return false;
      }

      // Check if already recording
      if (await _recorder.isRecording()) {
        _logger.w('Already recording');
        return false;
      }

      // Get recording path
      _recordingPath = await _getRecordingPath();
      
      // Initialize stream controller
      _audioStreamController = StreamController<Uint8List>.broadcast();

      // Start recording with medical-grade settings
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits, // PCM format for Scribe v2
          sampleRate: 16000,               // 16kHz recommended for speech
          numChannels: 1,                   // Mono
          bitRate: 256000,                  // High quality
        ),
        path: _recordingPath!,
      );

      _audioBuffer.clear();
      _isRecording = true;
      _recordingStartTime = DateTime.now();
      
      // Start periodic audio chunk reading for streaming
      if (onAudioChunk != null) {
        _startAudioStreaming(onAudioChunk);
      }
      
      _logger.i('Recording started: $_recordingPath');
      return true;
    } catch (e) {
      _logger.e('Recording start error: $e');
      return false;
    }
  }

  /// Start streaming audio chunks for real-time transcription
  void _startAudioStreaming(Function(Uint8List) onAudioChunk) {
    _audioChunkTimer = Timer.periodic(
      const Duration(milliseconds: 250), // 250ms chunks for low latency
      (timer) async {
        if (!_isRecording) {
          timer.cancel();
          return;
        }
        
        final bytes = await getNewAudioBytes();
        if (bytes.isNotEmpty) {
          final uint8Bytes = Uint8List.fromList(bytes);
          onAudioChunk(uint8Bytes);
          _audioStreamController?.add(uint8Bytes);
        }
      },
    );
  }

  /// Get new audio bytes since last call (for streaming to Scribe v2)
  Future<List<int>> getNewAudioBytes() async {
    try {
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();

          // Return only new bytes since last call
          if (bytes.length > _audioBuffer.length) {
            final newBytes = bytes.sublist(_audioBuffer.length);
            _audioBuffer.addAll(newBytes);
            return newBytes;
          }
        }
      }
    } catch (e) {
      _logger.e('Error getting audio bytes: $e');
    }
    return [];
  }

  /// Get all recorded audio bytes
  Future<Uint8List?> getAllAudioBytes() async {
    try {
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      }
    } catch (e) {
      _logger.e('Error getting all audio bytes: $e');
    }
    return null;
  }

  /// Stop recording and return path
  Future<String?> stopRecording() async {
    try {
      _audioChunkTimer?.cancel();
      _audioChunkTimer = null;
      
      final path = await _recorder.stop();
      _recordingPath = path;
      _isRecording = false;
      
      await _audioStreamController?.close();
      _audioStreamController = null;
      
      _logger.i('Recording stopped: $path');
      return path;
    } catch (e) {
      _logger.e('Recording stop error: $e');
      return null;
    }
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    try {
      await _recorder.pause();
      _logger.i('Recording paused');
    } catch (e) {
      _logger.e('Pause error: $e');
    }
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    try {
      await _recorder.resume();
      _logger.i('Recording resumed');
    } catch (e) {
      _logger.e('Resume error: $e');
    }
  }

  /// Check if recorder is paused
  Future<bool> isPaused() async {
    try {
      return await _recorder.isPaused();
    } catch (e) {
      _logger.e('Error checking pause status: $e');
      return false;
    }
  }

  /// Get recording duration
  Duration? getRecordingDuration() {
    if (_recordingStartTime != null && _isRecording) {
      return DateTime.now().difference(_recordingStartTime!);
    }
    return null;
  }

  /// Get recording duration from file size
  Future<Duration?> getRecordingDurationFromFile() async {
    try {
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          // PCM 16-bit at 16kHz = 32,000 bytes per second
          final seconds = bytes.length ~/ 32000;
          return Duration(seconds: seconds);
        }
      }
    } catch (e) {
      _logger.e('Error getting duration: $e');
    }
    return null;
  }

  /// Get amplitude for visualization
  Future<double> getAmplitude() async {
    try {
      final amplitude = await _recorder.getAmplitude();
      return amplitude.current;
    } catch (e) {
      return -160.0; // Minimum amplitude
    }
  }

  /// Delete recording file
  Future<bool> deleteRecording() async {
    try {
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
          _logger.i('Recording deleted: $_recordingPath');
          _recordingPath = null;
          return true;
        }
      }
    } catch (e) {
      _logger.e('Delete error: $e');
    }
    return false;
  }

  /// Clean up resources
  Future<void> dispose() async {
    try {
      _audioChunkTimer?.cancel();
      await _audioStreamController?.close();
      await _recorder.dispose();
      _logger.i('AudioService disposed');
    } catch (e) {
      _logger.e('Disposal error: $e');
    }
  }

  Future<String> _getRecordingPath() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    Directory? tempDir;
    
    try {
      tempDir = await getTemporaryDirectory();
    } catch (e) {
      tempDir = Directory.systemTemp;
    }
    
    return '${tempDir.path}/meditranscribe_audio_$timestamp.wav';
  }
}
