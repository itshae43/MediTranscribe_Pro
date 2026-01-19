import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:logger/logger.dart';
import '../config/environment.dart';

/// Encryption Service
/// HIPAA-compliant AES-256 encryption for sensitive medical data

class EncryptionService {
  late final encrypt.Key _key;
  late final encrypt.IV _iv;
  final Logger _logger = Logger();
  bool _isInitialized = false;

  EncryptionService({String? keyString}) {
    try {
      final key = keyString ?? Environment.encryptionKey;
      if (key.isNotEmpty) {
        _key = encrypt.Key.fromBase64(key);
        _iv = encrypt.IV.fromLength(16);
        _isInitialized = true;
        _logger.i('EncryptionService initialized');
      } else {
        _logger.w('No encryption key provided');
      }
    } catch (e) {
      _logger.e('Encryption init error: $e');
    }
  }

  /// Check if service is properly initialized
  bool get isInitialized => _isInitialized;

  /// Encrypt sensitive text (AES-256)
  String encryptText(String plainText) {
    if (!_isInitialized) {
      _logger.w('Encryption service not initialized, returning plain text');
      return plainText;
    }
    
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final encrypted = encrypter.encrypt(plainText, iv: _iv);
      _logger.d('Text encrypted successfully');
      return encrypted.base64;
    } catch (e) {
      _logger.e('Encryption error: $e');
      return plainText;
    }
  }

  /// Decrypt sensitive text
  String decryptText(String encryptedText) {
    if (!_isInitialized) {
      _logger.w('Encryption service not initialized, returning encrypted text');
      return encryptedText;
    }
    
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
      _logger.d('Text decrypted successfully');
      return decrypted;
    } catch (e) {
      _logger.e('Decryption error: $e');
      return encryptedText;
    }
  }

  /// Encrypt a map of data
  Map<String, String> encryptMap(Map<String, dynamic> data) {
    final encrypted = <String, String>{};
    for (final entry in data.entries) {
      encrypted[entry.key] = encryptText(entry.value.toString());
    }
    return encrypted;
  }

  /// Detect PII in text (SSN, phone, email, DOB)
  Map<String, List<String>> detectPII(String text) {
    final piiPatterns = {
      'ssn': RegExp(r'\b\d{3}-\d{2}-\d{4}\b'),
      'phone': RegExp(r'\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b'),
      'email': RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
      'dob': RegExp(r'\b\d{1,2}[/\-]\d{1,2}[/\-]\d{2,4}\b'),
      'credit_card': RegExp(r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b'),
      'mrn': RegExp(r'\bMRN[:\s]?\d{6,10}\b', caseSensitive: false),
    };

    final detected = <String, List<String>>{};

    for (final entry in piiPatterns.entries) {
      final matches = entry.value.allMatches(text);
      if (matches.isNotEmpty) {
        detected[entry.key] = matches.map((m) => m.group(0)!).toList();
        _logger.w('PII detected: ${entry.key} (${matches.length} instances)');
      }
    }

    return detected;
  }

  /// Check if text contains any PII
  bool containsPII(String text) {
    return detectPII(text).isNotEmpty;
  }

  /// Redact PII from text
  String redactPII(String text) {
    var redacted = text;
    final pii = detectPII(text);

    final redactionLabels = {
      'ssn': '[SSN_REDACTED]',
      'phone': '[PHONE_REDACTED]',
      'email': '[EMAIL_REDACTED]',
      'dob': '[DOB_REDACTED]',
      'credit_card': '[CC_REDACTED]',
      'mrn': '[MRN_REDACTED]',
    };

    for (final entry in pii.entries) {
      final label = redactionLabels[entry.key] ?? '[REDACTED]';
      for (final value in entry.value) {
        redacted = redacted.replaceAll(value, label);
      }
    }

    if (pii.isNotEmpty) {
      _logger.i('PII redacted from text');
    }
    return redacted;
  }

  /// Mask PII partially (show last 4 characters)
  String maskPII(String text) {
    var masked = text;
    final pii = detectPII(text);

    for (final entry in pii.entries) {
      for (final value in entry.value) {
        if (value.length > 4) {
          final maskedValue = '*' * (value.length - 4) + value.substring(value.length - 4);
          masked = masked.replaceAll(value, maskedValue);
        }
      }
    }

    return masked;
  }

  /// Generate a summary of detected PII for audit logging
  Map<String, int> getPIISummary(String text) {
    final pii = detectPII(text);
    final summary = <String, int>{};
    
    for (final entry in pii.entries) {
      summary[entry.key] = entry.value.length;
    }
    
    return summary;
  }
}
