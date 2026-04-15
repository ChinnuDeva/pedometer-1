/// Grammar Error Types
enum GrammarErrorType {
  subjectVerbAgreement,
  tenseMismatch,
  wordChoice,
  sentenceStructure,
  punctuation,
  spelling,
  other,
}

/// Extension to add helpful properties to GrammarErrorType
extension GrammarErrorTypeX on GrammarErrorType {
  String get shortName {
    switch (this) {
      case GrammarErrorType.subjectVerbAgreement:
        return 'SVA';
      case GrammarErrorType.tenseMismatch:
        return 'Tense';
      case GrammarErrorType.wordChoice:
        return 'Word';
      case GrammarErrorType.sentenceStructure:
        return 'Sentence';
      case GrammarErrorType.punctuation:
        return 'Punct.';
      case GrammarErrorType.spelling:
        return 'Spell';
      case GrammarErrorType.other:
        return 'Other';
    }
  }

  String get displayName {
    switch (this) {
      case GrammarErrorType.subjectVerbAgreement:
        return 'Subject-Verb Agreement';
      case GrammarErrorType.tenseMismatch:
        return 'Tense Mismatch';
      case GrammarErrorType.wordChoice:
        return 'Word Choice';
      case GrammarErrorType.sentenceStructure:
        return 'Sentence Structure';
      case GrammarErrorType.punctuation:
        return 'Punctuation';
      case GrammarErrorType.spelling:
        return 'Spelling';
      case GrammarErrorType.other:
        return 'Other';
    }
  }
}

/// Grammar Mistake Domain Entity
/// Extended to include fluency assessment for natural language validation
class GrammarMistake {
  GrammarMistake({
    required this.id,
    required this.text,
    required this.suggestion,
    required this.errorType,
    required this.startPosition,
    required this.endPosition,
    required this.confidence,
    this.fluencyScore,
    this.fluencyExplanation,
    this.isFluencyIssue = false,
  });
  final String id;
  final String text;
  final String suggestion;
  final GrammarErrorType errorType;
  final int startPosition;
  final int endPosition;
  final double confidence;

  /// Fluency score (0-100) if this is also a fluency issue
  /// null if only a grammar issue
  final double? fluencyScore;

  /// Explanation of fluency issue if detected
  final String? fluencyExplanation;

  /// Whether this mistake affects naturalness (fluency)
  /// as opposed to just being grammatically incorrect
  final bool isFluencyIssue;

  @override
  String toString() => 'GrammarMistake(id: $id, text: $text, type: $errorType, '
      'confidence: $confidence, fluency: $isFluencyIssue)';
}
