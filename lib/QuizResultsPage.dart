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
  int _currentIndex = 0; // State variable to track the current question index

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

  void _nextQuestion() {
    if (_currentIndex < _quizData!['questions'].length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
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
    final quizTitle = _quizData!['title'] ?? 'Quiz Results';

    final questionText = quizQuestions[_currentIndex];
    final options = List<String>.from(quizAnswers[_currentIndex]);
    final correctIndex = quizCorrectIndices[_currentIndex] as int;
    final userAnswerData = widget.userAnswers[_currentIndex];
    final selectedOptionIndex = userAnswerData['selected_option'];
    final isCorrect = userAnswerData['is_correct'];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    quizTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Action for more options
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              // Question progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentIndex + 1} of ${quizQuestions.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${((_currentIndex + 1) / quizQuestions.length * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: (_currentIndex + 1) / quizQuestions.length,
                minHeight: 12,
                color: Colors.pink,
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(height: 20),

              // Question content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        questionText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(options.length, (optionIndex) {
                        final isUserChoice = optionIndex == selectedOptionIndex;
                        final isCorrectAnswer = optionIndex == correctIndex;

                        Color backgroundColor;
                        Color textColor;
                        Color borderColor;
                        FontWeight fontWeight = FontWeight.w500;

                        if (isCorrectAnswer) {
                          backgroundColor = const Color(0xffCCFECB);
                          textColor = const Color(0xff72C457);
                          borderColor = const Color(0xff72C457);
                          fontWeight = FontWeight.bold;
                        } else if (isUserChoice) {
                          backgroundColor = Colors.red.withOpacity(0.2);
                          textColor = Colors.red;
                          borderColor = Colors.red;
                        } else {
                          backgroundColor = Colors.white;
                          textColor = Colors.black;
                          borderColor = Colors.grey;
                        }

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            '${getAlphabet(optionIndex)}. ${options[optionIndex]}',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: fontWeight,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? const Color(0xffCCFECB)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isCorrect
                              ? 'Correct Answer!'
                              : 'Your Answer is Incorrect!',
                          style: TextStyle(
                            color: isCorrect
                                ? const Color(0xff72C457)
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _currentIndex > 0 ? _previousQuestion : null,
                    child: const Text('Previous'),
                  ),
                  ElevatedButton(
                    onPressed: _currentIndex < quizQuestions.length - 1
                        ? _nextQuestion
                        : null,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getAlphabet(int index) {
    return String.fromCharCode('A'.codeUnitAt(0) + index);
  }
}
