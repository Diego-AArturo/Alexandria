import 'package:alexandria_movil/components/home_shell.dart';
import 'package:alexandria_movil/components/unit_card.dart';
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

class _CourseHomeScreenState extends State<CourseHomeScreen>
    with WidgetsBindingObserver {
  final _courseService = CourseGenerationService();

  bool _isLoading = false;
  String? _error;
  List<_CourseOverview> _courses = const [];

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

  void _goToCraftTab() {
    context.findAncestorStateOfType<HomeShellState>()?.switchToTab(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadCourses,
          color: const Color(0xFF5B2BE3),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Text(
                    l10n.courseHomeTitle,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1235),
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    _buildListItems(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildListItems() {
    if (_isLoading) {
      return [
        const SizedBox(height: 60),
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF5B2BE3)),
        ),
      ];
    }

    if (_error != null) {
      return [
        const SizedBox(height: 40),
        Center(
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
        const SizedBox(height: 24),
        _CreateCourseCard(onTap: _goToCraftTab, l10n: l10n),
      ];
    }

    final items = <Widget>[];

    if (_courses.isEmpty) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            l10n.courseHomeEmptyState,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B5E8C),
            ),
          ),
        ),
      );
    }

    for (final course in _courses) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _CourseCard(
            title: course.title,
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
                    currentUnit: units.isEmpty ? 0 : 1,
                    totalUnits: units.length,
                    units: units,
                  ),
                ),
              );
              if (mounted) _loadCourses();
            },
          ),
        ),
      );
    }

    items.add(_CreateCourseCard(onTap: _goToCraftTab, l10n: l10n));

    return items;
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────

class _CourseOverview {
  const _CourseOverview({
    required this.courseId,
    required this.title,
    required this.completionPercentage,
  });

  final int courseId;
  final String title;
  final double completionPercentage;
}

// ─── Course card ──────────────────────────────────────────────────────────────

class _CourseCard extends StatefulWidget {
  const _CourseCard({
    required this.title,
    required this.completionPercentage,
    this.onTap,
  });

  final String title;
  final double completionPercentage;
  final VoidCallback? onTap;

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final progress =
        (widget.completionPercentage.clamp(0, 100) / 100).toDouble();
    final pctLabel =
        '${widget.completionPercentage.clamp(0, 100).round()}%';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: _pressed
            ? Matrix4.translationValues(0, 2, 0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFECE7F7), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFECE7F7),
              offset: Offset(0, _pressed ? 1 : 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ArtBlock(size: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1235),
                        letterSpacing: -0.4,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _ProgressBar(value: progress)),
                        const SizedBox(width: 10),
                        Text(
                          pctLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF6B5E8C),
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
    );
  }
}

// ─── Create course dashed card ────────────────────────────────────────────────

class _CreateCourseCard extends StatefulWidget {
  const _CreateCourseCard({required this.onTap, required this.l10n});

  final VoidCallback onTap;
  final AppLocalizations l10n;

  @override
  State<_CreateCourseCard> createState() => _CreateCourseCardState();
}

class _CreateCourseCardState extends State<_CreateCourseCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _pressed ? 0.75 : 1.0,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: const Color(0xFFC7B0FF),
            radius: 22,
            strokeWidth: 2.5,
            dashLength: 8,
            dashGap: 5,
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                _ArtBlock(
                  size: 56,
                  icon: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.l10n.craftCourseTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1235),
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.l10n.craftCourseToastEmptyPrompt,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B5E8C),
                        ),
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

// ─── Shared art block ─────────────────────────────────────────────────────────

class _ArtBlock extends StatelessWidget {
  const _ArtBlock({required this.size, this.icon});

  final double size;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF5B2BE3),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF3F1AAD),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: icon ??
          Transform.scale(
            scale: 1.35,
            child: Image.asset(
              'assets/splash/splash.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
              color: Colors.white,
              colorBlendMode: BlendMode.srcATop,
            ),
          ),
    );
  }
}

// ─── Progress bar ─────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFE2D6FF),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B38F2), Color(0xFF4A1FC7)],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dashed border painter ────────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashGap,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final half = strokeWidth / 2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(half, half, size.width - strokeWidth,
              size.height - strokeWidth),
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashLength),
          paint,
        );
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.dashLength != dashLength ||
      old.dashGap != dashGap;
}

// ─── Unit mapping (unchanged) ─────────────────────────────────────────────────

List<CourseUnit> _mapUnits(
    AppLocalizations l10n, CourseGenerationResponse data) {
  final unitsList =
      (data.units['units'] as List?)?.cast<Map>() ?? const [];
  if (unitsList.isEmpty) return const [];

  return unitsList.asMap().entries.map((entry) {
    final idx = entry.key;
    final raw = Map<String, dynamic>.from(entry.value);
    final title = raw['unit_title']?.toString().isNotEmpty == true
        ? raw['unit_title'].toString()
        : l10n.unitNumberLabel(idx + 1);
    final subtitle = raw['description']?.toString() ??
        (raw['objectives'] is List &&
                (raw['objectives'] as List).isNotEmpty
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
