import 'package:logger/logger.dart';
import 'package:word_pedometer/core/services/grammar_rules.dart';
import 'package:word_pedometer/core/services/grammar_rules_engine.dart';
import 'package:word_pedometer/core/services/natural_language_validator.dart';
import 'package:word_pedometer/features/grammar_checker/domain/entities/grammar_mistake.dart';

/// Grammar Checker Service
/// High-level wrapper around the GrammarRulesEngine that provides
/// convenient methods for checking grammar and calculating metrics
class GrammarCheckerService {
  final GrammarRulesEngine _engine;
  final Logger _logger = Logger();
  late final NaturalLanguageValidator _nlValidator;

  GrammarCheckerService({
    GrammarRulesEngine? engine,
    NaturalLanguageValidator? nlValidator,
  }) : _engine = engine ?? GrammarRulesEngine() {
    _nlValidator = nlValidator ?? NaturalLanguageValidator();
    _initializeDefaultRules();
  }

  /// Initialize with default grammar rules
  void _initializeDefaultRules() {
    _engine.registerRules(DefaultGrammarRules.getAllRules());
    _logger.i('Grammar checker initialized with default rules');
  }

  /// Check text for grammar errors
  /// Returns a list of GrammarMistake objects found in the text
  Future<List<GrammarMistake>> checkText(
    String text, {
    int sessionId = 0,
  }) async {
    try {
      if (text.isEmpty) {
        return [];
      }

      final mistakes = _engine.checkText(text, sessionId: sessionId);
      _logger.i('Grammar check complete: ${mistakes.length} errors found');
      return mistakes;
    } catch (e) {
      _logger.e('Error checking grammar: $e');
      rethrow;
    }
  }

  /// Check text for both grammar and fluency issues
  /// Returns mistakes with fluency information attached
  Future<List<GrammarMistake>> checkTextWithFluency(
    String text, {
    int sessionId = 0,
  }) async {
    try {
      if (text.isEmpty) {
        return [];
      }

      // Get grammar mistakes
      final grammaticalMistakes = _engine.checkText(text, sessionId: sessionId);

      // Get fluency validation
      final fluencyResult = await _nlValidator.validate(text);

      // Merge fluency issues into mistakes
      final enrichedMistakes = _enrichMistakesWithFluency(
        grammaticalMistakes,
        fluencyResult,
      );

      _logger.i(
        'Grammar + fluency check complete: ${enrichedMistakes.length} total issues',
      );
      return enrichedMistakes;
    } catch (e) {
      _logger.e('Error checking grammar and fluency: $e');
      rethrow;
    }
  }

  /// Get fluency validation for text without grammar checking
  Future<FluencyValidationResult> checkFluency(String text) async {
    try {
      return await _nlValidator.validate(text);
    } catch (e) {
      _logger.e('Error checking fluency: $e');
      rethrow;
    }
  }

  /// Get detailed fluency report
  Future<String> getFluencyReport(String text) async {
    try {
      return await _nlValidator.getDetailedReport(text);
    } catch (e) {
      _logger.e('Error generating fluency report: $e');
      rethrow;
    }
  }

  /// Calculate combined grammar and fluency accuracy
  /// Returns (grammarAccuracy, fluencyScore, combinedScore)
  Future<(double, double, double)> calculateCombinedAccuracy(
    String text,
    List<GrammarMistake> mistakes,
  ) async {
    try {
      if (text.isEmpty) return (100.0, 100.0, 100.0);

      // Calculate grammar accuracy
      final grammarAccuracy = await calculateAccuracy(text, mistakes);

      // Get fluency score
      final fluencyResult = await _nlValidator.validate(text);
      final fluencyScore = fluencyResult.fluencyScore;

      // Calculate combined score (average of both)
      final combinedScore = (grammarAccuracy + fluencyScore) / 2;

      _logger.d(
        'Combined accuracy: grammar=$grammarAccuracy%, fluency=$fluencyScore%, combined=$combinedScore%',
      );

      return (grammarAccuracy, fluencyScore, combinedScore);
    } catch (e) {
      _logger.e('Error calculating combined accuracy: $e');
      rethrow;
    }
  }

  /// Calculate accuracy percentage based on mistakes found
  /// Accuracy = (total_words - mistake_count) / total_words * 100
  Future<double> calculateAccuracy(
    String text,
    List<GrammarMistake> mistakes,
  ) async {
    try {
      if (text.isEmpty) return 100.0;

      final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
      final wordCount = words.length;

      if (wordCount == 0) return 100.0;

      // One mistake might affect multiple words, so cap at 1 per mistake
      final errorCount = mistakes.length;
      final accuracy =
          ((wordCount - errorCount) / wordCount * 100).clamp(0.0, 100.0);

      _logger.d(
        'Accuracy calculated: $accuracy% ($wordCount words, $errorCount errors)',
      );
      return accuracy;
    } catch (e) {
      _logger.e('Error calculating accuracy: $e');
      rethrow;
    }
  }

  /// Get statistics about errors found
  Future<GrammarStatistics> getErrorStatistics(
    List<GrammarMistake> mistakes,
  ) async {
    try {
      final byType = <GrammarErrorType, int>{};
      final bySeverity = <ErrorSeverity, int>{};
      final byConfidence = <String, int>{};

      for (final mistake in mistakes) {
        byType[mistake.errorType] = (byType[mistake.errorType] ?? 0) + 1;

        // Determine severity from registered rules
        final rule = _engine
            .getRules()
            .where((r) => r.errorType == mistake.errorType)
            .firstOrNull;
        if (rule != null) {
          bySeverity[rule.severity] = (bySeverity[rule.severity] ?? 0) + 1;
        }

        // Categorize by confidence level
        final confidenceLevel = mistake.confidence >= 0.9
            ? 'high'
            : mistake.confidence >= 0.75
                ? 'medium'
                : 'low';
        byConfidence[confidenceLevel] =
            (byConfidence[confidenceLevel] ?? 0) + 1;
      }

      final stats = GrammarStatistics(
        totalErrors: mistakes.length,
        errorsByType: byType,
        errorsBySeverity: bySeverity,
        errorsByConfidence: byConfidence,
        criticalErrors: bySeverity[ErrorSeverity.critical] ?? 0,
        majorErrors: bySeverity[ErrorSeverity.major] ?? 0,
        minorErrors: bySeverity[ErrorSeverity.minor] ?? 0,
      );

      _logger.d('Error statistics: $stats');
      return stats;
    } catch (e) {
      _logger.e('Error calculating statistics: $e');
      rethrow;
    }
  }

  /// Get errors grouped by type for easier analysis
  Future<Map<GrammarErrorType, List<GrammarMistake>>> getErrorsByType(
    List<GrammarMistake> mistakes,
  ) async {
    try {
      final grouped = <GrammarErrorType, List<GrammarMistake>>{};

      for (final mistake in mistakes) {
        grouped[mistake.errorType] ??= [];
        grouped[mistake.errorType]!.add(mistake);
      }

      return grouped;
    } catch (e) {
      _logger.e('Error grouping by type: $e');
      rethrow;
    }
  }

  /// Get top N most common error types
  Future<List<(GrammarErrorType, int)>> getTopErrorTypes(
    List<GrammarMistake> mistakes,
    int limit,
  ) async {
    try {
      final grouped = <GrammarErrorType, int>{};

      for (final mistake in mistakes) {
        grouped[mistake.errorType] = (grouped[mistake.errorType] ?? 0) + 1;
      }

      final sorted = grouped.entries.map((e) => (e.key, e.value)).toList()
        ..sort((a, b) => b.$2.compareTo(a.$2));

      return sorted.take(limit).toList();
    } catch (e) {
      _logger.e('Error getting top error types: $e');
      rethrow;
    }
  }

  /// Register a custom grammar rule
  void registerCustomRule(GrammarRule rule) {
    _engine.registerRule(rule);
    _logger.i('Custom grammar rule registered: ${rule.ruleName}');
  }

  /// Get all registered grammar rules
  Future<List<GrammarRule>> getRegisteredRules() async {
    return _engine.getRules();
  }

  /// Get available grammar rule information
  Future<Map<String, dynamic>> getRuleInformation() async {
    try {
      final rules = _engine.getRules();

      return {
        'total_rules': rules.length,
        'rules': [
          for (final rule in rules)
            {
              'name': rule.ruleName,
              'description': rule.description,
              'error_type': rule.errorType.toString(),
              'severity': rule.severity.toString(),
            }
        ],
        'error_types':
            GrammarErrorType.values.map((e) => e.toString()).toList(),
        'severity_levels':
            ErrorSeverity.values.map((e) => e.toString()).toList(),
      };
    } catch (e) {
      _logger.e('Error getting rule information: $e');
      rethrow;
    }
  }

  /// Check if a word is likely a typo based on common patterns
  bool isLikelyTypo(String word) {
    final commonTypos = [
      'teh',
      'recieve',
      'occured',
      'untill',
      'wierd',
      'wich',
      'hte',
    ];
    return commonTypos.contains(word.toLowerCase());
  }

  /// Enrich grammar mistakes with fluency information
  List<GrammarMistake> _enrichMistakesWithFluency(
    List<GrammarMistake> grammaticalMistakes,
    FluencyValidationResult fluencyResult,
  ) {
    // For now, return grammatical mistakes as-is
    // In future, could match fluency issues with grammar mistakes by position
    // and merge them into a single mistake with both scores

    // Also add fluency-only issues as separate mistakes
    final enriched = [...grammaticalMistakes];

    for (final fluencyIssue in fluencyResult.issues) {
      enriched.add(
        GrammarMistake(
          id: 'fluency_${fluencyIssue.issueType.toString()}_${fluencyIssue.startPosition}',
          text: fluencyIssue.text,
          suggestion: fluencyIssue.suggestions.isNotEmpty
              ? fluencyIssue.suggestions.first
              : 'Rephrase for clarity',
          errorType: GrammarErrorType.other,
          startPosition: fluencyIssue.startPosition,
          endPosition: fluencyIssue.endPosition,
          confidence: 0.7,
          fluencyScore: fluencyResult.fluencyScore,
          fluencyExplanation: fluencyIssue.explanation,
          isFluencyIssue: true,
        ),
      );
    }

    return enriched;
  }

  /// Get suggestions for improving a piece of text
  Future<List<String>> getSuggestions(List<GrammarMistake> mistakes) async {
    try {
      final suggestions = <String>[];

      final stats = await getErrorStatistics(mistakes);

      if (stats.criticalErrors > 0) {
        suggestions.add(
          'You have ${stats.criticalErrors} critical error(s) that affect clarity. '
          'Please review and fix these first.',
        );
      }

      if (stats.majorErrors > 0) {
        suggestions.add(
          'You have ${stats.majorErrors} major error(s). '
          'Fixing these will significantly improve your grammar.',
        );
      }

      final topErrors = await getTopErrorTypes(mistakes, 3);
      if (topErrors.isNotEmpty) {
        final topError = topErrors.first;
        suggestions.add(
          'Your most common error is ${topError.$1.toString()}. '
          'Try to focus on this area.',
        );
      }

      return suggestions;
    } catch (e) {
      _logger.e('Error getting suggestions: $e');
      rethrow;
    }
  }
}

/// Statistics about grammar errors
class GrammarStatistics {
  final int totalErrors;
  final Map<GrammarErrorType, int> errorsByType;
  final Map<ErrorSeverity, int> errorsBySeverity;
  final Map<String, int> errorsByConfidence;
  final int criticalErrors;
  final int majorErrors;
  final int minorErrors;

  GrammarStatistics({
    required this.totalErrors,
    required this.errorsByType,
    required this.errorsBySeverity,
    required this.errorsByConfidence,
    required this.criticalErrors,
    required this.majorErrors,
    required this.minorErrors,
  });

  @override
  String toString() => 'GrammarStatistics('
      'total: $totalErrors, '
      'critical: $criticalErrors, '
      'major: $majorErrors, '
      'minor: $minorErrors)';
}
