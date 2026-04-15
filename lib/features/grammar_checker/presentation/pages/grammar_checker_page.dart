import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/grammar_mistake.dart';
import '../bloc/grammar_checker_bloc.dart';

/// Grammar Checker page
class GrammarCheckerPage extends StatefulWidget {

  const GrammarCheckerPage({Key? key, this.initialText})
      : super(key: key);
  final String? initialText;

  @override
  State<GrammarCheckerPage> createState() => _GrammarCheckerPageState();
}

class _GrammarCheckerPageState extends State<GrammarCheckerPage> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Grammar Checker'),
        centerTitle: true,
      ),
      body: BlocListener<GrammarCheckerBloc, GrammarCheckerState>(
        listener: (context, state) {
          if (state is GrammarCheckerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(kPaddingMedium),
          child: Column(
            children: [
              // Text input field
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Enter text to check',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                ),
                minLines: 4,
                maxLines: 6,
              ),
              const SizedBox(height: kPaddingMedium),

              // Check button
              ElevatedButton.icon(
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    context.read<GrammarCheckerBloc>().add(
                          CheckGrammarEvent(text: _textController.text),
                        );
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Check Grammar'),
              ),
              const SizedBox(height: kPaddingMedium),

              // Results
              Expanded(
                child:
                    BlocBuilder<GrammarCheckerBloc, GrammarCheckerState>(
                  builder: (context, state) {
                    if (state is GrammarCheckerInitial) {
                      return Center(
                        child: Text(
                          'Enter text and tap "Check Grammar" to get started',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else if (state is GrammarCheckerLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is GrammarCheckerLoaded) {
                      return _buildResultsView(context, state);
                    } else if (state is GrammarCheckerError) {
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.red),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

  Widget _buildResultsView(
    BuildContext context,
    GrammarCheckerLoaded state,
  ) => SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accuracy card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(kPaddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accuracy Score',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: kPaddingSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.accuracy.toStringAsFixed(2)}%',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                          color: _getAccuracyColor(state.accuracy),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(kBorderRadius),
                          color: Colors.grey[300],
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: 100 * (state.accuracy / 100),
                              height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  kBorderRadius,
                                ),
                                color:
                                    _getAccuracyColor(state.accuracy),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: kPaddingMedium),

          // Mistakes list
          if (state.mistakes.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(kPaddingMedium),
                child: Text(
                  'No grammar mistakes found!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            )
          else ...[
            Text(
              'Found ${state.mistakes.length} mistake(s)',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: kPaddingSmall),
            ...state.mistakes.map((mistake) =>
                _buildMistakeCard(context, mistake)),
          ],
        ],
      ),
    );

  Widget _buildMistakeCard(
    BuildContext context,
    GrammarMistake mistake,
  ) => Card(
      margin: const EdgeInsets.only(bottom: kPaddingSmall),
      child: Padding(
        padding: const EdgeInsets.all(kPaddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '"${mistake.text}"',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(_errorTypeLabel(mistake.errorType)),
                  backgroundColor:
                      _getErrorTypeColor(mistake.errorType)
                          .withOpacity(0.3),
                ),
              ],
            ),
            const SizedBox(height: kPaddingSmall),
            Text(
              'Suggestion: ${mistake.suggestion}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: kPaddingSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Confidence: ${(mistake.confidence * 100).toStringAsFixed(0)}%',
                  style:
                      Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= kGoodAccuracyThreshold) {
      return Colors.green;
    } else if (accuracy >= kAverageAccuracyThreshold) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getErrorTypeColor(GrammarErrorType errorType) {
    switch (errorType) {
      case GrammarErrorType.subjectVerbAgreement:
        return Colors.red;
      case GrammarErrorType.tenseMismatch:
        return Colors.orange;
      case GrammarErrorType.wordChoice:
        return Colors.yellow;
      case GrammarErrorType.sentenceStructure:
        return Colors.blue;
      case GrammarErrorType.punctuation:
        return Colors.purple;
      case GrammarErrorType.spelling:
        return Colors.pink;
      case GrammarErrorType.other:
        return Colors.grey;
    }
  }

  String _errorTypeLabel(GrammarErrorType errorType) {
    switch (errorType) {
      case GrammarErrorType.subjectVerbAgreement:
        return 'Subject-Verb';
      case GrammarErrorType.tenseMismatch:
        return 'Tense';
      case GrammarErrorType.wordChoice:
        return 'Word Choice';
      case GrammarErrorType.sentenceStructure:
        return 'Structure';
      case GrammarErrorType.punctuation:
        return 'Punctuation';
      case GrammarErrorType.spelling:
        return 'Spelling';
      case GrammarErrorType.other:
        return 'Other';
    }
  }
}
