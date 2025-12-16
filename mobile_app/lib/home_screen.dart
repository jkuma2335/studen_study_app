import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_app/core/providers/bottom_nav_provider.dart';
import 'package:mobile_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:mobile_app/features/subjects/presentation/screens/subjects_screen.dart';
import 'package:mobile_app/features/tasks/screens/tasks_screen.dart';
import 'package:mobile_app/features/notes/screens/notes_list_screen.dart';
import 'package:mobile_app/features/profile/screens/profile_screen.dart';
import 'package:mobile_app/features/planner/screens/planner_screen.dart';

/// Main Layout Wrapper with Bottom Navigation
/// Apple Health / Notion mobile app style navigation
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<Widget> _screens = [
    const DashboardScreen(),
    const SubjectsScreen(),
    const TasksScreen(),
    const PlannerScreen(),
    const NotesListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: _screens[currentIndex]
          .animate()
          .fadeIn(duration: 300.ms)
          .slideX(begin: 0.02, end: 0, curve: Curves.easeOut),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        destinations: [
          NavigationDestination(
            icon: Icon(LucideIcons.layoutDashboard),
            selectedIcon: _AnimatedNavIcon(
              icon: Icon(LucideIcons.layoutDashboard),
              isSelected: currentIndex == 0,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.library),
            selectedIcon: _AnimatedNavIcon(
              icon: Icon(LucideIcons.library),
              isSelected: currentIndex == 1,
            ),
            label: 'Subjects',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.checkSquare),
            selectedIcon: _AnimatedNavIcon(
              icon: Icon(LucideIcons.checkSquare),
              isSelected: currentIndex == 2,
            ),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.calendar),
            selectedIcon: _AnimatedNavIcon(
              icon: Icon(LucideIcons.calendar),
              isSelected: currentIndex == 3,
            ),
            label: 'Planner',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.stickyNote),
            selectedIcon: _AnimatedNavIcon(
              icon: Icon(LucideIcons.stickyNote),
              isSelected: currentIndex == 4,
            ),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.user),
            selectedIcon: _AnimatedNavIcon(
              icon: Icon(LucideIcons.user),
              isSelected: currentIndex == 5,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Animated navigation icon with scale effect
class _AnimatedNavIcon extends StatefulWidget {
  final Widget icon;
  final bool isSelected;

  const _AnimatedNavIcon({
    required this.icon,
    required this.isSelected,
  });

  @override
  State<_AnimatedNavIcon> createState() => _AnimatedNavIconState();
}

class _AnimatedNavIconState extends State<_AnimatedNavIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(_AnimatedNavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isSelected ? _scaleAnimation.value : 1.0,
          child: widget.icon,
        );
      },
    );
  }
}
