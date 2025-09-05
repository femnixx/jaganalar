import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jaganalar/History.dart';
import 'package:jaganalar/main_screen.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'Supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'UserModel.dart';

class DailyMissionsQuiz extends StatefulWidget {
  final List<String> questions;
  final List<int> correctIndex;
  final List<List<String>> answers;
  final VoidCallback? addXp; // Callback when quiz is finished
  final String? nextRoute; // Route to navigate after quiz
  final int quizId; // Quiz ID for history
  final String quizTitle; // Quiz title for history

  const DailyMissionsQuiz({
    super.key,
    required this.questions,
    required this.answers,
    required this.correctIndex,
    required this.quizId,
    required this.quizTitle,
    this.addXp,
    this.nextRoute,
  });

  @override
  State<DailyMissionsQuiz> createState() => _DailyMissionsQuizState();
}

class _DailyMissionsQuizState extends State<DailyMissionsQuiz> {
  late MatchEngine _matchEngine;
  final List<SwipeItem> _swipeItems = [];
  int currentIndex = 0;

  final Map<int, String> explanations = {
    0: 'PROVOKASI (Ini adalah generalisasi berlebihan yang bertujuan memanaskan konflik).',
    1: 'FAKTA (Ini adalah informasi yang bisa diverifikasi).',
  };

  @override
  void initState() {
    super.initState();
    _prepareSwipeItems();
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  void _prepareSwipeItems() {
    for (var question in widget.questions) {
      _swipeItems.add(
        SwipeItem(
          content: question,
          likeAction: () => _handleSwipe(true),
          nopeAction: () => _handleSwipe(false),
        ),
      );
    }
  }

  Future<UserModel?> _fetchUser() async {
    final userId = SupabaseService.client.auth.currentUser!.id;
    final response = await SupabaseService.client
        .from('users')
        .select('*')
        .eq('uuid', userId)
        .single();
    return response != null ? UserModel.fromMap(response) : null;
  }

  int _xpForNextLevel(int level) => 100 + (level - 1) * 20;

  Future<void> _updateMissionCountAndLevelUp() async {
    final user = await _fetchUser();
    if (user == null) return;

    int newMissions = (user.missions ?? 0) + 1;
    int xpGain = 20;
    int totalXP = (user.xp ?? 0) + xpGain;
    int newLevel = user.level ?? 1;

    while (totalXP >= _xpForNextLevel(newLevel)) {
      totalXP -= _xpForNextLevel(newLevel);
      newLevel++;
    }

    await SupabaseService.client
        .from('users')
        .update({'missions': newMissions, 'xp': totalXP, 'level': newLevel})
        .eq('uuid', SupabaseService.client.auth.currentUser!.id);
  }

  Future<void> _addHistory() async {
    final userId = SupabaseService.client.auth.currentUser!.id;
    try {
      await SupabaseService.client.from('quiz_completed').upsert({
        'uuid': userId,
        'quiz_id': widget.quizId,
        'completed': true,
        'title': widget.quizTitle,
      });
    } catch (e) {
      print("Error adding quiz to history: $e");
    }
  }

  void _handleSwipe(bool userSwipedRight) async {
    if (currentIndex >= widget.questions.length) return;

    int correctAnswer = widget.correctIndex[currentIndex];
    bool userIsCorrect =
        (userSwipedRight && correctAnswer == 1) ||
        (!userSwipedRight && correctAnswer == 0);

    // Wait for user to see the dialog before moving to next card
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              userIsCorrect ? 'assets/correct.svg' : 'assets/wrong.svg',
              height: 250,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userIsCorrect ? 'Jawaban Anda Benar' : 'Jawaban Anda Salah',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: userIsCorrect
                          ? const Color(0xff72C457)
                          : const Color(0xffDB5550),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    explanations[correctAnswer]!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      setState(() => currentIndex++);
                    },
                    child: const Text('Lanjut'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.questions.length;
    final progress = total > 0 ? (currentIndex + 1) / total : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kuis Analisis Fakta"),
        backgroundColor: Colors.blueAccent,
      ),
      body: total == 0
          ? const Center(
              child: Text(
                "No questions available",
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: [
                // Progress bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          color: Colors.green,
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${currentIndex + 1}/$total",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Swipe cards
                Expanded(
                  child: SwipeCards(
                    matchEngine: _matchEngine,
                    itemBuilder: (context, index) {
                      final question = widget.questions[index];
                      return Card(
                        elevation: 6,
                        margin: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              question,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    onStackFinished: () async {
                      // This triggers when all cards are swiped
                      await _addHistory();
                      await _updateMissionCountAndLevelUp();
                      if (widget.addXp != null) widget.addXp!();

                      if (!mounted) return;
                      if (widget.nextRoute != null) {
                        Navigator.pushReplacementNamed(
                          context,
                          widget.nextRoute!,
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyMainScreen(),
                          ),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 10),
                // Swipe hints
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "← Provokasi",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      Text(
                        "Fakta →",
                        style: TextStyle(color: Colors.green, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
