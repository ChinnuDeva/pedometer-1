import 'package:word_pedometer/features/grammar_checker/domain/entities/grammar_mistake.dart';

/// Data model for grammar mistake with JSON serialization
class GrammarMistakeModel extends GrammarMistake {
  GrammarMistakeModel({
    required super.id,
    required super.text,
    required super.suggestion,
    required super.errorType,
    required super.startPosition,
    required super.endPosition,
    required super.confidence,
  });

  /// Create from JSON
  factory GrammarMistakeModel.fromJson(Map<String, dynamic> json) {
    return GrammarMistakeModel(
      id: json['id'] as String,
      text: json['text'] as String,
      suggestion: json['suggestion'] as String,
      errorType: GrammarErrorType.values.firstWhere(
        (e) => e.toString() == json['errorType'] as String,
        orElse: () => GrammarErrorType.other,
      ),
      startPosition: json['startPosition'] as int,
      endPosition: json['endPosition'] as int,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  /// Create from entity
  factory GrammarMistakeModel.fromEntity(GrammarMistake entity) {
    return GrammarMistakeModel(
      id: entity.id,
      text: entity.text,
      suggestion: entity.suggestion,
      errorType: entity.errorType,
      startPosition: entity.startPosition,
      endPosition: entity.endPosition,
      confidence: entity.confidence,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'suggestion': suggestion,
      'errorType': errorType.toString(),
      'startPosition': startPosition,
      'endPosition': endPosition,
      'confidence': confidence,
    };
  }

  /// Create a copy with optional field updates
  GrammarMistakeModel copyWith({
    String? id,
    String? text,
    String? suggestion,
    GrammarErrorType? errorType,
    int? startPosition,
    int? endPosition,
    double? confidence,
  }) {
    return GrammarMistakeModel(
      id: id ?? this.id,
      text: text ?? this.text,
      suggestion: suggestion ?? this.suggestion,
      errorType: errorType ?? this.errorType,
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
      confidence: confidence ?? this.confidence,
    );
  }
}
