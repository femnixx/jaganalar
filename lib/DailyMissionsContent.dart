import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jaganalar/QuizQuestion.dart';
import 'package:jaganalar/Supabase.dart';

class DailyMissionsContent extends StatelessWidget {
  DailyMissionsContent({super.key});

  // Fetch the daily mission.
  final Future<Map<String, dynamic>?> dailyMissionFuture = SupabaseService
      .client
      .from('questions')
      .select('*')
      .eq('is_daily', true)
      .maybeSingle();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: dailyMissionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData) {
          return const Center(child: Text("No daily mission available."));
        }

        final mission = snapshot.data!;
        final int numberOfQuestions =
            (mission['questions'] as List<dynamic>?)?.length ?? 0;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Stack(
            children: [
              Positioned.fill(
                child: SvgPicture.asset(
                  'assets/questionsframe.svg', // Your SVG asset
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${mission['title'] ?? "No title"}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$numberOfQuestions Pertanyaan • ${mission['points'] ?? 0}XP',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Navigate to the quiz page with the single fetched mission
                        final selectedQuiz = QuizSet.fromMap(mission);
                        print(selectedQuiz);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizPage(quizSet: selectedQuiz),
                          ),
                        );
                      },
                      child: const Text('Mulai >>'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
