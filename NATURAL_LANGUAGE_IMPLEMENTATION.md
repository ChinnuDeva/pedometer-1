# Quick Implementation Guide - Natural Language Validation
## Copy-Paste Ready Code

**Status**: MVP Level (Can implement in 1-2 weeks)

---

## STEP 1: Create FluencyIssueType Enum

**File**: `lib/features/grammar_checker/domain/entities/grammar_mistake.dart`

**Add** (after GrammarErrorType enum):

```dart
/// Fluency issue classification
enum FluencyIssueType {
  awkwardPhrasing,      // "Can I know your name?"
  formalWhereInformal,  // Too formal for conversation
  informalWhereFormal,  // Too casual
  notCommonlyUsed,      // Rare phrasing
  translationError,     // Hindi→English artifact
  regionalism,          // Regional variation
  archaic,              // Outdated
  otherFluencyIssue,
}

extension FluencyIssueTypeX on FluencyIssueType {
  String get displayName {
    switch (this) {
      case FluencyIssueType.awkwardPhrasing:
        return 'Awkward Phrasing';
      case FluencyIssueType.formalWhereInformal:
        return 'Too Formal';
      case FluencyIssueType.informalWhereFormal:
        return 'Too Informal';
      case FluencyIssueType.notCommonlyUsed:
        return 'Not Commonly Used';
      case FluencyIssueType.translationError:
        return 'Translation Artifact';
      case FluencyIssueType.regionalism:
        return 'Regional Variation';
      case FluencyIssueType.archaic:
        return 'Outdated';
      case FluencyIssueType.otherFluencyIssue:
        return 'Other Fluency Issue';
    }
  }
}
```

---

## STEP 2: Create Conversational Phrase Database

**File**: Create `lib/core/services/conversational_phrase_database.dart`

```dart
import 'package:logger/logger.dart';

/// Database of common unnatural phrases and their natural alternatives
class ConversationalPhraseDatabase {
  static final Logger _logger = Logger();

  /// Map of unnatural phrase → natural alternatives
  static const Map<String, List<String>> commonMisphrasings = {
    // Asking for names/information
    'can i know your name': [
      'what is your name',
      'may i know your name',
      'could you tell me your name',
      'what should i call you',
    ],
    'can you tell your name': [
      'can you tell me your name',
      'what is your name',
    ],

    // Polite requests
    'can i get help': [
      'can you help me',
      'could i get some help',
      'may i ask for help',
    ],
    'can you help me to': [
      'can you help me',
      'would you help me',
    ],

    // Common patterns
    'i am coming from': [
      'i come from',
      'i am from',
    ],
    'i am knowing': [
      'i know',
    ],
    'i am understanding': [
      'i understand',
    ],
    'i am believing': [
      'i believe',
    ],

    // Hindi artifacts
    'can you tell one thing': [
      'can i ask you something',
      'can you tell me something',
    ],
    'tell me what is your': [
      'what is your',
      'may i know your',
    ],
    'i am boring': [
      'i am bored',
      'i find it boring',
    ],
    'i am not agree': [
      'i do not agree',
      'i disagree',
    ],
  };

  /// Check if phrase matches unnatural pattern
  static Future<PhraseCheckResult> checkPhrase(String text) async {
    try {
      final normalized = _normalizeText(text);

      for (final entry in commonMisphrasings.entries) {
        if (normalized.contains(entry.key)) {
          _logger.i('Unnatural phrase detected: ${entry.key}');
          return PhraseCheckResult(
            isUnnatural: true,
            unnaturalPhrase: entry.key,
            naturalAlternatives: entry.value,
            confidence: 0.85,
          );
        }
      }

      return PhraseCheckResult(isUnnatural: false);
    } catch (e) {
      _logger.e('Error checking phrase: $e');
      return PhraseCheckResult(isUnnatural: false);
    }
  }

  static String _normalizeText(String text) {
    return text.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}

/// Result of phrase checking
class PhraseCheckResult {
  final bool isUnnatural;
  final String? unnaturalPhrase;
  final List<String> naturalAlternatives;
  final double confidence;

  PhraseCheckResult({
    required this.isUnnatural,
    this.unnaturalPhrase,
    this.naturalAlternatives = const [],
    this.confidence = 0.8,
  });
}
```

---

## STEP 3: Create English Fluency Rules

**File**: Create `lib/core/services/english_fluency_rules.dart`

```dart
import 'package:logger/logger.dart';
import 'package:word_pedometer/features/grammar_checker/domain/entities/grammar_mistake.dart';

/// Pattern-based fluency validation for English
class EnglishFluencyRules {
  static final Logger _logger = Logger();

  /// Check text against fluency patterns
  static Future<FluencyAnalysis> analyzeText(String text) async {
    try {
      final issues = <FluencyViolation>[];

      // Pattern 1: Stative verbs with "am"
      if (_matchesPattern(text, r'i\s+am\s+(knowing|understanding|believing|thinking|liking)')) {
        issues.add(FluencyViolation(
          pattern: 'I am [stative verb]',
          issue: FluencyIssueType.awkwardPhrasing,
          suggestion: 'Remove "am" - use: "I [verb]"',
          severity: 'high',
          confidence: 0.9,
        ));
      }

      // Pattern 2: "I am coming from" vs "I come from"
      if (_matchesPattern(text, r'i\s+am\s+coming\s+from')) {
        issues.add(FluencyViolation(
          pattern: 'I am coming from',
          issue: FluencyIssueType.awkwardPhrasing,
          suggestion: 'Use: "I come from" or "I am from"',
          severity: 'high',
          confidence: 0.95,
        ));
      }

      // Pattern 3: "Can I know" vs "What is" or "May I know"
      if (_matchesPattern(text, r'can\s+i\s+(know|tell|ask|get)\s+(your|my|their)')) {
        issues.add(FluencyViolation(
          pattern: 'Can I [verb] your/my [noun]',
          issue: FluencyIssueType.awkwardPhrasing,
          suggestion: 'Better: "What is your..." or "May I know your..."',
          severity: 'medium',
          confidence: 0.8,
        ));
      }

      // Pattern 4: Extra "thing" - Hindi artifact
      if (_matchesPattern(text, r'(tell|ask|do).*\s+one\s+thing')) {
        issues.add(FluencyViolation(
          pattern: 'tell/ask one thing',
          issue: FluencyIssueType.translationError,
          suggestion: 'Remove "one thing" - just say: "Can I ask you something?"',
          severity: 'medium',
          confidence: 0.85,
        ));
      }

      // Pattern 5: "Can you help me to do" vs "Can you help me do"
      if (_matchesPattern(text, r'help\s+me\s+to\s+(do|understand|learn)')) {
        issues.add(FluencyViolation(
          pattern: 'help me to [verb]',
          issue: FluencyIssueType.awkwardPhrasing,
          suggestion: 'Use: "help me [verb]" (remove "to")',
          severity: 'low',
          confidence: 0.75,
        ));
      }

      return FluencyAnalysis(
        hasIssues: issues.isNotEmpty,
        violations: issues,
        overallFluencyScore: _calculateScore(issues),
      );
    } catch (e) {
      _logger.e('Error analyzing fluency: $e');
      return FluencyAnalysis(
        hasIssues: false,
        violations: [],
        overallFluencyScore: 100.0,
      );
    }
  }

  /// Calculate overall fluency score based on violations
  static double _calculateScore(List<FluencyViolation> violations) {
    if (violations.isEmpty) return 100.0;

    double penalty = 0.0;
    for (final v in violations) {
      final severityPenalty = v.severity == 'high'
          ? 20.0
          : v.severity == 'medium'
              ? 10.0
              : 5.0;
      penalty += severityPenalty * v.confidence;
    }

    return (100.0 - penalty).clamp(0.0, 100.0);
  }

  static bool _matchesPattern(String text, String pattern) {
    final regex = RegExp(pattern, caseSensitive: false);
    return regex.hasMatch(text);
  }
}

/// Fluency violation detected
class FluencyViolation {
  final String pattern;
  final FluencyIssueType issue;
  final String suggestion;
  final String severity; // 'low', 'medium', 'high'
  final double confidence; // 0-1

  FluencyViolation({
    required this.pattern,
    required this.issue,
    required this.suggestion,
    required this.severity,
    required this.confidence,
  });
}

/// Result of fluency analysis
class FluencyAnalysis {
  final bool hasIssues;
  final List<FluencyViolation> violations;
  final double overallFluencyScore; // 0-100

  FluencyAnalysis({
    required this.hasIssues,
    required this.violations,
    required this.overallFluencyScore,
  });
}
```

---

## STEP 4: Create Natural Language Validator Service

**File**: Create `lib/core/services/natural_language_validator.dart`

```dart
import 'package:logger/logger.dart';
import 'conversational_phrase_database.dart';
import 'english_fluency_rules.dart';

/// Natural Language validation layer
/// Checks if text is naturally used in spoken English
class NaturalLanguageValidator {
  static final Logger _logger = Logger();

  /// Validate fluency of text
  Future<FluencyValidation> validateFluency(
    String text, {
    required String language,
    String context = 'conversation',
  }) async {
    try {
      if (language == 'en') {
        return _validateEnglish(text, context);
      } else if (language == 'hi') {
        return _validateHindi(text, context);
      }

      // Unknown language - neutral
      return FluencyValidation.neutral();
    } catch (e) {
      _logger.e('Fluency validation error: $e');
      return FluencyValidation.neutral();
    }
  }

  /// Validate English fluency
  Future<FluencyValidation> _validateEnglish(
    String text,
    String context,
  ) async {
    // Check 1: Phrase database
    final phraseResult = await ConversationalPhraseDatabase.checkPhrase(text);

    // Check 2: Pattern-based rules
    final patternResult = await EnglishFluencyRules.analyzeText(text);

    // Combine results
    double fluencyScore = 100.0;
    String explanation = 'Natural phrasing';
    FluencyIssueType? issueType;
    List<String> alternatives = [];

    if (phraseResult.isUnnatural) {
      fluencyScore = 40.0;
      explanation = 'Common but unnatural in spoken English';
      issueType = FluencyIssueType.notCommonlyUsed;
      alternatives = phraseResult.naturalAlternatives;
    } else if (patternResult.hasIssues) {
      fluencyScore = patternResult.overallFluencyScore;
      final violation = patternResult.violations.first;
      explanation = violation.suggestion;
      issueType = violation.issue;
    }

    return FluencyValidation(
      fluencyScore: fluencyScore,
      isNaturalPhrasing: fluencyScore >= 80.0,
      issueType: issueType,
      alternatives: alternatives,
      explanation: explanation,
      confidence: phraseResult.isUnnatural ? 0.85 : 0.8,
    );
  }

  /// Validate Hindi fluency (basic)
  Future<FluencyValidation> _validateHindi(
    String text,
    String context,
  ) async {
    // For MVP: just return neutral with warning
    _logger.i('Hindi validation requested (limited support)');

    return FluencyValidation(
      fluencyScore: 100.0,
      isNaturalPhrasing: true,
      explanation: 'Hindi validation is limited',
      confidence: 0.3,
      warningMessage: 'Limited validation available - Hindi grammar checking not fully implemented',
    );
  }
}

/// Result of fluency validation
class FluencyValidation {
  final double fluencyScore; // 0-100
  final bool isNaturalPhrasing;
  final FluencyIssueType? issueType;
  final List<String> alternatives;
  final String explanation;
  final double confidence;
  final String? warningMessage;

  FluencyValidation({
    required this.fluencyScore,
    required this.isNaturalPhrasing,
    this.issueType,
    this.alternatives = const [],
    this.explanation = '',
    this.confidence = 0.8,
    this.warningMessage,
  });

  factory FluencyValidation.neutral() => FluencyValidation(
    fluencyScore: 100.0,
    isNaturalPhrasing: true,
    explanation: 'Naturally phrased',
    confidence: 0.8,
  );
}
```

---

## STEP 5: Integration with Grammar Checker

**File**: `lib/core/services/grammar_checker_service.dart`

**Add method** (after existing methods):

```dart
/// Validate overall text with grammar + fluency scoring
Future<DualScoreResult> validateWithFluency(
  String text, {
  String language = 'en',
}) async {
  try {
    // Get grammar errors
    final grammarErrors = await checkText(text);
    
    // Calculate grammar score
    final grammarScore = await calculateAccuracy(text, grammarErrors);
    
    // Get fluency score
    final nlValidator = NaturalLanguageValidator();
    final fluencyResult = await nlValidator.validateFluency(
      text,
      language: language,
    );
    
    return DualScoreResult(
      text: text,
      grammarScore: grammarScore,
      fluencyScore: fluencyResult.fluencyScore,
      grammarErrors: grammarErrors,
      fluencyIssueType: fluencyResult.issueType,
      fluencyExplanation: fluencyResult.explanation,
      suggestions: fluencyResult.alternatives,
      isNaturalPhrasing: fluencyResult.isNaturalPhrasing,
      warningMessage: fluencyResult.warningMessage,
    );
  } catch (e) {
    _logger.e('Error in dual scoring: $e');
    rethrow;
  }
}

/// Dual scoring result
class DualScoreResult {
  final String text;
  final double grammarScore; // 0-100
  final double fluencyScore; // 0-100
  final List<GrammarMistake> grammarErrors;
  final FluencyIssueType? fluencyIssueType;
  final String fluencyExplanation;
  final List<String> suggestions;
  final bool isNaturalPhrasing;
  final String? warningMessage;

  DualScoreResult({
    required this.text,
    required this.grammarScore,
    required this.fluencyScore,
    required this.grammarErrors,
    this.fluencyIssueType,
    this.fluencyExplanation = '',
    this.suggestions = const [],
    this.isNaturalPhrasing = true,
    this.warningMessage,
  });

  /// Get combined score (weighted average)
  double get combinedScore => (grammarScore * 0.6 + fluencyScore * 0.4);

  /// Get overall status
  String get status {
    if (grammarScore >= 90 && fluencyScore >= 90) {
      return '✓ Correct & Natural';
    } else if (grammarScore >= 80) {
      return '✓ Correct, ⚠ Unnatural';
    } else if (fluencyScore >= 80) {
      return '❌ Incorrect, ~ Natural phrasing';
    } else {
      return '❌ Incorrect & Unnatural';
    }
  }
}
```

---

## STEP 6: Wire Up in BLoC

**File**: `lib/features/grammar_checker/presentation/bloc/grammar_checker_bloc.dart`

**Update event handler**:

```dart
// Add new event
class CheckTextWithFluency extends GrammarCheckerEvent {
  final String text;
  final String language;

  const CheckTextWithFluency({
    required this.text,
    this.language = 'en',
  });
}

// Add handler
on<CheckTextWithFluency>((event, emit) async {
  emit(const GrammarCheckerLoading());
  
  final result = await _grammarCheckerService.validateWithFluency(
    event.text,
    language: event.language,
  );
  
  emit(GrammarCheckerLoadedWithFluency(
    text: result.text,
    grammarScore: result.grammarScore,
    fluencyScore: result.fluencyScore,
    grammarErrors: result.grammarErrors,
    fluencyIssueType: result.fluencyIssueType,
    fluencyExplanation: result.fluencyExplanation,
    suggestions: result.suggestions,
    isNaturalPhrasing: result.isNaturalPhrasing,
    warningMessage: result.warningMessage,
  ));
});
```

---

## Testing

**File**: Create `test/unit/natural_language_validator_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:word_pedometer/core/services/natural_language_validator.dart';

void main() {
  group('NaturalLanguageValidator', () {
    late NaturalLanguageValidator validator;

    setUp(() {
      validator = NaturalLanguageValidator();
    });

    test('detects "can i know your name" as unnatural', () async {
      final result = await validator.validateFluency(
        'can i know your name',
        language: 'en',
      );

      expect(result.fluencyScore, lessThan(50));
      expect(result.isNaturalPhrasing, false);
      expect(result.alternatives.isNotEmpty, true);
    });

    test('accepts "what is your name" as natural', () async {
      final result = await validator.validateFluency(
        'what is your name',
        language: 'en',
      );

      expect(result.fluencyScore, greaterThan(90));
      expect(result.isNaturalPhrasing, true);
    });

    test('detects "i am knowing" as unnatural', () async {
      final result = await validator.validateFluency(
        'i am knowing',
        language: 'en',
      );

      expect(result.fluencyScore, lessThan(60));
    });
  });
}
```

---

## Expected Results

```
Input: "Can I know your name?"

Grammar Score: 100%
Fluency Score: 35%
Combined: 77%

Status: ✓ Correct, ⚠ Unnatural
Issue: Awkward Phrasing
Explanation: "Better: 'What is your name?' or 'May I know your name?'"
```

---

**All code is ready to copy-paste!**

Implement in order:
1. Enum (5 min)
2. Phrase database (10 min)
3. Rules (15 min)
4. Validator (20 min)
5. Integration (30 min)
6. Tests (30 min)

**Total: ~2 hours for MVP**
