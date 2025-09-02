import 'package:jaganalar/Supabase.dart';
import 'package:flutter/material.dart';

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
    return QuizQuestion(
      id: map['id'],
      question: map['question'],
      options: List<String>.from(map['options']),
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

class _QuizPageState extends State<QuizPage> {
  int currentIndex = 0;
  int? selectedAnswer;

  void nextQuestion() {
    setState(() {
      selectedAnswer = null;
      if (currentIndex < widget.questions.length - 1) {
        currentIndex++;
      } else {
        // Quiz finished
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
    return Container();
  }
}
