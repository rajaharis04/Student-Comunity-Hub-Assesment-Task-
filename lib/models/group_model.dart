// ============================================================
// group_model.dart — Data model for a student interest group
// ============================================================

class Group {
  final String id;
  final String name;
  final String description;
  final String creatorId; // user ID of the person who created it
  final DateTime createdAt;

  // These two are NOT from the database — they are calculated:
  int memberCount; // how many members are in this group
  bool isMember; // whether the current logged-in user has joined

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.createdAt,
    this.memberCount = 0,
    this.isMember = false,
  });

  // Converts a Supabase database row into a Group object
  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] ?? '',
      creatorId: map['creator_id'] ?? '',
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
    );
  }
}
