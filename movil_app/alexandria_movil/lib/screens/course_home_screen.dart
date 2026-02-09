import 'package:alexandria_movil/components/course_card.dart';
import 'package:alexandria_movil/components/unit_card.dart';
import 'package:alexandria_movil/core/text_styles.dart';
import 'package:alexandria_movil/data/course_generation_service.dart';
import 'package:alexandria_movil/data/session.dart';
import 'package:alexandria_movil/screens/course_units_screen.dart';
import 'package:flutter/material.dart';
import 'package:alexandria_movil/l10n/app_localizations.dart';

class CourseHomeScreen extends StatefulWidget {
  const CourseHomeScreen({super.key});

  @override
  State<CourseHomeScreen> createState() => _CourseHomeScreenState();
}

class _CourseHomeScreenState extends State<CourseHomeScreen> with WidgetsBindingObserver {
  final _courseService = CourseGenerationService();

  bool _isLoading = false;
  String? _error;
  List<_CourseOverview> _courses = const [];

  void _showCraftHint() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.courseHomeEmptyMockActionHint)),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCourses());
  }

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadCourses();
    }
  }

  Future<void> _loadCourses() async {
    final userId = Session.userId ?? 0;
    if (userId == 0) {
      setState(() {
        _courses = const [];
        _error = l10n.courseHomeSignInPrompt;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await _courseService.fetchUserCourses(userId);
      if (!mounted) return;
      setState(() {
        _courses = list
            .map(
              (item) => _CourseOverview(
                courseId: item.courseId,
                title: item.learningTopic,
                description:
                    l10n.courseHomeProgressLabel(item.completionPercentage.round()),
                completionPercentage: item.completionPercentage,
              ),
            )
            .toList();
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _error = l10n.courseHomeLoadFailed('$err');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadCourses,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.courseHomeTitle,
                  style: AppTextStyles.headingLarge(theme),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Text(
                    _error!,
                    style: AppTextStyles.bodyMediumMuted(theme, alpha: 0.7),
                  )
                else if (_courses.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.courseHomeEmptyMockTitle,
                        style: AppTextStyles.titleMediumBold(theme),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.courseHomeEmptyMockDescription,
                        style: AppTextStyles.bodyMediumMuted(theme, alpha: 0.8),
                      ),
                      const SizedBox(height: 16),
                      CourseCard(
                        title: l10n.courseHomeEmptyMockSampleTitle,
                        description: l10n.courseHomeEmptyMockSampleDescription,
                        currentUnit: 0,
                        totalUnits: 3,
                        completionPercentage: 0,
                        onTap: _showCraftHint,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _showCraftHint,
                        icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                        label: Text(l10n.courseHomeEmptyMockAction),
                      ),
                    ],
                  )
                else
                  ..._courses.map(
                    (course) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CourseCard(
                        title: course.title,
                        description: course.description,
                        currentUnit: 0,
                        totalUnits: 1,
                        completionPercentage: course.completionPercentage,
                        onTap: () async {
                          final detail =
                              await _courseService.fetchCourse(course.courseId);
                          final units = _mapUnits(l10n, detail.courseData);
                          if (!mounted) return;
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CourseUnitsScreen(
                                courseId: course.courseId,
                                courseData: detail.courseData,
                                courseTitle: course.title,
                                courseDescription: course.description,
                                currentUnit: units.isEmpty ? 0 : 1,
                                totalUnits: units.length,
                                units: units,
                              ),
                            ),
                          );
                          if (mounted) _loadCourses(); // refresh after returning
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseOverview {
  const _CourseOverview({
    required this.courseId,
    required this.title,
    required this.description,
    required this.completionPercentage,
  });

  final int courseId;
  final String title;
  final String description;
  final double completionPercentage;
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
