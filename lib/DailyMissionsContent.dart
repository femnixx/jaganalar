import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jaganalar/QuizQuestion.dart';
import 'package:jaganalar/Supabase.dart';
import 'DailyMissionsQuiz.dart';

class DailyMissionsContent extends StatelessWidget {
  DailyMissionsContent({super.key});

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

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // same as weekly missions
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.20,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // match Card's radius
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: SvgPicture.asset(
                                'assets/questionsframe.svg', // or any SVG for daily mission
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${mission['title'] ?? "No title"}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '$numberOfQuestions Pertanyaan • ${mission['points'] ?? 0}XP',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(
                                        0.1,
                                      ),
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      final List<String> questions =
                                          List<String>.from(
                                            mission['questions'] ?? [],
                                          );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DailyMissionsQuiz(
                                            questions:
                                                questions, // Pass questions to the quiz template
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
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
