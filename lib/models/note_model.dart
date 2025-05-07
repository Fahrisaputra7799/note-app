class Note {
  final String id;
  final String title;
  final String content;
  final String? userId;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.userId,
  });

  factory Note.fromMap(Map<String, dynamic> data, String docId) {
    return Note(
      id: docId,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
    };
  }
}
