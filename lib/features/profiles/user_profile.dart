class UserProfile {
  final String id;
  final String fullName;
  final String bio;
  final List<int> selectedCategoryIds;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.bio,
    required this.selectedCategoryIds,
  });

  factory UserProfile.fromRow(Map<String, dynamic> row) {
    return UserProfile(
      id: row['id'] as String,
      fullName: (row['full_name'] as String? ?? '').trim(),
      bio: (row['bio'] as String).trim(),
      selectedCategoryIds: List<int>.unmodifiable(
        row['selected_category_ids'] as List<dynamic>? ?? const [],
      ),
    );
  }
}
