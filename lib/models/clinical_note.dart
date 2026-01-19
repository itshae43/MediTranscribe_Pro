import 'package:json_annotation/json_annotation.dart';

part 'clinical_note.g.dart';

/// Clinical Note Model
/// Represents auto-generated clinical notes from a consultation

@JsonSerializable()
class ClinicalNote {
  final String consultationId;
  final String chiefComplaint;
  final String historyOfPresentIllness;
  final List<String> diagnoses;
  final List<String> medications;
  final List<String> procedures;
  final String assessment;
  final String followUp;
  final Map<String, dynamic> extractedEntities;
  final DateTime generatedAt;

  const ClinicalNote({
    required this.consultationId,
    required this.chiefComplaint,
    required this.historyOfPresentIllness,
    required this.diagnoses,
    required this.medications,
    required this.procedures,
    required this.assessment,
    required this.followUp,
    required this.extractedEntities,
    required this.generatedAt,
  });

  factory ClinicalNote.fromJson(Map<String, dynamic> json) =>
      _$ClinicalNoteFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicalNoteToJson(this);

  ClinicalNote copyWith({
    String? consultationId,
    String? chiefComplaint,
    String? historyOfPresentIllness,
    List<String>? diagnoses,
    List<String>? medications,
    List<String>? procedures,
    String? assessment,
    String? followUp,
    Map<String, dynamic>? extractedEntities,
    DateTime? generatedAt,
  }) =>
      ClinicalNote(
        consultationId: consultationId ?? this.consultationId,
        chiefComplaint: chiefComplaint ?? this.chiefComplaint,
        historyOfPresentIllness: historyOfPresentIllness ?? this.historyOfPresentIllness,
        diagnoses: diagnoses ?? this.diagnoses,
        medications: medications ?? this.medications,
        procedures: procedures ?? this.procedures,
        assessment: assessment ?? this.assessment,
        followUp: followUp ?? this.followUp,
        extractedEntities: extractedEntities ?? this.extractedEntities,
        generatedAt: generatedAt ?? this.generatedAt,
      );

  /// Check if notes are complete
  bool get isComplete =>
      chiefComplaint.isNotEmpty &&
      assessment.isNotEmpty;

  /// Get summary for display
  String get summary {
    if (diagnoses.isEmpty) return 'No diagnoses recorded';
    return diagnoses.take(2).join(', ');
  }

  /// Get medication count
  int get medicationCount => medications.length;
  
  /// Get procedure count
  int get procedureCount => procedures.length;
}
