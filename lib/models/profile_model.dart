// ============================================================
// profile_model.dart — Data model for a user's profile
// ============================================================

class Profile {
  final String id; // same as auth user ID
  final String username;
  final String bio;

  Profile({required this.id, required this.username, required this.bio});

  // Converts a Supabase database row into a Profile object
  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      username: map['username'] ?? '',
      bio: map['bio'] ?? '',
    );
  }
}
