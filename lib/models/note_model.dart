class Note {
  final String id;
  final String title;
  final String content;
  final bool? isPinned;
  final DateTime? timestamp;

  var userId;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.isPinned,
    this.timestamp, required userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'isPinned': isPinned ?? false,
      'timestamp': timestamp?.millisecondsSinceEpoch,
    };
  }

  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      isPinned: map['isPinned'] ?? false,
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : null, userId: null,
    );
  }
}
