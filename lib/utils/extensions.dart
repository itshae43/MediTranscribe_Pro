/// String Extensions
extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - 3)}...';
  }

  /// Check if string is valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Check if string is valid phone
  bool get isValidPhone {
    return RegExp(r'^\d{10}$').hasMatch(replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  /// Remove extra whitespace
  String get trimmed {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Convert to slug
  String get slug {
    return toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }
}

/// DateTime Extensions
extension DateTimeExtensions on DateTime {
  /// Format as readable date
  String get formattedDate {
    return '$day/$month/$year';
  }

  /// Format as readable time
  String get formattedTime {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Format as readable date and time
  String get formattedDateTime {
    return '$formattedDate at $formattedTime';
  }

  /// Get relative time string
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays ~/ 7}w ago';
    } else {
      return formattedDate;
    }
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Get start of day
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59);
  }
}

/// Duration Extensions
extension DurationExtensions on Duration {
  /// Format as MM:SS
  String get formatted {
    final mins = inMinutes;
    final secs = inSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Format as human readable
  String get humanReadable {
    if (inSeconds < 60) {
      return '$inSeconds seconds';
    } else if (inMinutes < 60) {
      return '$inMinutes min ${inSeconds % 60} sec';
    } else {
      return '$inHours hr ${inMinutes % 60} min';
    }
  }
}

/// List Extensions
extension ListExtensions<T> on List<T> {
  /// Get first or null
  T? get firstOrNull {
    return isEmpty ? null : first;
  }

  /// Get last or null
  T? get lastOrNull {
    return isEmpty ? null : last;
  }

  /// Safe element at index
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}

/// Num Extensions
extension NumExtensions on num {
  /// Format as file size
  String get fileSize {
    if (this < 1024) {
      return '${toStringAsFixed(0)} B';
    } else if (this < 1024 * 1024) {
      return '${(this / 1024).toStringAsFixed(1)} KB';
    } else if (this < 1024 * 1024 * 1024) {
      return '${(this / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
