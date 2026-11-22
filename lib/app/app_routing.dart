import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:idea_radar/app/main_shell.dart';
import 'package:idea_radar/app/session/session_cubit.dart';
import 'package:idea_radar/features/auth/pages/login_page.dart';
import 'package:idea_radar/features/auth/pages/splash_page.dart';
import 'package:idea_radar/features/profiles/pages/choose_categories_page.dart';
import 'package:idea_radar/features/profiles/pages/create_profile_page.dart';
import 'package:idea_radar/features/profiles/pages/edit_categories_page.dart';
import 'package:idea_radar/features/profiles/pages/edit_profile_page.dart';
import 'package:idea_radar/features/profiles/pages/profile_page.dart';
import 'package:idea_radar/features/profiles/profile_repository.dart';
import 'package:idea_radar/features/radar/idea_editor.dart';
import 'package:idea_radar/features/radar/radar_browse.dart';
import 'package:idea_radar/features/radar/radar_collection.dart';
import 'package:idea_radar/features/radar/radar_controller.dart';
import 'package:idea_radar/features/radar/radar_dashboard.dart';
import 'package:idea_radar/features/radar/radar_repository.dart';
import 'package:idea_radar/features/radar/radar_scope.dart';

enum AppRoute {
  splash,
  login,
  createProfile,
  chooseCategories,
  home,
  searchIdea,
  addIdea,
  collection,
  profile,
  editProfile,
  editCategories,
}

GoRouter createAppRouter(SessionCubit sessionCubit) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) =>
        _redirectForSession(state, sessionCubit.state),
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/create-profile',
        name: AppRoute.createProfile.name,
        builder: (context, state) => const CreateProfilePage(),
      ),
      GoRoute(
        path: '/choose-categories',
        name: AppRoute.chooseCategories.name,
        builder: (context, state) => const ChooseCategoriesPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final session = context.watch<SessionCubit>().state;
          if (session is! SessionAuthenticated) return const SizedBox.shrink();
          return BlocProvider(
            key: ValueKey(session.user.id),
            create: (context) {
              final controller = RadarController(
                RadarRepository(
                  userId: session.user.id,
                  profiles: context.read<ProfileRepository>(),
                ),
              );
              unawaited(controller.refresh());
              return controller;
            },
            child: RadarViewer(
              id: session.user.id,
              name: session.profile.fullName,
              interests: session.profile.selectedCategoryIds,
              child: MainShell(
                index: navigationShell.currentIndex,
                onDestination: (index) => navigationShell.goBranch(index),
                body: navigationShell,
              ),
            ),
          );
        },
        branches: [
          _branch(
            '/',
            AppRoute.home,
            (context, state) => RadarDashboard(
              onBrowse: () => context.goNamed(AppRoute.searchIdea.name),
            ),
          ),
          _branch(
            '/search',
            AppRoute.searchIdea,
            (_, _) => const RadarBrowse(),
          ),
          _branch(
            '/add-idea',
            AppRoute.addIdea,
            (context, state) => IdeaEditor(
              onSaved: (id) {
                if (!context.mounted ||
                    GoRouter.of(context).state.uri.path != '/add-idea')
                  return;
                context.goNamed(
                  AppRoute.collection.name,
                  queryParameters: {'saved': id},
                );
              },
            ),
          ),
          _branch('/collection', AppRoute.collection, (_, state) {
            final saved = state.uri.queryParameters['saved'];
            return RadarCollection(
              key: ValueKey(saved),
              showOwn: saved != null,
            );
          }),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: AppRoute.profile.name,
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'edit-profile',
                    name: AppRoute.editProfile.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const EditProfilePage(),
                  ),
                  GoRoute(
                    path: 'edit-categories',
                    name: AppRoute.editCategories.name,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const EditCategoriesPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

String? _redirectForSession(GoRouterState state, SessionState session) {
  final location = state.matchedLocation;
  final isOnSplash = location == state.namedLocation(AppRoute.splash.name);
  final isOnLogin = location == state.namedLocation(AppRoute.login.name);
  final isOnProfileSetup =
      location == state.namedLocation(AppRoute.createProfile.name) ||
      location == state.namedLocation(AppRoute.chooseCategories.name);

  final destination = switch (session) {
    SessionChecking() ||
    SessionAuthFailure() ||
    SessionProfileFailure() => AppRoute.splash,
    SessionUnauthenticated() => AppRoute.login,
    SessionSettingName() => AppRoute.createProfile,
    SessionSettingCategories() => AppRoute.chooseCategories,
    SessionAuthenticated() =>
      isOnSplash || isOnLogin || isOnProfileSetup ? AppRoute.home : null,
  };

  if (destination == null) return null;

  final destinationLocation = state.namedLocation(destination.name);
  return location == destinationLocation ? null : destinationLocation;
}

StatefulShellBranch _branch(
  String path,
  AppRoute route,
  GoRouterWidgetBuilder builder,
) {
  return StatefulShellBranch(
    routes: [GoRoute(path: path, name: route.name, builder: builder)],
  );
}
