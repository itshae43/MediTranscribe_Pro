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

class _RecordingScreenState extends ConsumerState<RecordingScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Auto-start recording when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRecording();
    });
  }

  Future<void> _startRecording() async {
    final recordingNotifier = ref.read(recordingStateProvider.notifier);
    final transcriptNotifier = ref.read(transcriptStateProvider.notifier);
    final scribeService = ref.read(scribeServiceProvider);

    try {
      await transcriptNotifier.startTranscription(
        keyTerms: ['hypertension', 'diabetes', 'medication', 'treatment'],
      );
      
      final success = await recordingNotifier.startRecording(
        onAudioChunk: (bytes) {
          scribeService.sendAudioChunk(bytes);
        },
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start recording')),
        );
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    final recordingNotifier = ref.read(recordingStateProvider.notifier);
    final transcriptNotifier = ref.read(transcriptStateProvider.notifier);

    await recordingNotifier.stopRecording();
    await transcriptNotifier.stopTranscription();
  }

  Future<void> _finalizeConsultation() async {
    await _stopRecording();
    
    if (!mounted) return;

    final transcriptState = ref.read(transcriptStateProvider);
    final consultationNotifier = ref.read(currentConsultationProvider.notifier);

    consultationNotifier.updateTranscript(transcriptState.transcript);
    await consultationNotifier.finalize();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => NotesScreen(consultationId: widget.consultationId),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stopRecording();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingStateProvider);
    final transcriptState = ref.watch(transcriptStateProvider);
    final amplitudeAsync = ref.watch(amplitudeProvider);

    // Auto-scroll to bottom when new content arrives
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Live Consultation',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Timer Section
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                // Recording Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeTransition(
                        opacity: _pulseController,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'RECORDING...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Big Timer
                Text(
                  recordingState.formattedDuration,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Monospace', // Keep monospace for timer stability
                    letterSpacing: -1,
                  ),
                ),
                
                // Visualizer
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: _buildWaveform(amplitudeAsync),
                ),
              ],
            ),
          ),

          // Transcript Area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Date Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'STARTED ${TimeOfDay.now().format(context)}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  
                  // List
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                      itemCount: transcriptState.speakerSegments.length + (transcriptState.partialTranscript.isNotEmpty ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Handle partial transcript item (last item)
                        if (index == transcriptState.speakerSegments.length) {
                          return _buildTranscriptItem(
                            speaker: 'LISTENING',
                            text: transcriptState.partialTranscript,
                            isPartial: true,
                          );
                        }

                        // Handle finalized segments
                        final segment = transcriptState.speakerSegments[index];
                        // Heuristic mapping: Speaker 0/A -> Doctor, Speaker 1/B -> Patient
                        // For now we trust the service, but let's override based on label if it's generic
                        String displaySpeaker = segment.speaker;
                        if (displaySpeaker == '0' || displaySpeaker == 'A' || displaySpeaker == 'SPEAKER_00') {
                          displaySpeaker = 'DOCTOR';
                        } else if (displaySpeaker == '1' || displaySpeaker == 'B' || displaySpeaker == 'SPEAKER_01') {
                          displaySpeaker = 'PATIENT';
                        } else if (displaySpeaker == 'SPEAKER') {
                           // Keep generic if unknown
                        }

                        return _buildTranscriptItem(
                          speaker: displaySpeaker,
                          text: segment.text,
                          timestamp: _formatTimestamp(segment.timestamp),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Controls (Now part of body for better layout control)
          Container(
            color: const Color(0xFFF8FAFC), // Match background of transcript
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Security Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock, size: 12, color: Color(0xFF00C853)),
                        const SizedBox(width: 6),
                        Text(
                          'HIPAA Secure & Encrypted 256-bit',
                          style: TextStyle(
                            color: const Color(0xFF00C853).withOpacity(0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Controls
                    Row(
                      children: [
                        // Pause Button
                        InkWell(
                          onTap: recordingState.isPaused
                              ? ref.read(recordingStateProvider.notifier).resumeRecording
                              : ref.read(recordingStateProvider.notifier).pauseRecording,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              recordingState.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                              color: AppTheme.primaryColor,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Stop Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _finalizeConsultation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.warningColor, // Orange
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.stop, color: AppTheme.warningColor, size: 16),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'STOP RECORDING',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // bottomSheet removed
    );
  }

  Widget _buildTranscriptItem({
    required String speaker,
    required String text,
    String? timestamp,
    bool isPartial = false,
  }) {
    final isDoctor = speaker.toUpperCase() == 'DOCTOR' || speaker.toUpperCase().contains('DOC'); // Loose matching
    // Use the reference design colors
    final labelBgColor = isDoctor ? AppTheme.primaryColor.withOpacity(0.1) : (isPartial ? Colors.grey[100] : AppTheme.backgroundColor);
    final labelColor = isDoctor ? AppTheme.primaryColor : (isPartial ? Colors.grey : AppTheme.textSecondary);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Speaker Label Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: labelBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '[${speaker.toUpperCase()}]',
                  style: TextStyle(
                    color: labelColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (timestamp != null) ...[
                const SizedBox(width: 12),
                Text(
                  timestamp,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              color: isPartial ? Colors.grey[500] : const Color(0xFF1E293B), // Darker slate for better readability
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w400,
              fontStyle: isPartial ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform(AsyncValue<double> amplitudeAsync) {
    final amplitude = amplitudeAsync.when(
      data: (val) => val,
      loading: () => -160.0,
      error: (_, __) => -160.0,
    );

    // Normalize amplitude to 0-1 range
    final normalizedAmp = ((amplitude + 60) / 60).clamp(0.0, 1.0);
    
    // Use the pulse controller to add some "breathing" even when silent
    // and random factors for dynamic feel
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(24, (index) {
            // Create a symmetric wave effect from center
            final distanceFromCenter = (index - 11.5).abs();
            
            // Base "breathing" height
            final breathing = 8.0 + (_pulseController.value * 4);
            
            // Dynamic height based on amplitude
            // Add some randomness per bar to make it look organic
            final randomFactor = (index * 7 % 3) * 2.0; 
            
            final variableHeight = 40.0 * normalizedAmp * (1 - (distanceFromCenter / 14));
            
            final height = (breathing + variableHeight - randomFactor).clamp(4.0, 48.0);
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 4,
              height: height,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }
}

