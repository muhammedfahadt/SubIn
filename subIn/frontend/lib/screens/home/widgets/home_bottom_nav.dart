import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_in/config/app_theme.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          context.go('/events');
        } else if (index == 2) {
          context.go('/venues');
        } else {
          context.go('/home');
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Events'),
        BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Venues'),
      ],
      selectedItemColor: AppTheme.lime,
      unselectedItemColor: AppTheme.secondaryText,
    );
  }
}