import 'package:logger/logger.dart';

/// Represents a common phrase mapping from unnatural to natural phrasing
class PhraseMapping {
  final String unnatural;
  final List<String> naturalAlternatives;
  final String explanation;
  final bool isCritical; // If true, strongly suggests unnatural usage

  const PhraseMapping({
    required this.unnatural,
    required this.naturalAlternatives,
    required this.explanation,
    this.isCritical = false,
  });
}

/// Database of common conversational phrases and their natural alternatives
/// Particularly useful for detecting Hindi-English speaker patterns
class ConversationalPhraseDatabase {
  final Logger _logger = Logger();
  static final ConversationalPhraseDatabase _instance =
      ConversationalPhraseDatabase._internal();

  late final Map<String, PhraseMapping> _phraseMap;
  late final Map<String, List<String>> _partialMatchCache;

  factory ConversationalPhraseDatabase() {
    return _instance;
  }

  ConversationalPhraseDatabase._internal() {
    _phraseMap = {};
    _partialMatchCache = {};
    _initializePhraseDatabase();
  }

  /// Initialize the phrase database with common patterns
  void _initializePhraseDatabase() {
    // Questions - Common unnatural question patterns
    _addPhrase(
      'can i know',
      ['what is', 'may i know', 'could you tell me'],
      'Unnatural question formation; "Can I know" is grammatically odd',
      isCritical: true,
    );

    _addPhrase(
      'can you tell me one thing',
      ['can you tell me something', 'can i ask you something'],
      'Awkward particle; "one thing" instead of "something"',
    );

    _addPhrase(
      'one more thing',
      ['another thing', 'one more thing is okay'],
      'While grammatical, often overused; "another thing" is more natural',
    );

    // Progressive tense - Common errors with continuous tense
    _addPhrase(
      'i am knowing',
      ['i know', 'i am aware'],
      'Know is stative verb; cannot use progressive form',
      isCritical: true,
    );

    _addPhrase(
      'i am coming from',
      ['i come from', 'i am from'],
      'Unnatural use of progressive; should be simple present',
      isCritical: true,
    );

    _addPhrase(
      'i am having',
      ['i have', 'i own'],
      'Have is stative; rarely used in progressive form',
      isCritical: true,
    );

    _addPhrase(
      'i am understanding',
      ['i understand', 'i get it'],
      'Understand is typically not progressive',
      isCritical: true,
    );

    // Prepositions - Common preposition errors
    _addPhrase(
      'on time',
      ['on time', 'in time'], // on time is correct, but "in time" also works
      'Both acceptable; "on time" means punctual, "in time" means before deadline',
    );

    _addPhrase(
      'beside',
      ['besides', 'next to', 'near'],
      '"Beside" means next to; "besides" means moreover/furthermore',
    );

    _addPhrase(
      'at present',
      ['at the moment', 'currently', 'now', 'at present'],
      '"At present" is correct but dated; more modern: currently/right now',
    );

    // Articles - Common article errors
    _addPhrase(
      'i am engineer',
      ['i am an engineer', 'i am a engineer'],
      'Missing article; "engineer" starts with vowel sound, needs "an"',
      isCritical: true,
    );

    _addPhrase(
      'go to school',
      ['go to school', 'go to the school'],
      'No article for regular activities; add article for specific school',
    );

    // Pluralization - Uncountable noun errors
    _addPhrase(
      'many informations',
      ['much information', 'a lot of information'],
      'Information is uncountable; use "much" not "many"',
      isCritical: true,
    );

    _addPhrase(
      'many advices',
      ['much advice', 'many pieces of advice'],
      'Advice is uncountable; use "much advice" or "pieces of advice"',
      isCritical: true,
    );

    // Word choice - Better alternatives
    _addPhrase(
      'do the needful',
      ['do what is necessary', 'take care of it', 'handle it'],
      'Archaic colonial English; modern: "do what is necessary" or "handle it"',
    );

    _addPhrase(
      'kindly do',
      ['please do', 'could you'],
      'Over-formal; "please" or "could you" is more natural',
    );

    _addPhrase(
      'pass out',
      ['graduate', 'faint', 'pass around'],
      '"Pass out" ambiguous; in UK: faint, in India: graduate (use "graduate" in modern English)',
    );

    // Word order - Unnatural sentence structure
    _addPhrase(
      'very much thank you',
      ['thank you very much', 'thank you so much'],
      'Unnatural word order; proper: "thank you very much"',
      isCritical: true,
    );

    _addPhrase(
      'what you are doing',
      ['what are you doing', 'what you doing'],
      'Question word order: helping verb comes before subject',
      isCritical: true,
    );

    // Particles and interjections - Hindi transfer errors
    _addPhrase(
      'no problem, i will come',
      ['sure, i will come', 'i will come'],
      'Over-use of "no problem" as response; "sure" is more natural',
    );

    _addPhrase(
      'only',
      ['just', 'simply', 'only'],
      'Hindi: "sirf"; often misused in English for other meanings',
    );

    _logger.i(
      'Conversational phrase database initialized with ${_phraseMap.length} phrases',
    );
  }

  /// Add a phrase to the database
  void _addPhrase(
    String unnatural,
    List<String> naturalAlternatives,
    String explanation, {
    bool isCritical = false,
  }) {
    final key = unnatural.toLowerCase().trim();
    _phraseMap[key] = PhraseMapping(
      unnatural: unnatural,
      naturalAlternatives: naturalAlternatives,
      explanation: explanation,
      isCritical: isCritical,
    );
  }

  /// Check if text contains an unnatural phrase
  /// Returns the matching PhraseMapping if found, null otherwise
  PhraseMapping? findUnaturalPhrase(String text) {
    final lowerText = text.toLowerCase();

    // Check for exact matches first (faster)
    for (final entry in _phraseMap.entries) {
      if (lowerText.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Find all unnatural phrases in the given text
  List<(String, PhraseMapping)> findAllUnnaturalPhrases(String text) {
    final results = <(String, PhraseMapping)>[];
    final lowerText = text.toLowerCase();

    for (final entry in _phraseMap.entries) {
      if (lowerText.contains(entry.key)) {
        results.add((entry.key, entry.value));
      }
    }

    return results;
  }

  /// Get a phrase mapping by the unnatural phrase
  PhraseMapping? getPhraseMapping(String unnaturalPhrase) {
    return _phraseMap[unnaturalPhrase.toLowerCase().trim()];
  }

  /// Get all critical phrases (those that strongly suggest unnatural usage)
  List<PhraseMapping> getCriticalPhrases() {
    return _phraseMap.values.where((p) => p.isCritical).toList();
  }

  /// Get suggested alternatives for an unnatural phrase
  List<String> getSuggestions(String unnaturalPhrase) {
    final mapping = getPhraseMapping(unnaturalPhrase);
    return mapping?.naturalAlternatives ?? [];
  }

  /// Get explanation for why a phrase is unnatural
  String? getExplanation(String unnaturalPhrase) {
    return getPhraseMapping(unnaturalPhrase)?.explanation;
  }

  /// Get total number of phrases in the database
  int get databaseSize => _phraseMap.length;

  /// Get total number of critical phrases
  int get criticalPhrasesCount =>
      _phraseMap.values.where((p) => p.isCritical).length;
}
