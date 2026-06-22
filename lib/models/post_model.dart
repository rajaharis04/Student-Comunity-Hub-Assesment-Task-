// ============================================================
// post_model.dart — Data model for an anonymous post
// ============================================================
// A "model" is just a class that holds data from the database.
// fromMap() converts a database row (Map) into a Post object.

class Post {
  final String id; // unique ID from Supabase
  final String content; // the post text
  final DateTime createdAt; // when it was posted

  Post({required this.id, required this.content, required this.createdAt});

  // Converts a Supabase database row into a Post object
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as String,
      content: map['content'] as String,
      // .toLocal() converts UTC time to device local time
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
    );
  }
}
