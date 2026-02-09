import 'package:alexandria_movil/components/unit_card.dart';
import 'package:alexandria_movil/core/text_styles.dart';
import 'package:alexandria_movil/data/course_generation_service.dart';
import 'package:alexandria_movil/data/progress_service.dart';
import 'package:alexandria_movil/data/session.dart';
import 'package:alexandria_movil/screens/course_screen.dart';
import 'package:flutter/material.dart';
import 'package:alexandria_movil/l10n/app_localizations.dart';

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
    required this.courseDescription,
    required this.currentUnit,
    required this.totalUnits,
    required this.units,
  });

  final int courseId;
  final CourseGenerationResponse courseData;
  final String courseTitle;
  final String courseDescription;
  final int currentUnit;
  final int totalUnits;
  final List<CourseUnit> units;

  @override
  State<CourseUnitsScreen> createState() => _CourseUnitsScreenState();
}

class _CourseUnitsScreenState extends State<CourseUnitsScreen> {
  final _progressService = ProgressService();

  bool _loading = false;
  String? _error;
  int _currentUnit = 1;
  double _completion = 0;
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _currentUnit = widget.currentUnit == 0 ? 1 : widget.currentUnit;
    _completion = 0;
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final userId = Session.userId;
    if (userId == null || userId == 0) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final progress =
          await _progressService.fetchProgress(userId: userId, courseId: widget.courseId);
      if (!mounted) return;
      setState(() {
        _currentUnit = progress.currentUnit == 0 ? 1 : progress.currentUnit;
        _completion = progress.completionPercentage;
      });
    } catch (err) {
      if (!mounted) return;
      // Si no hay progreso previo (404), ignoramos y usamos defaults.
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
    // fallback: based on current unit position
    final ratio = (_currentUnit - 1) / widget.totalUnits;
    return (ratio * 100).clamp(0, 100).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLabel =
        l10n.courseUnitsCurrentLabel(_currentUnit, widget.totalUnits);
    final progressLabel = l10n.courseUnitsProgressLabel(_computedCompletion.round());

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.courseTitle,
                      style: AppTextStyles.headingLarge(theme),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Divider(color: theme.dividerColor),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          progressLabel,
                          style: AppTextStyles.bodyMediumBold(
                            theme,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.courseDescription,
                          style: AppTextStyles.bodyLarge(theme),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentLabel,
                          style: AppTextStyles.bodyMediumBold(
                            theme,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _error!,
                              style: AppTextStyles.bodyMediumMuted(
                                theme,
                                alpha: 0.7,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                          itemCount: widget.units.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final unit = widget.units[index];
                            final status = _statusForUnit(unit.number);
                            return UnitCard(
                              unitNumber: unit.number,
                              title: unit.title,
                              subtitle: unit.subtitle,
                              status: status,
                    onTap: status == UnitStatus.locked
                        ? null
                        : () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CourseScreen(
                                  courseId: widget.courseId,
                                  courseData: widget.courseData,
                                  unitIndex: index,
                                  totalUnits: widget.totalUnits,
                                ),
                              ),
                            );
                            if (mounted) {
                              _loadProgress();
                            }
                          },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
