import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:idea_radar/app/main_shell.dart';
import 'package:idea_radar/app/session/session_cubit.dart';
import 'package:idea_radar/features/auth/pages/login_page.dart';
import 'package:idea_radar/features/auth/pages/splash_page.dart';
import 'package:idea_radar/features/profiles/pages/create_profile_page.dart';
import 'package:idea_radar/features/profiles/pages/profile_page.dart';
import 'package:idea_radar/pages/add_idea_page.dart';
import 'package:idea_radar/pages/home_page.dart';
import 'package:idea_radar/pages/placeholder_page.dart';
import 'package:idea_radar/pages/search_idea_page.dart';

enum AppRoute {
  splash,
  login,
  createProfile,
  home,
  searchIdea,
  addIdea,
  placeholder,
  profile,
}

GoRouter createAppRouter(SessionCubit sessionCubit) {
  return GoRouter(
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          _branch('/', AppRoute.home, const HomePage()),
          _branch('/search', AppRoute.searchIdea, const SearchIdeaPage()),
          _branch('/add-idea', AppRoute.addIdea, const AddIdeaPage()),
          _branch(
            '/placeholder',
            AppRoute.placeholder,
            const PlaceholderPage(),
          ),
          _branch('/profile', AppRoute.profile, const ProfilePage()),
        ],
      ),
    ],
  );
}

String? _redirectForSession(GoRouterState state, SessionState session) {
  final location = state.matchedLocation;
  final isOnSplash = location == state.namedLocation(AppRoute.splash.name);
  final isOnLogin = location == state.namedLocation(AppRoute.login.name);
  final isOnCreateProfile =
      location == state.namedLocation(AppRoute.createProfile.name);

  final destination = switch (session) {
    SessionChecking() ||
    SessionAuthFailure() ||
    SessionProfileFailure() => AppRoute.splash,
    SessionUnauthenticated() => AppRoute.login,
    SessionProfileSetupRequired() => AppRoute.createProfile,
    SessionAuthenticated() =>
      isOnSplash || isOnLogin || isOnCreateProfile ? AppRoute.home : null,
  };

  if (destination == null) return null;

  final destinationLocation = state.namedLocation(destination.name);
  return location == destinationLocation ? null : destinationLocation;
}

StatefulShellBranch _branch(String path, AppRoute route, Widget page) {
  return StatefulShellBranch(
    routes: [
      GoRoute(path: path, name: route.name, builder: (context, state) => page),
    ],
  );
}
