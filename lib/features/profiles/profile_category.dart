class ProfileCategory {
  final int id;
  final String name;

  const ProfileCategory({required this.id, required this.name});

  factory ProfileCategory.fromRow(Map<String, dynamic> row) {
    return ProfileCategory(id: row['id'] as int, name: row['name'] as String);
  }
}
