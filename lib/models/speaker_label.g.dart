// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speaker_label.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpeakerLabel _$SpeakerLabelFromJson(Map<String, dynamic> json) => SpeakerLabel(
      speaker: json['speaker'] as String,
      text: json['text'] as String,
      startTime: (json['startTime'] as num?)?.toDouble(),
      endTime: (json['endTime'] as num?)?.toDouble(),
      confidence: (json['confidence'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SpeakerLabelToJson(SpeakerLabel instance) =>
    <String, dynamic>{
      'speaker': instance.speaker,
      'text': instance.text,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'confidence': instance.confidence,
    };
