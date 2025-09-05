import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:jaganalar/Dashboard.dart';
import 'package:jaganalar/History.dart';
import 'package:jaganalar/Supabase.dart';
import 'package:jaganalar/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'consts.dart';
import 'UserModel.dart';

final Gemini gemini = Gemini.init(apiKey: GEMINI_API_KEY);

class QuizSet {
  final int id;
  final String title;
  final List<dynamic> questions;
  final List<dynamic> answers;
  final List<dynamic> correctIndex;
  final int points;

  QuizSet({
    required this.id,
    required this.title,
    required this.questions,
    required this.answers,
    required this.correctIndex,
    required this.points,
  });

  factory QuizSet.fromMap(Map<String, dynamic> data) {
    return QuizSet(
      id: data['id'] as int,
      title: data['title'] as String,
      questions: (data['questions'] is String)
          ? List<dynamic>.from(jsonDecode(data['questions']))
          : List<dynamic>.from(data['questions'] ?? []),
      answers: (data['answers'] is String)
          ? List<dynamic>.from(jsonDecode(data['answers']))
          : List<dynamic>.from(data['answers'] ?? []),
      correctIndex: (data['correctIndex'] is String)
          ? List<dynamic>.from(jsonDecode(data['correctIndex']))
          : List<dynamic>.from(data['correctIndex'] ?? []),
      points: data['points'] as int,
    );
  }
}

/// Fetch user info
Future<UserModel?> fetchUser() async {
  final userId = SupabaseService.client.auth.currentUser!.id;
  final response = await SupabaseService.client
      .from('users')
      .select('*')
      .eq('uuid', userId)
      .single();
  return response != null ? UserModel.fromMap(response) : null;
}

int xpForNextLevel(int level) => 100 + (level - 1) * 20;

/// Quiz Page
class QuizPage extends StatefulWidget {
  final QuizSet quizSet;
  const QuizPage({super.key, required this.quizSet});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentIndex = 0;
  int? selectedAnswer;
  String? feedbackMessage;

  List<Map<String, dynamic>> _userAnswers = [];
  List<String> _feedbackList = []; // <-- JSON array of feedback per question

  /// Update XP and mission count
  Future<void> updateMissionCountAndLevelUp() async {
    final user = await fetchUser();
    if (user == null) return;

    int newMissions = (user.missions ?? 0) + 1;
    int xpGain = 20;
    int totalXP = (user.xp ?? 0) + xpGain;
    int newLevel = user.level ?? 1;

    while (totalXP >= xpForNextLevel(newLevel)) {
      totalXP -= xpForNextLevel(newLevel);
      newLevel++;
    }

    await SupabaseService.client
        .from('users')
        .update({'missions': newMissions, 'xp': totalXP, 'level': newLevel})
        .eq('uuid', SupabaseService.client.auth.currentUser!.id);
  }

  /// Add quiz to history
  Future<void> addHistory(int quizId) async {
    final userId = SupabaseService.client.auth.currentUser!.id;
    try {
      await SupabaseService.client.from('quiz_completed').upsert({
        'uuid': userId,
        'quiz_id': quizId,
        'completed': true,
        'title': widget.quizSet.title,
      });
    } catch (e) {
      print("Error adding quiz to history: $e");
    }
  }

  /// Save quiz results with feedback JSON
  Future<void> saveQuizResults() async {
    final userId = SupabaseService.client.auth.currentUser!.id;
    final score = _userAnswers.where((a) => a['is_correct'] == true).length;

    try {
      await SupabaseService.client.from('quiz_results').insert({
        'uuid': userId,
        'quiz_id': widget.quizSet.id,
        'selected_answers': _userAnswers,
        'score': score,
        'created_at': DateTime.now().toIso8601String(),
        'feedback': jsonEncode(_feedbackList), // <-- save JSON array
      });
      print('Quiz results saved successfully!');
    } catch (e) {
      print('Error saving quiz results: $e');
    }
  }

  /// Get feedback for a single question
  Future<void> getAndSetFeedback({
    required String question,
    required List<String> options,
    required int correctIndex,
    required int userAnswerIndex,
  }) async {
    setState(() {
      feedbackMessage = "Loading feedback...";
    });

    try {
      String safeQuestion = question.replaceAll(RegExp(r'[^\w\s\+\-\*/]'), '');
      List<String> safeOptions = options
          .map((e) => e.replaceAll(RegExp(r'[^\w\s\+\-\*/]'), ''))
          .toList();

      String formattedOptions = safeOptions
          .asMap()
          .entries
          .map((e) => "${e.key + 1}. ${e.value}")
          .join("\n");

      String prompt =
          """
Question: $safeQuestion
Options:
$formattedOptions

Correct answer: ${safeOptions[correctIndex]}
Student answer: ${safeOptions[userAnswerIndex]}

If wrong: explain shortly why and give the correct answer.
If correct: explain briefly why others are wrong.
""";

      final response = await Gemini.instance.prompt(parts: [Part.text(prompt)]);
      String feedback = response?.output ?? "No feedback available.";

      setState(() {
        feedbackMessage = feedback;
      });

      // Add feedback to JSON array
      if (_feedbackList.length > currentIndex) {
        _feedbackList[currentIndex] = feedback;
      } else {
        _feedbackList.add(feedback);
      }

      // Update feedback in user answers as well
      _userAnswers[currentIndex]['feedback'] = feedback;
    } catch (e) {
      print("Gemini Error: $e");
      setState(() {
        feedbackMessage = "Error getting feedback.";
      });

      if (_feedbackList.length > currentIndex) {
        _feedbackList[currentIndex] = "Error getting feedback.";
      } else {
        _feedbackList.add("Error getting feedback.");
      }
    }
  }

  /// Move to next question or finish quiz
  Future<void> nextQuestion() async {
    if (currentIndex < widget.quizSet.questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
        feedbackMessage = null;
      });
    } else {
      await updateMissionCountAndLevelUp();
      await addHistory(widget.quizSet.id);
      await saveQuizResults();
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Quiz Completed!'),
          content: const Text('You gained XP and completed a mission!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => MyMainScreen()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  /// UI for correct/wrong feedback
  Widget _ifCorrect() => Container(
    decoration: BoxDecoration(
      color: const Color(0xffCCFECB).withOpacity(0.5),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: const [
          Text(
            'Jawaban Anda Benar',
            style: TextStyle(
              color: Color(0xff72C457),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Silahkan lanjut ke soal berikutnya',
            style: TextStyle(
              color: Color(0xff969696),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _ifWrong() => Container(
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.5),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: const [
          Text(
            'Jawaban Anda Salah',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Silahkan lanjut ke soal berikutnya!',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _feedbackContainer() {
    final isLastQuestion = currentIndex == widget.quizSet.questions.length - 1;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Pembahasan Soal:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                feedbackMessage ?? 'Loading feedback...',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent,
            backgroundColor: Color(0xff1C6EA4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: nextQuestion,
          child: Align(
            alignment: isLastQuestion
                ? Alignment.center
                : Alignment.centerRight,
            child: Text(
              isLastQuestion ? 'Ruang Diskusi' : 'Lanjut >>',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quizSet.questions[currentIndex];
    final options = List<String>.from(widget.quizSet.answers[currentIndex]);
    final correctIndex = widget.quizSet.correctIndex[currentIndex] as int;
    final progress = (currentIndex + 1) / widget.quizSet.questions.length;
    final progressPercentage = (progress * 100).toStringAsFixed(0);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pertanyaan ${currentIndex + 1} dari ${widget.quizSet.questions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$progressPercentage%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress,
                color: Colors.black,
                valueColor: const AlwaysStoppedAnimation(Colors.pink),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...List.generate(options.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  onPressed: selectedAnswer != null
                      ? null
                      : () async {
                          setState(() {
                            selectedAnswer = index;
                            _userAnswers.add({
                              'question_index': currentIndex,
                              'selected_option': index,
                              'is_correct': index == correctIndex,
                              'feedback': '',
                            });
                          });

                          await getAndSetFeedback(
                            question: question,
                            options: options,
                            correctIndex: correctIndex,
                            userAnswerIndex: index,
                          );
                        },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (selectedAnswer == null) return Colors.white;
                      if (index == correctIndex)
                        return const Color(0xff00FF03); // green
                      if (index == selectedAnswer &&
                          selectedAnswer != correctIndex)
                        return const Color(0xffDB5550); // red
                      return Colors.white;
                    }),
                    foregroundColor: MaterialStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (selectedAnswer == null) return Colors.black;
                      if (index == correctIndex ||
                          (index == selectedAnswer &&
                              selectedAnswer != correctIndex))
                        return Colors.white;
                      return Colors.black;
                    }),
                    side: MaterialStateProperty.all(
                      const BorderSide(color: Color(0xff9396A0)),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: Text(options[index]),
                ),
              );
            }),
            if (selectedAnswer != null) ...[
              const SizedBox(height: 20),
              selectedAnswer ==
                      (widget.quizSet.correctIndex[currentIndex] as int)
                  ? _ifCorrect()
                  : _ifWrong(),
              const SizedBox(height: 20),
              _feedbackContainer(),
            ],
          ],
        ),
      ),
    );
  }
}

/// Option color helper
Color getOptionColor(int index, int? selectedAnswer, int correctIndex) {
  if (selectedAnswer == null) return Colors.white;
  if (index == correctIndex) return const Color(0xff00FF03);
  if (index == selectedAnswer && selectedAnswer != correctIndex)
    return const Color(0xffDB5550);
  return Colors.white;
}
