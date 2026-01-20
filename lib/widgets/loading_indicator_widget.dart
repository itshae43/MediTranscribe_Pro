import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/theme.dart';

/// Loading Indicator Widget
/// Various loading states for the app

class LoadingIndicatorWidget extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingIndicatorWidget({
    super.key,
    this.message,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(strokeWidth: 3),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Full Screen Loading
class FullScreenLoadingWidget extends StatelessWidget {
  final String message;

  const FullScreenLoadingWidget({
    super.key,
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer Loading Card
class ShimmerLoadingCard extends StatelessWidget {
  final double height;

  const ShimmerLoadingCard({
    super.key,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(height: height),
      ),
    );
  }
}

/// Shimmer List Loading
class ShimmerListLoading extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ShimmerListLoading({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerLoadingCard(height: itemHeight),
        );
      },
    );
  }
}

/// Processing Overlay
class ProcessingOverlay extends StatelessWidget {
  final String message;
  final bool show;
  final Widget child;

  const ProcessingOverlay({
    super.key,
    required this.message,
    required this.show,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (show)
          Container(
            color: Colors.black54,
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
