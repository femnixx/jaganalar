import 'dart:convert';

import 'package:jaganalar/Supabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
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
    // Correctly handle the 'options' field
    List<String> optionsList;

    if (map['options'] is String) {
      // Decode the JSON string into a List<dynamic> and then convert
      optionsList = List<String>.from(jsonDecode(map['options']));
    } else if (map['options'] is List) {
      // If it's already a List, use it directly
      optionsList = List<String>.from(map['options']);
    } else {
      // Handle unexpected data types by returning an empty list
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
  print(response);

  // new client retuns <list<map<String, dynamic>> directly
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

  if (response != null) {
    return UserModel.fromMap(response);
  }
  return null;
}

class _QuizPageState extends State<QuizPage> {
  int currentIndex = 0;
  int? selectedAnswer;

  // points
  final userId = SupabaseService.client.auth.currentUser!.id;
  late Future<UserModel?> userFuture;

  // add mission count and XP (trying lol) once point quiz is done
  Future<void> updateMissionCount() async {
    final user = await fetchUser();
    int _addMissions = (user?.missions ?? 0) + 1;
    int _addXP = (user?.xp ?? 0) + 20;

    final response = await SupabaseService.client
        .from('users')
        .update({'missions': _addMissions, 'xp': _addXP})
        .eq('uuid', userId)
        .select();
    if (response != null) {
      print('Successfully updated missions');
    }
    setState(() {
      userFuture = fetchUser();
    });
  }

  Future<void> nextQuestion() async {
    setState(() {
      selectedAnswer = null;
      if (currentIndex < widget.questions.length - 1) {
        setState(() {
          selectedAnswer = null;
          currentIndex++;
        });
      } else {
        // Quiz finished
        updateMissionCount();
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Quiz completed'),
            content: Text('good job'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            ...List.generate(question.options.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      selectedAnswer = index;
                    });

                    // Optional: generate feedback using Gemini
                    final feedback = await getQuizFeedback(
                      question: question.question,
                      options: question.options,
                      correctIndex: question.correctIndex,
                      userAnswerIndex: index,
                    );

                    // Show feedback in dialog
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Feedback"),
                        content: Text(feedback),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              nextQuestion(); // go to next question
                            },
                            child: Text("Next"),
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
