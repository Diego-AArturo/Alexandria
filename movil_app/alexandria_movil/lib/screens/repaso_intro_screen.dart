import 'package:alexandria_movil/core/text_styles.dart';
import 'package:alexandria_movil/l10n/app_localizations.dart';
import 'package:alexandria_movil/l10n/app_localizations_extra.dart';
import 'package:flutter/material.dart';

class RepasoIntroScreen extends StatefulWidget {
  const RepasoIntroScreen({super.key, required this.questionCount});

  final int questionCount;

  @override
  State<RepasoIntroScreen> createState() => _RepasoIntroScreenState();
}

class _RepasoIntroScreenState extends State<RepasoIntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _slideAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FF),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Opacity(
            opacity: _fadeAnim.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnim.value),
              child: child,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 3),
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6C0DF1), Color(0xFF4F46E5)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C0DF1).withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2D6FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.repasoIntroBadge,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5B2BE3),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.repasoIntroHeading,
                  style: AppTextStyles.headingLarge(
                    theme,
                    color: const Color(0xFF1A1235),
                  ).copyWith(height: 1.2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.repasoIntroBody,
                  style: AppTextStyles.bodyLarge(
                    theme,
                    color: const Color(0xFF6B5E8C),
                  ).copyWith(height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1ECFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.repasoIntroQuestionCount(widget.questionCount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6C0DF1),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 4),
                GestureDetector(
                  onTapDown: (_) => setState(() => _pressed = true),
                  onTapUp: (_) {
                    setState(() => _pressed = false);
                    Navigator.of(context).pop();
                  },
                  onTapCancel: () => setState(() => _pressed = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOut,
                    transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _pressed
                          ? []
                          : const [
                              BoxShadow(
                                color: Color(0xFF3730A3),
                                offset: Offset(0, 5),
                                blurRadius: 0,
                              ),
                            ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      l10n.repasoIntroCta,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
