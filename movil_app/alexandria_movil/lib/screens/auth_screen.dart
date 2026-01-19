import 'package:alexandria_movil/core/app_colors.dart';
import 'package:alexandria_movil/core/text_styles.dart';
import 'package:alexandria_movil/data/auth_service.dart';
import 'package:alexandria_movil/data/session.dart';
import 'package:alexandria_movil/data/users_service.dart';
import 'package:alexandria_movil/components/home_shell.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Pantalla sencilla para inicio/creación de sesión (UI solamente).
/// Integra con tu backend cuando los endpoints de auth estén listos.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _usersService = UsersService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  bool _isLogin = true;
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || (!_isLogin && name.isEmpty) || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final token = _isLogin
          ? await _authService.login(email: email, password: password)
          : await _authService.register(email: email, name: name, password: password);

      final user = await _usersService.getByEmail(email, token: token.accessToken);

      Session.accessToken = token.accessToken;
      Session.userId = user.id;
      Session.userEmail = user.email;

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (_) => false,
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth failed: $err')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: AppColors.deepPurple,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isLogin ? 'Sign in' : 'Create account',
                    style: AppTextStyles.headingLarge(theme),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (!_isLogin)
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.deepPurple,
                    foregroundColor: AppColors.white,
                    textStyle: AppTextStyles.titleMediumBold(theme),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white),
                          ),
                        )
                      : Text(_isLogin ? 'Continue' : 'Create account'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _googleLoading ? null : _signInWithGoogle,
                  icon: _googleLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login),
                  label: Text(
                    _googleLoading ? 'Signing in...' : 'Continue with Google',
                    style: AppTextStyles.bodyMediumBold(theme),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin
                        ? 'No account? Sign up'
                        : 'Already have an account? Sign in',
                    style: AppTextStyles.bodyMediumBold(
                      theme,
                      color: AppColors.deepPurple,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _googleLoading = true);
    try {
      final account = await _googleSignIn.signInSilently() ??
          await _googleSignIn.signIn();
      if (account == null) {
        throw Exception('Google sign-in was cancelled.');
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw Exception('Missing Google idToken');
      }
      final token = await _authService.googleLogin(idToken: idToken);
      final email = account.email;
      final user = await _usersService.getByEmail(email, token: token.accessToken);

      Session.accessToken = token.accessToken;
      Session.userId = user.id;
      Session.userEmail = user.email;

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (_) => false,
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $err')),
      );
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }
}
