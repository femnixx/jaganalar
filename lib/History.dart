import 'package:flutter/material.dart';
import 'package:jaganalar/ChatQuiz.dart';
import 'Supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  // Async function to fetch completed quizzes
  Future<List<Map<String, dynamic>>> fetchCompletedQuizzes() async {
    final currentUserId = SupabaseService.client.auth.currentUser!.id;

    final response = await SupabaseService.client
        .from('quiz_completed')
        .select('quiz_id') // include quiz_id
        .eq('uuid', currentUserId);

    if (response is List) {
      final futures = response.map<Future<Map<String, dynamic>>>((row) async {
        final title = await getQuizTitleById(row['quiz_id'] as int);
        return {
          'quiz_id': row['quiz_id'], // include ID here
          'title': title,
          'completedAt': row['timestamp'],
        };
      }).toList();

      return await Future.wait(futures);
    }

    return [];
  }

  Future<String> getQuizTitleById(int quizId) async {
    final response = await SupabaseService.client
        .from('questions')
        .select('title')
        .eq('id', quizId)
        .single(); // fetch a single row

    if (response != null && response['title'] != null) {
      return response['title'] as String;
    }
    return 'Quiz $quizId';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchCompletedQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final completedQuizzes = snapshot.data ?? [];

          if (completedQuizzes.isEmpty) {
            return const Center(
              child: Text('You have not completed any quizzes yet.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: completedQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = completedQuizzes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(quiz['title']),
                  subtitle: Text('Completed at: ${quiz['completedAt']}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Optional: navigate to review page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            QuizDiscussionPage(quizId: quiz['quiz_id']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
