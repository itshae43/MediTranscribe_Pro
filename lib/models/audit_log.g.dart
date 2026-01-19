// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditLog _$AuditLogFromJson(Map<String, dynamic> json) => AuditLog(
      id: json['id'] as String,
      consultationId: json['consultationId'] as String,
      userId: json['userId'] as String,
      action: json['action'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String?,
      details: json['details'] as Map<String, dynamic>?,
      ipAddress: json['ipAddress'] as String,
      userAgent: json['userAgent'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$AuditLogToJson(AuditLog instance) => <String, dynamic>{
      'id': instance.id,
      'consultationId': instance.consultationId,
      'userId': instance.userId,
      'action': instance.action,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'details': instance.details,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'timestamp': instance.timestamp.toIso8601String(),
    };
