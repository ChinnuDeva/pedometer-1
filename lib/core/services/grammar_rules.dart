import 'package:uuid/uuid.dart';
import 'package:word_pedometer/core/services/grammar_rules_engine.dart';
import 'package:word_pedometer/features/grammar_checker/domain/entities/grammar_mistake.dart';

/// Rule 1: Subject-Verb Agreement
/// Detects mismatches between subject and verb (e.g., "he are" vs "he is")
class SubjectVerbAgreementRule extends GrammarRule {
  // Common subject-verb agreement patterns
  static const Map<String, String> _corrections = {
    // Singular subjects should use singular verbs
    'i am': 'i am',
    'i is': 'i am',
    'he is': 'he is',
    'he are': 'he is',
    'she is': 'she is',
    'she are': 'she is',
    'it is': 'it is',
    'it are': 'it is',
    // Plural subjects should use plural verbs
    'we are': 'we are',
    'we is': 'we are',
    'you are': 'you are',
    'you is': 'you are',
    'they are': 'they are',
    'they is': 'they are',
    // Past tense
    'i was': 'i was',
    'i were': 'i was',
    'he was': 'he was',
    'he were': 'he was',
    'she was': 'she was',
    'she were': 'she was',
    'it was': 'it was',
    'it were': 'it was',
    'we were': 'we were',
    'we was': 'we were',
    'you were': 'you were',
    'you was': 'you were',
    'they were': 'they were',
    'they was': 'they were',
  };

  @override
  String get ruleName => 'Subject-Verb Agreement';

  @override
  GrammarErrorType get errorType => GrammarErrorType.subjectVerbAgreement;

  @override
  ErrorSeverity get severity => ErrorSeverity.major;

  @override
  String get description =>
      'Checks that subjects and verbs agree in number (singular/plural)';

  @override
  List<GrammarMistake> check(String text, int sessionId) {
    final mistakes = <GrammarMistake>[];
    final words = text.toLowerCase().split(RegExp(r'\s+'));

    for (var i = 0; i < words.length - 1; i++) {
      final twoWords = '${words[i]} ${words[i + 1]}'
          .replaceAll(RegExp(r'[.,!?;:]'), '');

      if (_corrections.containsKey(twoWords) &&
          _corrections[twoWords] != twoWords) {
        final startPos = text.toLowerCase().indexOf(twoWords);
        if (startPos != -1) {
          mistakes.add(
            GrammarMistake(
              id: const Uuid().v4(),
              text: twoWords,
              suggestion: 'Use "${_corrections[twoWords]}" instead',
              errorType: errorType,
              startPosition: startPos,
              endPosition: startPos + twoWords.length,
              confidence: 0.95,
            ),
          );
        }
      }
    }

    return mistakes;
  }
}

/// Rule 2: Article Usage (a/an/the)
/// Detects missing or incorrect articles
class ArticleUsageRule extends GrammarRule {
  static const List<String> _vowelSounds = [
    'a',
    'e',
    'i',
    'o',
    'u',
  ];

  @override
  String get ruleName => 'Article Usage';

  @override
  GrammarErrorType get errorType => GrammarErrorType.other;

  @override
  ErrorSeverity get severity => ErrorSeverity.minor;

  @override
  String get description =>
      'Checks for correct usage of articles (a, an, the)';

  @override
  List<GrammarMistake> check(String text, int sessionId) {
    final mistakes = <GrammarMistake>[];
    final words = text.split(RegExp(r'\s+'));

    for (var i = 0; i < words.length - 1; i++) {
      final currentWord = words[i].toLowerCase();
      final nextWord = words[i + 1].toLowerCase();

      // Check for "a" before vowel sounds
      if (currentWord == 'a' &&
          _vowelSounds.contains(nextWord[0]) &&
          nextWord[0] != 'u') {
        final startPos = text.toLowerCase().indexOf('$currentWord $nextWord');
        if (startPos != -1) {
          mistakes.add(
            GrammarMistake(
              id: const Uuid().v4(),
              text: '$currentWord $nextWord',
              suggestion: 'Use "an" instead of "a" before a vowel sound',
              errorType: errorType,
              startPosition: startPos,
              endPosition: startPos + currentWord.length,
              confidence: 0.85,
            ),
          );
        }
      }

      // Check for "an" before consonant sounds
      if (currentWord == 'an' &&
          !_vowelSounds.contains(nextWord[0]) &&
          nextWord[0].isNotEmpty) {
        final startPos = text.toLowerCase().indexOf('$currentWord $nextWord');
        if (startPos != -1) {
          mistakes.add(
            GrammarMistake(
              id: const Uuid().v4(),
              text: '$currentWord $nextWord',
              suggestion: 'Use "a" instead of "an" before a consonant sound',
              errorType: errorType,
              startPosition: startPos,
              endPosition: startPos + currentWord.length,
              confidence: 0.85,
            ),
          );
        }
      }
    }

    return mistakes;
  }
}

/// Rule 3: Tense Consistency
/// Detects sudden shifts in verb tense
class TenseConsistencyRule extends GrammarRule {
  static const Map<String, String> _tenseFamilies = {
    'present': 'is|are|go|goes|eat|eats',
    'past': 'was|were|went|ate',
    'future': 'will|shall|going',
  };

  @override
  String get ruleName => 'Tense Consistency';

  @override
  GrammarErrorType get errorType => GrammarErrorType.tenseMismatch;

  @override
  ErrorSeverity get severity => ErrorSeverity.major;

  @override
  String get description =>
      'Checks that verb tense remains consistent throughout the text';

  @override
  List<GrammarMistake> check(String text, int sessionId) {
    final mistakes = <GrammarMistake>[];
    final words = text.toLowerCase().split(RegExp(r'\s+'));

    String? establishedTense;

    for (var i = 0; i < words.length; i++) {
      final word = words[i].replaceAll(RegExp(r'[.,!?;:]'), '');

      // Detect verbs and their tenses
      for (final entry in _tenseFamilies.entries) {
        final regex = RegExp(entry.value);
        if (regex.hasMatch(word)) {
          if (establishedTense == null) {
            establishedTense = entry.key;
          } else if (establishedTense != entry.key) {
            final startPos = text.toLowerCase().indexOf(word);
            if (startPos != -1) {
              mistakes.add(
                GrammarMistake(
                  id: const Uuid().v4(),
                  text: word,
                  suggestion:
                      'Tense shift detected. Use $establishedTense tense',
                  errorType: errorType,
                  startPosition: startPos,
                  endPosition: startPos + word.length,
                  confidence: 0.75,
                ),
              );
            }
          }
          break;
        }
      }
    }

    return mistakes;
  }
}

/// Rule 4: Common Spelling/Contraction Errors
/// Detects common misspellings and missing apostrophes
class CommonErrorsRule extends GrammarRule {
  static const Map<String, String> _commonErrors = {
    'dont': "don't",
    'cant': "can't",
    'wont': "won't",
    'wouldnt': "wouldn't",
    'couldnt': "couldn't",
    'shouldnt': "shouldn't",
    'isnt': "isn't",
    'arent': "aren't",
    'wasnt': "wasn't",
    'werent': "weren't",
    'havent': "haven't",
    'hasnt': "hasn't",
    'im': "I'm",
    'ive': "I've",
    'theyre': "they're",
    'its': "it's",
    'were': "we're",
    'thier': 'their',
    'recieve': 'receive',
    'occured': 'occurred',
    'untill': 'until',
    'wierd': 'weird',
  };

  @override
  String get ruleName => 'Common Errors';

  @override
  GrammarErrorType get errorType => GrammarErrorType.spelling;

  @override
  ErrorSeverity get severity => ErrorSeverity.minor;

  @override
  String get description =>
      'Detects common spelling mistakes and missing apostrophes';

  @override
  List<GrammarMistake> check(String text, int sessionId) {
    final mistakes = <GrammarMistake>[];

    _commonErrors.forEach((error, correction) {
      final regex = RegExp(r'\b' + error + r'\b', caseSensitive: false);
      final matches = regex.allMatches(text.toLowerCase());

      for (final match in matches) {
        mistakes.add(
          GrammarMistake(
            id: const Uuid().v4(),
            text: text.substring(match.start, match.end),
            suggestion: 'Did you mean "$correction"?',
            errorType: errorType,
            startPosition: match.start,
            endPosition: match.end,
            confidence: 0.9,
          ),
        );
      }
    });

    return mistakes;
  }
}

/// Rule 5: Word Order Issues
/// Detects common word order problems
class WordOrderRule extends GrammarRule {
  @override
  String get ruleName => 'Word Order';

  @override
  GrammarErrorType get errorType => GrammarErrorType.sentenceStructure;

  @override
  ErrorSeverity get severity => ErrorSeverity.major;

  @override
  String get description =>
      'Checks for correct word order in sentences and phrases';

  @override
  List<GrammarMistake> check(String text, int sessionId) {
    final mistakes = <GrammarMistake>[];

    // Check for adverb placement issues (adverbs usually go after auxiliary verbs)
    final adverbIssues = [
      RegExp(r'\b(is|are|was|were|be|been)\s+(very|really|too|quite)\s+(\w+ed)\b',
          caseSensitive: false),
    ];

    for (final pattern in adverbIssues) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        mistakes.add(
          GrammarMistake(
            id: const Uuid().v4(),
            text: match.group(0) ?? 'text',
            suggestion:
                'Check word order: verb modifiers should be placed correctly',
            errorType: errorType,
            startPosition: match.start,
            endPosition: match.end,
            confidence: 0.7,
          ),
        );
      }
    }

    return mistakes;
  }
}

/// Rule 6: Pronoun-Antecedent Agreement
/// Detects mismatches between pronouns and their antecedents
class PronounAgreementRule extends GrammarRule {
  @override
  String get ruleName => 'Pronoun-Antecedent Agreement';

  @override
  GrammarErrorType get errorType => GrammarErrorType.sentenceStructure;

  @override
  ErrorSeverity get severity => ErrorSeverity.major;

  @override
  String get description =>
      'Checks that pronouns agree with their antecedent nouns';

  @override
  List<GrammarMistake> check(String text, int sessionId) {
    final mistakes = <GrammarMistake>[];

    // Check for singular antecedent with plural pronoun
    final singularAntePattern = RegExp(
      r'\b(everyone|anybody|someone|each|every|neither|either)\s+(\w+\s+)?them\b',
      caseSensitive: false,
    );

    final matches = singularAntePattern.allMatches(text);
    for (final match in matches) {
      mistakes.add(
        GrammarMistake(
          id: const Uuid().v4(),
          text: match.group(0) ?? 'text',
          suggestion: 'Use "him/her" or rewrite to use "their" grammatically',
          errorType: errorType,
          startPosition: match.start,
          endPosition: match.end,
          confidence: 0.8,
        ),
      );
    }

    return mistakes;
  }
}

/// Rule 7: Comma Splice Detection
/// Detects sentences joined with commas instead of proper punctuation
class CommaSpliceRule extends GrammarRule {
  @override
  String get ruleName => 'Comma Splice';

  @override
  GrammarErrorType get errorType => GrammarErrorType.punctuation;

  @override
  ErrorSeverity get severity => ErrorSeverity.major;

  @override
  String get description =>
      'Detects comma splices (two independent clauses joined only by a comma)';

  @override
  List<GrammarMistake> check(String text, int sessionId) {
    final mistakes = <GrammarMistake>[];

    // Look for pattern: independent clause + comma + independent clause
    final commaPattern = RegExp(r'[^,]+,\s+[a-z]\w+\s+(is|are|was|were|have)',
        caseSensitive: false);

    final matches = commaPattern.allMatches(text);
    for (final match in matches) {
      mistakes.add(
        GrammarMistake(
          id: const Uuid().v4(),
          text: match.group(0) ?? 'text',
          suggestion:
              'Comma splice detected. Use a semicolon, period, or conjunction instead',
          errorType: errorType,
          startPosition: match.start,
          endPosition: match.end,
          confidence: 0.75,
        ),
      );
    }

    return mistakes;
  }
}

/// Rule 8: Double Negation
/// Detects double negatives which are typically non-standard
class DoubleNegationRule extends GrammarRule {
  @override
  String get ruleName => 'Double Negation';

  @override
  GrammarErrorType get errorType => GrammarErrorType.sentenceStructure;

  @override
  ErrorSeverity get severity => ErrorSeverity.minor;

  @override
  String get description =>
      'Detects double negatives which are typically non-standard';

  @override
  List<GrammarMistake> check(String text, int sessionId) {
    final mistakes = <GrammarMistake>[];

    // Look for common double negation patterns
    final patterns = [
      RegExp(r'\b(not|no|never|neither)\s+\w+\s+(not|no|never)\b',
          caseSensitive: false),
      RegExp(r"\b(can't|won't|don't)\s+\w+\s+no\b", caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        mistakes.add(
          GrammarMistake(
            id: const Uuid().v4(),
            text: match.group(0) ?? 'text',
            suggestion:
                'Avoid double negatives. Rewrite to express one negative idea',
            errorType: errorType,
            startPosition: match.start,
            endPosition: match.end,
            confidence: 0.8,
          ),
        );
      }
    }

    return mistakes;
  }
}

/// Factory to create all default grammar rules
class DefaultGrammarRules {
  /// Get all default grammar rules
  static List<GrammarRule> getAllRules() {
    return [
      SubjectVerbAgreementRule(),
      ArticleUsageRule(),
      TenseConsistencyRule(),
      CommonErrorsRule(),
      WordOrderRule(),
      PronounAgreementRule(),
      CommaSpliceRule(),
      DoubleNegationRule(),
    ];
  }
}
