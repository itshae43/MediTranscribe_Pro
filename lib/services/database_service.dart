import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';
import '../models/consultation.dart';

/// Database Service
/// Handles local SQLite storage for offline-first functionality

class DatabaseService {
  static Database? _database;
  final Logger _logger = Logger();
  
  static const String _dbName = 'meditranscribe.db';
  static const int _dbVersion = 2; // Upgraded for chief_complaint and consultation_type

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      
      _logger.i('Initializing database at: $path');
      
      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      _logger.e('Database initialization error: $e');
      rethrow;
    }
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    _logger.i('Creating database tables...');
    
    // Consultations table
    await db.execute('''
      CREATE TABLE consultations (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        doctor_id TEXT NOT NULL,
        chief_complaint TEXT,
        consultation_type TEXT,
        transcript TEXT,
        clinical_notes TEXT,
        audio_duration INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        status TEXT DEFAULT 'draft',
        is_encrypted INTEGER DEFAULT 0,
        is_synced INTEGER DEFAULT 0
      )
    ''');
    
    // Clinical notes table
    await db.execute('''
      CREATE TABLE clinical_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        consultation_id TEXT NOT NULL,
        chief_complaint TEXT,
        history_of_present_illness TEXT,
        diagnoses TEXT,
        medications TEXT,
        procedures TEXT,
        assessment TEXT,
        follow_up TEXT,
        extracted_entities TEXT,
        generated_at TEXT,
        FOREIGN KEY (consultation_id) REFERENCES consultations (id)
      )
    ''');
    
    // Audit logs table
    await db.execute('''
      CREATE TABLE audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        consultation_id TEXT,
        user_id TEXT,
        action TEXT NOT NULL,
        entity_type TEXT,
        entity_id TEXT,
        details TEXT,
        ip_address TEXT,
        user_agent TEXT,
        timestamp TEXT NOT NULL
      )
    ''');
    
    // Sync queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        action TEXT NOT NULL,
        data TEXT,
        created_at TEXT NOT NULL,
        attempts INTEGER DEFAULT 0
      )
    ''');
    
    _logger.i('Database tables created successfully');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.i('Upgrading database from v$oldVersion to v$newVersion');
    
    if (oldVersion < 2) {
      // Add chief_complaint and consultation_type columns
      await db.execute('ALTER TABLE consultations ADD COLUMN chief_complaint TEXT');
      await db.execute('ALTER TABLE consultations ADD COLUMN consultation_type TEXT');
      _logger.i('Added chief_complaint and consultation_type columns');
    }
  }

  // ==================== CONSULTATION OPERATIONS ====================

  /// Insert new consultation
  Future<int> insertConsultation(Consultation consultation) async {
    try {
      final db = await database;
      final result = await db.insert(
        'consultations',
        {
          'id': consultation.id,
          'patient_id': consultation.patientId,
          'doctor_id': consultation.doctorId,
          'chief_complaint': consultation.chiefComplaint,
          'consultation_type': consultation.consultationType,
          'transcript': consultation.transcript,
          'clinical_notes': consultation.clinicalNotes?.toString(),
          'audio_duration': consultation.audioDuration,
          'created_at': consultation.createdAt.toIso8601String(),
          'status': consultation.status,
          'is_encrypted': consultation.isEncrypted ? 1 : 0,
          'is_synced': consultation.isSynced ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.i('Consultation inserted: ${consultation.id}');
      return result;
    } catch (e) {
      _logger.e('Insert consultation error: $e');
      rethrow;
    }
  }

  /// Get consultation by ID
  Future<Consultation?> getConsultation(String id) async {
    try {
      final db = await database;
      final maps = await db.query(
        'consultations',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isEmpty) return null;
      return _mapToConsultation(maps.first);
    } catch (e) {
      _logger.e('Get consultation error: $e');
      return null;
    }
  }

  /// Get all consultations
  Future<List<Consultation>> getAllConsultations({
    int limit = 50,
    int offset = 0,
    String? status,
  }) async {
    try {
      final db = await database;
      
      String? where;
      List<dynamic>? whereArgs;
      
      if (status != null) {
        where = 'status = ?';
        whereArgs = [status];
      }
      
      final maps = await db.query(
        'consultations',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
        limit: limit,
        offset: offset,
      );
      
      return maps.map(_mapToConsultation).toList();
    } catch (e) {
      _logger.e('Get all consultations error: $e');
      return [];
    }
  }

  /// Get unsynced consultations
  Future<List<Consultation>> getUnsyncedConsultations() async {
    try {
      final db = await database;
      final maps = await db.query(
        'consultations',
        where: 'is_synced = ?',
        whereArgs: [0],
      );
      
      return maps.map(_mapToConsultation).toList();
    } catch (e) {
      _logger.e('Get unsynced consultations error: $e');
      return [];
    }
  }

  /// Update consultation
  Future<int> updateConsultation(Consultation consultation) async {
    try {
      final db = await database;
      final result = await db.update(
        'consultations',
        {
          'transcript': consultation.transcript,
          'clinical_notes': consultation.clinicalNotes?.toString(),
          'audio_duration': consultation.audioDuration,
          'status': consultation.status,
          'is_encrypted': consultation.isEncrypted ? 1 : 0,
          'is_synced': consultation.isSynced ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [consultation.id],
      );
      _logger.i('Consultation updated: ${consultation.id}');
      return result;
    } catch (e) {
      _logger.e('Update consultation error: $e');
      rethrow;
    }
  }

  /// Mark consultation as synced
  Future<void> markAsSynced(String id) async {
    try {
      final db = await database;
      await db.update(
        'consultations',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      _logger.i('Consultation marked as synced: $id');
    } catch (e) {
      _logger.e('Mark as synced error: $e');
    }
  }

  /// Delete consultation
  Future<int> deleteConsultation(String id) async {
    try {
      final db = await database;
      final result = await db.delete(
        'consultations',
        where: 'id = ?',
        whereArgs: [id],
      );
      _logger.i('Consultation deleted: $id');
      return result;
    } catch (e) {
      _logger.e('Delete consultation error: $e');
      rethrow;
    }
  }

  // ==================== AUDIT LOG OPERATIONS ====================

  /// Insert audit log
  Future<int> insertAuditLog({
    required String action,
    String? consultationId,
    String? userId,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? details,
  }) async {
    try {
      final db = await database;
      final result = await db.insert(
        'audit_logs',
        {
          'consultation_id': consultationId,
          'user_id': userId,
          'action': action,
          'entity_type': entityType,
          'entity_id': entityId,
          'details': details?.toString(),
          'ip_address': 'local',
          'user_agent': 'MediTranscribe/1.0',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      _logger.d('Audit log inserted: $action');
      return result;
    } catch (e) {
      _logger.e('Insert audit log error: $e');
      rethrow;
    }
  }

  /// Get audit logs for consultation
  Future<List<Map<String, dynamic>>> getAuditLogs(String consultationId) async {
    try {
      final db = await database;
      return await db.query(
        'audit_logs',
        where: 'consultation_id = ?',
        whereArgs: [consultationId],
        orderBy: 'timestamp DESC',
      );
    } catch (e) {
      _logger.e('Get audit logs error: $e');
      return [];
    }
  }

  // ==================== SYNC QUEUE OPERATIONS ====================

  /// Add to sync queue
  Future<void> addToSyncQueue({
    required String entityType,
    required String entityId,
    required String action,
    String? data,
  }) async {
    try {
      final db = await database;
      await db.insert(
        'sync_queue',
        {
          'entity_type': entityType,
          'entity_id': entityId,
          'action': action,
          'data': data,
          'created_at': DateTime.now().toIso8601String(),
        },
      );
      _logger.d('Added to sync queue: $entityType/$entityId');
    } catch (e) {
      _logger.e('Add to sync queue error: $e');
    }
  }

  /// Get pending sync items
  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    try {
      final db = await database;
      return await db.query(
        'sync_queue',
        where: 'attempts < ?',
        whereArgs: [3],
        orderBy: 'created_at ASC',
      );
    } catch (e) {
      _logger.e('Get pending sync items error: $e');
      return [];
    }
  }

  /// Remove from sync queue
  Future<void> removeFromSyncQueue(int id) async {
    try {
      final db = await database;
      await db.delete(
        'sync_queue',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      _logger.e('Remove from sync queue error: $e');
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Convert database map to Consultation object
  Consultation _mapToConsultation(Map<String, dynamic> map) {
    return Consultation(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      doctorId: map['doctor_id'] as String,
      chiefComplaint: map['chief_complaint'] as String?,
      consultationType: map['consultation_type'] as String?,
      transcript: map['transcript'] as String?,
      audioDuration: map['audio_duration'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      status: map['status'] as String? ?? 'draft',
      isEncrypted: (map['is_encrypted'] as int? ?? 0) == 1,
      isSynced: (map['is_synced'] as int? ?? 0) == 1,
    );
  }

  /// Get database statistics
  Future<Map<String, int>> getStats() async {
    try {
      final db = await database;
      
      final consultations = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM consultations'),
      ) ?? 0;
      
      final unsynced = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM consultations WHERE is_synced = 0'),
      ) ?? 0;
      
      final auditLogs = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM audit_logs'),
      ) ?? 0;
      
      return {
        'total_consultations': consultations,
        'unsynced_consultations': unsynced,
        'audit_logs': auditLogs,
      };
    } catch (e) {
      _logger.e('Get stats error: $e');
      return {};
    }
  }

  /// Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _logger.i('Database closed');
    }
  }

  /// Delete entire database (for testing/reset)
  Future<void> deleteDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      await databaseFactory.deleteDatabase(path);
      _database = null;
      _logger.w('Database deleted');
    } catch (e) {
      _logger.e('Delete database error: $e');
    }
  }
}
