import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';

/// Database service for managing local SQLite database
class DatabaseService {
  static const String databaseName = 'word_pedometer.db';
  static const int databaseVersion = 2;

  static Database? _database;
  final Logger _logger = Logger();

  /// Get database instance (singleton pattern)
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initializeDatabase() async {
    try {
      _logger.i('Initializing database...');

      final databasePath = await getDatabasesPath();
      final path = join(databasePath, databaseName);

      _logger.d('Database path: $path');

      final database = await openDatabase(
        path,
        version: databaseVersion,
        onCreate: _createTables,
        onUpgrade: _upgradeTables,
      );

      _logger.i('Database initialized successfully');
      return database;
    } catch (e) {
      _logger.e('Error initializing database: $e');
      rethrow;
    }
  }

  /// Create all database tables
  Future<void> _createTables(Database db, int version) async {
    _logger.d('Creating database tables...');

    try {
      // Users table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id TEXT PRIMARY KEY,
          username TEXT UNIQUE NOT NULL,
          email TEXT UNIQUE,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          language_preference TEXT DEFAULT 'en-US',
          timezone TEXT DEFAULT 'UTC',
          daily_goal_minutes INTEGER DEFAULT 30
        )
      ''');

      // Speech sessions table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS speech_sessions (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          started_at INTEGER NOT NULL,
          ended_at INTEGER NOT NULL,
          duration_seconds INTEGER NOT NULL,
          total_words INTEGER DEFAULT 0,
          total_mistakes INTEGER DEFAULT 0,
          accuracy_score REAL DEFAULT 100.0,
          status TEXT DEFAULT 'completed',
          notes TEXT,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
          CHECK (ended_at >= started_at)
        )
      ''');

      // Create index for faster queries
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sessions_user_date ON speech_sessions(user_id, started_at)'
      );

      // Transcriptions table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS transcriptions (
          id TEXT PRIMARY KEY,
          session_id TEXT NOT NULL,
          user_id TEXT NOT NULL,
          sequence INTEGER NOT NULL,
          raw_text TEXT NOT NULL,
          cleaned_text TEXT,
          confidence REAL DEFAULT 0.0,
          word_count INTEGER DEFAULT 0,
          has_grammar_error INTEGER DEFAULT 0,
          language_detected TEXT,
          is_final INTEGER DEFAULT 0,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (session_id) REFERENCES speech_sessions(id) ON DELETE CASCADE,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
          UNIQUE (session_id, sequence)
        )
      ''');

      // Create index
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_transcriptions_session ON transcriptions(session_id, sequence)'
      );

      // Grammar errors table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS grammar_errors (
          id TEXT PRIMARY KEY,
          session_id TEXT NOT NULL,
          transcription_id TEXT NOT NULL,
          user_id TEXT NOT NULL,
          error_type TEXT NOT NULL,
          error_category TEXT NOT NULL,
          original_text TEXT NOT NULL,
          corrected_text TEXT NOT NULL,
          severity TEXT DEFAULT 'medium',
          position_start INTEGER,
          position_end INTEGER,
          explanation TEXT,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (session_id) REFERENCES speech_sessions(id) ON DELETE CASCADE,
          FOREIGN KEY (transcription_id) REFERENCES transcriptions(id) ON DELETE CASCADE,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');

      // Create indexes
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_errors_session_type ON grammar_errors(session_id, error_type)'
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_errors_category ON grammar_errors(user_id, error_category)'
      );

      // Daily stats table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS daily_stats (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          stat_date TEXT NOT NULL,
          total_sessions INTEGER DEFAULT 0,
          total_minutes INTEGER DEFAULT 0,
          total_words INTEGER DEFAULT 0,
          total_errors INTEGER DEFAULT 0,
          daily_accuracy REAL DEFAULT 100.0,
          error_breakdown TEXT,
          most_common_error TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
          UNIQUE (user_id, stat_date)
        )
      ''');

      // Create index
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_daily_stats_user_date ON daily_stats(user_id, stat_date DESC)'
      );

      // Weekly stats table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS weekly_stats (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          week_start_date TEXT NOT NULL,
          total_sessions INTEGER DEFAULT 0,
          total_minutes INTEGER DEFAULT 0,
          total_words INTEGER DEFAULT 0,
          total_errors INTEGER DEFAULT 0,
          weekly_accuracy REAL DEFAULT 100.0,
          improvement_vs_last_week REAL,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
          UNIQUE (user_id, week_start_date)
        )
      ''');

      // Create index
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_weekly_stats_user ON weekly_stats(user_id, week_start_date DESC)'
      );

      // Monthly stats table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS monthly_stats (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          year_month TEXT NOT NULL,
          total_sessions INTEGER DEFAULT 0,
          total_minutes INTEGER DEFAULT 0,
          total_words INTEGER DEFAULT 0,
          total_errors INTEGER DEFAULT 0,
          monthly_accuracy REAL DEFAULT 100.0,
          top_error_categories TEXT,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
          UNIQUE (user_id, year_month)
        )
      ''');

      // Create index
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_monthly_stats_user ON monthly_stats(user_id, year_month DESC)'
      );

      // Error type definitions table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS error_type_definitions (
          id TEXT PRIMARY KEY,
          error_type TEXT UNIQUE NOT NULL,
          category TEXT NOT NULL,
          severity_default TEXT DEFAULT 'medium',
          description TEXT,
          common_examples TEXT,
          teaching_resource_url TEXT
        )
      ''');

      // User settings table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_settings (
          id TEXT PRIMARY KEY,
          user_id TEXT UNIQUE NOT NULL,
          notification_enabled INTEGER DEFAULT 1,
          notification_time TEXT DEFAULT '09:00',
          dark_mode_enabled INTEGER DEFAULT 0,
          auto_correct_suggestions INTEGER DEFAULT 1,
          privacy_allow_analytics INTEGER DEFAULT 1,
          backup_enabled INTEGER DEFAULT 1,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');

      // Backup metadata table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS backup_metadata (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          backup_date INTEGER NOT NULL,
          backup_size_bytes INTEGER,
          session_count_in_backup INTEGER,
          backup_hash TEXT,
          notes TEXT,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');

      // Create index
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_backup_user_date ON backup_metadata(user_id, backup_date DESC)'
      );

      _logger.i('All tables created successfully');
    } catch (e) {
      _logger.e('Error creating tables: $e');
      rethrow;
    }
  }

  /// Handle database upgrades
  Future<void> _upgradeTables(Database db, int oldVersion, int newVersion) async {
    _logger.d('Upgrading database from v$oldVersion to v$newVersion');

    // Version 1 -> 2: Add missing columns to transcriptions
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE transcriptions ADD COLUMN word_count INTEGER DEFAULT 0');
        await db.execute('ALTER TABLE transcriptions ADD COLUMN has_grammar_error INTEGER DEFAULT 0');
        _logger.i('Added word_count and has_grammar_error columns to transcriptions');
      } catch (e) {
        _logger.w('Columns may already exist: $e');
      }
    }
  }

  /// Close database connection
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _logger.i('Database closed');
    }
  }

  /// Clear all database (for testing/reset)
  Future<void> clearDatabase() async {
    try {
      final db = await database;
      
      // List of all tables
      final tables = [
        'backup_metadata',
        'user_settings',
        'error_type_definitions',
        'monthly_stats',
        'weekly_stats',
        'daily_stats',
        'grammar_errors',
        'transcriptions',
        'speech_sessions',
        'users',
      ];

      // Delete all data from each table
      for (final table in tables) {
        await db.delete(table);
      }

      _logger.w('Database cleared - all data deleted');
    } catch (e) {
      _logger.e('Error clearing database: $e');
      rethrow;
    }
  }

  /// Execute raw SQL query
  Future<List<Map<String, dynamic>>> executeQuery(String query, [List<dynamic>? arguments]) async {
    try {
      final db = await database;
      return await db.rawQuery(query, arguments);
    } catch (e) {
      _logger.e('Error executing query: $e');
      rethrow;
    }
  }

  /// Execute raw SQL update
  Future<int> executeUpdate(String query, [List<dynamic>? arguments]) async {
    try {
      final db = await database;
      return await db.rawUpdate(query, arguments);
    } catch (e) {
      _logger.e('Error executing update: $e');
      rethrow;
    }
  }

  /// Optimize database (vacuum)
  Future<void> optimizeDatabase() async {
    try {
      final db = await database;
      await db.execute('VACUUM');
      _logger.i('Database optimized');
    } catch (e) {
      _logger.e('Error optimizing database: $e');
    }
  }

  /// Seed demo data for presentation
  Future<void> seedDemoData() async {
    try {
      final db = await database;
      _logger.i('Seeding demo data...');

      // Create demo user
      await db.insert('users', {
        'id': 'demo_user_001',
        'username': 'demo_user',
        'email': 'demo@wordpedometer.app',
        'created_at': DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'language_preference': 'en-US',
        'timezone': 'UTC',
        'daily_goal_minutes': 30,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // Sample speech sessions for past 7 days
      final now = DateTime.now();
      final sampleSessions = [
        {
          'date': now.subtract(const Duration(days: 1)),
          'words': 45,
          'mistakes': 3,
          'duration': 180,
        },
        {
          'date': now.subtract(const Duration(days: 2)),
          'words': 62,
          'mistakes': 5,
          'duration': 240,
        },
        {
          'date': now.subtract(const Duration(days: 3)),
          'words': 38,
          'mistakes': 2,
          'duration': 150,
        },
        {
          'date': now.subtract(const Duration(days: 4)),
          'words': 55,
          'mistakes': 4,
          'duration': 210,
        },
        {
          'date': now.subtract(const Duration(days: 5)),
          'words': 70,
          'mistakes': 6,
          'duration': 300,
        },
        {
          'date': now.subtract(const Duration(days: 6)),
          'words': 42,
          'mistakes': 2,
          'duration': 165,
        },
        {
          'date': now.subtract(const Duration(days: 7)),
          'words': 58,
          'mistakes': 4,
          'duration': 225,
        },
      ];

      int seq = 1;
      for (final session in sampleSessions) {
        final sessionDate = session['date'] as DateTime;
        final sessionId = 'session_${sessionDate.millisecondsSinceEpoch}';
        final accuracy = ((session['words'] as int) - (session['mistakes'] as int)) / (session['words'] as int) * 100;

        await db.insert('speech_sessions', {
          'id': sessionId,
          'user_id': 'demo_user_001',
          'started_at': sessionDate.millisecondsSinceEpoch,
          'ended_at': sessionDate.add(Duration(seconds: session['duration'] as int)).millisecondsSinceEpoch,
          'duration_seconds': session['duration'],
          'total_words': session['words'],
          'total_mistakes': session['mistakes'],
          'accuracy_score': accuracy,
          'status': 'completed',
          'created_at': sessionDate.millisecondsSinceEpoch,
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        // Sample transcriptions with mistakes
        final transcriptions = _getSampleTranscriptions();
        for (final t in transcriptions) {
          final hasError = t['hasError'] == true ? 1 : 0;
          await db.insert('transcriptions', {
            'id': 'trans_${sessionId}_$seq',
            'session_id': sessionId,
            'user_id': 'demo_user_001',
            'sequence': seq,
            'raw_text': t['raw'],
            'cleaned_text': t['corrected'],
            'confidence': 0.85 + (seq * 0.02),
            'word_count': (t['raw'] as String).split(' ').length,
            'has_grammar_error': hasError,
            'language_detected': 'en-US',
            'is_final': 1,
            'created_at': sessionDate.add(Duration(seconds: seq * 5)).millisecondsSinceEpoch,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          
          // Add grammar errors for incorrect transcriptions
          if (t['hasError'] == true) {
            await db.insert('grammar_errors', {
              'id': 'error_${sessionId}_$seq',
              'session_id': sessionId,
              'transcription_id': 'trans_${sessionId}_$seq',
              'user_id': 'demo_user_001',
              'error_type': 'grammar',
              'error_category': 'verb_agreement',
              'original_text': t['raw'],
              'corrected_text': t['corrected'],
              'severity': 'medium',
              'explanation': 'Grammar correction applied',
              'created_at': sessionDate.add(Duration(seconds: seq * 5)).millisecondsSinceEpoch,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
          seq++;
        }
      }

      _logger.i('Demo data seeded successfully');
    } catch (e) {
      _logger.e('Error seeding demo data: $e');
    }
  }

  List<Map<String, dynamic>> _getSampleTranscriptions() {
    return [
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
  }
}
