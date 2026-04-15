import 'package:logger/logger.dart';
import 'package:word_pedometer/core/services/conversational_phrase_database.dart';
import 'package:word_pedometer/core/services/english_fluency_rules.dart';
import 'package:word_pedometer/core/services/fluency_issue_type.dart';

/// Result of natural language validation with both detected issues and fluency score
class FluencyValidationResult {
  /// List of detected fluency issues
  final List<FluencyIssue> issues;

  /// Fluency score (0-100), where 100 is perfectly natural
  final double fluencyScore;

  /// Overall assessment of naturalness
  final String assessment;

  /// Specific suggestions for improvement
  final List<String> suggestions;

  /// Whether the text is acceptable despite fluency issues
  final bool isAcceptable;

  FluencyValidationResult({
    required this.issues,
    required this.fluencyScore,
    required this.assessment,
    required this.suggestions,
    required this.isAcceptable,
  });

  @override
  String toString() => 'FluencyValidationResult('
      'score: $fluencyScore%, issues: ${issues.length}, acceptable: $isAcceptable)';
}

/// Main service for validating natural language fluency
/// Uses both phrase database and pattern-based rule detection
class NaturalLanguageValidator {
  final Logger _logger = Logger();
  late final ConversationalPhraseDatabase _phraseDatabase;
  late final EnglishFluencyRules _fluencyRules;

  NaturalLanguageValidator({
    ConversationalPhraseDatabase? phraseDatabase,
    EnglishFluencyRules? fluencyRules,
  }) {
    _phraseDatabase = phraseDatabase ?? ConversationalPhraseDatabase();
    _fluencyRules = fluencyRules ?? EnglishFluencyRules();
    _logger.i('NaturalLanguageValidator initialized');
  }

  /// Validate text for natural language fluency
  /// Returns a comprehensive assessment of naturalness
  Future<FluencyValidationResult> validate(String text) async {
    try {
      if (text.isEmpty) {
        return FluencyValidationResult(
          issues: [],
          fluencyScore: 100.0,
          assessment: 'No text to validate',
          suggestions: [],
          isAcceptable: true,
        );
      }

      // Step 1: Check for unnatural phrases from database
      final phraseIssues = _checkConversationalPhrases(text);

      // Step 2: Check for pattern-based fluency issues
      final patternIssues = _fluencyRules.checkFluency(text);

      // Step 3: Combine all issues
      final allIssues = <FluencyIssue>[...phraseIssues, ...patternIssues];

      // Step 4: Calculate fluency score
      final fluencyScore = _calculateFluencyScore(text, allIssues);

      // Step 5: Generate assessment and suggestions
      final assessment = _generateAssessment(fluencyScore, allIssues);
      final suggestions = _generateSuggestions(allIssues);
      final isAcceptable = fluencyScore >= 50.0; // Minimum 50% for acceptance

      final result = FluencyValidationResult(
        issues: allIssues,
        fluencyScore: fluencyScore,
        assessment: assessment,
        suggestions: suggestions,
        isAcceptable: isAcceptable,
      );

      _logger.d('Validation result: $result');
      return result;
    } catch (e) {
      _logger.e('Error validating text: $e');
      rethrow;
    }
  }

  /// Check for unnatural phrases from the conversational database
  List<FluencyIssue> _checkConversationalPhrases(String text) {
    final issues = <FluencyIssue>[];
    final phrases = _phraseDatabase.findAllUnnaturalPhrases(text);

    for (final (phrase, mapping) in phrases) {
      // Find position in text
      final startPos = text.toLowerCase().indexOf(phrase.toLowerCase());
      if (startPos >= 0) {
        final issueType = _mapPhraseToIssueType(mapping);

        issues.add(FluencyIssue(
          text: phrase,
          issueType: issueType,
          startPosition: startPos,
          endPosition: startPos + phrase.length,
          explanation: mapping.explanation,
          suggestions: mapping.naturalAlternatives,
          severity: mapping.isCritical ? 0.8 : 0.5,
        ));
      }
    }

    return issues;
  }

  /// Map a phrase mapping to a fluency issue type
  FluencyIssueType _mapPhraseToIssueType(PhraseMapping mapping) {
    final unnatural = mapping.unnatural.toLowerCase();

    if (unnatural.contains('am') && unnatural.contains('know')) {
      return FluencyIssueType.incorrectProgressive;
    }

    if (unnatural.contains('can i know')) {
      return FluencyIssueType.unnaturalQuestion;
    }

    if (unnatural.contains('am coming from') || unnatural.contains('from')) {
      return FluencyIssueType.hindiTransferError;
    }

    if (unnatural.contains('one thing') || unnatural.contains('one more')) {
      return FluencyIssueType.awkwardParticle;
    }

    return FluencyIssueType.unnaturalPhrasing;
  }

  /// Calculate fluency score based on issues found
  /// Returns score from 0-100
  double _calculateFluencyScore(String text, List<FluencyIssue> issues) {
    if (issues.isEmpty) {
      return 100.0;
    }

    // Base score
    double score = 100.0;

    // Deduct based on severity of each issue
    for (final issue in issues) {
      final penalty = issue.severity * 15; // Max 15 points per issue
      score -= penalty;
    }

    // Extra penalty for critical issues
    final criticalCount = issues.where((i) => i.severity > 0.7).length;
    score -= (criticalCount * 10);

    // Normalize to 0-100 range
    return score.clamp(0.0, 100.0);
  }

  /// Generate assessment text based on fluency score
  String _generateAssessment(double score, List<FluencyIssue> issues) {
    if (score >= 95) {
      return '✓ Excellent fluency';
    } else if (score >= 80) {
      return '✓ Good fluency';
    } else if (score >= 65) {
      return '⚠ Acceptable but could be more natural';
    } else if (score >= 50) {
      return '⚠ Multiple fluency issues detected';
    } else {
      return '❌ Significant fluency problems';
    }
  }

  /// Generate specific suggestions for improvement
  List<String> _generateSuggestions(List<FluencyIssue> issues) {
    final suggestions = <String>[];

    if (issues.isEmpty) {
      return ['Your phrasing sounds natural!'];
    }

    // Add specific suggestions from issues
    for (final issue in issues) {
      if (issue.suggestions.isNotEmpty) {
        suggestions.add(
          'Instead of "${issue.text}", try: ${issue.suggestions.first}',
        );
      }
    }

    // Add general guidance
    final criticalIssues = issues.where((i) => i.severity > 0.7).toList();
    if (criticalIssues.isNotEmpty) {
      suggestions.add(
        'Focus on: ${criticalIssues.map((i) => i.issueType.displayName).join(", ")}',
      );
    }

    return suggestions.take(5).toList(); // Return top 5 suggestions
  }

  /// Get detailed report for a single piece of text
  Future<String> getDetailedReport(String text) async {
    final result = await validate(text);

    final buffer = StringBuffer();
    buffer.writeln('=== Natural Language Fluency Report ===');
    buffer.writeln('Fluency Score: ${result.fluencyScore.toStringAsFixed(1)}%');
    buffer.writeln('Assessment: ${result.assessment}');
    buffer.writeln('Acceptable: ${result.isAcceptable ? "Yes" : "No"}');

    if (result.issues.isNotEmpty) {
      buffer.writeln('\nIssues Found:');
      for (var i = 0; i < result.issues.length; i++) {
        final issue = result.issues[i];
        buffer.writeln('  ${i + 1}. ${issue.issueType.displayName}');
        buffer.writeln('     Text: "${issue.text}"');
        buffer.writeln('     Explanation: ${issue.explanation}');
        buffer.writeln('     Suggestions: ${issue.suggestions.join(", ")}');
      }
    }

    if (result.suggestions.isNotEmpty) {
      buffer.writeln('\nRecommendations:');
      for (var i = 0; i < result.suggestions.length; i++) {
        buffer.writeln('  ${i + 1}. ${result.suggestions[i]}');
      }
    }

    return buffer.toString();
  }

  /// Get brief summary for UI display
  String getSummary(FluencyValidationResult result) {
    if (result.issues.isEmpty) {
      return 'Natural and fluent';
    }

    final topIssue =
        result.issues.reduce((a, b) => a.severity > b.severity ? a : b);
    return 'Issue detected: ${topIssue.issueType.displayName}';
  }
}
