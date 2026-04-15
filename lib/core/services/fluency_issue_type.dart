/// Fluency Issue Types - for detecting unnatural phrasing
enum FluencyIssueType {
  /// Unnatural question phrasing (e.g., "Can I know your name?")
  unnaturalQuestion,

  /// Unnatural progressive tense usage (e.g., "I am knowing")
  incorrectProgressive,

  /// Unnatural preposition or particle usage (e.g., "tell me one thing")
  awkwardParticle,

  /// Unnatural word choice or phrasing
  unnaturalPhrasing,

  /// Unnatural word order or sentence structure
  wordOrderIssue,

  /// Common Hindi-English transfer error
  hindiTransferError,

  /// Overly formal/informal for context
  registerMismatch,

  /// Other fluency issues
  other,
}

/// Extension to add helpful properties to FluencyIssueType
extension FluencyIssueTypeX on FluencyIssueType {
  String get displayName {
    switch (this) {
      case FluencyIssueType.unnaturalQuestion:
        return 'Unnatural Question';
      case FluencyIssueType.incorrectProgressive:
        return 'Incorrect Progressive';
      case FluencyIssueType.awkwardParticle:
        return 'Awkward Particle';
      case FluencyIssueType.unnaturalPhrasing:
        return 'Unnatural Phrasing';
      case FluencyIssueType.wordOrderIssue:
        return 'Word Order Issue';
      case FluencyIssueType.hindiTransferError:
        return 'Hindi Transfer Error';
      case FluencyIssueType.registerMismatch:
        return 'Register Mismatch';
      case FluencyIssueType.other:
        return 'Other Fluency Issue';
    }
  }

  String get shortName {
    switch (this) {
      case FluencyIssueType.unnaturalQuestion:
        return 'Question';
      case FluencyIssueType.incorrectProgressive:
        return 'Progressive';
      case FluencyIssueType.awkwardParticle:
        return 'Particle';
      case FluencyIssueType.unnaturalPhrasing:
        return 'Phrasing';
      case FluencyIssueType.wordOrderIssue:
        return 'Order';
      case FluencyIssueType.hindiTransferError:
        return 'Hindi Transfer';
      case FluencyIssueType.registerMismatch:
        return 'Register';
      case FluencyIssueType.other:
        return 'Other';
    }
  }

  /// Severity of fluency issue (0.0 = minor, 1.0 = major)
  double get severityScore {
    switch (this) {
      case FluencyIssueType.hindiTransferError:
        return 0.8; // High impact on naturalness
      case FluencyIssueType.incorrectProgressive:
        return 0.7; // Significant impact
      case FluencyIssueType.unnaturalQuestion:
        return 0.6; // Moderate impact
      case FluencyIssueType.unnaturalPhrasing:
        return 0.5; // Noticeable
      case FluencyIssueType.wordOrderIssue:
        return 0.5;
      case FluencyIssueType.awkwardParticle:
        return 0.4; // Minor impact
      case FluencyIssueType.registerMismatch:
        return 0.3; // Minor
      case FluencyIssueType.other:
        return 0.5;
    }
  }
}
