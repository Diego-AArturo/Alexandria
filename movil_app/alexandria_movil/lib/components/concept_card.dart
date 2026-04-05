import 'package:alexandria_movil/core/app_colors.dart';
import 'package:alexandria_movil/core/text_styles.dart';
import 'package:flutter/material.dart';

class ConceptCard extends StatelessWidget {
  const ConceptCard({
    super.key,
    this.title,
    required this.body,
    this.bulletPoints = const [],
  });

  /// Optional title shown above the concept body.
  final String? title;

  /// Main explanatory text (can include line breaks).
  final String body;

  /// Optional list of bullet points to emphasize examples/details.
  final List<String> bulletPoints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: 0.35)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.trim().isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.menu_book_rounded, color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title!,
                    style: AppTextStyles.titleLargeBold(theme, color: primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ] else ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.menu_book_rounded, color: primary),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            body,
            style: AppTextStyles.bodyLarge(theme),
          ),
          if (bulletPoints.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...bulletPoints.map(
              (point) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Text(
                        point,
                        style: AppTextStyles.bodyLarge(theme),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
