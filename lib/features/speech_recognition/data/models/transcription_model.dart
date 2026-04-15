import 'package:word_pedometer/features/speech_recognition/domain/entities/transcription.dart';

/// Data model for transcription with JSON serialization
class TranscriptionModel extends Transcription {
  TranscriptionModel({
    required String id,
    required String text,
    required DateTime timestamp,
    required double confidence,
    required Duration duration,
  }) : super(
          id: id,
          text: text,
          timestamp: timestamp,
          confidence: confidence,
          duration: duration,
        );

  /// Create from JSON
  factory TranscriptionModel.fromJson(Map<String, dynamic> json) =>
      TranscriptionModel(
        id: json['id'] as String,
        text: json['text'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        confidence: (json['confidence'] as num).toDouble(),
        duration: Duration(
          milliseconds: json['durationMs'] as int? ?? 0,
        ),
      );

  /// Create from entity
  factory TranscriptionModel.fromEntity(Transcription entity) =>
      TranscriptionModel(
        id: entity.id,
        text: entity.text,
        timestamp: entity.timestamp,
        confidence: entity.confidence,
        duration: entity.duration,
      );

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'confidence': confidence,
        'durationMs': duration.inMilliseconds,
      };

  /// Create a copy with optional field updates
  TranscriptionModel copyWith({
    String? id,
    String? text,
    DateTime? timestamp,
    double? confidence,
    Duration? duration,
  }) =>
      TranscriptionModel(
        id: id ?? this.id,
        text: text ?? this.text,
        timestamp: timestamp ?? this.timestamp,
        confidence: confidence ?? this.confidence,
        duration: duration ?? this.duration,
      );
}
