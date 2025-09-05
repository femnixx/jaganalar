import 'package:flutter/material.dart';
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

  void handleSwipe(bool userSwipedRight) {
    final correct =
        widget.correctIndex[currentIndex] == (userSwipedRight ? 1 : 0);

    // show dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: correct ? Colors.green : Colors.red,
        title: Text(correct ? "Jawaban Benar!" : "Jawaban Salah"),
        content: Text(
          correct
              ? "Bagus! Jawaban Anda benar"
              : "Oops! Jawaban yang bennar adalah: ${widget.answers[currentIndex][widget.correctIndex[currentIndex]]}",
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.questions.isNotEmpty) {
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
  }

  void handleSwipe(bool isFact) {
    setState(() => currentIndex++);
    if (currentIndex >= widget.questions.length) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Quiz Completed!")));
      Navigator.pop(context);
    }
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
                        "$currentIndex/$total",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
