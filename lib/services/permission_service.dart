import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

/// Permission Service
/// Handles all app permission requests for iOS and Android

class PermissionService {
  final Logger _logger = Logger();

  /// Request microphone permission
  Future<bool> requestMicrophone() async {
    try {
      final status = await Permission.microphone.request();
      _logger.i('Microphone permission: $status');
      return status.isGranted;
    } catch (e) {
      _logger.e('Microphone permission error: $e');
      return false;
    }
  }

  /// Check microphone permission status
  Future<bool> hasMicrophone() async {
    return await Permission.microphone.isGranted;
  }

  /// Request storage permission
  Future<bool> requestStorage() async {
    try {
      final status = await Permission.storage.request();
      _logger.i('Storage permission: $status');
      return status.isGranted;
    } catch (e) {
      _logger.e('Storage permission error: $e');
      return false;
    }
  }

  /// Check storage permission status
  Future<bool> hasStorage() async {
    return await Permission.storage.isGranted;
  }

  /// Request notification permission
  Future<bool> requestNotification() async {
    try {
      final status = await Permission.notification.request();
      _logger.i('Notification permission: $status');
      return status.isGranted;
    } catch (e) {
      _logger.e('Notification permission error: $e');
      return false;
    }
  }

  /// Request all required permissions
  Future<Map<Permission, PermissionStatus>> requestAllRequired() async {
    try {
      final statuses = await [
        Permission.microphone,
        Permission.storage,
        Permission.notification,
      ].request();
      
      _logger.i('All permissions requested: $statuses');
      return statuses;
    } catch (e) {
      _logger.e('Request all permissions error: $e');
      return {};
    }
  }

  /// Check if all required permissions are granted
  Future<bool> hasAllRequired() async {
    final microphone = await Permission.microphone.isGranted;
    final storage = await Permission.storage.isGranted;
    
    return microphone && storage;
  }

  /// Open app settings
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Get permission status summary
  Future<Map<String, bool>> getPermissionSummary() async {
    return {
      'microphone': await Permission.microphone.isGranted,
      'storage': await Permission.storage.isGranted,
      'notification': await Permission.notification.isGranted,
    };
  }

  /// Check if permission is permanently denied
  Future<bool> isPermanentlyDenied(Permission permission) async {
    return await permission.isPermanentlyDenied;
  }
}
