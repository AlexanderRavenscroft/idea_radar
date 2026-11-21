import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:idea_radar/app/app_routing.dart';
import 'package:idea_radar/app/session/session_cubit.dart';
import 'package:idea_radar/features/auth/auth_repository.dart';
import 'package:idea_radar/features/profiles/profile_repository.dart';
import 'package:idea_radar/theme/app_theme.dart';

class IdeaRadarApp extends StatefulWidget {
  const IdeaRadarApp({super.key});

  @override
  State<IdeaRadarApp> createState() => _IdeaRadarAppState();
}

class _IdeaRadarAppState extends State<IdeaRadarApp> {
  late final AuthRepository _authRepository;
  late final ProfileRepository _profileRepository;
  late final SessionCubit _sessionCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository();
    _profileRepository = ProfileRepository();
    _sessionCubit = SessionCubit(
      authRepository: _authRepository,
      profileRepository: _profileRepository,
    );
    _router = createAppRouter(_sessionCubit);
  }

  @override
  void dispose() {
    _router.dispose();
    unawaited(_sessionCubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<ProfileRepository>.value(value: _profileRepository),
      ],
      child: BlocProvider<SessionCubit>.value(
        value: _sessionCubit,
        child: BlocListener<SessionCubit, SessionState>(
          listener: (context, state) => _router.refresh(),
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Idea Radar',
            theme: AppTheme.dark,
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}
