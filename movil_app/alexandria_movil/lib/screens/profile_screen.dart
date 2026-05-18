import 'package:alexandria_movil/data/course_generation_service.dart';
import 'package:alexandria_movil/data/session.dart';
import 'package:alexandria_movil/data/users_service.dart';
import 'package:alexandria_movil/l10n/app_localizations.dart';
import 'package:alexandria_movil/l10n/app_localizations_extra.dart';
import 'package:flutter/material.dart';

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
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAF7FF),
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF5B2BE3)),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF7FF),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B5E8C),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final user = _user;
    final displayName =
        user?.name.isNotEmpty == true ? user!.name : l10n.profileGuestName;
    final initials = displayName[0].toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF5B2BE3),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileTitle,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1235),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 18),

                // Card 1: Identity
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAvatar(user, initials),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1A1235),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.email ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF6B5E8C),
                                  ),
                                ),
                                if (_displayLanguageLabel() != null) ...[
                                  const SizedBox(height: 6),
                                  _buildLanguageBadge(_displayLanguageLabel()!),
                                ],
                              ],
                            ),
                          ),
                          _buildEditButton(),
                        ],
                      ),
                      if (_editing) ...[
                        const SizedBox(height: 16),
                        _buildEditFields(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Card 2: Total | Completed (side-by-side)
                Container(
                  width: double.infinity,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border:
                        Border.all(color: const Color(0xFFECE7F7), width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFECE7F7),
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 18),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                  color: Color(0xFFECE7F7), width: 2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$_coursesTotal',
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF4A1FC7),
                                  letterSpacing: -1,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.profileCoursesTotalSublabel(_coursesTotal),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF6B5E8C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 18),
                          child: Column(
                            children: [
                              Text(
                                '$_coursesCompleted',
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF5B2BE3),
                                  letterSpacing: -1,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.profileCoursesCompletedSublabel(_coursesCompleted),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF6B5E8C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Card 3: In Progress (gold gradient)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFD66B), Color(0xFFF5B53A)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFC8841F),
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$_coursesInProgress',
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: -2,
                          color: Color(0xFF5C3F00),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.profileCoursesActiveSublabel(_coursesInProgress),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF5C3F00),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Card 4: Account info
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.profileAccountInfoTitle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF6B5E8C),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B5E8C),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              user?.email ?? '-',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1235),
                              ),
                            ),
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

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: child,
    );
  }

  Widget _buildAvatar(UserData? user, String initials) {
    if (user?.profilePhoto != null) {
      return ClipOval(
        child: Image.network(
          user!.profilePhoto!,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5BFF), Color(0xFF4A1FC7)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3F1AAD),
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLanguageBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE2D6FF),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        '🌍 $label',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Color(0xFF4A1FC7),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return GestureDetector(
      onTap: _saving ? null : _toggleEditing,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF1ECFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2D6FF), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFE2D6FF),
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          _editing ? Icons.close : Icons.edit_outlined,
          size: 18,
          color: const Color(0xFF4A1FC7),
        ),
      ),
    );
  }

  Widget _buildEditFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profileNewNameLabel.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Color(0xFF6B5E8C),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        _inputField(
            controller: _nameController, placeholder: l10n.profileNameLabel),
        const SizedBox(height: 12),
        Text(
          l10n.profilePasswordLabel.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Color(0xFF6B5E8C),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        _inputField(
          controller: _passwordController,
          placeholder: l10n.profilePasswordHint,
          obscure: true,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.profileLanguageFieldLabel.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Color(0xFF6B5E8C),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _languageChip(storedValue: 'Es', label: 'Español'),
            _languageChip(storedValue: 'En', label: 'English'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ghostButton(
                label: l10n.profileCancelAction,
                onTap: _saving ? null : _cancelEditing,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _solidButton(
                label: l10n.profileSaveAction,
                onTap: _saving ? null : _saveProfile,
                isLoading: _saving,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String placeholder,
    String? hint,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCD5EC), width: 2),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1235),
        ),
        decoration: InputDecoration(
          hintText: hint ?? placeholder,
          hintStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFFB5ACC9),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _languageChip({
    required String storedValue,
    required String label,
  }) {
    final current = _normalizedStoredLanguage(_user?.language);
    final isSelected = current == storedValue;

    return GestureDetector(
      onTap: _saving
          ? null
          : () {
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B2BE3) : Colors.white,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5B2BE3)
                : const Color(0xFFDCD5EC),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF3F1AAD)
                  : const Color(0xFFECE7F7),
              offset: const Offset(0, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : const Color(0xFF3D2E66),
          ),
        ),
      ),
    );
  }

  Widget _ghostButton({required String label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFECE7F7), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFECE7F7),
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4A1FC7),
          ),
        ),
      ),
    );
  }

  Widget _solidButton({
    required String label,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF5B2BE3),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF3F1AAD),
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // ─── Logic helpers (unchanged) ─────────────────────────────────────────────

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

  String? _normalizedStoredLanguage(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == 'es') return 'Es';
    if (normalized == 'en') return 'En';
    return null;
  }
}
