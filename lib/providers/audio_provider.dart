import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';

/// Audio Provider
/// Manages audio recording state using Riverpod

// Audio service provider
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

// Recording state provider
final recordingStateProvider = StateNotifierProvider<RecordingStateNotifier, RecordingState>((ref) {
  return RecordingStateNotifier(ref);
});

/// Recording State
class RecordingState {
  final bool isRecording;
  final bool isPaused;
  final int durationSeconds;
  final double amplitude;
  final String? recordingPath;
  final String? error;

  const RecordingState({
    this.isRecording = false,
    this.isPaused = false,
    this.durationSeconds = 0,
    this.amplitude = 0,
    this.recordingPath,
    this.error,
  });

  RecordingState copyWith({
    bool? isRecording,
    bool? isPaused,
    int? durationSeconds,
    double? amplitude,
    String? recordingPath,
    String? error,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      isPaused: isPaused ?? this.isPaused,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      amplitude: amplitude ?? this.amplitude,
      recordingPath: recordingPath ?? this.recordingPath,
      error: error,
    );
  }

  /// Get formatted duration string
  String get formattedDuration {
    final mins = durationSeconds ~/ 60;
    final secs = durationSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

/// Recording State Notifier
class RecordingStateNotifier extends StateNotifier<RecordingState> {
  final Ref _ref;
  DateTime? _recordingStartTime;

  RecordingStateNotifier(this._ref) : super(const RecordingState());

  /// Start recording
  Future<bool> startRecording({Function(Uint8List)? onAudioChunk}) async {
    final audioService = _ref.read(audioServiceProvider);
    
    final success = await audioService.startRecording(
      onAudioChunk: onAudioChunk,
    );
    
    if (success) {
      _recordingStartTime = DateTime.now();
      state = state.copyWith(
        isRecording: true,
        isPaused: false,
        durationSeconds: 0,
        error: null,
      );
      _startDurationTimer();
    } else {
      state = state.copyWith(
        error: 'Failed to start recording. Check microphone permission.',
      );
    }
    
    return success;
  }

  /// Stop recording
  Future<String?> stopRecording() async {
    final audioService = _ref.read(audioServiceProvider);
    final path = await audioService.stopRecording();
    
    state = state.copyWith(
      isRecording: false,
      isPaused: false,
      recordingPath: path,
    );
    
    return path;
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    final audioService = _ref.read(audioServiceProvider);
    await audioService.pauseRecording();
    state = state.copyWith(isPaused: true);
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    final audioService = _ref.read(audioServiceProvider);
    await audioService.resumeRecording();
    state = state.copyWith(isPaused: false);
  }

  /// Update amplitude
  void updateAmplitude(double amplitude) {
    state = state.copyWith(amplitude: amplitude);
  }

  /// Update duration
  void updateDuration(int seconds) {
    state = state.copyWith(durationSeconds: seconds);
  }

  /// Reset state
  void reset() {
    state = const RecordingState();
  }

  /// Start duration timer
  void _startDurationTimer() {
    Future.delayed(const Duration(seconds: 1)).then((_) {
      if (state.isRecording && !state.isPaused) {
        state = state.copyWith(
          durationSeconds: state.durationSeconds + 1,
        );
        _startDurationTimer();
      }
    });
  }

  /// Get audio bytes
  Future<List<int>> getAudioBytes() async {
    final audioService = _ref.read(audioServiceProvider);
    return await audioService.getNewAudioBytes();
  }
}

/// Amplitude stream provider
final amplitudeProvider = StreamProvider<double>((ref) async* {
  final audioService = ref.watch(audioServiceProvider);
  
  while (true) {
    await Future.delayed(const Duration(milliseconds: 100));
    final amplitude = await audioService.getAmplitude();
    yield amplitude;
  }
});
