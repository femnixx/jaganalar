import 'dart:convert';
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
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchQuizData();
  }

  Future<void> _fetchQuizData() async {
    try {
      final userId = SupabaseService.client.auth!.currentUser!.id;

      // Fetch quiz questions
      final quizResponse = await SupabaseService.client
          .from('questions')
          .select()
          .eq('id', widget.quizId)
          .single();

      // Fetch user's quiz result including feedback
      final resultResponse = await SupabaseService.client
          .from('quiz_results')
          .select()
          .eq('quiz_id', widget.quizId)
          .eq('uuid', userId)
          .single();

      setState(() {
        _quizData = {
          'questions': quizResponse['questions'],
          'answers': quizResponse['answers'],
          'correctIndex': quizResponse['correctIndex'],
          'title': quizResponse['title'],
          'feedback': resultResponse['feedback'],
        };
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching quiz data: $e');
      setState(() => _isLoading = false);
    }
  }

  List<String> parseFeedback(String raw) {
    try {
      // Feedback is saved as a JSON array string, decode once
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      print('Error parsing feedback: $e');
      return [];
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _quizData!['questions'].length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  String getAlphabet(int index) {
    return String.fromCharCode('A'.codeUnitAt(0) + index);
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

    final quizFeedback = _quizData!['feedback'] != null
        ? parseFeedback(_quizData!['feedback'])
        : [];

    final questionText = quizQuestions[_currentIndex];
    final options = List<String>.from(quizAnswers[_currentIndex]);
    final correctIndex = quizCorrectIndices[_currentIndex] as int;
    final userAnswerData = widget.userAnswers[_currentIndex];
    final selectedOptionIndex = userAnswerData['selected_option'];
    final isCorrect = userAnswerData['is_correct'];
    final feedback =
        quizFeedback.isNotEmpty && quizFeedback.length > _currentIndex
        ? quizFeedback[_currentIndex]
        : 'No feedback available';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      quizTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Icon(Icons.more_vert),
                ],
              ),
              const Divider(),
              // Question navigation circles
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: quizQuestions.length,
                  itemBuilder: (context, index) {
                    final isCurrent = index == _currentIndex;
                    final isQuestionCorrect =
                        widget.userAnswers[index]['is_correct'];
                    Color circleColor = isCurrent
                        ? Colors.blue
                        : (isQuestionCorrect ? Colors.green : Colors.red);

                    return GestureDetector(
                      onTap: () => setState(() => _currentIndex = index),
                      child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(8),
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: circleColor,
                        ),
                        child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              // Progress
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
              // Question and options
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
                      // Correct / Incorrect indicator
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
                      const SizedBox(height: 20),
                      // Feedback
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isCorrect)
                              const Text(
                                "Jawaban anda salah karena",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            Text(feedback),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Navigation buttons
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
}
