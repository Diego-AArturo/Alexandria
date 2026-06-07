import 'package:alexandria_movil/components/home_shell.dart';
import 'package:alexandria_movil/data/session.dart';
import 'package:alexandria_movil/data/users_service.dart';
import 'package:alexandria_movil/screens/auth_screen.dart';
import 'package:alexandria_movil/data/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:alexandria_movil/l10n/app_localizations.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  static MainAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainAppState>();
  }

  @override
  State<MainApp> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocaleFromCurrentUser();
  }

  Future<void> _loadLocaleFromCurrentUser() async {
    final email = Session.userEmail;
    final token = Session.accessToken;
    if (email == null || token == null) return;

    try {
      final user = await UsersService().getByEmail(email, token: token);
      setPreferredLocaleCode(user.language);
    } catch (_) {
      // Fall back to device locale if user info cannot be resolved on init.
    }
  }

  void setPreferredLocaleCode(String? languageCode) {
    final normalized = _normalizeLanguageCode(languageCode);
    if (!mounted) return;
    setState(() {
      _locale = normalized == null ? null : Locale(normalized);
    });
  }

  String? _normalizeLanguageCode(String? languageCode) {
    final normalized = languageCode?.trim().toLowerCase();
    if (normalized == 'en') return 'en';
    if (normalized == 'es') return 'es';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      home: const AuthScreen(),
    );
  }
}
