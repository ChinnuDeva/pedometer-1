/// Speech Recognition Domain Entity
class Transcription {

  Transcription({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.confidence,
    required this.duration,
  });
  final String id;
  final String text;
  final DateTime timestamp;
  final double confidence;
  final Duration duration;

  @override
  String toString() =>
      'Transcription(id: $id, text: $text, timestamp: $timestamp, '
      'confidence: $confidence, duration: $duration)';
}
