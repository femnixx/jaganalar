import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaganalar/DiscussionPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Supabase.dart';
import 'ChatQuiz.dart';

class FeedbackPage extends StatefulWidget {
  final int quizId;
  const FeedbackPage({super.key, required this.quizId});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  Map<String, dynamic>? _quizData;
  Map<String, dynamic>? _resultData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuizData();
  }

  Future<void> _fetchQuizData() async {
    try {
      final userId = SupabaseService.client.auth.currentUser!.id;

      final quizResponse = await SupabaseService.client
          .from('questions')
          .select()
          .eq('id', widget.quizId)
          .maybeSingle();

      final resultResponse = await SupabaseService.client
          .from('quiz_results')
          .select()
          .eq('quiz_id', widget.quizId)
          .eq('uuid', userId)
          .maybeSingle();

      setState(() {
        _quizData = quizResponse;
        _resultData = resultResponse;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching quiz data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_quizData == null || _resultData == null) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: const Center(child: Text('Could not load quiz data.')),
      );
    }

    final quizTitle = _quizData!['title'] ?? 'Quiz Feedback';
    final correctAnswers = _resultData!['score'] as int? ?? 0;
    final totalQuestions =
        (_quizData!['questions'] as List<dynamic>?)?.length ?? 0;
    final incorrectAnswers = totalQuestions - correctAnswers;
    final xpEarned = _resultData!['xp_earned'] as int? ?? 0;
    final xp = _quizData!['points'] as int? ?? 0;
    final quizId = _quizData!['id'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top section with Container.svg background
            SizedBox(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned.fill(
                    child: SvgPicture.asset(
                      'assets/Container.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 80, bottom: 60),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset('assets/checksilver.svg', height: 120),
                        const SizedBox(height: 16),
                        const Text(
                          'Misi Mingguan selesai!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Kamu berhasil menuntaskan tantangan pekan ini.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Combined Score and XP Card
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quiz Title & Stats Section
                    Text(
                      quizTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '$totalQuestions Pertanyaan',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.circle, size: 5, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          '${xp.toString()}XP',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$correctAnswers Benar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          '$incorrectAnswers Salah',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: totalQuestions > 0
                          ? correctAnswers / totalQuestions
                          : 0,
                      backgroundColor: Colors.red[200],
                      color: Colors.green[400],
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    // Divider to separate sections
                    const Divider(height: 32, color: Colors.black12),

                    // XP Section
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber[700], size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kamu mendapatkan $xp XP',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Teruskan dengan bermain misi harian maupun mingguan',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Discussion button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            QuizDiscussionPage(quizId: quizId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xff1C6EA4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ruang Diskusi',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
