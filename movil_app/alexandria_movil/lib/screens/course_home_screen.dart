import 'package:alexandria_movil/components/course_card.dart';
import 'package:alexandria_movil/core/text_styles.dart';
import 'package:flutter/material.dart';

class CourseHomeScreen extends StatefulWidget {
  const CourseHomeScreen({super.key});

  @override
  State<CourseHomeScreen> createState() => _CourseHomeScreenState();
}

class _CourseHomeScreenState extends State<CourseHomeScreen> {
  static const List<_CourseOverview> _courses = [
    _CourseOverview(
      title: 'Introduction to Flutter',
      description: 'Learn the basics of Flutter development.',
      currentUnit: 3,
      totalUnits: 4,
    ),
    _CourseOverview(
      title: 'Introduction to Flutter',
      description: 'Learn the basics of Flutter development.',
      currentUnit: 3,
      totalUnits: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My courses',
                style: AppTextStyles.headingLarge(theme),
              ),
              const SizedBox(height: 24),
              ..._courses.map(
                (course) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CourseCard(
                    title: course.title,
                    description: course.description,
                    currentUnit: course.currentUnit,
                    totalUnits: course.totalUnits,
                    onTap: () {
                      // Handle course card tap
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseOverview {
  const _CourseOverview({
    required this.title,
    required this.description,
    required this.currentUnit,
    required this.totalUnits,
  });

  final String title;
  final String description;
  final int currentUnit;
  final int totalUnits;
}
