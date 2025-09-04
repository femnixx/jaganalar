import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
            final int numberOfQuestions =
                (mission['questions'] as List<dynamic>?)?.length ?? 0;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.20,
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(12),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: SvgPicture.asset(
                          'assets/questionsframefull.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${mission['title'] ?? "No title"}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '$numberOfQuestions Pertanyaan • ${mission['points'] ?? 0}XP',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.1),
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                final selectedQuiz = QuizSet.fromMap(mission);
                                print(selectedQuiz);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        QuizPage(quizSet: selectedQuiz),
                                  ),
                                );
                              },
                              child: Text(
                                'Mulai >>',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
