import 'package:alexandria_movil/core/text_styles.dart';
import 'package:flutter/material.dart';

import '../components/profile_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
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
                  child: Icon(
                    Icons.person_outline,
                    size: 40,
                    color: primary,
                  ),
                ),
                title: 'Alex Learner',
                subtitle: 'Enthusiastic Learner',
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
                            '3',
                            style: AppTextStyles.statValue(theme),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Active courses',
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
                            '4',
                            style: AppTextStyles.statValue(theme),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Completed',
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
                title: 'Account Information',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event_outlined,
                          color: primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Member since',
                          style: AppTextStyles.bodyMediumMuted(theme),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '2025',
                      style: AppTextStyles.titleMediumBold(theme),
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
