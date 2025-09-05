import 'package:flutter/material.dart';
import 'package:jaganalar/ChatQuiz.dart';
import 'Supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  // Fetch completed quizzes for the current user
  Future<List<Map<String, dynamic>>> fetchCompletedQuizzes() async {
    final currentUserId = SupabaseService.client.auth.currentUser?.id;
    if (currentUserId == null) return [];

    final response = await SupabaseService.client
        .from('quiz_completed')
        .select(
          'quiz_id, completed, created_at',
        ) // Assuming timestamp field is 'created_at'
        .eq('uuid', currentUserId);

    if (response is List) {
      final futures = response.map<Future<Map<String, dynamic>>>((row) async {
        final title = await getQuizTitleById(row['quiz_id'] as int);
        return {
          'quiz_id': row['quiz_id'],
          'title': title,
          'completed': row['completed'] ?? false,
          'completedAt': row['created_at'],
        };
      }).toList();

      return await Future.wait(futures);
    }

    return [];
  }

  // Fetch quiz title from the 'questions' table
  Future<String> getQuizTitleById(int quizId) async {
    final response = await SupabaseService.client
        .from('questions')
        .select('title')
        .eq('id', quizId)
        .maybeSingle();

    return response?['title'] ?? 'Quiz $quizId';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchCompletedQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final quizzes = snapshot.data ?? [];

          if (quizzes.isEmpty) {
            return const Center(
              child: Text('You have not completed any quizzes yet.'),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 20),
                Expanded(child: _buildQuizList(quizzes, context)),
              ],
            ),
          );
        },
      ),
    );
  }

  // Header Row with Title and Icon
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Quiz',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari',
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.filter_list, color: Colors.blue),
        ],
      ),
    );
  }

  // Quiz List
  Widget _buildQuizList(
    List<Map<String, dynamic>> quizzes,
    BuildContext context,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(
              quiz['completed'] ? Icons.check_circle : Icons.circle_outlined,
              color: quiz['completed'] ? Colors.green : Colors.grey,
            ),
            title: Text(quiz['title']),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 1, // 100%
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('100%'),
                ],
              ),
            ),
            onTap: () {
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
  }
}
