import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:logger/logger.dart';

/// Exception thrown by speech recognition service
class SpeechRecognitionException implements Exception {

  SpeechRecognitionException({
    required this.message,
    this.originalError,
  });
  final String message;
  final dynamic originalError;

  @override
  String toString() => 'SpeechRecognitionException: $message';
}

/// Callback type for speech recognition result
typedef OnSpeechResult = Function(String recognizedText, bool isFinal);

/// Callback type for status changes
typedef OnStatusChange = Function(String status);

/// Callback type for errors
typedef OnError = Function(String error);

/// Service for handling speech-to-text recognition
class SpeechRecognitionService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final Logger _logger = Logger();

  // Callbacks
  OnSpeechResult? _onResult;
  OnStatusChange? _onStatusChange;
  OnError? _onError;

  // State
  bool _isListening = false;
  bool _isInitialized = false;
  String? _currentLocaleId;

  // Getters
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  bool get isNotListening => !_isListening;

  /// Initialize the speech recognition service
  /// Should be called once during app startup
  Future<bool> initialize({
    OnStatusChange? onStatusChange,
    OnError? onError,
    bool debugLogging = false,
  }) async {
    try {
      _onStatusChange = onStatusChange;
      _onError = onError;

      final initialized = await _speechToText.initialize(
        onStatus: _handleStatus,
        onError: _handleError,
        debugLogging: debugLogging,
      );

      if (initialized) {
        _isInitialized = true;
        _logger.i('Speech recognition initialized successfully');
        
        // Get available locales
        try {
          final locales = await _speechToText.locales();
          _logger.d('Available locales: ${locales.length}');
          
          // Use device default locale
          if (locales.isNotEmpty) {
            _currentLocaleId = locales.first.localeId;
            _logger.d('Using locale: $_currentLocaleId');
          }
        } catch (e) {
          _logger.w('Could not fetch locales: $e');
        }
      } else {
        _logger.w('Speech recognition not available on this device');
      }

      return initialized;
    } catch (e) {
      _logger.e('Error initializing speech recognition: $e');
      _onError?.call('Initialization failed: $e');
      throw SpeechRecognitionException(
        message: 'Failed to initialize speech recognition',
        originalError: e,
      );
    }
  }

  /// Start listening for speech
  /// 
  /// Parameters:
  /// - [onResult]: Callback when speech is recognized
  /// - [listenFor]: Duration to listen (default: 30 seconds)
  /// - [pauseFor]: Duration to pause before stopping (default: 3 seconds)
  /// - [partialResults]: Include partial results (default: true)
  /// - [localeId]: Specific language locale (default: device locale)
  Future<void> startListening({
    required OnSpeechResult onResult,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
    bool partialResults = true,
    String? localeId,
  }) async {
    try {
      if (!_isInitialized) {
        throw SpeechRecognitionException(
          message: 'Speech recognition not initialized. Call initialize() first.',
        );
      }

      if (_isListening) {
        _logger.w('Already listening, ignoring startListening call');
        return;
      }

      _onResult = onResult;
      _currentLocaleId = localeId ?? _currentLocaleId;

      _logger.d(
        'Starting speech listening - '
        'listenFor: ${listenFor.inSeconds}s, '
        'locale: $_currentLocaleId',
      );

      await _speechToText.listen(
        onResult: _handleResult,
        listenFor: listenFor,
        pauseFor: pauseFor,
        partialResults: partialResults,
        localeId: _currentLocaleId,
        cancelOnError: true,
        onSoundLevelChange: _handleSoundLevel,
      );

      _isListening = true;
      _onStatusChange?.call('listening');
    } catch (e) {
      _logger.e('Error starting listening: $e');
      _onError?.call('Failed to start listening: $e');
      throw SpeechRecognitionException(
        message: 'Failed to start listening',
        originalError: e,
      );
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    try {
      if (!_isListening) {
        _logger.w('Not listening, ignoring stopListening call');
        return;
      }

      await _speechToText.stop();
      _isListening = false;
      _onStatusChange?.call('stopped');
      _logger.d('Stopped listening');
    } catch (e) {
      _logger.e('Error stopping listening: $e');
      _onError?.call('Failed to stop listening: $e');
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    try {
      if (!_isListening) {
        return;
      }

      await _speechToText.cancel();
      _isListening = false;
      _onStatusChange?.call('cancelled');
      _logger.d('Cancelled listening');
    } catch (e) {
      _logger.e('Error cancelling listening: $e');
      _onError?.call('Failed to cancel listening: $e');
    }
  }

  /// Get available locales
  Future<List<LocaleInfo>> getAvailableLocales() async {
    try {
      return await _speechToText.locales();
    } catch (e) {
      _logger.e('Error getting locales: $e');
      return [];
    }
  }

  /// Set the language locale for speech recognition
  void setLocale(String localeId) {
    _currentLocaleId = localeId;
    _logger.d('Locale set to: $localeId');
  }

  // Private callback handlers

  void _handleStatus(String status) {
    _logger.d('Status: $status');
    _onStatusChange?.call(status);
  }

  void _handleError(dynamic error) {
    _logger.e('Speech error: $error');
    _onError?.call(error.toString());
    _isListening = false;
  }

  void _handleResult(SpeechRecognitionResult result) {
    final text = result.recognizedWords;
    final isFinal = result.finalResult;

    if (text.isEmpty) {
      return;
    }

    _logger.d(
      'Recognized: "$text" (final: $isFinal, confidence: ${result.confidence})',
    );

    _onResult?.call(text, isFinal);

    // Auto-stop after final result
    if (isFinal) {
      _isListening = false;
    }
  }

  void _handleSoundLevel(double level) {
    // Can be used for visual feedback (microphone level)
    // Uncomment for debugging:
    // _logger.d('Sound level: $level');
  }

  /// Dispose the service
  void dispose() {
    _onResult = null;
    _onStatusChange = null;
    _onError = null;
  }
}

/// Extension to access locales as a type alias
typedef LocaleInfo = stt.LocaleName;
