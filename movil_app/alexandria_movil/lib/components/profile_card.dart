import 'package:flutter/material.dart';

/// Generic card used across the profile screen to keep styling consistent.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.child,
    this.padding,
  });

  final Widget? leading;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;

    final header = (leading != null || title != null || trailing != null)
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: leading!,
                )
              ],
              if (title != null || subtitle != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: bodyColor,
                          ),
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: bodyColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              if (trailing != null) trailing!,
            ],
          )
        : null;

    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null) header,
          if (header != null && child != null) const SizedBox(height: 16),
          if (child != null) child!,
        ],
      ),
    );
  }
}
