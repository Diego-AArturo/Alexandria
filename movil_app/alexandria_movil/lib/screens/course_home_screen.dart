import 'package:alexandria_movil/components/course_card.dart';
import 'package:flutter/material.dart';

class CourseHomeScreen extends StatefulWidget {
  const CourseHomeScreen({super.key});

  @override
  State<CourseHomeScreen> createState() => _CourseHomeScreenState();
}

class _CourseHomeScreenState extends State<CourseHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Column (children: [
      Padding( padding: const EdgeInsets.all(16.0),
      child:
        CourseCard(
          title: 'Introduction to Flutter',
          description: 'Learn the basics of Flutter development.',
          currentUnit: 3,
          totalUnits: 4,
          onTap: () {
            // Handle course card tap
          },
        ),
      ), 
      Padding( padding: const EdgeInsets.only(top: 8.0, bottom: 8.0,left: 16.0, right: 16.0),
      child:
        CourseCard(
          title: 'Introduction to Flutter',
          description: 'Learn the basics of Flutter development.',
          currentUnit: 3,
          totalUnits: 4,
          onTap: () {
            // Handle course card tap
          },
        ),
      ) 
    ],);
  }
}