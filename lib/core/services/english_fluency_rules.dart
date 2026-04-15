import 'package:logger/logger.dart';
import 'package:word_pedometer/core/services/fluency_issue_type.dart';

/// Represents a detected fluency issue with position information
class FluencyIssue {
  final String text; // The problematic text
  final FluencyIssueType issueType;
  final int startPosition;
  final int endPosition;
  final String explanation;
  final List<String> suggestions;
  final double severity; // 0.0-1.0, where 1.0 is most severe

  FluencyIssue({
    required this.text,
    required this.issueType,
    required this.startPosition,
    required this.endPosition,
    required this.explanation,
    required this.suggestions,
    required this.severity,
  });

  @override
  String toString() =>
      'FluencyIssue($issueType, pos: $startPosition-$endPosition, severity: $severity)';
}

/// Pattern-based rules for detecting unnatural English phrasing
/// Detects common patterns without relying on a phrase database
class EnglishFluencyRules {
  final Logger _logger = Logger();

  /// Progressive tense with stative verbs - pattern detection
  /// e.g., "am knowing", "is having", "are understanding"
  final RegExp _stativeProgressivePattern = RegExp(
    r'\b(am|is|are|was|were)\s+(knowing|having|understanding|wanting|liking|loving|hating|believing|thinking|remembering|forgetting|feeling|meaning|containing|owning|existing|appearing|belonging|being|seeming)\b',
    caseSensitive: false,
  );

  /// Question word order error
  /// e.g., "what you are doing" should be "what are you doing"
  /// Pattern: question word followed by subject then verb
  final RegExp _questionWordOrderPattern = RegExp(
    r'\b(what|where|who|when|which|how|why)\s+([A-Z][a-z]+|I|you|he|she|it|we|they)\s+(is|am|are|was|were|do|does|did|have|has|had)\b',
    caseSensitive: false,
  );

  /// Unnatural word order: adverb before auxiliary
  /// e.g., "very much thank you" should be "thank you very much"
  final RegExp _adverbBeforeAuxPattern = RegExp(
    r'\b(very|really|extremely)\s+(much|soon|often|now)\s+(thank|tell|ask|help|like|want)\b',
    caseSensitive: false,
  );

  /// Repeated progressive forms (Hindi pattern)
  /// e.g., "I am doing going" or "I am come coming"
  final RegExp _doubleProgressivePattern = RegExp(
    r'\b(am|is|are)\s+(\w+ing)\s+(going|coming|knowing|having)\b',
    caseSensitive: false,
  );

  /// Missing article before consonant sound
  /// Common pattern: vowel verb + noun starting with consonant
  final RegExp _missingArticlePattern = RegExp(
    r'\b(am|is|are|was|were)\s+[aeiou]([bdfghjklmnpqrstvwxyz][a-z]+)\b',
    caseSensitive: false,
  );

  EnglishFluencyRules() {
    _logger.i('EnglishFluencyRules initialized');
  }

  /// Check text for all fluency issues
  List<FluencyIssue> checkFluency(String text) {
    final issues = <FluencyIssue>[];

    issues.addAll(_checkStativeProgressive(text));
    issues.addAll(_checkQuestionWordOrder(text));
    issues.addAll(_checkAdverbWordOrder(text));
    issues.addAll(_checkDoubleProgressive(text));
    issues.addAll(_checkMissingArticles(text));
    issues.addAll(_checkHindiTransferPatterns(text));

    // Sort by position for consistency
    issues.sort((a, b) => a.startPosition.compareTo(b.startPosition));

    return issues;
  }

  /// Detect progressive forms with stative verbs
  /// "I am knowing", "is having", etc.
  List<FluencyIssue> _checkStativeProgressive(String text) {
    final issues = <FluencyIssue>[];
    final matches = _stativeProgressivePattern.allMatches(text);

    for (final match in matches) {
      final auxiliary = match.group(1) ?? '';
      final stativeVerb = match.group(2) ?? '';

      issues.add(FluencyIssue(
        text: match.group(0) ?? '',
        issueType: FluencyIssueType.incorrectProgressive,
        startPosition: match.start,
        endPosition: match.end,
        explanation:
            '"$stativeVerb" is a stative verb and should not be used with progressive form "$auxiliary $stativeVerb"',
        suggestions: [
          'Use simple present: "$stativeVerb"',
          'Example: "I $stativeVerb" instead of "$auxiliary $stativeVerb"',
        ],
        severity: 0.7,
      ));
    }

    return issues;
  }

  /// Detect inverted question word order (common Hindi transfer error)
  /// "what you are doing" should be "what are you doing"
  List<FluencyIssue> _checkQuestionWordOrder(String text) {
    final issues = <FluencyIssue>[];

    // Simple pattern: check for question words not at start of question
    final questionWords = [
      'what',
      'where',
      'who',
      'when',
      'which',
      'how',
      'why'
    ];
    final auxiliaryVerbs = [
      'is',
      'am',
      'are',
      'was',
      'were',
      'do',
      'does',
      'did'
    ];

    for (final word in questionWords) {
      for (final aux in auxiliaryVerbs) {
        final pattern = RegExp(
          r'\b' + word + r'\s+(\w+)\s+' + aux + r'\b',
          caseSensitive: false,
        );
        final matches = pattern.allMatches(text);

        for (final match in matches) {
          final subject = match.group(1) ?? '';
          issues.add(FluencyIssue(
            text: match.group(0) ?? '',
            issueType: FluencyIssueType.wordOrderIssue,
            startPosition: match.start,
            endPosition: match.end,
            explanation:
                'Question word order: auxiliary verb should come before subject',
            suggestions: [
              '$word $aux $subject ${_getVerbBase(word)}?',
              'Correct pattern: [Question word] [Auxiliary] [Subject]?',
            ],
            severity: 0.6,
          ));
        }
      }
    }

    return issues;
  }

  /// Detect adverb before auxiliary pattern
  /// "very much thank you" should be "thank you very much"
  List<FluencyIssue> _checkAdverbWordOrder(String text) {
    final issues = <FluencyIssue>[];

    final patterns = [
      'very much thank',
      'very much like',
      'very much want',
      'very much help',
    ];

    for (final pattern in patterns) {
      final regex = RegExp(pattern, caseSensitive: false);
      final matches = regex.allMatches(text);

      for (final match in matches) {
        final parts = match.group(0)!.split(RegExp(r'\s+'));
        final verb = parts.last;

        issues.add(FluencyIssue(
          text: match.group(0) ?? '',
          issueType: FluencyIssueType.wordOrderIssue,
          startPosition: match.start,
          endPosition: match.end,
          explanation:
              'Adverbs of degree should come after the verb, not before',
          suggestions: [
            '${verb} ${parts.take(parts.length - 1).join(" ")}',
            'Example: "$verb very much" or just "$verb"',
          ],
          severity: 0.4,
        ));
      }
    }

    return issues;
  }

  /// Detect double progressive forms (Hindi speaker pattern)
  /// "I am doing going" or similar constructions
  List<FluencyIssue> _checkDoubleProgressive(String text) {
    final issues = <FluencyIssue>[];
    final matches = _doubleProgressivePattern.allMatches(text);

    for (final match in matches) {
      final aux = match.group(1) ?? '';
      final firstVerb = match.group(2) ?? '';
      final secondVerb = match.group(3) ?? '';

      issues.add(FluencyIssue(
        text: match.group(0) ?? '',
        issueType: FluencyIssueType.hindiTransferError,
        startPosition: match.start,
        endPosition: match.end,
        explanation:
            'Double progressive form is not natural in English; use only one progressive verb',
        suggestions: [
          '$aux $firstVerb',
          '$aux $secondVerb',
          'Only use one -ing form with auxiliary verb',
        ],
        severity: 0.8,
      ));
    }

    return issues;
  }

  /// Detect missing articles (basic pattern)
  /// "I am doctor" should be "I am a doctor"
  List<FluencyIssue> _checkMissingArticles(String text) {
    final issues = <FluencyIssue>[];

    // Pattern: "is/am/are" + vowel + noun (likely uncountable starting with vowel)
    // More advanced: could check for consonant sounds
    final patterns = [
      RegExp(
          r'\b(am|is|are)\s+(engineer|artist|actor|author|accountant|architect)\b',
          caseSensitive: false),
      RegExp(
          r'\b(am|is|are)\s+(Indian|American|American|Australian|Austrian)\b',
          caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);

      for (final match in matches) {
        final auxiliary = match.group(1) ?? '';
        final noun = match.group(2) ?? '';
        final article = _startsWithVowelSound(noun) ? 'an' : 'a';

        issues.add(FluencyIssue(
          text: match.group(0) ?? '',
          issueType: FluencyIssueType.awkwardParticle,
          startPosition: match.start,
          endPosition: match.end,
          explanation: 'Missing indefinite article before noun',
          suggestions: [
            '$auxiliary $article $noun',
          ],
          severity: 0.5,
        ));
      }
    }

    return issues;
  }

  /// Detect common Hindi-to-English transfer errors
  List<FluencyIssue> _checkHindiTransferPatterns(String text) {
    final issues = <FluencyIssue>[];

    // "Can I know your name?" pattern
    if (RegExp(r'\bcan\s+[I|you|they|we]\s+know\b', caseSensitive: false)
        .hasMatch(text)) {
      final match =
          RegExp(r'\bcan\s+[I|you|they|we]\s+know\b', caseSensitive: false)
              .firstMatch(text);

      if (match != null) {
        issues.add(FluencyIssue(
          text: match.group(0) ?? '',
          issueType: FluencyIssueType.unnaturalQuestion,
          startPosition: match.start,
          endPosition: match.end,
          explanation:
              '"Can I know" is grammatically odd; better to ask "what is" or "may I know"',
          suggestions: [
            'What is your name?',
            'May I know your name?',
            'Could you tell me your name?',
          ],
          severity: 0.6,
        ));
      }
    }

    // "I am coming from" pattern
    if (RegExp(r'\bam\s+coming\s+from\b', caseSensitive: false)
        .hasMatch(text)) {
      final match = RegExp(r'\bam\s+coming\s+from\b', caseSensitive: false)
          .firstMatch(text);

      if (match != null) {
        issues.add(FluencyIssue(
          text: match.group(0) ?? '',
          issueType: FluencyIssueType.hindiTransferError,
          startPosition: match.start,
          endPosition: match.end,
          explanation:
              'Unnatural use of progressive; "come from" uses simple present',
          suggestions: [
            'come from',
            'am from',
          ],
          severity: 0.7,
        ));
      }
    }

    return issues;
  }

  /// Helper: Check if a word starts with a vowel sound
  bool _startsWithVowelSound(String word) {
    if (word.isEmpty) return false;
    return 'aeiou'.contains(word.toLowerCase()[0]);
  }

  /// Helper: Get base form of a verb
  String _getVerbBase(String verb) {
    // Simplified; could be expanded
    return verb.endsWith('ing') ? verb.replaceAll(RegExp(r'ing$'), '') : verb;
  }
}
