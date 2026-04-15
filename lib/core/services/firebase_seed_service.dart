import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class FirebaseSeedService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  static const String demoUserId = 'demo_user_001';

  Future<void> seedDemoData() async {
    try {
      _logger.i('Starting Firebase demo data seeding...');

      await _seedUser();
      await _seedSpeechSessions();
      await _seedTranscriptions();
      await _seedGrammarErrors();
      await _seedDailyStats();
      await _seedWeeklyStats();
      await _seedMonthlyStats();

      _logger.i('Firebase demo data seeded successfully');
    } catch (e) {
      _logger.e('Error seeding Firebase demo data: $e');
      rethrow;
    }
  }

  Future<void> _seedUser() async {
    await _firestore.collection('users').doc(demoUserId).set({
      'id': demoUserId,
      'username': 'demo_user',
      'email': 'demo@wordpedometer.app',
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
      'updatedAt': DateTime.now(),
      'languagePreference': 'en-US',
      'timezone': 'UTC',
      'dailyGoalMinutes': 30,
    });
    _logger.d('User seeded');
  }

  Future<void> _seedSpeechSessions() async {
    final now = DateTime.now();
    final sessions = [
      {'daysAgo': 1, 'words': 45, 'mistakes': 3, 'duration': 180},
      {'daysAgo': 2, 'words': 62, 'mistakes': 5, 'duration': 240},
      {'daysAgo': 3, 'words': 38, 'mistakes': 2, 'duration': 150},
      {'daysAgo': 4, 'words': 55, 'mistakes': 4, 'duration': 210},
      {'daysAgo': 5, 'words': 70, 'mistakes': 6, 'duration': 300},
      {'daysAgo': 6, 'words': 42, 'mistakes': 2, 'duration': 165},
      {'daysAgo': 7, 'words': 58, 'mistakes': 4, 'duration': 225},
      {'daysAgo': 8, 'words': 52, 'mistakes': 3, 'duration': 195},
      {'daysAgo': 9, 'words': 48, 'mistakes': 2, 'duration': 180},
      {'daysAgo': 10, 'words': 65, 'mistakes': 4, 'duration': 250},
      {'daysAgo': 11, 'words': 40, 'mistakes': 2, 'duration': 160},
      {'daysAgo': 12, 'words': 55, 'mistakes': 3, 'duration': 200},
      {'daysAgo': 13, 'words': 70, 'mistakes': 5, 'duration': 280},
      {'daysAgo': 14, 'words': 45, 'mistakes': 2, 'duration': 170},
    ];

    for (int i = 0; i < sessions.length; i++) {
      final session = sessions[i];
      final sessionDate = now.subtract(Duration(days: session['daysAgo'] as int));
      final sessionId = 'session_${sessionDate.millisecondsSinceEpoch}';
      final accuracy = ((session['words'] as int) - (session['mistakes'] as int)) / (session['words'] as int) * 100;

      await _firestore.collection('speech_sessions').doc(sessionId).set({
        'id': sessionId,
        'userId': demoUserId,
        'startedAt': sessionDate,
        'endedAt': sessionDate.add(Duration(seconds: session['duration'] as int)),
        'durationSeconds': session['duration'],
        'totalWords': session['words'],
        'totalMistakes': session['mistakes'],
        'accuracyScore': accuracy,
        'status': 'completed',
        'createdAt': sessionDate,
      });
    }
    _logger.d('Speech sessions seeded');
  }

  Future<void> _seedTranscriptions() async {
    final transcriptions = [
      {'raw': 'I goes to the market yesterday', 'corrected': 'I went to the market yesterday', 'hasError': true},
      {'raw': 'She dont like apples', 'corrected': "She doesn't like apples", 'hasError': true},
      {'raw': 'They was very happy', 'corrected': 'They were very happy', 'hasError': true},
      {'raw': 'He is more smarter than me', 'corrected': 'He is smarter than me', 'hasError': true},
      {'raw': 'I have been to Paris last year', 'corrected': 'I went to Paris last year', 'hasError': true},
      {'raw': 'The weather is nice today', 'corrected': 'The weather is nice today', 'hasError': false},
      {'raw': 'She study English every day', 'corrected': 'She studies English every day', 'hasError': true},
      {'raw': 'My mom make delicious food', 'corrected': 'My mom makes delicious food', 'hasError': true},
      {'raw': 'I am agree with you', 'corrected': 'I agree with you', 'hasError': true},
      {'raw': 'This is a good book', 'corrected': 'This is a good book', 'hasError': false},
    ];

    final now = DateTime.now();
    int seq = 1;

    for (int day = 1; day <= 7; day++) {
      final sessionDate = now.subtract(Duration(days: day));
      final sessionId = 'session_${sessionDate.millisecondsSinceEpoch}';

      for (int i = 0; i < 3; i++) {
        final t = transcriptions[(seq - 1) % transcriptions.length];
        final transcriptionId = 'trans_${sessionId}_$seq';

        await _firestore.collection('transcriptions').doc(transcriptionId).set({
          'id': transcriptionId,
          'sessionId': sessionId,
          'userId': demoUserId,
          'sequence': seq,
          'rawText': t['raw'],
          'cleanedText': t['corrected'],
          'confidence': 0.85 + (seq * 0.02),
          'wordCount': (t['raw'] as String).split(' ').length,
          'hasGrammarError': t['hasError'],
          'languageDetected': 'en-US',
          'isFinal': true,
          'createdAt': sessionDate.add(Duration(seconds: seq * 5)),
        });
        seq++;
      }
    }
    _logger.d('Transcriptions seeded');
  }

  Future<void> _seedGrammarErrors() async {
    final errors = [
      {'original': 'I goes', 'corrected': 'I went', 'category': 'subjectVerbAgreement', 'severity': 'medium'},
      {'original': 'She dont', "corrected": "She doesn't", 'category': 'subjectVerbAgreement', 'severity': 'medium'},
      {'original': 'They was', 'corrected': 'They were', 'category': 'subjectVerbAgreement', 'severity': 'medium'},
      {'original': 'more smarter', 'corrected': 'smarter', 'category': 'wordChoice', 'severity': 'low'},
      {'original': 'have been to', 'corrected': 'went to', 'category': 'tenseMismatch', 'severity': 'medium'},
      {'original': 'She study', 'corrected': 'She studies', 'category': 'subjectVerbAgreement', 'severity': 'medium'},
      {'original': 'My mom make', 'corrected': 'My mom makes', 'category': 'subjectVerbAgreement', 'severity': 'medium'},
      {'original': 'I am agree', 'corrected': 'I agree', 'category': 'wordChoice', 'severity': 'low'},
    ];

    final now = DateTime.now();

    for (int day = 1; day <= 7; day++) {
      final sessionDate = now.subtract(Duration(days: day));
      final sessionId = 'session_${sessionDate.millisecondsSinceEpoch}';

      for (int i = 0; i < errors.length && i < 3; i++) {
        final error = errors[i];
        final errorId = 'error_${sessionId}_$i';
        final transcriptionId = 'trans_${sessionId}_${i + 1}';

        await _firestore.collection('grammar_errors').doc(errorId).set({
          'id': errorId,
          'sessionId': sessionId,
          'transcriptionId': transcriptionId,
          'userId': demoUserId,
          'errorType': 'grammar',
          'errorCategory': error['category'],
          'originalText': error['original'],
          'correctedText': error['corrected'],
          'severity': error['severity'],
          'explanation': 'Grammar correction applied',
          'createdAt': sessionDate.add(Duration(seconds: i * 5)),
        });
      }
    }
    _logger.d('Grammar errors seeded');
  }

  Future<void> _seedDailyStats() async {
    final now = DateTime.now();

    for (int day = 0; day < 30; day++) {
      final date = now.subtract(Duration(days: day));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final sessions = (day % 3) + 1;
      final words = 40 + (day * 3) % 50;
      final errors = (words * 0.06).round();
      final accuracy = 94.0 - (day * 0.3);

      await _firestore.collection('daily_stats').doc('${demoUserId}_$dateStr').set({
        'id': '${demoUserId}_$dateStr',
        'userId': demoUserId,
        'statDate': dateStr,
        'totalSessions': sessions,
        'totalMinutes': (sessions * 3) + (day % 5),
        'totalWords': words,
        'totalErrors': errors,
        'dailyAccuracy': accuracy.clamp(85.0, 100.0),
        'errorBreakdown': {
          'subjectVerbAgreement': (errors * 0.4).round(),
          'tenseMismatch': (errors * 0.25).round(),
          'wordChoice': (errors * 0.2).round(),
          'punctuation': (errors * 0.15).round(),
        },
        'mostCommonError': 'subjectVerbAgreement',
        'createdAt': date,
        'updatedAt': date,
      });
    }
    _logger.d('Daily stats seeded');
  }

  Future<void> _seedWeeklyStats() async {
    final now = DateTime.now();

    for (int week = 0; week < 4; week++) {
      final weekStart = now.subtract(Duration(days: (week + 1) * 7));
      final weekStartStr = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
      
      final totalSessions = 15 + (week * 2);
      final totalWords = 350 + (week * 30);
      final totalErrors = (totalWords * 0.06).round();
      final accuracy = 92.0 + (week * 1.5);

      await _firestore.collection('weekly_stats').doc('${demoUserId}_$weekStartStr').set({
        'id': '${demoUserId}_$weekStartStr',
        'userId': demoUserId,
        'weekStartDate': weekStartStr,
        'totalSessions': totalSessions,
        'totalMinutes': totalSessions * 4,
        'totalWords': totalWords,
        'totalErrors': totalErrors,
        'weeklyAccuracy': accuracy.clamp(85.0, 100.0),
        'improvementVsLastWeek': week == 0 ? 0.0 : 1.5 + (week * 0.5),
        'createdAt': weekStart,
      });
    }
    _logger.d('Weekly stats seeded');
  }

  Future<void> _seedMonthlyStats() async {
    final now = DateTime.now();

    for (int month = 0; month < 2; month++) {
      final monthDate = now.subtract(Duration(days: month * 30));
      final yearMonth = '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';
      
      final totalSessions = 60 + (month * 10);
      final totalWords = 1500 + (month * 200);
      final totalErrors = (totalWords * 0.055).round();

      await _firestore.collection('monthly_stats').doc('${demoUserId}_$yearMonth').set({
        'id': '${demoUserId}_$yearMonth',
        'userId': demoUserId,
        'yearMonth': yearMonth,
        'totalSessions': totalSessions,
        'totalMinutes': totalSessions * 4,
        'totalWords': totalWords,
        'totalErrors': totalErrors,
        'monthlyAccuracy': (94.0 + (month * 1.0)).clamp(85.0, 100.0),
        'topErrorCategories': ['subjectVerbAgreement', 'tenseMismatch', 'wordChoice'],
        'createdAt': monthDate,
      });
    }
    _logger.d('Monthly stats seeded');
  }

  Future<void> clearDemoData() async {
    try {
      _logger.i('Clearing Firebase demo data...');
      
      await _firestore.collection('users').doc(demoUserId).delete();
      
      final sessions = await _firestore.collection('speech_sessions')
          .where('userId', isEqualTo: demoUserId).get();
      for (final doc in sessions.docs) {
        await doc.reference.delete();
      }
      
      final transcriptions = await _firestore.collection('transcriptions')
          .where('userId', isEqualTo: demoUserId).get();
      for (final doc in transcriptions.docs) {
        await doc.reference.delete();
      }
      
      final errors = await _firestore.collection('grammar_errors')
          .where('userId', isEqualTo: demoUserId).get();
      for (final doc in errors.docs) {
        await doc.reference.delete();
      }
      
      final dailyStats = await _firestore.collection('daily_stats')
          .where('userId', isEqualTo: demoUserId).get();
      for (final doc in dailyStats.docs) {
        await doc.reference.delete();
      }
      
      final weeklyStats = await _firestore.collection('weekly_stats')
          .where('userId', isEqualTo: demoUserId).get();
      for (final doc in weeklyStats.docs) {
        await doc.reference.delete();
      }
      
      final monthlyStats = await _firestore.collection('monthly_stats')
          .where('userId', isEqualTo: demoUserId).get();
      for (final doc in monthlyStats.docs) {
        await doc.reference.delete();
      }
      
      _logger.i('Firebase demo data cleared');
    } catch (e) {
      _logger.e('Error clearing Firebase demo data: $e');
    }
  }
}
