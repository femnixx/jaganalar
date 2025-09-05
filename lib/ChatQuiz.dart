import 'package:flutter/material.dart';
import 'package:jaganalar/QuizQuestion.dart';
import 'package:jaganalar/UserModel.dart';
import 'Supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'UserModel.dart';

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

  Future<void> _loadMessages() async {
    try {
      final response = await SupabaseService.client
          .from('quiz_discussions')
          .select('message, uuid, created_at')
          .eq('quiz_id', widget.quizId)
          .order('created_at', ascending: true);

      if (response is List) {
        messages = response.cast<Map<String, dynamic>>();
      }

      final userId = SupabaseService.client.auth.currentUser!.id;
      hasSentMessage = messages.any((m) => m['uuid'] == userId);

      setState(() {});
    } catch (e) {
      print("Error loading messages: $e");
    }
  }

  Future<String> _getUsername(String uuid) async {
    try {
      final response = await SupabaseService.client
          .from('users')
          .select('username')
          .eq('uuid', uuid)
          .single();

      if (response != null && response['username'] != null) {
        return response['username'] as String;
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
    return 'Unknown';
  }

  Future<UserModel?> _getUser(String uuid) async {
    try {
      return await fetchUser();
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  Future<void> _sendMessage() async {
    final userId = SupabaseService.client.auth.currentUser!.id;
    final text = _controller.text.trim();
    if (text.isEmpty || hasSentMessage) return;

    try {
      await SupabaseService.client.from('quiz_discussions').insert({
        'quiz_id': widget.quizId,
        'uuid': userId,
        'message': text,
      });
      _controller.clear();
      await _loadMessages();
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  DateTime _parseTimestamp(dynamic rawTimestamp) {
    if (rawTimestamp == null) return DateTime.now();
    if (rawTimestamp is String) return DateTime.parse(rawTimestamp).toLocal();
    if (rawTimestamp is DateTime) return rawTimestamp.toLocal();
    return DateTime.now();
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
                      final timestamp = _parseTimestamp(m['created_at']);
                      final formattedTime =
                          "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";

                      return FutureBuilder<String>(
                        future: _getUsername(m['uuid']),
                        builder: (context, usernameSnapshot) {
                          final username = usernameSnapshot.data ?? 'Unknown';

                          return FutureBuilder<UserModel?>(
                            future: _getUser(m['uuid']),
                            builder: (context, userSnapshot) {
                              final user = userSnapshot.data;

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundImage: user?.avatarUrl != null
                                          ? NetworkImage(user!.avatarUrl!)
                                          : null,
                                      child: user?.avatarUrl == null
                                          ? const Icon(
                                              Icons.person,
                                              size: 26,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ListTile(
                                        title: Row(
                                          children: [
                                            Text(username),
                                            const SizedBox(width: 8),
                                            const Text('|'),
                                            const SizedBox(width: 8),
                                            Text(formattedTime),
                                          ],
                                        ),
                                        subtitle: Text(m['message'] ?? ''),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
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
