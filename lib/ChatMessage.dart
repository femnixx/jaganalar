class Chatmessage {
  final int questionId;
  final String userId, message;
  final bool alreadyCommented;

  Chatmessage({
    required this.questionId,
    required this.userId,
    required this.message,
    required this.alreadyCommented,
  });

  // formMap
  factory Chatmessage.fromMap(Map<String, dynamic> map) {
    return Chatmessage(
      questionId: map['question_id'],
      userId: map['uuid'],
      message: map['message'],
      alreadyCommented: map['already_commented'],
    );
  }
}
