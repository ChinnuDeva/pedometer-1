import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../domain/entities/transcription.dart';

/// Data source for speech recognition operations
abstract class SpeechRecognitionDataSource {
  /// Initialize speech recognition
  Future<bool> initialize();

  /// Start listening to speech
  Future<void> startListening();

  /// Stop listening to speech
  Future<void> stopListening();

  /// Get the transcribed text from the last recording
  String getTranscribedText();

  /// Get the confidence score of the transcription
  double getConfidenceScore();

  /// Check if the system is currently listening
  bool isListening();

  /// Stream of transcription results
  Stream<Transcription> get transcriptionStream;

  /// Dispose resources
  Future<void> dispose();
}

/// Implementation of speech recognition data source
class SpeechRecognitionDataSourceImpl implements SpeechRecognitionDataSource {
  final stt.SpeechToText _speechToText;
  final StreamController<Transcription> _transcriptionController =
      StreamController<Transcription>.broadcast();

  String _transcribedText = '';
  double _confidenceScore = 0.0;
  bool _isListening = false;
  final DateTime _startTime = DateTime.now();

  SpeechRecognitionDataSourceImpl({
    required stt.SpeechToText speechToText,
  }) : _speechToText = speechToText;

  @override
  Stream<Transcription> get transcriptionStream => _transcriptionController.stream;

  @override
  Future<bool> initialize() async {
    try {
      final available = await _speechToText.initialize(
        onError: _onError,
        onStatus: _onStatus,
      );
      return available;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> startListening() async {
    if (!_speechToText.isAvailable) {
      throw Exception('Speech recognition not available');
    }

    try {
      _isListening = true;
      _transcribedText = '';
      _confidenceScore = 0.0;

      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: 'en_US',
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    } catch (e) {
      _isListening = false;
      rethrow;
    }
  }

  @override
  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
      _isListening = false;
    } catch (e) {
      rethrow;
    }
  }

  @override
  String getTranscribedText() => _transcribedText;

  @override
  double getConfidenceScore() => _confidenceScore;

  @override
  bool isListening() => _isListening;

  @override
  Future<void> dispose() async {
    await _speechToText.cancel();
    await _transcriptionController.close();
  }

  void _onSpeechResult(result) {
    _transcribedText = result.recognizedWords;
    _confidenceScore = result.confidence;
    _isListening = !result.finalResult;

    final transcription = Transcription(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _transcribedText,
      timestamp: DateTime.now(),
      confidence: _confidenceScore,
      duration: DateTime.now().difference(_startTime),
    );

    _transcriptionController.add(transcription);
  }

  void _onError(error) {
    _isListening = false;
  }

  void _onStatus(String status) {
    if (status == 'notListening') {
      _isListening = false;
    }
  }
}
