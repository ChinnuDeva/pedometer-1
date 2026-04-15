import 'package:word_pedometer/core/errors/failures.dart';
import 'package:word_pedometer/core/errors/result.dart';
import 'package:word_pedometer/features/speech_recognition/data/datasources/speech_recognition_local_data_source.dart';
import 'package:word_pedometer/features/speech_recognition/data/models/transcription_model.dart';
import 'package:word_pedometer/features/speech_recognition/domain/entities/transcription.dart';
import 'package:word_pedometer/features/speech_recognition/domain/repositories/speech_recognition_repository.dart';
import 'package:uuid/uuid.dart';

/// Implementation of SpeechRecognitionRepository
class SpeechRecognitionRepositoryImpl
    implements SpeechRecognitionRepository {
  final SpeechRecognitionDataSource _dataSource;

  SpeechRecognitionRepositoryImpl({
    required SpeechRecognitionDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<bool, Failure>> initialize() async {
    try {
      final result = await _dataSource.initialize();
      return Result.success(result);
    } catch (e) {
      return Result.failure(
        SpeechRecognitionFailure(
          message: 'Failed to initialize speech recognition: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<void, Failure>> startListening() async {
    try {
      await _dataSource.startListening();
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        SpeechRecognitionFailure(
          message: 'Failed to start listening: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<void, Failure>> stopListening() async {
    try {
      await _dataSource.stopListening();
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        SpeechRecognitionFailure(
          message: 'Failed to stop listening: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<Transcription, Failure>> getLastTranscription() async {
    try {
      final text = _dataSource.getTranscribedText();
      if (text.isEmpty) {
        return Result.failure(
          SpeechRecognitionFailure(
            message: 'No transcription available',
          ),
        );
      }

      final model = TranscriptionModel(
        id: const Uuid().v4(),
        text: text,
        timestamp: DateTime.now(),
        confidence: _dataSource.getConfidenceScore(),
        duration: const Duration(seconds: 0),
      );

      return Result.success(model);
    } catch (e) {
      return Result.failure(
        UnexpectedFailure(message: e.toString()),
      );
    }
  }

  @override
  bool isListening() => _dataSource.isListening();

  @override
  Stream<Transcription> get transcriptionStream => _dataSource.transcriptionStream;

  @override
  Future<Result<void, Failure>> dispose() async {
    try {
      await _dataSource.dispose();
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        UnexpectedFailure(message: e.toString()),
      );
    }
  }
}
