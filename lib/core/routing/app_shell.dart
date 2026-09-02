import 'package:fitpulse/core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Persistent phone navigation shared by the five member-facing modules.
class AppShell extends StatelessWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  static const _destinations =
      <({String path, String label, IconData icon, IconData selectedIcon})>[
        (
          path: AppRoutes.dashboard,
          label: 'Today',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
        ),
        (
          path: AppRoutes.workouts,
          label: 'Train',
          icon: Icons.fitness_center_outlined,
          selectedIcon: Icons.fitness_center_rounded,
        ),
        (
          path: AppRoutes.nutrition,
          label: 'Food',
          icon: Icons.restaurant_outlined,
          selectedIcon: Icons.restaurant_rounded,
        ),
        (
          path: AppRoutes.progress,
          label: 'Progress',
          icon: Icons.show_chart_outlined,
          selectedIcon: Icons.show_chart_rounded,
        ),
        (
          path: AppRoutes.coach,
          label: 'Coach',
          icon: Icons.auto_awesome_outlined,
          selectedIcon: Icons.auto_awesome_rounded,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _destinations.indexWhere(
      (destination) => location.startsWith(destination.path),
    );
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) => context.go(_destinations[index].path),
        destinations: [
          for (final destination in _destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
              tooltip: 'Open ${destination.label}',
            ),
        ],
      ),
    );
  }
}
