import 'package:alexandria_movil/core/app_colors.dart';
import 'package:alexandria_movil/screens/course_home_screen.dart';
import 'package:alexandria_movil/screens/craft_course_screen.dart';
import 'package:alexandria_movil/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,});

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    const CourseHomeScreen(),
    const CraftCourseScreen(),
    const ProfileScreen(),
  ];

  void _onDestinationSelected(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.menu_book),
            icon: Icon(Icons.menu_book_outlined),
            label: 'My courses',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.auto_awesome),
            icon: Icon(Icons.auto_awesome_outlined),
            label: 'Craft course',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'My profile',
          ),
        ],
      ),
    );
  }
}
