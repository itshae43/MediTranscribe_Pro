// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClinicalNote _$ClinicalNoteFromJson(Map<String, dynamic> json) => ClinicalNote(
      consultationId: json['consultationId'] as String,
      chiefComplaint: json['chiefComplaint'] as String,
      historyOfPresentIllness: json['historyOfPresentIllness'] as String,
      diagnoses:
          (json['diagnoses'] as List<dynamic>).map((e) => e as String).toList(),
      medications: (json['medications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      procedures: (json['procedures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      assessment: json['assessment'] as String,
      followUp: json['followUp'] as String,
      extractedEntities: json['extractedEntities'] as Map<String, dynamic>,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$ClinicalNoteToJson(ClinicalNote instance) =>
    <String, dynamic>{
      'consultationId': instance.consultationId,
      'chiefComplaint': instance.chiefComplaint,
      'historyOfPresentIllness': instance.historyOfPresentIllness,
      'diagnoses': instance.diagnoses,
      'medications': instance.medications,
      'procedures': instance.procedures,
      'assessment': instance.assessment,
      'followUp': instance.followUp,
      'extractedEntities': instance.extractedEntities,
      'generatedAt': instance.generatedAt.toIso8601String(),
    };
