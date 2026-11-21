import 'package:idea_radar/features/profiles/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final _client = Supabase.instance.client;

  Future<UserProfile?> getProfile(String userId) async {
    final row = await _client.rpc<Map<String, dynamic>?>(
      'get_own_profile',
      params: {'profile_id': userId},
    );

    return row == null ? null : UserProfile.fromRow(row);
  }

  Future<UserProfile> saveBio(String userId, String bio) async {
    final row = await _client.rpc<Map<String, dynamic>>(
      'save_profile_bio',
      params: {'profile_id': userId, 'profile_bio': bio},
    );
    return UserProfile.fromRow(row);
  }
}
