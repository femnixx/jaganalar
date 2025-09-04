import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaganalar/QuizQuestion.dart'; // <-- QuizPage is here
import 'package:supabase_flutter/supabase_flutter.dart';
import 'QuizQuestion.dart'; // where QuizSet is defined

class WeeklyMissionsContent extends StatefulWidget {
  final String userId;

  const WeeklyMissionsContent({super.key, required this.userId});

  @override
  State<WeeklyMissionsContent> createState() => _WeeklyMissionsContentState();
}

class _WeeklyMissionsContentState extends State<WeeklyMissionsContent> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool loading = true;
  List<QuizSet> quizzes = [];

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    try {
      final completed = await supabase
          .from('quiz_completed')
          .select('quiz_id')
          .eq('uuid', widget.userId)
          .eq('completed', true);

      final completedIds = completed.map((q) => q['quiz_id']).toList();

      final allQuizzes = completedIds.isEmpty
          ? await supabase.from('questions').select()
          : await supabase
                .from('questions')
                .select()
                .not('id', 'in', completedIds);

      setState(() {
        quizzes = (allQuizzes as List)
            .map((e) => QuizSet.fromMap(e as Map<String, dynamic>))
            .toList();
        loading = false;
      });
    } catch (e) {
      print('Error fetching quizzes: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return quizzes.isEmpty
        ? const Center(child: Text("No quizzes available"))
        : ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Container(
                height: 180,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SvgPicture.asset(
                        'assets/questionsframefull.svg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quiz.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      '${quiz.questions.length} pertanyaan',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '•',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${quiz.points} XP',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        QuizPage(quizSet: quiz), // pass QuizSet
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xff498BB6,
                                ).withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Start Quiz",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
