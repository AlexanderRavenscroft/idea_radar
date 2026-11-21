import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:idea_radar/app/main_shell.dart';
import 'package:idea_radar/pages/add_idea_page.dart';
import 'package:idea_radar/pages/home_page.dart';
import 'package:idea_radar/pages/placeholder_page.dart';
import 'package:idea_radar/pages/profile_page.dart';
import 'package:idea_radar/pages/search_idea_page.dart';

enum AppRoute { home, searchIdea, addIdea, placeholder, profile }

GoRouter createAppRouter() {
  return GoRouter(
    routes: [
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

StatefulShellBranch _branch(String path, AppRoute route, Widget page) {
  return StatefulShellBranch(
    routes: [
      GoRoute(path: path, name: route.name, builder: (context, state) => page),
    ],
  );
}
