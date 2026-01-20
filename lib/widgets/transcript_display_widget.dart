import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Transcript Display Widget
/// Shows real-time transcript with speaker labels

class TranscriptDisplayWidget extends StatelessWidget {
  final String transcript;
  final List<Map<String, String>> speakerSegments;
  final bool isLive;

  const TranscriptDisplayWidget({
    super.key,
    required this.transcript,
    this.speakerSegments = const [],
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(minHeight: 200),
      child: speakerSegments.isEmpty
          ? _buildSimpleTranscript()
          : _buildSpeakerTranscript(),
    );
  }

  Widget _buildSimpleTranscript() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLive)
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.errorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Live',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        if (isLive) const SizedBox(height: 12),
        Text(
          transcript.isEmpty
              ? 'Transcript will appear here as you speak...'
              : transcript,
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: transcript.isEmpty ? Colors.grey : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakerTranscript() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLive)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.errorColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Live Transcription',
                  style: TextStyle(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ...speakerSegments.map((segment) {
          final speaker = segment['speaker'] ?? 'UNKNOWN';
          final text = segment['text'] ?? '';
          final isDoctor = speaker.toUpperCase() == 'DOCTOR';

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
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isDoctor ? 'Dr.' : 'Patient',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDoctor
                          ? AppTheme.primaryColor
                          : AppTheme.successColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
