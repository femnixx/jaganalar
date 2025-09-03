// QuizQuestion.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:jaganalar/Dashboard.dart';
import 'package:jaganalar/Supabase.dart';
import 'consts.dart';
import 'UserModel.dart';

final Gemini gemini = Gemini.init(apiKey: GEMINI_API_KEY);

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    List<String> optionsList;
    if (map['options'] is String) {
      optionsList = List<String>.from(jsonDecode(map['options']));
    } else if (map['options'] is List) {
      optionsList = List<String>.from(map['options']);
    } else {
      optionsList = [];
    }
    return QuizQuestion(
      id: map['id'].toString(),
      question: map['question'],
      options: optionsList,
      correctIndex: map['correctIndex'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
    };
  }
}

Future<List<QuizQuestion>> fetchQuizQuestions() async {
  final response = await SupabaseService.client.from('questions').select();
  if (response.isEmpty) {
    return [];
  }
  final data = response as List<dynamic>;
  return data
      .map((q) => QuizQuestion.fromMap(q as Map<String, dynamic>))
      .toList();
}

class QuizPage extends StatefulWidget {
  final List<QuizQuestion> questions;
  const QuizPage({super.key, required this.questions});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

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

class _QuizPageState extends State<QuizPage> {
  int currentIndex = 0;
  int? selectedAnswer;
  final String userId = SupabaseService.client.auth.currentUser!.id;

  Future<void> updateMissionCountAndLevelUp() async {
    final user = await fetchUser();
    if (user == null) return;

    // The user completed one mission
    int newMissions = (user.missions ?? 0) + 1;
    // The user gains 20 XP for completing the mission
    int xpGain = 20;

    // Calculate the new total XP
    int totalXP = (user.xp ?? 0) + xpGain;
    int newLevel = user.level ?? 1;

    // Loop to handle potential multiple level-ups
    while (totalXP >= xpForNextLevel(newLevel)) {
      totalXP -= xpForNextLevel(newLevel);
      newLevel++;
    }

    // Update the database with the new values
    await SupabaseService.client
        .from('users')
        .update({
          'missions': newMissions,
          'xp': totalXP, // Use the new, rollover XP
          'level': newLevel, // Use the new level
        })
        .eq('uuid', userId);
  }

  Future<void> nextQuestion() async {
    setState(() {
      selectedAnswer = null;
      if (currentIndex < widget.questions.length - 1) {
        currentIndex++;
      } else {
        // Quiz finished
        updateMissionCountAndLevelUp();
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Quiz Completed!'),
            content: const Text(
              'You did a great job! You gained XP and a new mission count.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Dashboard()),
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

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Question ${currentIndex + 1}/${widget.questions.length}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              question.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...List.generate(question.options.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      selectedAnswer = index;
                    });
                    final feedback = await getQuizFeedback(
                      question: question.question,
                      options: question.options,
                      correctIndex: question.correctIndex,
                      userAnswerIndex: index,
                    );
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Feedback"),
                        content: Text(feedback),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              nextQuestion();
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
                  child: Text(question.options[index]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<String> getQuizFeedback({
    required String question,
    required List<String> options,
    required int correctIndex,
    required int userAnswerIndex,
  }) async {
    String prompt =
        """
You are a helpful tutor. A student answered a multiple-choice question.
Question: $question
Options: ${options.asMap().entries.map((e) => "${e.key + 1}. ${e.value}").join(", ")}
Correct answer: ${options[correctIndex]}
Student answered: ${options[userAnswerIndex]}

If the student answered incorrectly, explain why it is wrong and provide the correct answer in a clear, concise, friendly way.
If correct, congratulate them and explain shortly why the other answers are wrong.
""";

    try {
      final response = await Gemini.instance.prompt(parts: [Part.text(prompt)]);
      return response?.output ?? "No feedback available.";
    } catch (e) {
      print("Gemini error: $e");
      return "Error generating feedback.";
    }
  }
}
