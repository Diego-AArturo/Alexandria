import 'package:alexandria_movil/core/app_colors.dart';
import 'package:alexandria_movil/core/text_styles.dart';
import 'package:flutter/material.dart';

enum UnitStatus { completed, current, locked }

class UnitCard extends StatelessWidget {
  const UnitCard({
    super.key,
    required this.unitNumber,
    required this.title,
    required this.subtitle,
    required this.status,
    this.onTap,
  });

  /// Unit number shown on the leading badge.
  final int unitNumber;

  /// Main title for the unit.
  final String title;

  /// Short description for the unit.
  final String subtitle;

  /// Current status of the unit.
  final UnitStatus status;

  /// Optional callback when the card is tapped (disabled when locked).
  final VoidCallback? onTap;

  bool get _isLocked => status == UnitStatus.locked;
  bool get _isCurrent => status == UnitStatus.current;
  bool get _isCompleted => status == UnitStatus.completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: _isLocked ? 0.45 : 0.7);

    final borderColor = _isCurrent
        ? theme.colorScheme.primary
        : theme.dividerColor.withValues(alpha: 0.4);
    final fillColor = _isCurrent
        ? theme.colorScheme.primary.withValues(alpha: 0.08)
        : theme.colorScheme.surface;
    final shadowColor = _isCurrent
        ? theme.colorScheme.primary.withValues(alpha: 0.15)
        : AppColors.shadowLow;

    return Opacity(
      opacity: _isLocked ? 0.7 : 1,
      child: GestureDetector(
        onTap: _isLocked ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: _isCurrent ? 16 : 8,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildLeading(theme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMediumBold(
                        theme,
                        color: _isLocked ? onSurface.withValues(alpha: 0.75) : onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium(theme, color: muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                _isCurrent
                    ? Icons.play_arrow_rounded
                    : Icons.chevron_right_rounded,
                color: _isCurrent
                    ? theme.colorScheme.primary
                    : onSurface.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(ThemeData theme) {
    if (_isCompleted) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Icon(
          Icons.check_circle,
          color: Colors.green.shade600,
        ),
      );
    }

    final color = _isLocked
        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
        : theme.colorScheme.primary;
    final background = _isCurrent
        ? theme.colorScheme.primary.withValues(alpha: 0.16)
        : theme.colorScheme.surface;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: _isCurrent ? 0.8 : 0.5),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '$unitNumber',
        style: AppTextStyles.titleMediumBold(theme, color: color),
      ),
    );
  }
}
