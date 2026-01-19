import 'package:alexandria_movil/components/unit_card.dart';
import 'package:alexandria_movil/core/app_colors.dart';
import 'package:alexandria_movil/core/text_styles.dart';
import 'package:alexandria_movil/data/course_generation_service.dart';
import 'package:alexandria_movil/data/session.dart';
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
  bool _isSubmitting = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _submitCourse() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the course you want.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final job = await _service.generateCourse(
        prompt,
        userId: Session.userId,
      );
      if (!mounted) return;
      await _openGeneratedCourse(job.courseId);
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate course: $err')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _openGeneratedCourse(int courseId) async {
    try {
      final detail = await _service.fetchCourse(courseId);
      final units = _mapUnits(detail.courseData);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => CourseUnitsScreen(
            courseId: courseId,
            courseData: detail.courseData,
            courseTitle: detail.courseData.topic['learning_topic']?.toString() ??
                'Generated course',
            courseDescription: detail.courseData.topic['additional_context']
                    ?.toString() ??
                'Your generated course',
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
        SnackBar(content: Text('Course generated but failed to open: $err')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppColors.deepPurple,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Craft a Course',
                    style: AppTextStyles.headingLarge(theme),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Describe what you want to learn and we'll create a short, tailored course for you.",
                style: AppTextStyles.bodyLargeMuted(theme),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowLow,
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  maxLines: 6,
                  minLines: 5,
                  controller: _promptController,
                  decoration: InputDecoration(
                    hintText:
                        'Example: I want to learn the basics of Python to automate simple tasks.',
                    hintStyle: AppTextStyles.bodyLargeMuted(theme),
                    border: InputBorder.none,
                  ),
                  style: AppTextStyles.bodyLarge(theme),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitCourse,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome, size: 20),
                  label: Text(_isSubmitting ? 'Creating...' : 'Create Course'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: AppTextStyles.titleMediumBold(
                      theme,
                      color: AppColors.white,
                    ),
                    backgroundColor: AppColors.deepPurple,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ).copyWith(
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.disabled)
                          ? AppColors.accentPurple.withValues(alpha: 0.6)
                          : AppColors.deepPurple,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_objects_outlined,
                          color: AppColors.deepPurple,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tips for great courses:',
                          style: AppTextStyles.titleMediumBold(theme),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _TipBullet(
                      text: 'Be specific about your learning goals',
                      style: AppTextStyles.bodyMediumMuted(theme),
                    ),
                    _TipBullet(
                      text: 'Mention your current knowledge level',
                      style: AppTextStyles.bodyMediumMuted(theme),
                    ),
                    _TipBullet(
                      text: 'Include any specific topics you want covered',
                      style: AppTextStyles.bodyMediumMuted(theme),
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
}

class _TipBullet extends StatelessWidget {
  const _TipBullet({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('-', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

List<CourseUnit> _mapUnits(CourseGenerationResponse data) {
  final unitsList = (data.units['units'] as List?)?.cast<Map>() ?? const [];
  if (unitsList.isEmpty) return const [];

  return unitsList.asMap().entries.map((entry) {
    final idx = entry.key;
    final raw = Map<String, dynamic>.from(entry.value);
    final title = raw['unit_title']?.toString() ?? 'Unit ${idx + 1}';
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
