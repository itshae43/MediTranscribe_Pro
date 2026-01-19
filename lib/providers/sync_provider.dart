import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';

/// Sync Provider
/// Manages data synchronization state using Riverpod

// Sync service provider
final syncServiceProvider = Provider<SyncService>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  
  final syncService = SyncService(
    dbService: dbService,
    apiService: apiService,
  );
  
  syncService.initialize();
  
  ref.onDispose(() {
    syncService.dispose();
  });
  
  return syncService;
});

// Database service provider (if not already defined)
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// API service provider (if not already defined)
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Sync status stream provider
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.syncStatusStream;
});

// Is syncing provider
final isSyncingProvider = Provider<bool>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.isSyncing;
});

// Last sync time provider
final lastSyncTimeProvider = Provider<DateTime?>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.lastSyncTime;
});

// Sync stats provider
final syncStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  return await syncService.getSyncStats();
});

/// Force sync action
Future<SyncResult> forceSyncAction(WidgetRef ref) async {
  final syncService = ref.read(syncServiceProvider);
  return await syncService.forceSync();
}
