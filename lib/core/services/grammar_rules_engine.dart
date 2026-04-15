import 'package:logger/logger.dart';
import '../../features/grammar_checker/domain/entities/grammar_mistake.dart';

/// Severity level for grammar errors
enum ErrorSeverity {
  critical, // Meaning is unclear without correction
  major,    // Affects clarity or professionalism
  minor,    // Stylistic or minor grammatical issue
}

/// Base class for all grammar rules
abstract class GrammarRule {
  /// Rule name for identification
  String get ruleName;

  /// Error type this rule detects
  GrammarErrorType get errorType;

  /// Severity of errors this rule detects
  ErrorSeverity get severity;

  /// Pattern or description of what this rule checks
  String get description;

  /// Check text and return list of mistakes found
  List<GrammarMistake> check(String text, int sessionId);
}

/// Grammar rules engine that manages and executes grammar rules
class GrammarRulesEngine {
  final List<GrammarRule> _rules = [];
  final Logger _logger = Logger();

  /// Register a new grammar rule
  void registerRule(GrammarRule rule) {
    _rules.add(rule);
    _logger.i('Grammar rule registered: ${rule.ruleName}');
  }

  /// Register multiple rules at once
  void registerRules(List<GrammarRule> rules) {
    for (final rule in rules) {
      registerRule(rule);
    }
  }

  /// Check text against all registered rules
  List<GrammarMistake> checkText(String text, {int sessionId = 0}) {
    final mistakes = <GrammarMistake>[];

    for (final rule in _rules) {
      try {
        final ruleErrors = rule.check(text, sessionId);
        mistakes.addAll(ruleErrors);
      } catch (e) {
        _logger.e(
          'Error executing grammar rule ${rule.ruleName}: $e',
        );
      }
    }

    return _deduplicateErrors(mistakes);
  }

  /// Get all registered rules
  List<GrammarRule> getRules() => List.unmodifiable(_rules);

  /// Get rules by error type
  List<GrammarRule> getRulesByType(GrammarErrorType type) => _rules.where((rule) => rule.errorType == type).toList();

  /// Get rules by severity level
  List<GrammarRule> getRulesBySeverity(ErrorSeverity severity) => _rules.where((rule) => rule.severity == severity).toList();

  /// Clear all registered rules
  void clearRules() {
    _rules.clear();
    _logger.i('All grammar rules cleared');
  }

  /// Remove duplicate errors at same position
  List<GrammarMistake> _deduplicateErrors(
    List<GrammarMistake> mistakes,
  ) {
    final deduplicated = <String, GrammarMistake>{};

    for (final mistake in mistakes) {
      final key = '${mistake.startPosition}-${mistake.endPosition}';

      // Keep error with higher confidence
      if (!deduplicated.containsKey(key) ||
          (deduplicated[key]!.confidence < mistake.confidence)) {
        deduplicated[key] = mistake;
      }
    }

    return deduplicated.values.toList();
  }
}
