import 'package:word_pedometer/core/errors/failures.dart';
import 'package:word_pedometer/core/errors/result.dart';
import 'package:word_pedometer/features/speech_recognition/domain/entities/transcription.dart';

/// Repository interface for speech recognition operations
abstract class SpeechRecognitionRepository {
  /// Initialize speech recognition
  Future<Result<bool, Failure>> initialize();

  /// Start listening to speech
  Future<Result<void, Failure>> startListening();

  /// Stop listening to speech
  Future<Result<void, Failure>> stopListening();

  /// Get the last transcription
  Future<Result<Transcription, Failure>> getLastTranscription();

  /// Stream of transcription results
  Stream<Transcription> get transcriptionStream;

  /// Check if currently listening
  bool isListening();

  /// Dispose resources
  Future<Result<void, Failure>> dispose();
}
