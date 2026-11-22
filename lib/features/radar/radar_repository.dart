import 'dart:async';

import 'package:idea_radar/features/profiles/profile_repository.dart';
import 'package:idea_radar/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'radar_models.dart';

class RadarRepository {
  final _client = Supabase.instance.client;
  final String userId;
  final ProfileRepository profiles;

  RadarRepository({required this.userId, required this.profiles});

  Future<RadarData> load() async {
    final (categories, ideas, own, favorites) = await (
      logTimed('radar.read.categories', profiles.getCategories),
      logTimed(
        'radar.read.ideas',
        () => _client
            .from('radar_ideas')
            .select()
            .eq('published', true)
            .neq('owner_id', userId)
            .order('created_at')
            .limit(100),
      ),
      logTimed(
        'radar.read.own',
        () => _client
            .from('radar_ideas')
            .select()
            .eq('owner_id', userId)
            .order('created_at')
            .limit(100),
      ),
      logTimed(
        'radar.read.favorites',
        () => _client
            .from('radar_favorites')
            .select('radar_ideas!inner(*)')
            .eq('user_id', userId)
            .order('created_at')
            .limit(100),
      ),
    ).wait;

    return RadarData(
      categories: categories,
      ideas: ideas.map(RadarIdea.fromRow).toList(),
      own: own.map(RadarIdea.fromRow).toList(),
      favorites: favorites.map((row) {
        return RadarIdea.fromRow(row['radar_ideas'] as Map<String, dynamic>);
      }).toList(),
    );
  }

  Future<void> saveIdea(RadarIdea idea) async {
    await _client.from('radar_ideas').upsert(idea.toRow());
  }

  Future<void> setFavorite(RadarIdea idea, bool saved) async {
    final request = _client.from('radar_favorites');
    if (saved) {
      await request.upsert({
        'user_id': userId,
        'idea_id': idea.id,
      }, ignoreDuplicates: true);
    } else {
      await request.delete().eq('user_id', userId).eq('idea_id', idea.id);
    }
  }
}
