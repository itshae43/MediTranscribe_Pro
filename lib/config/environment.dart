import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment Configuration
/// Manages environment-specific variables loaded from .env file

class Environment {
  static String get backendUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';
  
  static String get elevenLabsApiKey => dotenv.env['ELEVENLABS_API_KEY'] ?? '';
  
  static String get scribeEndpoint => dotenv.env['SCRIBE_V2_ENDPOINT'] ?? 
      'wss://api.elevenlabs.io/v1/speech-to-text/stream';
  
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  
  static String get buildNumber => dotenv.env['BUILD_NUMBER'] ?? '1';
  
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';
  
  static String get encryptionKey => dotenv.env['ENCRYPTION_KEY'] ?? '';
  
  static String get jwtSecret => dotenv.env['JWT_SECRET'] ?? '';
  
  static bool get enableOfflineMode => 
      dotenv.env['ENABLE_OFFLINE_MODE']?.toLowerCase() == 'true';
  
  static bool get enablePushNotifications => 
      dotenv.env['ENABLE_PUSH_NOTIFICATIONS']?.toLowerCase() == 'true';
  
  static bool get enableDarkMode => 
      dotenv.env['ENABLE_DARK_MODE']?.toLowerCase() == 'true';
  
  static bool get isDevelopment => environment == 'development';
  
  static bool get isProduction => environment == 'production';
}
