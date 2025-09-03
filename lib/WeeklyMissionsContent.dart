import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jaganalar/QuizQuestion.dart'; // Make sure this file exists and is correct
import 'package:jaganalar/Supabase.dart'; // Assuming this file sets up the Supabase client

class WeeklyMissionsContent extends StatelessWidget {
  WeeklyMissionsContent({super.key});

  // Fetch missions in the build method's FutureBuilder to display a loading indicator
  // or error state.
  final Future<List<Map<String, dynamic>>> weeklyMissionsFuture =
      SupabaseService.client
          .from('questions')
          .select('*')
          .order('created_at', ascending: false);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: weeklyMissionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No weekly missions available."));
        }

        final missions = snapshot.data!;
        return ListView.builder(
          itemCount: missions.length,
          itemBuilder: (context, index) {
            final mission = missions[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(mission['title'] ?? 'No title'),
                subtitle: Text(mission['description'] ?? 'No description'),
                trailing: Text(
                  mission['points']?.toString() ?? '0',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  final quizSets = await SupabaseService.client
                      .from('questions')
                      .select('*')
                      .eq('id', mission['id'].toString());

                  if (quizSets.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "No quiz questions available for this mission.",
                        ),
                      ),
                    );
                    return;
                  }

                  // ✅ Here's the fix: convert the map to a QuizSet object
                  final selectedQuiz = QuizSet.fromMap(quizSets.first);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizPage(quizSet: selectedQuiz),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
