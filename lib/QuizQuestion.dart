import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:jaganalar/Dashboard.dart';
import 'package:jaganalar/Supabase.dart';
import 'consts.dart';
import 'UserModel.dart';

final Gemini gemini = Gemini.init(apiKey: GEMINI_API_KEY);

/// Model for quiz sets
// lib/QuizSet.dart (or wherever you define your models)
class QuizSet {
  final int id;
  final String title;
  final List<dynamic>
  questions; // Or a more specific type if you have a Question model
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

  // ✅ This is the factory constructor that fixes your error
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

  Future<String> getQuizFeedback({
    required String question,
    required List<String> options,
    required int correctIndex,
    required int userAnswerIndex,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      // Sanitize input to avoid Gemini errors
      String safeQuestion = question.replaceAll(RegExp(r'[^\w\s\+\-\*/]'), '');
      List<String> safeOptions = options
          .map((e) => e.toString().replaceAll(RegExp(r'[^\w\s\+\-\*/]'), ''))
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

      // Debug log to check what we send to Gemini
      print("Gemini Prompt:\n$prompt");

      final response = await Gemini.instance.prompt(parts: [Part.text(prompt)]);
      return response?.output ?? "No feedback available.";
    } catch (e) {
      print("Gemini Error: $e");
      return "Error getting feedback: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quizSet.questions[currentIndex];
    final options = List<String>.from(widget.quizSet.answers[currentIndex]);
    final correctIndex = widget.quizSet.correctIndex[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Question ${currentIndex + 1}/${widget.quizSet.questions.length}",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Generate answer buttons
            ...List.generate(options.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      selectedAnswer = index;
                    });

                    // Try Gemini feedback, fallback to basic message if fails
                    String feedback = await getQuizFeedback(
                      question: question,
                      options: options,
                      correctIndex: correctIndex,
                      userAnswerIndex: index,
                    );

                    if (!context.mounted) return;

                    // Show feedback dialog
                    await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Feedback"),
                        content: Text(feedback),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              nextQuestion(); // Always moves forward
                            },
                            child: const Text("Next"),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedAnswer == index
                        ? Colors.orange
                        : Colors.blue,
                  ),
                  child: Text(options[index]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
