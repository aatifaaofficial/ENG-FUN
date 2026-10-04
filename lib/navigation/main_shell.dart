// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:englishfun/navigation/app_router.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  final String currentLocation;
  const MainShell({
    required this.child,
    required this.currentLocation,
    Key? key,
  }) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _locationToIndex(String location) {
    if (location.startsWith(AppRouter.practice)) return 1;
    if (location.startsWith(AppRouter.vocabulary)) return 2;
    if (location.startsWith(AppRouter.profile)) return 3;
    return 0; // home
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _locationToIndex(widget.currentLocation);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRouter.home);
              break;
            case 1:
              context.go(AppRouter.practice);
              break;
            case 2:
              context.go(AppRouter.vocabulary);
              break;
            case 3:
              context.go(AppRouter.profile);
              break;
          }
        },
        // Use Theme colors – no hard‑coded colours
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Practice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Vocabulary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
