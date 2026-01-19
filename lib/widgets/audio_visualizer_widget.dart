import 'package:flutter/material.dart';

/// Audio Visualizer Widget
/// Displays audio amplitude as animated bars

class AudioVisualizerWidget extends StatelessWidget {
  final double amplitude;
  final int barCount;
  final Color color;
  final double height;

  const AudioVisualizerWidget({
    super.key,
    required this.amplitude,
    this.barCount = 20,
    this.color = Colors.white,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    // Normalize amplitude to 0-1 range (amplitude is typically -160 to 0 dB)
    final normalizedAmp = ((amplitude + 60) / 60).clamp(0.0, 1.0);

    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(barCount, (index) {
          // Create varying heights for visual interest
          final multiplier = (index % 3 + 1) / 3;
          final barHeight = 10 + (normalizedAmp * (height - 10) * multiplier);
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 4,
            height: barHeight,
            decoration: BoxDecoration(
              color: color.withOpacity(0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

/// Circular Audio Visualizer
class CircularAudioVisualizerWidget extends StatelessWidget {
  final double amplitude;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const CircularAudioVisualizerWidget({
    super.key,
    required this.amplitude,
    this.size = 120,
    this.activeColor = Colors.red,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedAmp = ((amplitude + 60) / 60).clamp(0.0, 1.0);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer pulsing ring
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size + (normalizedAmp * 40),
          height: size + (normalizedAmp * 40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: activeColor.withOpacity(0.2 * normalizedAmp),
          ),
        ),
        // Middle ring
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: size + (normalizedAmp * 20),
          height: size + (normalizedAmp * 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: activeColor.withOpacity(0.3 * normalizedAmp),
          ),
        ),
        // Inner circle
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: activeColor,
          ),
          child: const Icon(
            Icons.mic,
            color: Colors.white,
            size: 48,
          ),
        ),
      ],
    );
  }
}
