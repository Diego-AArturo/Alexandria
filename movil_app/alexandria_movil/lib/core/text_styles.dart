import 'package:flutter/material.dart';


class AppTextStyles {
  const AppTextStyles._();

  static TextStyle headingLarge(ThemeData theme, {Color? color}) {
    final base = theme.textTheme.headlineMedium ??
        const TextStyle(fontSize: 28, fontWeight: FontWeight.w700);
    return base.copyWith(
      fontWeight: FontWeight.w800,
      color: color ?? theme.colorScheme.onSurface,
    );
  }

  static TextStyle bodyLarge(ThemeData theme, {Color? color}) {
    final base = theme.textTheme.bodyLarge ??
        const TextStyle(fontSize: 16, height: 1.4);
    return base.copyWith(
      color: color ?? theme.colorScheme.onSurface,
    );
  }

  static TextStyle bodyLargeMuted(
    ThemeData theme, {
    Color? color,
    double alpha = 0.75,
  }) {
    final mutedColor =
        color ?? theme.colorScheme.onSurface.withValues(alpha: alpha);
    return bodyLarge(theme, color: mutedColor);
  }

  static TextStyle titleLargeBold(ThemeData theme, {Color? color}) {
    final base = theme.textTheme.titleLarge ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
    return base.copyWith(
      fontWeight: FontWeight.w700,
      color: color ?? theme.colorScheme.onSurface,
    );
  }

  static TextStyle titleMediumBold(ThemeData theme, {Color? color}) {
    final base = theme.textTheme.titleMedium ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    return base.copyWith(
      fontWeight: FontWeight.w700,
      color: color ?? theme.colorScheme.onSurface,
    );
  }

  static TextStyle bodyMedium(ThemeData theme, {Color? color}) {
    final base = theme.textTheme.bodyMedium ??
        const TextStyle(fontSize: 14, height: 1.4);
    return base.copyWith(
      color: color ?? theme.colorScheme.onSurface,
    );
  }

  static TextStyle bodyMediumMuted(
    ThemeData theme, {
    Color? color,
    double alpha = 0.6,
  }) {
    final mutedColor =
        color ?? theme.colorScheme.onSurface.withValues(alpha: alpha);
    return bodyMedium(theme, color: mutedColor);
  }

  static TextStyle bodyMediumBold(ThemeData theme, {Color? color}) {
    return bodyMedium(
      theme,
      color: color,
    ).copyWith(fontWeight: FontWeight.w600);
  }

  static TextStyle statValue(ThemeData theme, {Color? color}) {
    final base = theme.textTheme.displaySmall ??
        const TextStyle(fontSize: 34, fontWeight: FontWeight.w600);
    return base.copyWith(
      fontWeight: FontWeight.w700,
      color: color ?? theme.colorScheme.onSurface,
    );
  }
}
