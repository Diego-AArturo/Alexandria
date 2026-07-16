import 'package:alexandria_movil/components/unit_card.dart';
import 'package:alexandria_movil/data/course_generation_service.dart';
import 'package:alexandria_movil/data/notification_service.dart';
import 'package:alexandria_movil/data/session.dart';
import 'package:alexandria_movil/l10n/app_localizations.dart';
import 'package:alexandria_movil/l10n/app_localizations_extra.dart';
import 'package:alexandria_movil/screens/course_units_screen.dart';
import 'package:flutter/material.dart';


class CraftCourseScreen extends StatefulWidget {
  const CraftCourseScreen({super.key});

  @override
  State<CraftCourseScreen> createState() => _CraftCourseScreenState();
}

class _CraftCourseScreenState extends State<CraftCourseScreen> {
  final _promptController = TextEditingController();
  final _service = CourseGenerationService();
  static const int _maxCoursesPerUser = 3;
  int _expertiseLevel = 3;
  bool _isSubmitting = false;
  bool _jobInProgress = false;
  bool _hasNavigatedPartial = false;
  double? _jobProgress;
  String? _jobStatusText;
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _submitCourse() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.craftCourseToastEmptyPrompt)),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _jobStatusText = null;
    });

    try {
      final reachedLimit = await _isCourseLimitReached();
      if (reachedLimit) {
        return;
      }

      final job = await _service.generateCourse(
        prompt,
        userId: Session.userId,
        expertiseLevel: _expertiseLevel,
      );
      if (!mounted) return;

      setState(() {
        _jobInProgress = true;
        _jobProgress = job.progress;
        _jobStatusText = 'queued';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.craftCourseQueuedMessage)),
      );

      _pollJobInBackground(job.jobId);
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.craftCourseGenerateFailed('$err'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<bool> _isCourseLimitReached() async {
    final userId = Session.userId;
    if (userId == null) return false;

    try {
      final courses = await _service.fetchUserCourses(userId);
      final limitReached = courses.length >= _maxCoursesPerUser;
      if (limitReached && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.craftCourseLimitReached(_maxCoursesPerUser))),
        );
      }
      return limitReached;
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.craftCourseLimitCheckFailed('$err'))),
        );
      }
      return true;
    }
  }

  void _pollJobInBackground(int jobId) {
    Future(() async {
      final startedAt = DateTime.now();
      int consecutiveErrors = 0;
      try {
        while (mounted) {
          try {
            final status = await _service.getJobStatus(jobId);
            consecutiveErrors = 0;
            if (!mounted) return;
            setState(() {
              _jobInProgress = true;
              _jobProgress = status.progress;
              _jobStatusText = status.status;
            });

            if (status.status == 'partial' && status.courseId != null && !_hasNavigatedPartial) {
              setState(() => _hasNavigatedPartial = true);
              try {
                final detail = await _service.fetchCourse(status.courseId!);
                if (!mounted) return;
                if (ModalRoute.of(context)?.isCurrent == true) {
                  _openPartialCourse(status.courseId!, existingDetail: detail);
                }
              } catch (_) {}
              // Continue polling — don't return
            }

            if (status.status == 'completed' && status.courseId != null) {
              final detail = await _service.fetchCourse(status.courseId!);
              final courseTitle = detail.courseData.topic['learning_topic']?.toString();

              await NotificationService().showCourseReady(
                courseId: status.courseId!,
                courseTitle: courseTitle,
              );

              if (!mounted) return;
              setState(() {
                _jobInProgress = false;
              });

              if (ModalRoute.of(context)?.isCurrent == true) {
                await _openGeneratedCourse(status.courseId!, existingDetail: detail);
              }
              return;
            }

            if (status.status == 'failed') {
              await NotificationService().showError();
              if (!mounted) return;
              setState(() {
                _jobInProgress = false;
                _jobStatusText = 'failed';
              });
              return;
            }
          } catch (_) {
            consecutiveErrors += 1;
          }

          final elapsed = DateTime.now().difference(startedAt);
          final hitTimeout = elapsed > const Duration(minutes: 10);
          final tooManyErrors = consecutiveErrors >= 3;

          if (hitTimeout || tooManyErrors) {
            await NotificationService().showError();
            if (!mounted) return;
            setState(() {
              _jobInProgress = false;
              _jobStatusText = hitTimeout ? 'timeout' : 'error';
            });
            return;
          }

          await Future.delayed(const Duration(seconds: 2));
        }
      } catch (err) {
        await NotificationService().showError();
        if (!mounted) return;
        setState(() {
          _jobInProgress = false;
          _jobStatusText = 'error';
        });
      }
    });
  }

  Future<void> _openGeneratedCourse(int courseId, {CourseGenerationStoredResponse? existingDetail}) async {
    try {
      final detail = existingDetail ?? await _service.fetchCourse(courseId);
      final units = _mapUnits(l10n, detail.courseData);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => CourseUnitsScreen(
            courseId: courseId,
            courseData: detail.courseData,
            courseTitle: detail.courseData.topic['learning_topic']?.toString() ??
                l10n.craftCourseGeneratedTitleFallback,
            currentUnit: units.isEmpty ? 0 : 1,
            totalUnits: units.length,
            units: units,
          ),
        ),
        (route) => false,
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.craftCourseOpenFailed('$err'))),
      );
    }
  }

  Future<void> _openPartialCourse(int courseId, {CourseGenerationStoredResponse? existingDetail}) async {
    try {
      final detail = existingDetail ?? await _service.fetchCourse(courseId);
      final units = _mapUnits(l10n, detail.courseData);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CourseUnitsScreen(
            courseId: courseId,
            courseData: detail.courseData,
            courseTitle: detail.courseData.topic['learning_topic']?.toString() ??
                l10n.craftCourseGeneratedTitleFallback,
            currentUnit: units.isEmpty ? 0 : 1,
            totalUnits: units.length,
            units: units,
            isGenerating: true,
          ),
        ),
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.craftCourseOpenFailed('$err'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.craftCourseTitle,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1235),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.craftCourseSubtitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B5E8C),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              IgnorePointer(
                ignoring: _jobInProgress || _isSubmitting,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: (_jobInProgress || _isSubmitting)
                        ? const Color(0xFFF5F2FC)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (_jobInProgress || _isSubmitting)
                          ? const Color(0xFFE2DAF0)
                          : const Color(0xFFDCD5EC),
                      width: 2,
                    ),
                  ),
                  child: TextField(
                    maxLines: 8,
                    minLines: 6,
                    controller: _promptController,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: (_jobInProgress || _isSubmitting)
                          ? const Color(0xFF9A91B0)
                          : const Color(0xFF1A1235),
                      height: 1.45,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.craftCoursePromptHint,
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB5ACC9),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              IgnorePointer(
                ignoring: _jobInProgress || _isSubmitting,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: (_jobInProgress || _isSubmitting) ? 0.5 : 1.0,
                  child: _ExpertisePicker(
                    selected: _expertiseLevel,
                    onChanged: (level) =>
                        setState(() => _expertiseLevel = level),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _Btn3d(
                onTap: _isSubmitting ? null : _submitCourse,
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                              backgroundColor: Color(0x66FFFFFF),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            l10n.craftCourseSubmittingLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.craftCourseSubmitLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
              ),
              if (_jobInProgress)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: _JobProgressBanner(
                    status: _jobStatusText ?? 'processing',
                    progress: _jobProgress,
                  ),
                ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EFFB),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                      color: const Color(0xFFECE7F7), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFECE7F7),
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF5B53A),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.craftCourseTipsTitle.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A1235),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _TipBullet(
                        number: 1, text: l10n.craftCourseTipSpecificGoals),
                    const SizedBox(height: 10),
                    _TipBullet(
                        number: 2, text: l10n.craftCourseTipKnowledgeLevel),
                    const SizedBox(height: 10),
                    _TipBullet(
                        number: 3, text: l10n.craftCourseTipTopics),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Private widgets ───────────────────────────────────────────────────────

class _ExpertisePicker extends StatelessWidget {
  const _ExpertisePicker({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFFB),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFECE7F7), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFECE7F7),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                color: Color(0xFF6C0DF1),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.craftExpertiseTitle.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1235),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.craftExpertiseSubtitle,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B5E8C),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(5, (i) {
              final level = i + 1;
              final isSelected = level == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    margin: EdgeInsets.only(left: i > 0 ? 6 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF5B2BE3)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF5B2BE3)
                            : const Color(0xFFDCD5EC),
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Color(0xFF3F1AAD),
                                offset: Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$level',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF6B5E8C),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.craftExpertiseLabelBeginner,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B5E8C),
                ),
              ),
              Text(
                l10n.craftExpertiseLabelExpert,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B5E8C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              l10n.craftExpertiseDescription(selected),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3D2E66),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Btn3d extends StatefulWidget {
  const _Btn3d({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_Btn3d> createState() => _Btn3dState();
}

class _Btn3dState extends State<_Btn3d> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;
    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            },
      onTapCancel: isDisabled ? null : () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isDisabled
              ? const Color(0xFFDCD5EC)
              : const Color(0xFF5B2BE3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDisabled
                  ? const Color(0xFFB5ACC9)
                  : const Color(0xFF3F1AAD),
              offset: Offset(0, _pressed ? 1 : 4),
              blurRadius: 0,
            ),
          ],
        ),
        transform: _pressed
            ? Matrix4.translationValues(0, 3, 0)
            : Matrix4.identity(),
        child: widget.child,
      ),
    );
  }
}

class _JobProgressBanner extends StatelessWidget {
  const _JobProgressBanner({required this.status, this.progress});

  final String status;
  final double? progress;

  int get _stageIndex => switch (status) {
        'queued' => 0,
        'processing' => 1,
        'completed' => 2,
        _ => -1,
      };

  String get _stageMessage => switch (status) {
        'queued' => 'Queued…',
        'processing' => 'Generating course…',
        'completed' => 'Course ready!',
        'failed' => 'Generation failed',
        'timeout' => 'Generation timed out',
        _ => 'Generating course…',
      };

  @override
  Widget build(BuildContext context) {
    final si = _stageIndex;
    final isError = si == -1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFC7B0FF), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE2D6FF),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  backgroundColor: Color(0xFFE2D6FF),
                  valueColor:
                      AlwaysStoppedAnimation(Color(0xFF5B2BE3)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _stageMessage,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3F1AAD),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "We'll notify you when it's done — feel free to leave this screen.",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B5E8C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (i) {
              final filled = !isError && si >= i;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(left: i > 0 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: filled
                        ? const Color(0xFF6B38F2)
                        : const Color(0xFFECE7F7),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TipBullet extends StatelessWidget {
  const _TipBullet({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFE2D6FF),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4A1FC7),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3D2E66),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

List<CourseUnit> _mapUnits(AppLocalizations l10n, CourseGenerationResponse data) {
  final unitsList = (data.units['units'] as List?)?.cast<Map>() ?? const [];
  if (unitsList.isEmpty) return const [];

  return unitsList.asMap().entries.map((entry) {
    final idx = entry.key;
    final raw = Map<String, dynamic>.from(entry.value);
    final title = raw['unit_title']?.toString().isNotEmpty == true
        ? raw['unit_title'].toString()
        : l10n.unitNumberLabel(idx + 1);
    final subtitle = raw['description']?.toString() ??
        (raw['objectives'] is List && (raw['objectives'] as List).isNotEmpty
            ? (raw['objectives'] as List).first.toString()
            : '');

    final status = idx == 0 ? UnitStatus.current : UnitStatus.locked;

    return CourseUnit(
      number: idx + 1,
      title: title,
      subtitle: subtitle,
      status: status,
    );
  }).toList();
}
