import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:jaganalar/Dashboard.dart';
import 'package:jaganalar/Supabase.dart';
import 'consts.dart';
import 'UserModel.dart';
import 'DiscussionPage.dart';

final Gemini gemini = Gemini.init(apiKey: GEMINI_API_KEY);

/// Model for quiz sets
// lib/QuizSet.dart (or wherever you define your models)
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
      questions: data['questions'] as List<dynamic>,
      answers: data['answers'] as List<dynamic>,
      correctIndex: data['correctIndex'] as List<dynamic>,
      points: data['points'] as int,
    );
  }
}

Future<List<QuizSet>> fetchQuizSets() async {
  final response = await SupabaseService.client.from('questions').select('*');

  if (response is List) {
    return response
        .map((e) => QuizSet.fromMap(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

/// Fetch user info for XP updates
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
  String? feedbackMessage; // New state variable for feedback

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

  Future<void> nextQuestion() async {
    setState(() {
      selectedAnswer = null;
      feedbackMessage = null; // Clear feedback for the next question
      if (currentIndex < widget.quizSet.questions.length - 1) {
        currentIndex++;
      } else {
        updateMissionCountAndLevelUp();
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Quiz Completed!'),
            content: const Text('You gained XP and completed a mission!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const Dashboard()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

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
      // Sanitize input to avoid Gemini errors
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
      setState(() {
        feedbackMessage = response?.output ?? "No feedback available.";
      });
    } catch (e) {
      print("Gemini Error: $e");
      setState(() {
        feedbackMessage = "Error getting feedback.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quizSet.questions[currentIndex];
    final options = List<String>.from(widget.quizSet.answers[currentIndex]);
    final correctIndex = widget.quizSet.correctIndex[currentIndex] as int;
    final progress = (currentIndex + 1) / widget.quizSet.questions.length;
    final progressPercentage = (progress * 100).toStringAsFixed(0);

    return Scaffold(
      body: Padding(
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
                    onPressed: () {
                      // implement confirm to go out or whatever but will not get points
                    },
                    icon: Icon(Icons.arrow_back_ios),
                  ),
                  Text(
                    question,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    onPressed: () {
                      // idk what to implement here
                    },
                    icon: Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
            Divider(),
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
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress,
                color: Colors.black,
                valueColor: AlwaysStoppedAnimation(Colors.pink),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              question,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            // Generate answer buttons
            ...List.generate(options.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedAnswer != null)
                      return; // prevent multiple clicks

                    setState(() {
                      selectedAnswer = index;
                    });

                    await getAndSetFeedback(
                      question: question,
                      options: options,
                      correctIndex: correctIndex,
                      userAnswerIndex: index,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Color(0xff9396A0)),
                    shadowColor: Colors.transparent,
                    backgroundColor: getOptionColor(
                      index,
                      selectedAnswer,
                      correctIndex,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    options[index],
                    style: TextStyle(
                      color:
                          (selectedAnswer != null &&
                              (index == selectedAnswer ||
                                  index == correctIndex))
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              );
            }),
            if (selectedAnswer != null) ...[
              const SizedBox(height: 20),
              selectedAnswer == correctIndex ? _ifCorrect() : _ifWrong(),
              const SizedBox(height: 20),
              _feedbackContainer(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _ifCorrect() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffCCFECB).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
  }

  Widget _ifWrong() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
  }

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
              Text(
                'Pembahasan Soal:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                feedbackMessage ?? 'Loading feedback...',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent,
            backgroundColor: Color(0xff1C6EA4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            if (isLastQuestion) {
              // Quiz finished → Navigate to discussion page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Discussionpage()),
              );
            } else {
              await nextQuestion();
            }
          },
          child: Align(
            alignment: isLastQuestion
                ? Alignment.center
                : Alignment.centerRight,
            child: Text(
              isLastQuestion ? 'Ruang Diskusi' : 'Lanjut >>',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Color getOptionColor(int index, int? selectedAnswer, int correctIndex) {
    if (selectedAnswer == null) {
      return Colors.white; // default before selecting
    } else if (index == correctIndex) {
      return Color(0xff00FF03); // green for correct answer
    } else if (index == selectedAnswer) {
      return Color(0xffDB5550); // red for wrong selected answer
    } else {
      return Colors.white; // unselected buttons remain white
    }
  }
}
