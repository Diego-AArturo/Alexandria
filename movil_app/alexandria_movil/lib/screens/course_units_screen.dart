import 'dart:async';

import 'package:alexandria_movil/components/unit_card.dart';
import 'package:alexandria_movil/data/course_generation_service.dart';
import 'package:alexandria_movil/data/progress_service.dart';
import 'package:alexandria_movil/data/session.dart';
import 'package:alexandria_movil/screens/course_screen.dart';
import 'package:flutter/material.dart';
import 'package:alexandria_movil/l10n/app_localizations.dart';
import 'package:alexandria_movil/l10n/app_localizations_extra.dart';

// Design tokens
const _violet = Color(0xFF4F46E5);
const _violetBorder = Color(0xFFC7D2FE);
const _teal = Color(0xFF059669);
const _muted = Color(0xFF9CA3AF);
const _textDark = Color(0xFF1E1B4B);

class CourseUnit {
  const CourseUnit({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final int number;
  final String title;
  final String subtitle;
  final UnitStatus status;
}

class CourseUnitsScreen extends StatefulWidget {
  const CourseUnitsScreen({
    super.key,
    required this.courseId,
    required this.courseData,
    required this.courseTitle,
    required this.currentUnit,
    required this.totalUnits,
    required this.units,
    this.isGenerating = false,
  });

  final int courseId;
  final CourseGenerationResponse courseData;
  final String courseTitle;
  final int currentUnit;
  final int totalUnits;
  final List<CourseUnit> units;
  final bool isGenerating;

  @override
  State<CourseUnitsScreen> createState() => _CourseUnitsScreenState();
}

class _CourseUnitsScreenState extends State<CourseUnitsScreen> {
  final _progressService = ProgressService();
  final _courseService = CourseGenerationService();

  bool _loading = false;
  String? _error;
  int _currentUnit = 1;
  double _completion = 0;
  late CourseGenerationResponse _courseData;
  bool _isGenerating = false;
  Timer? _generationTimer;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _currentUnit = widget.currentUnit == 0 ? 1 : widget.currentUnit;
    _courseData = widget.courseData;
    _isGenerating = widget.isGenerating;
    _loadProgress();
    if (_isGenerating) _startGenerationPolling();
  }

  @override
  void dispose() {
    _generationTimer?.cancel();
    super.dispose();
  }

  void _startGenerationPolling() {
    _generationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final detail = await _courseService.fetchCourse(widget.courseId);
        if (!mounted) {
          _generationTimer?.cancel();
          return;
        }
        setState(() => _courseData = detail.courseData);
        final totalUnits = (_courseData.units['units'] as List?)?.length ?? 0;
        if (totalUnits > 0 && _courseData.concepts.length >= totalUnits) {
          _generationTimer?.cancel();
          setState(() => _isGenerating = false);
        }
      } catch (_) {}
    });
  }

  Future<void> _loadProgress() async {
    final userId = Session.userId;
    if (userId == null || userId == 0) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final progress = await _progressService.fetchProgress(
          userId: userId, courseId: widget.courseId);
      if (!mounted) return;
      setState(() {
        _currentUnit = progress.currentUnit == 0 ? 1 : progress.currentUnit;
        _completion = progress.completionPercentage;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _error = err.toString().contains('404')
            ? null
            : l10n.courseUnitsLoadFailed('$err');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  UnitStatus _statusForUnit(int number) {
    if (number < _currentUnit) return UnitStatus.completed;
    if (number == _currentUnit) return UnitStatus.current;
    return UnitStatus.locked;
  }

  double get _computedCompletion {
    if (widget.totalUnits == 0) return 0;
    if (_completion > 0) return _completion.clamp(0, 100).toDouble();
    final ratio = (_currentUnit - 1) / widget.totalUnits;
    return (ratio * 100).clamp(0, 100).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: Column(
        children: [
          _buildHeroHeader(),
          if (_isGenerating) _buildGeneratingBanner(),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: _violet))
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _error!,
                            style: const TextStyle(
                                fontSize: 14, color: _muted, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : _buildUnitPath(),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFE2D6FF),
      child: Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF5B2BE3),
              backgroundColor: Color(0xFFC7B0FF),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Generating remaining units…',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4A1FC7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    final completedCount = widget.units
        .where((u) => _statusForUnit(u.number) == UnitStatus.completed)
        .length;
    final progress = _computedCompletion;

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
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _HeroBackButton(onTap: () => Navigator.of(context).pop()),
                  const SizedBox(width: 4),
                  Text(
                    l10n.courseUnitsBackLabel,
                    style: TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.38),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Transform.scale(
                        scale: 1.35,
                        child: Image.asset(
                          'assets/splash/splash.png',
                          width: 56,
                          height: 56,
                          fit: BoxFit.contain,
                          color: Colors.white,
                          colorBlendMode: BlendMode.srcATop,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.courseTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.courseUnitsUnitsComplete(completedCount, widget.totalUnits),
                          style: const TextStyle(
                            color: Color(0xBFFFFFFF),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.courseUnitsProgressSectionLabel,
                    style: TextStyle(
                      color: Color(0xBFFFFFFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${progress.round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      widthFactor: (progress / 100).clamp(0.0, 1.0),
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.white, Color(0xCCFFFFFF)],
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitPath() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
      children: [
        Text(
          l10n.courseUnitsLearningPathLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: _muted,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < widget.units.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _UnitPathNode(
            unit: widget.units[i],
            status: _statusForUnit(widget.units[i].number),
            onTap: _statusForUnit(widget.units[i].number) == UnitStatus.locked
                ? null
                : () async {
                    final status = _statusForUnit(widget.units[i].number);
                    if (status == UnitStatus.completed) {
                      final action = await showDialog<_CompletedUnitAction>(
                        context: context,
                        builder: (ctx) => _CompletedUnitDialog(l10n: l10n),
                      );
                      if (!mounted || action == null) return;
                      await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => CourseScreen(
                            courseId: widget.courseId,
                            courseData: _courseData,
                            unitIndex: i,
                            totalUnits: widget.totalUnits,
                            isRepeat: true,
                            previewMode: action == _CompletedUnitAction.review,
                          ),
                        ),
                      );
                      if (mounted) _loadProgress();
                      return;
                    }
                    final courseCompleted = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => CourseScreen(
                          courseId: widget.courseId,
                          courseData: _courseData,
                          unitIndex: i,
                          totalUnits: widget.totalUnits,
                        ),
                      ),
                    );
                    if (!mounted) return;
                    _loadProgress();
                    if (courseCompleted == true) Navigator.of(context).maybePop();
                  },
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

}

// ─── Hero back button ─────────────────────────────────────────────────────────

class _HeroBackButton extends StatefulWidget {
  const _HeroBackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_HeroBackButton> createState() => _HeroBackButtonState();
}

class _HeroBackButtonState extends State<_HeroBackButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _pressed
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xB3FFFFFF),
          size: 18,
        ),
      ),
    );
  }
}

// ─── Unit path node ───────────────────────────────────────────────────────────

class _UnitPathNode extends StatefulWidget {
  const _UnitPathNode({
    required this.unit,
    required this.status,
    this.onTap,
  });

  final CourseUnit unit;
  final UnitStatus status;
  final VoidCallback? onTap;

  @override
  State<_UnitPathNode> createState() => _UnitPathNodeState();
}

class _UnitPathNodeState extends State<_UnitPathNode> {
  bool _pressed = false;

  bool get _isLocked => widget.status == UnitStatus.locked;
  bool get _isCurrent => widget.status == UnitStatus.current;
  bool get _isCompleted => widget.status == UnitStatus.completed;

  Color get _nodeColor =>
      _isCompleted ? _teal : _isCurrent ? _violet : _muted;
  Color get _borderColor =>
      _isLocked ? const Color(0xFFE5E7EB) : _violetBorder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _isLocked ? null : (_) => setState(() => _pressed = true),
      onTapUp: _isLocked
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        scale: _pressed ? 0.975 : (_isCurrent ? 1.02 : 1.0),
        child: Opacity(
          opacity: _isLocked ? 0.5 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: _isLocked ? const Color(0xFFF9FAFB) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _borderColor, width: 2.5),
              boxShadow: (_pressed || _isLocked)
                  ? []
                  : [
                      BoxShadow(
                        color: _isCurrent
                            ? const Color(0x264F46E5)
                            : _borderColor,
                        offset: _isCurrent
                            ? const Offset(0, 5)
                            : const Offset(0, 3),
                        blurRadius: 0,
                      ),
                      if (_isCurrent)
                        const BoxShadow(
                          color: Color(0x1A4F46E5),
                          offset: Offset(0, 8),
                          blurRadius: 20,
                        ),
                    ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _buildNodeIcon(),
                const SizedBox(width: 14),
                Expanded(child: _buildNodeText()),
                if (!_isLocked)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _violet,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNodeIcon() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _nodeColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isLocked
            ? []
            : [
                BoxShadow(
                  color: _isCompleted
                      ? const Color(0xFF047857)
                      : const Color(0xFF3730A3),
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
      ),
      alignment: Alignment.center,
      child: _isCompleted
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 26)
          : _isCurrent
              ? const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 26)
              : const Icon(Icons.lock_rounded,
                  color: Color(0xFF9CA3AF), size: 20),
    );
  }

  Widget _buildNodeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.unit.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: _isLocked ? _muted : _textDark,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          widget.unit.subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: _muted,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

// ─── Completed unit re-entry action ──────────────────────────────────────────

enum _CompletedUnitAction { repeat, review }

// ─── Completed unit re-entry dialog ──────────────────────────────────────────

class _CompletedUnitDialog extends StatelessWidget {
  const _CompletedUnitDialog({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D2E66).withValues(alpha: 0.18),
              offset: const Offset(0, 8),
              blurRadius: 24,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: _teal,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF047857),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 38),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.unitAlreadyCompletedHeading,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1235),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.unitAlreadyCompletedBody,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B5E8C),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pop(_CompletedUnitAction.review),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _violet,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  l10n.unitCompletionReview,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).pop(_CompletedUnitAction.repeat),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: _violet, width: 2),
                  foregroundColor: _violet,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  l10n.unitCompletionRepeat,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(
                l10n.unitCompletionExit,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B5E8C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

