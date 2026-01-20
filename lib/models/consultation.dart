import 'package:json_annotation/json_annotation.dart';

part 'consultation.g.dart';

/// Consultation Model
/// Represents a single doctor-patient consultation session

@JsonSerializable()
class Consultation {
  final String id;
  final String patientId;
  final String doctorId;
  final String? transcript;
  final String? chiefComplaint;
  final Map<String, dynamic>? clinicalNotes;
  final int audioDuration;
  final DateTime createdAt;
  final String status; // draft, reviewed, finalized
  final bool isEncrypted;
  final bool isSynced;

  const Consultation({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.transcript,
    this.chiefComplaint,
    this.clinicalNotes,
    required this.audioDuration,
    required this.createdAt,
    required this.status,
    required this.isEncrypted,
    this.isSynced = false,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) =>
      _$ConsultationFromJson(json);

  Map<String, dynamic> toJson() => _$ConsultationToJson(this);

  Consultation copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? transcript,
    String? chiefComplaint,
    Map<String, dynamic>? clinicalNotes,
    int? audioDuration,
    DateTime? createdAt,
    String? status,
    bool? isEncrypted,
    bool? isSynced,
  }) =>
      Consultation(
        id: id ?? this.id,
        patientId: patientId ?? this.patientId,
        doctorId: doctorId ?? this.doctorId,
        transcript: transcript ?? this.transcript,
        chiefComplaint: chiefComplaint ?? this.chiefComplaint,
        clinicalNotes: clinicalNotes ?? this.clinicalNotes,
        audioDuration: audioDuration ?? this.audioDuration,
        createdAt: createdAt ?? this.createdAt,
        status: status ?? this.status,
        isEncrypted: isEncrypted ?? this.isEncrypted,
        isSynced: isSynced ?? this.isSynced,
      );

  /// Check if consultation is complete
  bool get isFinalized => status == 'finalized';
  
  /// Check if consultation has notes
  bool get hasNotes => clinicalNotes != null && clinicalNotes!.isNotEmpty;
  
  /// Get formatted duration
  String get formattedDuration {
    final minutes = audioDuration ~/ 60;
    final seconds = audioDuration % 60;
    return '${minutes}m ${seconds}s';
  }
}

/// Consultation Status enum
enum ConsultationStatus {
  draft,
  waiting,
  reviewed,
  finalized,
}

extension ConsultationStatusExtension on ConsultationStatus {
  String get value {
    switch (this) {
      case ConsultationStatus.draft:
        return 'draft';
      case ConsultationStatus.waiting:
        return 'waiting';
      case ConsultationStatus.reviewed:
        return 'reviewed';
      case ConsultationStatus.finalized:
        return 'finalized';
    }
  }
  
  static ConsultationStatus fromString(String status) {
    switch (status) {
      case 'draft':
        return ConsultationStatus.draft;
      case 'waiting':
        return ConsultationStatus.waiting;
      case 'reviewed':
        return ConsultationStatus.reviewed;
      case 'finalized':
        return ConsultationStatus.finalized;
      default:
        return ConsultationStatus.draft;
    }
  }
}
