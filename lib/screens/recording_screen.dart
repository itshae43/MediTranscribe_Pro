import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/audio_provider.dart';
import '../providers/transcript_provider.dart';
import '../providers/consultation_provider.dart';
import '../services/scribe_service.dart';
import '../config/environment.dart';
import 'notes_screen.dart';

/// Recording Screen
/// Main recording UI with real-time transcription display

class RecordingScreen extends ConsumerStatefulWidget {
  final String consultationId;

  const RecordingScreen({
    super.key,
    required this.consultationId,
  });

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> {


  @override
  void initState() {
    super.initState();
  }

  Future<void> _startRecording() async {
    final recordingNotifier = ref.read(recordingStateProvider.notifier);
    final transcriptNotifier = ref.read(transcriptStateProvider.notifier);
    final scribeService = ref.read(scribeServiceProvider);
    
    try {
      // Start transcription service and WAIT for WebSocket connection
      print('🎤 Starting transcription service...');
      await transcriptNotifier.startTranscription(
        keyTerms: ['hypertension', 'diabetes', 'medication', 'treatment'],
      );
      print('✅ Transcription service connected');
      
      // Now start audio recording with callback to send to Scribe
      final success = await recordingNotifier.startRecording(
        onAudioChunk: (bytes) {
          scribeService.sendAudioChunk(bytes);
        },
      );
      
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start recording. Please check microphone permission.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect to transcription service: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    final recordingNotifier = ref.read(recordingStateProvider.notifier);
    final transcriptNotifier = ref.read(transcriptStateProvider.notifier);
    
    await recordingNotifier.stopRecording();
    await transcriptNotifier.stopTranscription();
  }

  Future<void> _finalizeConsultation() async {
    final transcriptState = ref.read(transcriptStateProvider);
    final consultationNotifier = ref.read(currentConsultationProvider.notifier);
    
    // Update consultation with transcript
    consultationNotifier.updateTranscript(transcriptState.transcript);
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating clinical notes...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    // Simulate note generation (in real app, call backend)
    await Future.delayed(const Duration(seconds: 2));
    
    // Finalize
    await consultationNotifier.finalize();
    
    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      
      // Navigate to notes screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => NotesScreen(consultationId: widget.consultationId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingStateProvider);
    final transcriptState = ref.watch(transcriptStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏥 Recording Session'),
        centerTitle: true,
        backgroundColor: recordingState.isRecording 
            ? AppTheme.recordingActive 
            : AppTheme.primaryColor,
        actions: [
          if (recordingState.isRecording)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: const Row(
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text('LIVE', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Recording Section
            _buildRecordingSection(recordingState)
                .animate()
                .fadeIn(duration: 400.ms),
            
            // Live Transcript Section
            _buildTranscriptSection(transcriptState)
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms),
            
            // Compliance Section
            _buildComplianceSection()
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms),
            
            // Action Buttons
            _buildActionButtons(recordingState, transcriptState)
                .animate()
                .fadeIn(delay: 600.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingSection(RecordingState recordingState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: recordingState.isRecording
              ? [AppTheme.recordingActive, AppTheme.recordingActive.withOpacity(0.8)]
              : [AppTheme.primaryColor, AppTheme.primaryColorDark],
        ),
      ),
      child: Column(
        children: [
          // Timer Display
          Text(
            recordingState.formattedDuration,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 64,
                ),
          ),
          
          const SizedBox(height: 8),
          
          // Status Text
          Text(
            recordingState.isRecording 
                ? (recordingState.isPaused ? 'Paused' : 'Recording...')
                : 'Ready to Record',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Audio Visualizer (simplified)
          if (recordingState.isRecording)
            _buildAudioVisualizer(recordingState.amplitude),
          
          const SizedBox(height: 24),
          
          // Record/Stop Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Record/Stop Button
              GestureDetector(
                onTap: recordingState.isRecording ? _stopRecording : _startRecording,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    recordingState.isRecording ? Icons.stop : Icons.mic,
                    size: 40,
                    color: recordingState.isRecording 
                        ? AppTheme.recordingActive 
                        : AppTheme.primaryColor,
                  ),
                ),
              ),
              
              if (recordingState.isRecording) ...[
                const SizedBox(width: 24),
                // Pause/Resume Button
                GestureDetector(
                  onTap: recordingState.isPaused
                      ? ref.read(recordingStateProvider.notifier).resumeRecording
                      : ref.read(recordingStateProvider.notifier).pauseRecording,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      recordingState.isPaused ? Icons.play_arrow : Icons.pause,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            recordingState.isRecording ? 'Tap to stop' : 'Tap to start recording',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioVisualizer(double amplitude) {
    // Normalize amplitude to 0-1 range
    final normalizedAmp = ((amplitude + 60) / 60).clamp(0.0, 1.0);
    
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(20, (index) {
          final height = 10 + (normalizedAmp * 30 * ((index % 3) + 1) / 3);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 4,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scaleY(
                begin: 0.5,
                end: 1.0,
                duration: Duration(milliseconds: 300 + (index * 50)),
              )
              .then()
              .scaleY(begin: 1.0, end: 0.5);
        }),
      ),
    );
  }

  Widget _buildTranscriptSection(TranscriptState transcriptState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📝 Live Transcript',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${transcriptState.wordCount} words',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(minHeight: 200, maxHeight: 400),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: transcriptState.speakerSegments.isEmpty
                  ? Text(
                      transcriptState.transcript.isEmpty
                          ? 'Transcript will appear here as you speak...'
                          : transcriptState.transcript,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: transcriptState.transcript.isEmpty
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: transcriptState.speakerSegments.map((segment) {
                        final isDoctor = segment.speaker == 'DOCTOR';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDoctor
                                      ? Colors.blue.shade100
                                      : Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isDoctor ? 'Dr.' : 'Patient',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDoctor
                                        ? Colors.blue.shade800
                                        : Colors.green.shade800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  segment.text,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔒 Compliance & Security',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: AppConstants.complianceFeatures.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    RecordingState recordingState,
    TranscriptState transcriptState,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Finalize Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: recordingState.isRecording || transcriptState.transcript.isEmpty
                  ? null
                  : _finalizeConsultation,
              icon: const Icon(Icons.check),
              label: const Text('✅ Finalize & Generate Notes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                if (recordingState.isRecording) {
                  _stopRecording();
                }
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Stop transcription when leaving the screen
    ref.read(transcriptStateProvider.notifier).stopTranscription();
    super.dispose();
  }
}
