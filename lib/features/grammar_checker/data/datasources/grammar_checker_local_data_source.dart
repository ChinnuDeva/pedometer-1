import '../../../../core/services/grammar_checker_service.dart';
import '../../../../core/utils/injection_container.dart';
import '../../domain/entities/grammar_mistake.dart';

/// Data source for grammar checking operations
abstract class GrammarCheckerDataSource {
  /// Check text for grammar mistakes
  Future<List<GrammarMistake>> checkGrammar(String text);

  /// Get available grammar rules
  Future<Map<String, dynamic>> getGrammarRules();
}

/// Implementation of grammar checker data source
/// Uses the GrammarCheckerService for actual grammar checking
class GrammarCheckerDataSourceImpl implements GrammarCheckerDataSource {

  GrammarCheckerDataSourceImpl() {
    _checkerService = getIt<GrammarCheckerService>();
  }
  late final GrammarCheckerService _checkerService;

  @override
  Future<List<GrammarMistake>> checkGrammar(String text) async {
    if (text.isEmpty) {
      return [];
    }

    // Use the GrammarCheckerService to check the text
    final mistakes = await _checkerService.checkText(text);

    // Return the mistakes as is (they're already GrammarMistake objects)
    return mistakes;
  }

  @override
  Future<Map<String, dynamic>> getGrammarRules() async {
    // Get detailed rule information from the service
    return _checkerService.getRuleInformation();
  }
}
