/// Daily Statistics Domain Entity
class DailyStats {

  DailyStats({
    required this.id,
    required this.date,
    required this.totalWords,
    required this.totalErrors,
    required this.accuracyPercentage,
    required this.speakingTime,
    required this.sessionCount,
  });

  /// Calculate accuracy from total words and errors
  factory DailyStats.fromStats({
    required String id,
    required DateTime date,
    required int totalWords,
    required int totalErrors,
    required Duration speakingTime,
    required int sessionCount,
  }) {
    final accuracy = totalWords > 0
        ? ((totalWords - totalErrors) / totalWords) * 100
        : 0.0;

    return DailyStats(
      id: id,
      date: date,
      totalWords: totalWords,
      totalErrors: totalErrors,
      accuracyPercentage: accuracy,
      speakingTime: speakingTime,
      sessionCount: sessionCount,
    );
  }
  final String id;
  final DateTime date;
  final int totalWords;
  final int totalErrors;
  final double accuracyPercentage;
  final Duration speakingTime;
  final int sessionCount;

  @override
  String toString() =>
      'DailyStats(date: $date, totalWords: $totalWords, '
      'totalErrors: $totalErrors, accuracy: $accuracyPercentage%)';
}
