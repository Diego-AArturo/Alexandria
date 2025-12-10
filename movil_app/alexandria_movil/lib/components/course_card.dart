import 'package:flutter/material.dart';

class CourseCard extends StatefulWidget {
  const CourseCard({
    super.key,
    required this.title,
    required this.description,
    required this.currentUnit,
    required this.totalUnits,
    this.onTap,
  });

  /// Title of the course shown at the top of the card.
  final String title;

  /// Short description for the course.
  final String description;

  /// Current unit number the learner is in.
  final int currentUnit;

  /// Total units the course has.
  final int totalUnits;

  /// Optional callback fired when the card is tapped.
  final VoidCallback? onTap;

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _isHovered = false;

  void _setHover(bool hover) {
    if (_isHovered == hover) return;
    setState(() => _isHovered = hover);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rawProgress = widget.totalUnits == 0
        ? 0.0
        : widget.currentUnit / widget.totalUnits;
    final clampedProgress =
        double.parse(rawProgress.clamp(0.0, 1.0).toStringAsFixed(2));
    final percentLabel = '${(clampedProgress * 100).round()}%';
    final unitsLabel = 'Unit ${widget.currentUnit} of ${widget.totalUnits}';
    final titleColor = _isHovered
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface;

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        onTapDown: (_) => _setHover(true),
        onTapCancel: () => _setHover(false),
        onTapUp: (_) => _setHover(false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovered
                  ? theme.colorScheme.primary.withOpacity(0.4)
                  : theme.dividerColor.withOpacity(0.4),
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 24,
                    color: Colors.black45,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      unitsLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                  Text(
                    percentLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: clampedProgress,
                  minHeight: 8,
                  backgroundColor:
                      theme.colorScheme.primary.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
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
