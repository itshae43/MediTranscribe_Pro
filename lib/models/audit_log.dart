import 'package:json_annotation/json_annotation.dart';

part 'audit_log.g.dart';

/// Audit Log Model
/// HIPAA-compliant audit trail for all data access and modifications

@JsonSerializable()
class AuditLog {
  final String id;
  final String consultationId;
  final String userId;
  final String action; // create, read, update, delete, export
  final String entityType; // consultation, clinical_note, transcript
  final String? entityId;
  final Map<String, dynamic>? details;
  final String ipAddress;
  final String userAgent;
  final DateTime timestamp;

  const AuditLog({
    required this.id,
    required this.consultationId,
    required this.userId,
    required this.action,
    required this.entityType,
    this.entityId,
    this.details,
    required this.ipAddress,
    required this.userAgent,
    required this.timestamp,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) =>
      _$AuditLogFromJson(json);

  Map<String, dynamic> toJson() => _$AuditLogToJson(this);

  /// Get human-readable action description
  String get actionDescription {
    switch (action) {
      case 'create':
        return 'Created $entityType';
      case 'read':
        return 'Viewed $entityType';
      case 'update':
        return 'Modified $entityType';
      case 'delete':
        return 'Deleted $entityType';
      case 'export':
        return 'Exported $entityType';
      default:
        return 'Performed $action on $entityType';
    }
  }

  /// Get formatted timestamp
  String get formattedTimestamp {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

/// Audit Action Types
enum AuditAction {
  create,
  read,
  update,
  delete,
  export,
}

extension AuditActionExtension on AuditAction {
  String get value {
    switch (this) {
      case AuditAction.create:
        return 'create';
      case AuditAction.read:
        return 'read';
      case AuditAction.update:
        return 'update';
      case AuditAction.delete:
        return 'delete';
      case AuditAction.export:
        return 'export';
    }
  }
}
