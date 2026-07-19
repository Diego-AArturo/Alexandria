import 'package:alexandria_movil/data/auth_service.dart';
import 'package:alexandria_movil/data/session.dart';
import 'package:alexandria_movil/data/users_service.dart';
import 'package:alexandria_movil/components/home_shell.dart';
import 'package:alexandria_movil/l10n/app_localizations.dart';
import 'package:alexandria_movil/main.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  late final Future<void> _googleInit;

  bool _isLogin = true;
  bool _loading = false;
  bool _googleLoading = false;
  Map<String, String> _fieldErrors = {};

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _googleInit = GoogleSignIn.instance.initialize();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();
    if (!email.contains('@')) errors['email'] = l10n.authValidationEmail;
    if (password.length < 8) errors['password'] = l10n.authValidationPassword;
    if (!_isLogin && name.isEmpty) errors['name'] = l10n.authValidationName;
    return errors;
  }

  Future<void> _submit() async {
    final errors = _validate();
    if (errors.isNotEmpty) {
      setState(() => _fieldErrors = errors);
      return;
    }
    setState(() {
      _fieldErrors = {};
      _loading = true;
    });

    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text;

    try {
      final token = _isLogin
          ? await _authService.login(email: email, password: password)
          : await _authService.register(email: email, name: name, password: password);

      final user = await _usersService.getByEmail(email, token: token.accessToken);

      Session.accessToken = token.accessToken;
      Session.userId = user.id;
      Session.userEmail = user.email;

      if (!mounted) return;
      MainApp.of(context)?.setPreferredLocaleCode(user.language);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (_) => false,
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authSnackbarAuthFailed('$err'))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _googleLoading = true);
    try {
      await _googleInit;

      GoogleSignInAccount? account;
      final Future<GoogleSignInAccount?>? restored =
          GoogleSignIn.instance.attemptLightweightAuthentication();
      if (restored != null) account = await restored;
      account ??= await GoogleSignIn.instance.authenticate();

      final auth = account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception(l10n.authErrorGoogleMissingIdToken);

      final token = await _authService.googleLogin(idToken: idToken);
      final email = account.email;
      final user = await _usersService.getByEmail(email, token: token.accessToken);

      Session.accessToken = token.accessToken;
      Session.userId = user.id;
      Session.userEmail = user.email;

      if (!mounted) return;
      MainApp.of(context)?.setPreferredLocaleCode(user.language);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (_) => false,
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authSnackbarGoogleFailed('$err'))),
      );
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  void _switchMode(bool isLogin) {
    setState(() {
      _isLogin = isLogin;
      _fieldErrors = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: Column(
        children: [
          Expanded(child: _buildHero()),
          _buildFormSheet(),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
          colors: [
            Color(0xFF1E1B4B),
            Color(0xFF312E81),
            Color(0xFF4F46E5),
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -60, left: -60,
            child: _decorativeCircle(200, 0.06),
          ),
          Positioned(
            bottom: 20, right: -40,
            child: _decorativeCircle(140, 0.08),
          ),
          Align(
            alignment: const Alignment(0.85, -0.4),
            child: _decorativeCircle(80, 0.06),
          ),
          SafeArea(
            bottom: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Transform.scale(
                        scale: 1.35,
                        child: Image.asset(
                          'assets/splash/splash.png',
                          width: 62,
                          height: 62,
                          fit: BoxFit.contain,
                          color: Colors.white,
                          colorBlendMode: BlendMode.srcATop,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Alexandria',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.authHeroTagline,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorativeCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildFormSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x2E4F46E5),
            blurRadius: 40,
            offset: Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabSwitcher(),
            const SizedBox(height: 22),
            _buildFields(),
            const SizedBox(height: 20),
            _PressableButton(
              label: _isLogin ? l10n.authSignInButton : l10n.authPrimaryCreateAccount,
              loading: _loading,
              onTap: _loading ? null : _submit,
            ),
            // if (_isLogin) ...[
            //   const SizedBox(height: 11),
            //   _buildDivider(),
            //   const SizedBox(height: 11),
            //   _GoogleButton(
            //     loading: _googleLoading,
            //     onTap: _googleLoading ? null : _signInWithGoogle,
            //   ),
            // ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E7FF), width: 2),
      ),
      child: Row(
        children: [
          _tabButton(l10n.authTitleSignIn, isSelected: _isLogin, onTap: () => _switchMode(true)),
          _tabButton(l10n.authTitleCreateAccount, isSelected: !_isLogin, onTap: () => _switchMode(false)),
        ],
      ),
    );
  }

  Widget _tabButton(String label, {required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0xFF3730A3),
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFields() {
    return Column(
      children: [
        _AuthInputField(
          label: l10n.authLabelEmail.toUpperCase(),
          controller: _emailController,
          placeholder: l10n.authPlaceholderEmail,
          keyboardType: TextInputType.emailAddress,
          error: _fieldErrors['email'],
          autofocus: true,
        ),
        if (!_isLogin) ...[
          const SizedBox(height: 12),
          _AuthInputField(
            label: l10n.authLabelName.toUpperCase(),
            controller: _nameController,
            placeholder: l10n.authPlaceholderName,
            error: _fieldErrors['name'],
          ),
        ],
        const SizedBox(height: 12),
        _AuthInputField(
          label: l10n.authLabelPassword.toUpperCase(),
          controller: _passwordController,
          placeholder: '••••••••',
          obscureText: true,
          error: _fieldErrors['password'],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFE0E7FF), thickness: 1.5)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'or',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFE0E7FF), thickness: 1.5)),
      ],
    );
  }
}

// ─── Input Field ──────────────────────────────────────────────────────────────

class _AuthInputField extends StatefulWidget {
  const _AuthInputField({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.error,
    this.autofocus = false,
  });

  final String label;
  final TextEditingController controller;
  final String placeholder;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? error;
  final bool autofocus;

  @override
  State<_AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<_AuthInputField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.error != null
        ? const Color(0xFFEF4444)
        : _focused
            ? const Color(0xFF4F46E5)
            : const Color(0xFFE0E7FF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF9CA3AF),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 7),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 2.5),
            color: Colors.white,
            boxShadow: _focused
                ? [
                    const BoxShadow(
                      color: Color(0xFFEEF2FF),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : [],
          ),
          child: Focus(
            onFocusChange: (focused) => setState(() => _focused = focused),
            child: TextField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              autofocus: widget.autofocus,
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
              ),
              style: const TextStyle(fontSize: 15, color: Color(0xFF1E1B4B)),
            ),
          ),
        ),
        if (widget.error != null) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.error_rounded, size: 12, color: Color(0xFFEF4444)),
              const SizedBox(width: 4),
              Text(
                widget.error!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Primary Button (3D press effect) ────────────────────────────────────────

class _PressableButton extends StatefulWidget {
  const _PressableButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool loading;

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: disabled ? const Color(0xFFC7D2FE) : const Color(0xFF4F46E5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: (_pressed || disabled)
              ? []
              : [
                  const BoxShadow(
                    color: Color(0xFF3730A3),
                    offset: Offset(0, 5),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                    offset: const Offset(0, 8),
                    blurRadius: 20,
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: widget.loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}

// ─── Google Button ────────────────────────────────────────────────────────────

class _GoogleButton extends StatefulWidget {
  const _GoogleButton({required this.onTap, this.loading = false});

  final VoidCallback? onTap;
  final bool loading;

  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E7FF), width: 2.5),
          boxShadow: _pressed
              ? []
              : const [
                  BoxShadow(
                    color: Color(0xFFE0E7FF),
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              CustomPaint(size: const Size(18, 18), painter: _GoogleLogoPainter()),
            const SizedBox(width: 10),
            const Text(
              'Continue with Google',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Color(0xFF1E1B4B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Google logo (4-color) via CustomPainter ─────────────────────────────────

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final paint = Paint()..style = PaintingStyle.fill;

    // Red — top-left arc
    paint.color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(s * 0.5, s * 0.198)
      ..cubicTo(s * 0.622, s * 0.198, s * 0.731, s * 0.244, s * 0.813, s * 0.319)
      ..lineTo(s * 0.955, s * 0.177)
      ..cubicTo(s * 0.856, s * 0.083, s * 0.713, s * 0.023, s * 0.5, s * 0.023)
      ..cubicTo(s * 0.305, s * 0.023, s * 0.135, s * 0.115, s * 0.027, s * 0.264)
      ..lineTo(s * 0.193, s * 0.396)
      ..cubicTo(s * 0.247, s * 0.276, s * 0.364, s * 0.198, s * 0.5, s * 0.198)
      ..close();
    canvas.drawPath(redPath, paint);

    // Blue — right arc
    paint.color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(s * 0.979, s * 0.511)
      ..cubicTo(s * 0.979, s * 0.478, s * 0.976, s * 0.446, s * 0.971, s * 0.416)
      ..lineTo(s * 0.5, s * 0.416)
      ..lineTo(s * 0.5, s * 0.604)
      ..lineTo(s * 0.77, s * 0.604)
      ..cubicTo(s * 0.758, s * 0.666, s * 0.723, s * 0.718, s * 0.672, s * 0.751)
      ..lineTo(s * 0.833, s * 0.877)
      ..cubicTo(s * 0.933, s * 0.784, s * 0.979, s * 0.659, s * 0.979, s * 0.511)
      ..close();
    canvas.drawPath(bluePath, paint);

    // Yellow — bottom-left arc
    paint.color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(s * 0.193, s * 0.604)
      ..cubicTo(s * 0.173, s * 0.544, s * 0.173, s * 0.478, s * 0.193, s * 0.417)
      ..lineTo(s * 0.027, s * 0.285)
      ..cubicTo(s * -0.01, s * 0.366, s * -0.01, s * 0.457, s * 0.027, s * 0.537)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Green — bottom arc
    paint.color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(s * 0.5, s * 1.0)
      ..cubicTo(s * 0.635, s * 1.0, s * 0.749, s * 0.956, s * 0.833, s * 0.877)
      ..lineTo(s * 0.672, s * 0.751)
      ..cubicTo(s * 0.624, s * 0.782, s * 0.563, s * 0.802, s * 0.5, s * 0.802)
      ..cubicTo(s * 0.364, s * 0.802, s * 0.247, s * 0.724, s * 0.193, s * 0.604)
      ..lineTo(s * 0.027, s * 0.737)
      ..cubicTo(s * 0.135, s * 0.886, s * 0.305, s * 1.0, s * 0.5, s * 1.0)
      ..close();
    canvas.drawPath(greenPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
