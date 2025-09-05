import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaganalar/ChatQuiz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Supabase.dart';
import 'main_screen.dart';

class FeedbackPageWeekly extends StatefulWidget {
  final int quizId;

  const FeedbackPageWeekly({super.key, required this.quizId});

  @override
  State<FeedbackPageWeekly> createState() => _FeedbackPageWeeklyState();
}

class _FeedbackPageWeeklyState extends State<FeedbackPageWeekly> {
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

      // Fetch quiz questions data (to get total questions and title)
      final quizResponse = await SupabaseService.client
          .from('questions')
          .select()
          .eq('id', widget.quizId)
          .maybeSingle();

      // Fetch the quiz result for the current user (to get correct answers and XP)
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
        backgroundColor: Colors.grey[100],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_quizData == null || _resultData == null) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: const Center(child: Text('Could not load quiz data.')),
      );
    }

    // Extract data from fetched results
    final quizTitle = _quizData!['title'] ?? 'Quiz Feedback';
    final correctAnswers = _resultData!['score'] as int? ?? 0;
    final totalQuestions =
        (_quizData!['questions'] as List<dynamic>?)?.length ?? 0;
    final incorrectAnswers = totalQuestions - correctAnswers;
    final xp = _quizData!['points'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    Text(
                      'Ringkasan',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Score Card
              Container(
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
                    const SizedBox(height: 16),
                    const Text(
                      'Respon AI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sangat bagus! Nalar Anda sudah sangat tajam dalam membedakan antara diskusi substansial dan narasi adu domba. Anda selangkah lebih maju dari kebanyakan orang dalam memahami strategi di balik informasi.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    // XP Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xff9396A0).withOpacity(
                              0.3,
                            ), // Changed to be slightly transparent
                            blurRadius: 10, // How much the shadow blurs
                            spreadRadius: 2, // How much the shadow spreads
                            offset: Offset(0, 5), // X, Y offset of the shadow
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[700], size: 40),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kamu mendapatkan ${xp.toString()} XP',
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Return to main button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyMainScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xff1C6EA4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kembali Ke Misi Harian',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
