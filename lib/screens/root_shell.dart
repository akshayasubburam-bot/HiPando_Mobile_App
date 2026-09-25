import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'saved_screen.dart';
import 'search_screen.dart';
import 'sign_in_screen.dart';

/// Hosts the five persistent tabs behind the shared bottom nav.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  String? _searchQuery;
  final Set<String> _savedIds = {};
  bool _signedIn = false;

  void _goToSearch(String query) {
    setState(() {
      _searchQuery = query;
      _index = 2;
    });
  }

  void _toggleSave(String id) {
    setState(() {
      if (_savedIds.contains(id)) {
        _savedIds.remove(id);
      } else {
        _savedIds.add(id);
      }
    });
  }

  void _openProfile() {
    if (_signedIn) {
      setState(() => _index = 4);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignInScreen(
          onVerified: () => setState(() {
            _signedIn = true;
            _index = 4;
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onSearch: _goToSearch),
      const ExploreScreen(),
      SearchScreen(
        initialQuery: _searchQuery,
        savedIds: _savedIds,
        onToggleSave: _toggleSave,
        onProfileTap: _openProfile,
      ),
      SavedScreen(savedIds: _savedIds, onToggleSave: _toggleSave),
      ProfileScreen(
        signedIn: _signedIn,
        onSignOut: () => setState(() => _signedIn = false),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: BottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() {
          _index = i;
          if (i != 2) _searchQuery = null;
        }),
      ),
    );
  }
}
