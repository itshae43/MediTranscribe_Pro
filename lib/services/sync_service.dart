import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'database_service.dart';
import 'api_service.dart';
import '../models/consultation.dart';

/// Sync Service
/// Handles offline-first data synchronization with the backend

class SyncService {
  final DatabaseService _dbService;
  final ApiService _apiService;
  final Logger _logger = Logger();
  
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  
  final StreamController<SyncStatus> _syncStatusController = 
      StreamController<SyncStatus>.broadcast();

  SyncService({
    required DatabaseService dbService,
    required ApiService apiService,
  })  : _dbService = dbService,
        _apiService = apiService;

  /// Get sync status stream
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  
  /// Check if currently syncing
  bool get isSyncing => _isSyncing;
  
  /// Get last sync time
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Initialize sync service and listen for connectivity changes
  void initialize() {
    _logger.i('Initializing sync service');
    
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_handleConnectivityChange);
    
    // Perform initial sync check
    _checkAndSync();
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(ConnectivityResult result) {
    final hasConnection = result == ConnectivityResult.mobile || 
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;
    
    if (hasConnection) {
      _logger.i('Network connected, initiating sync');
      _checkAndSync();
    } else {
      _logger.i('Network disconnected, sync paused');
      _syncStatusController.add(SyncStatus.offline);
    }
  }

  /// Check connectivity and sync if online
  Future<void> _checkAndSync() async {
    final result = await Connectivity().checkConnectivity();
    final hasConnection = result == ConnectivityResult.mobile || 
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;
    
    if (hasConnection) {
      await syncAll();
    }
  }

  /// Sync all pending data
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      _logger.w('Sync already in progress');
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);
    
    int successCount = 0;
    int failCount = 0;
    final errors = <String>[];

    try {
      _logger.i('Starting full sync');
      
      // Get unsynced consultations
      final unsyncedConsultations = await _dbService.getUnsyncedConsultations();
      _logger.i('Found ${unsyncedConsultations.length} unsynced consultations');
      
      for (final consultation in unsyncedConsultations) {
        try {
          final synced = await _syncConsultation(consultation);
          if (synced) {
            successCount++;
          } else {
            failCount++;
          }
        } catch (e) {
          failCount++;
          errors.add('Consultation ${consultation.id}: $e');
          _logger.e('Sync error for ${consultation.id}: $e');
        }
      }
      
      // Process sync queue
      await _processSyncQueue();
      
      _lastSyncTime = DateTime.now();
      _syncStatusController.add(SyncStatus.synced);
      
      _logger.i('Sync complete: $successCount success, $failCount failed');
      
      return SyncResult(
        success: failCount == 0,
        message: 'Synced $successCount items, $failCount failed',
        successCount: successCount,
        failCount: failCount,
        errors: errors,
      );
    } catch (e) {
      _logger.e('Sync error: $e');
      _syncStatusController.add(SyncStatus.error);
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
        errors: [e.toString()],
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync a single consultation
  Future<bool> _syncConsultation(Consultation consultation) async {
    try {
      // Try to update on server
      final result = await _apiService.finalizeConsultation(
        consultationId: consultation.id,
        transcript: consultation.transcript ?? '',
        speakerLabels: [],
      );
      
      if (result != null) {
        await _dbService.markAsSynced(consultation.id);
        _logger.i('Consultation synced: ${consultation.id}');
        return true;
      }
      
      return false;
    } catch (e) {
      _logger.e('Sync consultation error: $e');
      return false;
    }
  }

  /// Process sync queue items
  Future<void> _processSyncQueue() async {
    try {
      final pendingItems = await _dbService.getPendingSyncItems();
      _logger.i('Processing ${pendingItems.length} sync queue items');
      
      for (final item in pendingItems) {
        final id = item['id'] as int;
        final entityType = item['entity_type'] as String;
        final entityId = item['entity_id'] as String;
        final action = item['action'] as String;
        
        try {
          bool success = false;
          
          switch (entityType) {
            case 'consultation':
              success = await _processSyncQueueItem(action, entityId);
              break;
          }
          
          if (success) {
            await _dbService.removeFromSyncQueue(id);
          }
        } catch (e) {
          _logger.e('Process sync queue item error: $e');
        }
      }
    } catch (e) {
      _logger.e('Process sync queue error: $e');
    }
  }

  /// Process a single sync queue item
  Future<bool> _processSyncQueueItem(String action, String entityId) async {
    switch (action) {
      case 'create':
        // Handle create action
        return true;
      case 'update':
        // Handle update action
        return true;
      case 'delete':
        return await _apiService.deleteConsultation(entityId);
      default:
        return false;
    }
  }

  /// Force sync now
  Future<SyncResult> forceSync() async {
    _logger.i('Force sync requested');
    return await syncAll();
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    final dbStats = await _dbService.getStats();
    return {
      ...dbStats,
      'last_sync': _lastSyncTime?.toIso8601String(),
      'is_syncing': _isSyncing,
    };
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
  }
}

/// Sync status enum
enum SyncStatus {
  idle,
  syncing,
  synced,
  error,
  offline,
}

/// Sync result class
class SyncResult {
  final bool success;
  final String message;
  final int successCount;
  final int failCount;
  final List<String> errors;

  SyncResult({
    required this.success,
    required this.message,
    this.successCount = 0,
    this.failCount = 0,
    this.errors = const [],
  });
}
