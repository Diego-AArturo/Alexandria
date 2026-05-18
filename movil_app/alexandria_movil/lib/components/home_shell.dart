import 'package:alexandria_movil/l10n/app_localizations.dart';
import 'package:alexandria_movil/l10n/app_localizations_extra.dart';
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

  void switchToTab(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onDestinationSelected(int index) => switchToTab(index);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FF),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFE2D6FF),
            surfaceTintColor: Colors.transparent,
            shadowColor: const Color(0xFFECE7F7),
            elevation: 0,
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return IconThemeData(
                color: selected
                    ? const Color(0xFF5B2BE3)
                    : const Color(0xFF6B5E8C),
              );
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.w800 : FontWeight.w700,
                color: selected
                    ? const Color(0xFF5B2BE3)
                    : const Color(0xFF6B5E8C),
              );
            }),
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFECE7F7), width: 2),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: [
              NavigationDestination(
                selectedIcon: const Icon(Icons.menu_book),
                icon: const Icon(Icons.menu_book_outlined),
                label: l10n.navMyCourses,
              ),
              NavigationDestination(
                selectedIcon: const Icon(Icons.auto_awesome),
                icon: const Icon(Icons.auto_awesome_outlined),
                label: l10n.navCraftCourse,
              ),
              NavigationDestination(
                selectedIcon: const Icon(Icons.person),
                icon: const Icon(Icons.person_outline),
                label: l10n.navMyProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
