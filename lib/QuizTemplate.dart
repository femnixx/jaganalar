import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';

class QuizTemplate extends StatefulWidget {
  final List<String> questions;

  const QuizTemplate({super.key, required this.questions});

  @override
  State<QuizTemplate> createState() => _QuizTemplateState();
}

class _QuizTemplateState extends State<QuizTemplate> {
  late MatchEngine _matchEngine;
  List<SwipeItem> _swipeItems = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Convert questions into swipe cards
    _swipeItems = widget.questions.map((question) {
      return SwipeItem(
        content: question,
        likeAction: () => handleSwipe(true),
        nopeAction: () => handleSwipe(false),
      );
    }).toList();

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  void handleSwipe(bool isFact) {
    setState(() {
      currentIndex++;
    });

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
    final progress = (currentIndex + 1) / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kuis Analisis Fakta"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: Colors.green,
              backgroundColor: Colors.grey[300],
            ),
          ),
          Text(
            "Pertanyaan ${currentIndex + 1} dari $total",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Swipeable cards
          Expanded(
            child: SwipeCards(
              matchEngine: _matchEngine,
              onStackFinished: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Quiz Completed!")),
                );
                Navigator.pop(context);
              },
              itemBuilder: (context, index) {
                return Card(
                  elevation: 6,
                  margin: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        widget.questions[index],
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
            ),
          ),

          // Swipe instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
