import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:swipe_cards/swipe_cards.dart';

class DailyMissionsQuiz extends StatefulWidget {
  final List<String> questions;
  final List<int> correctIndex;
  final List<List<String>> answers;

  const DailyMissionsQuiz({
    super.key,
    required this.questions,
    required this.answers,
    required this.correctIndex,
  });

  @override
  State<DailyMissionsQuiz> createState() => _DailyMissionsQuizState();
}

class _DailyMissionsQuizState extends State<DailyMissionsQuiz> {
  late MatchEngine _matchEngine;
  final List<SwipeItem> _swipeItems = [];
  int currentIndex = 0;

  // Map index to explanation
  final Map<int, String> explanations = {
    0: 'PROVOKASI (Ini adalah generalisasi berlebihan yang bertujuan memanaskan konflik).',
    1: 'FAKTA (Ini adalah informasi yang bisa diverifikasi).',
  };

  @override
  void initState() {
    super.initState();

    // Prepare swipe items
    for (var question in widget.questions) {
      _swipeItems.add(
        SwipeItem(
          content: question,
          likeAction: () => handleSwipe(true),
          nopeAction: () => handleSwipe(false),
        ),
      );
    }

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  void handleSwipe(bool userSwipedRight) {
    int correctAnswer = widget.correctIndex[currentIndex];
    bool userIsCorrect =
        (userSwipedRight && correctAnswer == 1) ||
        (!userSwipedRight && correctAnswer == 0);

    showDialog(
      context: context,
      barrierDismissible: false, // dims background until closed
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              children: [
                SvgPicture.asset(
                  userIsCorrect ? 'assets/correct.svg' : 'assets/wrong.svg',
                  height: 100,
                ),
                const SizedBox(height: 20),
                Text(
                  userIsCorrect ? 'Jawaban Anda Benar' : 'Jawaban Anda Salah',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: userIsCorrect
                        ? const Color(0xff72C457)
                        : const Color(0xffDB5550),
                  ),
                ),
                const SizedBox(height: 15),
                Text(explanations[correctAnswer]!, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    setState(() => currentIndex++); // move to next question
                  },
                  child: const Text('Lanjut'),
                ),
              ],
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
                "No questions available.",
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
                    onStackFinished: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Quiz Completed!")),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),

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
