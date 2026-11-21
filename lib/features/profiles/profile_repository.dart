import 'package:idea_radar/features/profiles/profile_category.dart';
import 'package:idea_radar/features/profiles/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final _client = Supabase.instance.client;

  Future<UserProfile?> getProfile() async {
    final row = await _client.rpc<Map<String, dynamic>?>('get_my_profile');

    return row == null ? null : UserProfile.fromRow(row);
  }

  Future<List<ProfileCategory>> getCategories() async {
    final rows = await _client
        .from('categories')
        .select('id, name')
        .order('name', ascending: true);
    return rows.map(ProfileCategory.fromRow).toList();
  }

  Future<UserProfile> saveProfile({
    required String fullName,
    required String bio,
    required List<int> categoryIds,
  }) async {
    final row = await _client.rpc<Map<String, dynamic>>(
      'complete_profile_setup',
      params: {
        'profile_full_name': fullName,
        'profile_bio': bio,
        'profile_category_ids': categoryIds,
      },
    );
    return UserProfile.fromRow(row);
  }
}
