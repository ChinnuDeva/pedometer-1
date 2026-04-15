import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:word_pedometer/core/constants/app_constants.dart';
import 'package:word_pedometer/features/speech_recognition/presentation/bloc/speech_recognition_bloc.dart';

/// Speech Recognition page
class SpeechRecognitionPage extends StatefulWidget {
  const SpeechRecognitionPage({Key? key}) : super(key: key);

  @override
  State<SpeechRecognitionPage> createState() => _SpeechRecognitionPageState();
}

class _SpeechRecognitionPageState extends State<SpeechRecognitionPage> {
  @override
  void initState() {
    super.initState();
    _requestPermissionsAndInitialize();
  }

  Future<void> _requestPermissionsAndInitialize() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      if (mounted) {
        context.read<SpeechRecognitionBloc>().add(
              const InitializeSpeechRecognitionEvent(),
            );
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionDeniedDialog();
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Text(
          'This app needs microphone access to recognize your speech. '
          'Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Recognition'),
        centerTitle: true,
      ),
      body: BlocConsumer<SpeechRecognitionBloc, SpeechRecognitionState>(
        listener: (context, state) {
          if (state is SpeechRecognitionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(kPaddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusIndicator(state),
                const SizedBox(height: kPaddingLarge),
                _buildTranscriptionDisplay(state),
                const SizedBox(height: kPaddingLarge),
                _buildControlButtons(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(SpeechRecognitionState state) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (state is SpeechRecognitionInitial ||
        state is SpeechRecognitionInitializing) {
      statusColor = Colors.grey;
      statusText = 'Initializing...';
      statusIcon = Icons.hourglass_empty;
    } else if (state is SpeechRecognitionInitialized) {
      statusColor = Colors.blue;
      statusText = 'Ready';
      statusIcon = Icons.check_circle;
    } else if (state is SpeechRecognitionListening) {
      statusColor = Colors.red;
      statusText = 'Listening...';
      statusIcon = Icons.mic;
    } else if (state is SpeechRecognitionStopped) {
      statusColor = Colors.blue;
      statusText = 'Stopped';
      statusIcon = Icons.stop_circle;
    } else if (state is SpeechRecognitionError) {
      statusColor = Colors.red;
      statusText = 'Error';
      statusIcon = Icons.error;
    } else if (state is TranscriptionReceived) {
      statusColor = Colors.green;
      statusText = 'Transcription Received';
      statusIcon = Icons.text_fields;
    } else {
      statusColor = Colors.grey;
      statusText = 'Unknown';
      statusIcon = Icons.help;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(
        horizontal: kPaddingMedium,
        vertical: kPaddingSmall,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        border: Border.all(color: statusColor, width: 2),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionDisplay(SpeechRecognitionState state) {
    String transcriptionText = '';
    double confidence = 0.0;

    if (state is TranscriptionReceived) {
      transcriptionText = state.transcription.text;
      confidence = state.transcription.confidence;
    } else if (state is SpeechRecognitionListening &&
        state.currentTranscription != null) {
      transcriptionText = state.currentTranscription!.text;
      confidence = state.currentTranscription!.confidence;
    } else if (state is SpeechRecognitionStopped &&
        state.lastTranscription != null) {
      transcriptionText = state.lastTranscription!.text;
      confidence = state.lastTranscription!.confidence;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(kPaddingMedium),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transcription',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: kPaddingSmall),
          Text(
            transcriptionText.isEmpty
                ? 'Start speaking to see transcription...'
                : transcriptionText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: transcriptionText.isEmpty ? Colors.grey : null,
                ),
          ),
          if (transcriptionText.isNotEmpty) ...[
            const SizedBox(height: kPaddingSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Confidence:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${(confidence * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getConfidenceColor(confidence),
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.5) return Colors.orange;
    return Colors.red;
  }

  Widget _buildControlButtons(
    BuildContext context,
    SpeechRecognitionState state,
  ) {
    final isListening = state is SpeechRecognitionListening;
    final isInitialized = state is SpeechRecognitionInitialized ||
        state is SpeechRecognitionListening ||
        state is SpeechRecognitionStopped ||
        state is TranscriptionReceived;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: !isListening && isInitialized
              ? () => context.read<SpeechRecognitionBloc>().add(
                    const StartListeningEvent(),
                  )
              : null,
          icon: const Icon(Icons.mic),
          label: const Text('Start'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: isListening
              ? () => context.read<SpeechRecognitionBloc>().add(
                    const StopListeningEvent(),
                  )
              : null,
          icon: const Icon(Icons.stop),
          label: const Text('Stop'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
