import 'package:alexandria_movil/components/home_shell.dart';
import 'package:alexandria_movil/screens/auth_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthScreen(),
    );
  }
}
