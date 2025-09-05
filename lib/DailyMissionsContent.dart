import 'dart:convert'; // <- Needed for jsonDecode
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'DailyMissionsQuiz.dart'; // <- your quiz page

class DailyMissionsContent extends StatefulWidget {
  const DailyMissionsContent({super.key});

  @override
  State<DailyMissionsContent> createState() => _DailyMissionsContentState();
}

class _DailyMissionsContentState extends State<DailyMissionsContent> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool loading = true;
  List<Map<String, dynamic>> dailyMissions = [];

  @override
  void initState() {
    super.initState();
    fetchDailyMissions();
  }

  Future<void> fetchDailyMissions() async {
    try {
      final response = await supabase
          .from('questions')
          .select()
          .eq('is_daily', true);

      setState(() {
        dailyMissions = (response as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        loading = false;
      });
    } catch (e) {
      print('Error fetching daily missions: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (dailyMissions.isEmpty)
      return const Center(child: Text("No daily missions available"));

    return ListView.builder(
      itemCount: dailyMissions.length,
      itemBuilder: (context, index) {
        final mission = dailyMissions[index];

        // Decode questions to pass to DailyMissionsQuiz
        List<String> questions = [];
        final rawQuestions = mission['questions'];
        if (rawQuestions is String) {
          questions = List<String>.from(jsonDecode(rawQuestions));
        } else if (rawQuestions is List) {
          questions = List<String>.from(rawQuestions);
        }

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
                            mission['title'] ?? "No title",
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
                                '${questions.length} pertanyaan',
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
                                '${mission['points'] ?? 0} XP',
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
                              builder: (_) => DailyMissionsQuiz(
                                questions:
                                    questions, // <- pass the questions list
                              ),
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
