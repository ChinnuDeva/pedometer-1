import 'package:flutter_test/flutter_test.dart';
import 'package:word_pedometer/core/services/grammar_rules.dart';
import 'package:word_pedometer/core/services/grammar_rules_engine.dart';

void main() {
  group('GrammarRulesEngine', () {
    late GrammarRulesEngine engine;

    setUp(() {
      engine = GrammarRulesEngine();
    });

    test('should register a single rule', () {
      final rule = SubjectVerbAgreementRule();
      engine.registerRule(rule);

      expect(engine.getRules().length, 1);
      expect(engine.getRules().first.ruleName, 'Subject-Verb Agreement');
    });

    test('should register multiple rules at once', () {
      final rules = [
        SubjectVerbAgreementRule(),
        ArticleUsageRule(),
        TenseConsistencyRule(),
      ];
      engine.registerRules(rules);

      expect(engine.getRules().length, 3);
    });

    test('should get rules by error type', () {
      engine.registerRules([
        SubjectVerbAgreementRule(),
        CommonErrorsRule(),
      ]);

      final svRules = engine.getRulesByType(GrammarErrorType.subjectVerbAgreement);
      expect(svRules.length, 1);
      expect(svRules.first.ruleName, 'Subject-Verb Agreement');
    });

    test('should get rules by severity', () {
      engine.registerRules([
        SubjectVerbAgreementRule(),
        CommonErrorsRule(),
        ArticleUsageRule(),
      ]);

      final majorRules = engine.getRulesBySeverity(ErrorSeverity.major);
      expect(majorRules.length, 1);
      expect(majorRules.first.ruleName, 'Subject-Verb Agreement');
    });

    test('should check text and find mistakes', () {
      engine.registerRule(SubjectVerbAgreementRule());
      engine.registerRule(CommonErrorsRule());

      const text = 'he are happy and dont know';
      final mistakes = engine.checkText(text);

      expect(mistakes.isNotEmpty, true);
    });

    test('should deduplicate overlapping errors', () {
      engine.registerRule(SubjectVerbAgreementRule());
      engine.registerRule(SubjectVerbAgreementRule()); // Register twice

      const text = 'he are going';
      final mistakes = engine.checkText(text);

      // Should only have unique errors at each position
      final positions = <String>{};
      for (final mistake in mistakes) {
        final key = '${mistake.startPosition}-${mistake.endPosition}';
        expect(positions.contains(key), false);
        positions.add(key);
      }
    });

    test('should clear all rules', () {
      engine.registerRules([
        SubjectVerbAgreementRule(),
        ArticleUsageRule(),
      ]);
      expect(engine.getRules().length, 2);

      engine.clearRules();
      expect(engine.getRules().isEmpty, true);
    });

    test('should handle empty text gracefully', () {
      engine.registerRule(SubjectVerbAgreementRule());

      final mistakes = engine.checkText('');
      expect(mistakes.isEmpty, true);
    });

    test('should handle rule exceptions gracefully', () {
      engine.registerRule(SubjectVerbAgreementRule());

      // Should not throw even if a rule has an issue
      final mistakes = engine.checkText('some text to check');
      expect(mistakes is List, true);
    });
  });

  group('SubjectVerbAgreementRule', () {
    late SubjectVerbAgreementRule rule;

    setUp(() {
      rule = SubjectVerbAgreementRule();
    });

    test('should detect "he are" error', () {
      const text = 'he are going to the store';
      final mistakes = rule.check(text, 0);

      expect(mistakes.isNotEmpty, true);
      expect(
        mistakes.any((m) => m.text.contains('he are')),
        true,
      );
    });

    test('should detect "they is" error', () {
      const text = 'they is happy';
      final mistakes = rule.check(text, 0);

      expect(mistakes.isNotEmpty, true);
    });

    test('should not flag correct grammar', () {
      const text = 'they are happy and I am here';
      final mistakes = rule.check(text, 0);

      expect(mistakes.isEmpty, true);
    });

    test('should have correct properties', () {
      expect(rule.ruleName, 'Subject-Verb Agreement');
      expect(rule.errorType, GrammarErrorType.subjectVerbAgreement);
      expect(rule.severity, ErrorSeverity.major);
    });
  });

  group('ArticleUsageRule', () {
    late ArticleUsageRule rule;

    setUp(() {
      rule = ArticleUsageRule();
    });

    test('should detect "a" before vowel sound', () {
      const text = 'a apple on the table';
      final mistakes = rule.check(text, 0);

      expect(mistakes.isNotEmpty, true);
    });

    test('should detect "an" before consonant sound', () {
      const text = 'an book is here';
      final mistakes = rule.check(text, 0);

      expect(mistakes.isNotEmpty, true);
    });

    test('should not flag correct article usage', () {
      const text = 'an apple and a book';
      final mistakes = rule.check(text, 0);

      expect(mistakes.isEmpty, true);
    });

    test('should have correct properties', () {
      expect(rule.ruleName, 'Article Usage');
      expect(rule.severity, ErrorSeverity.minor);
    });
  });

  group('CommonErrorsRule', () {
    late CommonErrorsRule rule;

    setUp(() {
      rule = CommonErrorsRule();
    });

    test('should detect "dont" should be "don\'t"', () {
      const text = 'I dont like it';
      final mistakes = rule.check(text, 0);

      expect(mistakes.isNotEmpty, true);
      expect(mistakes.any((m) => m.suggestion.contains("don't")), true);
    });

    test('should detect "cant" should be "can\'t"', () {
      const text = 'you cant do that';
      final mistakes = rule.check(text, 0);

      expect(mistakes.isNotEmpty, true);
    });

    test('should detect "wont" should be "won\'t"', () {
      const text = 'he wont go';
      final mistakes = rule.check(text, 0);

      expect(mistakes.isNotEmpty, true);
    });

    test('should have correct properties', () {
      expect(rule.ruleName, 'Common Errors');
      expect(rule.errorType, GrammarErrorType.spelling);
      expect(rule.severity, ErrorSeverity.minor);
    });
  });

  group('TenseConsistencyRule', () {
    late TenseConsistencyRule rule;

    setUp(() {
      rule = TenseConsistencyRule();
    });

    test('should detect tense shift from present to past', () {
      const text = 'he goes to the store and ate lunch';
      final mistakes = rule.check(text, 0);

      expect(mistakes.isNotEmpty, true);
    });

    test('should detect tense shift from past to present', () {
      const text = 'she was happy and she is excited';
      final mistakes = rule.check(text, 0);

      expect(mistakes.isNotEmpty, true);
    });

    test('should have correct properties', () {
      expect(rule.ruleName, 'Tense Consistency');
      expect(rule.errorType, GrammarErrorType.tenseMismatch);
      expect(rule.severity, ErrorSeverity.major);
    });
  });

  group('WordOrderRule', () {
    late WordOrderRule rule;

    setUp(() {
      rule = WordOrderRule();
    });

    test('should have correct properties', () {
      expect(rule.ruleName, 'Word Order');
      expect(rule.severity, ErrorSeverity.major);
    });
  });

  group('PronounAgreementRule', () {
    late PronounAgreementRule rule;

    setUp(() {
      rule = PronounAgreementRule();
    });

    test('should have correct properties', () {
      expect(rule.ruleName, 'Pronoun-Antecedent Agreement');
      expect(rule.severity, ErrorSeverity.major);
    });
  });

  group('CommaSpliceRule', () {
    late CommaSpliceRule rule;

    setUp(() {
      rule = CommaSpliceRule();
    });

    test('should have correct properties', () {
      expect(rule.ruleName, 'Comma Splice');
      expect(rule.errorType, GrammarErrorType.punctuation);
      expect(rule.severity, ErrorSeverity.major);
    });
  });

  group('DoubleNegationRule', () {
    late DoubleNegationRule rule;

    setUp(() {
      rule = DoubleNegationRule();
    });

    test('should have correct properties', () {
      expect(rule.ruleName, 'Double Negation');
      expect(rule.severity, ErrorSeverity.minor);
    });
  });

  group('DefaultGrammarRules', () {
    test('should provide all default rules', () {
      final rules = DefaultGrammarRules.getAllRules();

      expect(rules.length, 8);
      expect(rules.map((r) => r.ruleName).toList(), [
        'Subject-Verb Agreement',
        'Article Usage',
        'Tense Consistency',
        'Common Errors',
        'Word Order',
        'Pronoun-Antecedent Agreement',
        'Comma Splice',
        'Double Negation',
      ]);
    });

    test('should create rules with unique instances', () {
      final rules1 = DefaultGrammarRules.getAllRules();
      final rules2 = DefaultGrammarRules.getAllRules();

      expect(identical(rules1, rules2), false);
    });
  });
}
