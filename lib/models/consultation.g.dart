// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consultation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Consultation _$ConsultationFromJson(Map<String, dynamic> json) => Consultation(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      transcript: json['transcript'] as String?,
      chiefComplaint: json['chiefComplaint'] as String?,
      consultationType: json['consultationType'] as String?,
      clinicalNotes: json['clinicalNotes'] as Map<String, dynamic>?,
      audioDuration: (json['audioDuration'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
      isEncrypted: json['isEncrypted'] as bool,
      isSynced: json['isSynced'] as bool? ?? false,
    );

Map<String, dynamic> _$ConsultationToJson(Consultation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'doctorId': instance.doctorId,
      'transcript': instance.transcript,
      'chiefComplaint': instance.chiefComplaint,
      'consultationType': instance.consultationType,
      'clinicalNotes': instance.clinicalNotes,
      'audioDuration': instance.audioDuration,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': instance.status,
      'isEncrypted': instance.isEncrypted,
      'isSynced': instance.isSynced,
    };
