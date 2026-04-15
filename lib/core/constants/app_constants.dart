/// App-wide constants
const String appName = 'Word Pedometer';
const String appVersion = '1.0.0';

/// Time constants (in milliseconds)
const int kMaxRecordingDuration = 3600000; // 1 hour
const int kMinRecordingDuration = 1000; // 1 second
const int kAudioProcessingDelay = 500; // 500ms

/// Grammar accuracy thresholds
const double kGoodAccuracyThreshold = 90;
const double kAverageAccuracyThreshold = 70;
const double kPoorAccuracyThreshold = 50;

/// Database constants
const String kDatabaseName = 'word_pedometer.db';
const int kDatabaseVersion = 1;

/// UI constants
const double kPaddingSmall = 8;
const double kPaddingMedium = 16;
const double kPaddingLarge = 24;
const double kBorderRadius = 12;

/// Permission request delay
const Duration kPermissionRequestDelay = Duration(seconds: 1);
