import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Supabase.dart';
import 'consts.dart';

class QuizResultsPage extends StatefulWidget {
  final int quizId;
  final List<dynamic> userAnswers;

  const QuizResultsPage({
    super.key,
    required this.quizId,
    required this.userAnswers,
  });

  @override
  State<QuizResultsPage> createState() => _QuizResultsPageState();
}

class _QuizResultsPageState extends State<QuizResultsPage> {
  Map<String, dynamic>? _quizData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuizData();
  }

  Future<void> _fetchQuizData() async {
    try {
      final response = await SupabaseService.client
          .from('questions')
          .select()
          .eq('id', widget.quizId)
          .single();

      setState(() {
        _quizData = response;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching quiz data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Results...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_quizData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results Not Found')),
        body: const Center(child: Text('Could not load quiz data.')),
      );
    }

    final quizQuestions = _quizData!['questions'];
    final quizAnswers = _quizData!['answers'];
    final quizCorrectIndices = _quizData!['correctIndex'];

    return Scaffold(
      appBar: AppBar(
        title: Text(_quizData!['title'] ?? 'Quiz Results'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: quizQuestions.length,
          itemBuilder: (context, index) {
            final questionText = quizQuestions[index];
            final options = List<String>.from(quizAnswers[index]);
            final correctIndex = quizCorrectIndices[index] as int;
            final userAnswer = widget.userAnswers[index];
            final selectedOptionIndex = userAnswer['selected_option'];
            final isCorrect = userAnswer['is_correct'];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${index + 1}:',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(questionText, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    ...List.generate(options.length, (optionIndex) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '${getAlphabet(optionIndex)}. ${options[optionIndex]}',
                          style: TextStyle(
                            color: getOptionColor(
                              optionIndex,
                              selectedOptionIndex,
                              correctIndex,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    Text(
                      isCorrect ? 'Correct!' : 'Incorrect.',
                      style: TextStyle(
                        color: isCorrect ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'You chose: ${options[selectedOptionIndex]}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                    Text(
                      'Correct answer: ${options[correctIndex]}',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String getAlphabet(int index) {
    return String.fromCharCode('A'.codeUnitAt(0) + index);
  }

  Color getOptionColor(int index, int selectedOptionIndex, int correctIndex) {
    if (index == correctIndex) {
      return Colors.green;
    }
    if (index == selectedOptionIndex && selectedOptionIndex != correctIndex) {
      return Colors.red;
    }
    return Colors.black;
  }
}
