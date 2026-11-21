import 'package:idea_radar/features/profiles/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final _client = Supabase.instance.client;

  Future<UserProfile?> getProfile(String userId) async {
    final row = await _client
        .from('profiles')
        .select('id, full_name')
        .eq('id', userId)
        .maybeSingle();

    if (row == null) return null;

    return UserProfile(
      id: row['id'] as String,
      fullName: (row['full_name'] as String? ?? '').trim(),
    );
  }
}
