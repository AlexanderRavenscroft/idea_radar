class UserProfile {
  final String id;
  final String fullName;
  final String bio;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.bio,
  });

  factory UserProfile.fromRow(Map<String, dynamic> row) {
    return UserProfile(
      id: row['id'] as String,
      fullName: (row['full_name'] as String? ?? '').trim(),
      bio: (row['bio'] as String? ?? '').trim(),
    );
  }
}
