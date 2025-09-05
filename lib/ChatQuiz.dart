import 'package:flutter/material.dart';
import 'package:jaganalar/UserModel.dart';
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

  // Cache for all users involved in discussion
  Map<String, UserModel> usersCache = {};

  UserModel? currentUser;
  static const int maxComments = 3; // Max number of comments per user

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userId = SupabaseService.client.auth.currentUser!.id;
      final response = await SupabaseService.client
          .from('users')
          .select('*')
          .eq('uuid', userId)
          .single();
      if (response != null) {
        setState(() {
          currentUser = UserModel.fromMap(response);
        });
      }
    } catch (e) {
      print("Error loading current user: $e");
    }
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

        // preload all users
        for (var m in messages) {
          final uuid = m['uuid'];
          if (!usersCache.containsKey(uuid)) {
            final userResp = await SupabaseService.client
                .from('users')
                .select('*')
                .eq('uuid', uuid)
                .single();
            if (userResp != null) {
              usersCache[uuid] = UserModel.fromMap(userResp);
            }
          }
        }

        final currentUserId = SupabaseService.client.auth.currentUser!.id;

        // Count how many comments current user has made
        final userCommentsCount = messages
            .where((m) => m['uuid'] == currentUserId)
            .length;

        hasSentMessage = userCommentsCount >= maxComments;

        setState(() {});
      }
    } catch (e) {
      print("Error loading messages: $e");
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

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} Hari Lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} Jam Lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} Menit Lalu';
    } else {
      return 'Baru Saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = SupabaseService.client.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Diskusi"),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Input Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pendekteksi Missinformasi Digital",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Tulis Pendapatmu",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue,
                      backgroundImage: currentUser?.avatarUrl != null
                          ? NetworkImage(currentUser!.avatarUrl!)
                          : null,
                      child: currentUser?.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 120,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xff8B8F90)),
                        ),
                        child: TextField(
                          controller: _controller,
                          readOnly: hasSentMessage,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: hasSentMessage
                                ? "Batas komentar tercapai"
                                : "Bagaimana menurutmu......",
                            hintStyle: TextStyle(
                              color: hasSentMessage
                                  ? Colors.grey
                                  : Colors.black45,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Kamu punya $maxComments kesempatan untuk berdiskusi.\nGunakan dengan bijak ya!",
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: hasSentMessage ? null : _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007BFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Posting"),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Divider(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Discussion Messages Section
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text("Belum ada pesan."))
                : ListView.builder(
                    reverse: false,
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final m = messages[i];
                      final timestamp = _formatTime(
                        DateTime.parse(m['created_at']).toLocal(),
                      );
                      final user = usersCache[m['uuid']];
                      final username = user?.username ?? 'Unknown';
                      final avatar = user?.avatarUrl != null
                          ? NetworkImage(user!.avatarUrl!)
                          : null;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blue,
                              backgroundImage: avatar,
                              child: avatar == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 20,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        username,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '| $timestamp',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    m['message'] ?? '',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
