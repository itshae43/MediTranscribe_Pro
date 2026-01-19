import 'package:intl/intl.dart';

/// Data Formatters
/// Utility functions for formatting data for display

class Formatters {
  /// Format date as readable string
  static String formatDate(DateTime date, {String pattern = 'MMM dd, yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  /// Format time as readable string
  static String formatTime(DateTime time, {bool use24Hour = false}) {
    final pattern = use24Hour ? 'HH:mm' : 'h:mm a';
    return DateFormat(pattern).format(time);
  }

  /// Format date and time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy \'at\' h:mm a').format(dateTime);
  }

  /// Format duration as MM:SS
  static String formatDuration(Duration duration) {
    final mins = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Format duration as human readable
  static String formatDurationReadable(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds} sec';
    } else if (duration.inMinutes < 60) {
      final mins = duration.inMinutes;
      final secs = duration.inSeconds % 60;
      return '$mins min ${secs > 0 ? '$secs sec' : ''}';
    } else {
      final hours = duration.inHours;
      final mins = duration.inMinutes % 60;
      return '$hours hr ${mins > 0 ? '$mins min' : ''}';
    }
  }

  /// Format seconds to MM:SS
  static String formatSeconds(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Format number with commas
  static String formatNumber(num number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  /// Format currency
  static String formatCurrency(num amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.currency(symbol: symbol);
    return formatter.format(amount);
  }

  /// Format percentage
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// Format patient ID for display
  static String formatPatientId(String id) {
    if (id.startsWith('patient_')) {
      return 'P-${id.substring(8).substring(0, 6).toUpperCase()}';
    }
    return id;
  }

  /// Format consultation ID for display
  static String formatConsultationId(String id) {
    if (id.length > 8) {
      return id.substring(0, 8).toUpperCase();
    }
    return id.toUpperCase();
  }

  /// Format transcript for export
  static String formatTranscriptForExport(
    String transcript,
    List<Map<String, String>> speakerLabels,
  ) {
    if (speakerLabels.isEmpty) return transcript;

    final buffer = StringBuffer();
    for (final segment in speakerLabels) {
      final speaker = segment['speaker'] ?? 'Speaker';
      final text = segment['text'] ?? '';
      buffer.writeln('[$speaker]: $text');
      buffer.writeln();
    }
    return buffer.toString();
  }

  /// Remove PII markers for clean display
  static String cleanPIIMarkers(String text) {
    return text
        .replaceAll(RegExp(r'\[SSN_REDACTED\]'), '[REDACTED]')
        .replaceAll(RegExp(r'\[PHONE_REDACTED\]'), '[REDACTED]')
        .replaceAll(RegExp(r'\[EMAIL_REDACTED\]'), '[REDACTED]')
        .replaceAll(RegExp(r'\[DOB_REDACTED\]'), '[REDACTED]');
  }
}
