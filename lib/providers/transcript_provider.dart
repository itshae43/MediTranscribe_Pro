import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/scribe_service.dart';
import '../config/environment.dart';

/// Transcript Provider
/// Manages real-time transcription state using Riverpod

// Scribe service provider
final scribeServiceProvider = Provider<ScribeService>((ref) {
  return ScribeService(apiKey: Environment.elevenLabsApiKey);
});

// Transcript state provider
final transcriptStateProvider = StateNotifierProvider<TranscriptStateNotifier, TranscriptState>((ref) {
  return TranscriptStateNotifier(ref);
});

/// Transcript State
class TranscriptState {
  final bool isTranscribing;
  final String transcript;
  final String partialTranscript;
  final List<SpeakerSegment> speakerSegments;
  final String? error;

  const TranscriptState({
    this.isTranscribing = false,
    this.transcript = '',
    this.partialTranscript = '',
    this.speakerSegments = const [],
    this.error,
  });

  TranscriptState copyWith({
    bool? isTranscribing,
    String? transcript,
    String? partialTranscript,
    List<SpeakerSegment>? speakerSegments,
    String? error,
  }) {
    return TranscriptState(
      isTranscribing: isTranscribing ?? this.isTranscribing,
      transcript: transcript ?? this.transcript,
      partialTranscript: partialTranscript ?? this.partialTranscript,
      speakerSegments: speakerSegments ?? this.speakerSegments,
      error: error,
    );
  }

  /// Get formatted transcript with speaker labels
  String get formattedTranscript {
    if (speakerSegments.isEmpty) return transcript;
    
    final buffer = StringBuffer();
    for (final segment in speakerSegments) {
      buffer.writeln('[${segment.speaker}]: ${segment.text}');
    }
    return buffer.toString();
  }

  /// Get doctor segments only
  List<SpeakerSegment> get doctorSegments =>
      speakerSegments.where((s) => s.speaker == 'DOCTOR').toList();

  /// Get patient segments only
  List<SpeakerSegment> get patientSegments =>
      speakerSegments.where((s) => s.speaker == 'PATIENT').toList();

  /// Get word count
  int get wordCount =>
      transcript.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
}

/// Speaker Segment
class SpeakerSegment {
  final String speaker;
  final String text;
  final DateTime timestamp;

  SpeakerSegment({
    required this.speaker,
    required this.text,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, String> toMap() => {
        'speaker': speaker,
        'text': text,
      };
}

/// Transcript State Notifier
class TranscriptStateNotifier extends StateNotifier<TranscriptState> {
  final Ref _ref;
  Map<String, Stream>? _streams;

  TranscriptStateNotifier(this._ref) : super(const TranscriptState());

  /// Start transcription - NOW ASYNC to wait for WebSocket connection
  Future<void> startTranscription({List<String> keyTerms = const []}) async {
    final scribeService = _ref.read(scribeServiceProvider);
    
    // Await the WebSocket connection before proceeding
    _streams = await scribeService.startTranscription(keyTerms: keyTerms);
    
    state = state.copyWith(
      isTranscribing: true,
      transcript: '',
      partialTranscript: '',
      speakerSegments: [],
      error: null,
    );

    // Listen to transcript stream (committed)
    _streams?['transcript']?.listen(
      (transcript) {
        state = state.copyWith(
          transcript: transcript,
          partialTranscript: '', // Clear partial when committed
        );
      },
      onError: (error) {
        state = state.copyWith(error: error.toString());
      },
    );

    // Listen to partial transcript stream
    _streams?['partialTranscript']?.listen(
      (partial) {
        state = state.copyWith(partialTranscript: partial);
      },
      onError: (error) {
        // Log error but don't stop flow
        print('Partial transcript error: $error');
      },
    );

    // Listen to speaker labels stream
    _streams?['speakerLabels']?.listen(
      (labels) {
        final segments = (labels as List).map((l) {
          final map = l as Map<String, String>;
          return SpeakerSegment(
            speaker: map['speaker'] ?? 'UNKNOWN',
            text: map['text'] ?? '',
          );
        }).toList();
        
        state = state.copyWith(speakerSegments: segments);
      },
      onError: (error) {
        // Handle error
      },
    );
  }

  /// Stop transcription
  Future<void> stopTranscription() async {
    final scribeService = _ref.read(scribeServiceProvider);
    await scribeService.stopTranscription();
    
    state = state.copyWith(isTranscribing: false);
  }

  /// Add text to transcript manually
  void appendTranscript(String text, {String speaker = 'UNKNOWN'}) {
    final segment = SpeakerSegment(speaker: speaker, text: text);
    state = state.copyWith(
      transcript: '${state.transcript}\n[$speaker]: $text',
      speakerSegments: [...state.speakerSegments, segment],
    );
  }

  /// Clear transcript
  void clear() {
    state = const TranscriptState();
  }

  /// Get transcript for API submission
  String getTranscriptText() {
    return state.transcript;
  }

  /// Get speaker labels for API submission
  List<Map<String, String>> getSpeakerLabels() {
    return state.speakerSegments.map((s) => s.toMap()).toList();
  }
}

/// Real-time word count provider
final wordCountProvider = Provider<int>((ref) {
  final transcript = ref.watch(transcriptStateProvider);
  return transcript.wordCount;
});

/// Transcription status provider
final isTranscribingProvider = Provider<bool>((ref) {
  return ref.watch(transcriptStateProvider).isTranscribing;
});
