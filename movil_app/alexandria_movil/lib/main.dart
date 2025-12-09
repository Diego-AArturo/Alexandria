import 'package:alexandria_movil/core/app_colors.dart';
import 'package:alexandria_movil/screens/course_home_screen.dart';
import 'package:alexandria_movil/screens/profile_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Alexandria Movil')),
        backgroundColor: AppColors.background,
        body: ProfileScreen(),
        bottomNavigationBar: NavigationBar(destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.notifications_sharp)),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Badge(label: Text('2'), child: Icon(Icons.messenger_sharp)),
            label: 'Messages',
          ),
        ],),
      ),
    );
  }
}
