/// Application Constants
/// Contains all static configuration values for the app

class AppConstants {
  // API Endpoints
  static const String baseUrl = 'http://localhost:5000';
  static const String scribeEndpoint = 'wss://api.elevenlabs.io/v1/speech-to-text/stream';
  
  // API Routes
  static const String createConsultation = '/api/v1/consultation/create';
  static const String finalizeConsultation = '/api/v1/consultation/{id}/finalize';
  static const String getConsultation = '/api/v1/consultation/{id}/get';
  static const String getAuditLogs = '/api/v1/audit-logs/{id}';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Audio Recording Settings
  static const int sampleRate = 16000; // 16kHz for speech
  static const int bitRate = 256000;
  static const int numChannels = 1; // Mono
  
  // App Settings
  static const String appName = 'MediTranscribe Pro';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String encryptionKeyStorage = 'encryption_key';
  static const String userTokenStorage = 'user_token';
  static const String lastSyncStorage = 'last_sync';
  
  // Compliance
  static const List<String> complianceFeatures = [
    'End-to-End Encryption (AES-256)',
    'PII Detection & Redaction',
    'HIPAA Audit Trail',
    'Voice Activity Detection',
    'Zero Data Retention Mode',
  ];
}
