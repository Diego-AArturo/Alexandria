import 'package:alexandria_movil/core/text_styles.dart';
import 'package:alexandria_movil/data/course_generation_service.dart';
import 'package:alexandria_movil/data/session.dart';
import 'package:alexandria_movil/data/users_service.dart';
import 'package:flutter/material.dart';

import '../components/profile_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _usersService = UsersService();
  final _courseService = CourseGenerationService();

  bool _loading = false;
  String? _error;
  UserData? _user;
  int _coursesTotal = 0;
  int _coursesCompleted = 0;
  int _coursesInProgress = 0;
  bool _requestedOnce = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If the screen was built before session existed, retry once when deps change.
    if (!_requestedOnce && Session.userId != null && Session.userId != 0) {
      _loadData();
      _requestedOnce = true;
    }
  }

  Future<void> _loadData() async {
    final email = Session.userEmail;
    final userId = Session.userId;
    if (email == null || userId == null || userId == 0) {
      setState(() => _error = 'Please sign in to view your profile.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await _usersService.getByEmail(email, token: Session.accessToken);
      final courses = await _courseService.fetchUserCourses(userId);
      final completed = courses.where((c) => c.completionPercentage >= 99.9).length;
      final inProgress = courses.where((c) => c.completionPercentage > 0 && c.completionPercentage < 99.9).length;
      if (!mounted) return;
      setState(() {
        _user = user;
        _coursesTotal = courses.length;
        _coursesCompleted = completed;
        _coursesInProgress = inProgress;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load profile: $err');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    if (_loading) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMediumMuted(theme, alpha: 0.7),
              ),
            ),
          ),
        ),
      );
    }

    final user = _user;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Profile',
                  style: AppTextStyles.headingLarge(theme),
                ),
                const SizedBox(height: 24),
                ProfileCard(
                  leading: CircleAvatar(
                    radius: 36,
                    backgroundColor: primary.withValues(alpha: 0.1),
                    child: user?.profilePhoto != null
                        ? ClipOval(
                            child: Image.network(
                              user!.profilePhoto!,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person_outline,
                            size: 40,
                            color: primary,
                          ),
                  ),
                  title: user?.name ?? 'Guest',
                  subtitle: user?.email ?? 'Not signed in',
                  trailing: Icon(
                    Icons.edit_outlined,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ProfileCard(
                        leading: Icon(
                          Icons.menu_book_outlined,
                          color: primary,
                        ),
                        title: 'Courses',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_coursesTotal',
                              style: AppTextStyles.statValue(theme),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total courses',
                              style: AppTextStyles.bodyMediumMuted(theme),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ProfileCard(
                        leading: Icon(
                          Icons.emoji_events_outlined,
                          color: primary,
                        ),
                        title: 'Completed',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_coursesCompleted',
                              style: AppTextStyles.statValue(theme),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Courses completed',
                              style: AppTextStyles.bodyMediumMuted(theme),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ProfileCard(
                  leading: Icon(
                    Icons.play_circle_outline,
                    color: primary,
                  ),
                  title: 'In progress',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_coursesInProgress',
                        style: AppTextStyles.statValue(theme),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Courses currently active',
                        style: AppTextStyles.bodyMediumMuted(theme),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ProfileCard(
                  title: 'Account Information',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            user?.email ?? '-',
                            style: AppTextStyles.bodyMediumMuted(theme),
                          ),
                        ],
                      ),
                    ],
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
