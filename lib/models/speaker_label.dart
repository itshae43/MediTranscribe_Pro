import 'package:json_annotation/json_annotation.dart';

part 'speaker_label.g.dart';

/// Speaker Label Model
/// Represents a segment of transcribed speech with speaker identification

@JsonSerializable()
class SpeakerLabel {
  final String speaker; // DOCTOR, PATIENT, UNKNOWN
  final String text;
  final double? startTime;
  final double? endTime;
  final double? confidence;

  const SpeakerLabel({
    required this.speaker,
    required this.text,
    this.startTime,
    this.endTime,
    this.confidence,
  });

  factory SpeakerLabel.fromJson(Map<String, dynamic> json) =>
      _$SpeakerLabelFromJson(json);

  Map<String, dynamic> toJson() => _$SpeakerLabelToJson(this);

  /// Check if this is doctor speaking
  bool get isDoctor => speaker.toUpperCase() == 'DOCTOR';
  
  /// Check if this is patient speaking
  bool get isPatient => speaker.toUpperCase() == 'PATIENT';
  
  /// Get display label
  String get displayLabel {
    switch (speaker.toUpperCase()) {
      case 'DOCTOR':
        return 'Dr.';
      case 'PATIENT':
        return 'Patient';
      default:
        return 'Unknown';
    }
  }

  /// Get duration of this segment
  double? get duration {
    if (startTime != null && endTime != null) {
      return endTime! - startTime!;
    }
    return null;
  }

  /// Check if confidence is high
  bool get isHighConfidence => (confidence ?? 0) >= 0.8;
}

/// Speaker Type enum
enum SpeakerType {
  doctor,
  patient,
  unknown,
}

extension SpeakerTypeExtension on SpeakerType {
  String get value {
    switch (this) {
      case SpeakerType.doctor:
        return 'DOCTOR';
      case SpeakerType.patient:
        return 'PATIENT';
      case SpeakerType.unknown:
        return 'UNKNOWN';
    }
  }
  
  static SpeakerType fromString(String speaker) {
    switch (speaker.toUpperCase()) {
      case 'DOCTOR':
        return SpeakerType.doctor;
      case 'PATIENT':
        return SpeakerType.patient;
      default:
        return SpeakerType.unknown;
    }
  }
}
