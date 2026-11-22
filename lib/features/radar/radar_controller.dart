import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idea_radar/utils/app_logger.dart';

import 'radar_models.dart';
import 'radar_repository.dart';

class RadarState {
  final RadarData? data;
  final bool working;
  final bool loadFailed;

  const RadarState({this.data, this.working = false, this.loadFailed = false});
}

class RadarController extends Cubit<RadarState> {
  final RadarRepository _repository;

  RadarController(this._repository) : super(const RadarState());

  Future<void> refresh() async {
    if (isClosed || state.working) return;
    emit(RadarState(data: state.data, working: true));
    await _load();
  }

  Future<void> _load() async {
    try {
      final data = await logTimed('radar.load', _repository.load);
      log.d(
        '[RADAR] radar.load counts ideas=${data.ideas.length} '
        'owned=${data.own.length} favorites=${data.favorites.length}',
      );
      if (!isClosed) emit(RadarState(data: data));
    } catch (_) {
      if (!isClosed) emit(RadarState(data: state.data, loadFailed: true));
    }
  }

  Future<bool> _write(
    String operation,
    Future<void> Function() write, {
    RadarData Function(RadarData)? updateData,
  }) async {
    if (isClosed || state.working) return false;
    final previous = state;
    emit(RadarState(data: previous.data, working: true));
    try {
      await logTimed(operation, write);
    } catch (_) {
      if (!isClosed) emit(previous);
      return false;
    }
    if (!isClosed) {
      final data = previous.data;
      if (data != null && updateData != null) {
        emit(
          RadarState(data: updateData(data), loadFailed: previous.loadFailed),
        );
      } else {
        await _load();
      }
    }
    return true;
  }

  Future<bool> saveIdea(RadarIdea idea) =>
      _write('radar.write.idea', () => _repository.saveIdea(idea));

  Future<bool> setFavorite(RadarIdea idea, bool saved) {
    return _write(
      'radar.write.favorite',
      () => _repository.setFavorite(idea, saved),
      updateData: (data) => data.withFavorite(idea, saved),
    );
  }
}
