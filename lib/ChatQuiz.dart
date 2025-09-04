import 'package:flutter/material.dart';
import 'Supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuizDiscussionPage extends StatefulWidget {
  final int quizId;
  const QuizDiscussionPage({super.key, required this.quizId});

  @override
  State<QuizDiscussionPage> createState() => _QuizDiscussionPageState();
}

class _QuizDiscussionPageState extends State<QuizDiscussionPage> {
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  bool hasSentMessage = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  // Fetch messages for this quiz
  Future<void> _loadMessages() async {
    try {
      final response = await SupabaseService.client
          .from('quiz_discussions')
          .select('*')
          .eq('quiz_id', widget.quizId)
          .order('created_at', ascending: true);

      if (response is List) {
        messages = response.cast<Map<String, dynamic>>();
      }

      final userId = SupabaseService.client.auth.currentUser!.id;
      hasSentMessage = messages.any((m) => m['user_id'] == userId);

      setState(() {});
    } catch (e) {
      print("Error loading messages: $e");
    }
  }

  // Send a message (one per user per quiz)
  Future<void> _sendMessage() async {
    final userId = SupabaseService.client.auth.currentUser!.id;
    final text = _controller.text.trim();
    if (text.isEmpty || hasSentMessage) return;

    try {
      await SupabaseService.client.from('quiz_discussions').insert({
        'quiz_id': widget.quizId,
        'user_id': userId,
        'message': text,
      });
      _controller.clear();
      await _loadMessages();
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Diskusi Quiz")),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text("Belum ada pesan."))
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final m = messages[i];
                      return ListTile(
                        title: Text(m['message']),
                        subtitle: Text(
                          m['user_id'],
                        ), // replace with username if available
                      );
                    },
                  ),
          ),
          if (!hasSentMessage)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Kirim pesan Anda",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
