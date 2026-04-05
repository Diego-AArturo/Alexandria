import 'package:alexandria_movil/core/text_styles.dart';
import 'package:alexandria_movil/data/course_generation_service.dart';
import 'package:alexandria_movil/data/session.dart';
import 'package:alexandria_movil/data/users_service.dart';
import 'package:alexandria_movil/l10n/app_localizations_extra.dart';
import 'package:flutter/material.dart';
import 'package:alexandria_movil/l10n/app_localizations.dart';

import '../components/profile_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _usersService = UsersService();
  final _courseService = CourseGenerationService();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _saving = false;
  bool _editing = false;
  String? _error;
  UserData? _user;
  int _coursesTotal = 0;
  int _coursesCompleted = 0;
  int _coursesInProgress = 0;
  bool _requestedOnce = false;
  String? _editingOriginalLanguage;
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requestedOnce && Session.userId != null && Session.userId != 0) {
      _loadData();
      _requestedOnce = true;
    }
  }

  Future<void> _loadData() async {
    final email = Session.userEmail;
    final userId = Session.userId;
    if (email == null || userId == null || userId == 0) {
      setState(() => _error = l10n.profileSignInPrompt);
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
      final inProgress =
          courses.where((c) => c.completionPercentage > 0 && c.completionPercentage < 99.9).length;
      if (!mounted) return;
      setState(() {
        _user = user;
        _coursesTotal = courses.length;
        _coursesCompleted = completed;
        _coursesInProgress = inProgress;
        _nameController.text = user.name;
        _passwordController.clear();
      });
    } catch (err) {
      if (!mounted) return;
      setState(() => _error = l10n.profileLoadFailed('$err'));
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
                  l10n.profileTitle,
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
                  title: user?.name ?? l10n.profileGuestName,
                  subtitle: _buildProfileSubtitle(user),
                  trailing: IconButton(
                    onPressed: _saving ? null : _toggleEditing,
                    icon: Icon(
                      _editing ? Icons.close : Icons.edit_outlined,
                      color: primary,
                    ),
                  ),
                  child: _editing ? _buildEditFields(theme) : null,
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
                        title: l10n.profileCoursesTitle,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_coursesTotal',
                              style: AppTextStyles.statValue(theme),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.profileCoursesTotalLabel,
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
                        title: l10n.profileCompletedTitle,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_coursesCompleted',
                              style: AppTextStyles.statValue(theme),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.profileCoursesCompletedLabel,
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
                  title: l10n.profileInProgressTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_coursesInProgress',
                        style: AppTextStyles.statValue(theme),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.profileCoursesActiveLabel,
                        style: AppTextStyles.bodyMediumMuted(theme),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ProfileCard(
                  title: l10n.profileAccountInfoTitle,
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

  Widget _buildEditFields(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n.profileNameLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.profilePasswordLabel,
            hintText: l10n.profilePasswordHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _languageChip(theme, storedValue: 'Es', label: 'Español'),
            _languageChip(theme, storedValue: 'En', label: 'English'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving ? null : _cancelEditing,
                child: Text(l10n.profileCancelAction),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.profileSaveAction),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleEditing() {
    setState(() {
      _editing = !_editing;
      if (_editing) {
        _nameController.text = _user?.name ?? '';
        _editingOriginalLanguage = _normalizedStoredLanguage(_user?.language);
        _passwordController.clear();
      }
    });
  }

  void _cancelEditing() {
    setState(() {
      _editing = false;
      _saving = false;
      _nameController.text = _user?.name ?? '';
      _editingOriginalLanguage = null;
      _passwordController.clear();
    });
  }

  Future<void> _saveProfile() async {
    final token = Session.accessToken;
    if (token == null || token.isEmpty) return;

    final trimmedName = _nameController.text.trim();
    final normalizedLanguage = _normalizedStoredLanguage(_user?.language);
    final previousLanguage = _editingOriginalLanguage;
    if (trimmedName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileNameRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final updated = await _usersService.updateProfile(
        token: token,
        name: trimmedName,
        language: normalizedLanguage,
        password: _passwordController.text,
      );
      if (!mounted) return;
      setState(() {
        _user = updated;
        _editing = false;
        _saving = false;
        _editingOriginalLanguage = null;
        _nameController.text = updated.name;
        _passwordController.clear();
      });
      final updatedLanguage = _normalizedStoredLanguage(updated.language);
      final saveMessage = updatedLanguage != previousLanguage
          ? l10n.profileSavedRestartLanguageMessage
          : l10n.profileSavedMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(saveMessage)),
      );
    } catch (err) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileUpdateFailed('$err'))),
      );
    }
  }

  String? _displayLanguageLabel() {
    final normalized = (_user?.language ?? '').trim().toLowerCase();
    if (normalized == 'en') return 'English';
    if (normalized == 'es') return 'Español';
    return null;
  }

  Widget _languageChip(
    ThemeData theme, {
    required String storedValue,
    required String label,
  }) {
    final current = _normalizedStoredLanguage(_user?.language);
    final isSelected = current == storedValue;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        if (_saving) return;
        setState(() {
          final currentUser = _user;
          if (currentUser == null) return;
          _user = UserData(
            id: currentUser.id,
            email: currentUser.email,
            name: currentUser.name,
            googleUid: currentUser.googleUid,
            profilePhoto: currentUser.profilePhoto,
            language: storedValue,
          );
        });
      },
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.16),
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.dividerColor.withValues(alpha: 0.4),
        ),
      ),
      labelStyle: AppTextStyles.bodyMedium(
        theme,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
    );
  }

  String? _normalizedStoredLanguage(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == 'es') return 'Es';
    if (normalized == 'en') return 'En';
    return null;
  }

  String _buildProfileSubtitle(UserData? user) {
    final email = user?.email ?? l10n.profileNotSignedIn;
    final language = _displayLanguageLabel();
    if (language == null) {
      return email;
    }
    return '$email\n$language';
  }
}
