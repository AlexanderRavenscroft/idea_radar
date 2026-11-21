import 'package:flutter/material.dart';
import 'package:idea_radar/theme/app_colors.dart';
import 'package:idea_radar/theme/app_radius.dart';
import 'package:idea_radar/theme/app_spacing.dart';

abstract final class AppTheme {
  static const FontWeight navigationLabelWeight = FontWeight.w500;
  static const FontWeight selectedNavigationLabelWeight = FontWeight.w700;

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.onPrimary,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      surface: AppColors.surface,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      error: AppColors.error,
      onError: AppColors.onError,
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(
      height: 72,
      padding: EdgeInsets.zero,
    ),
    inputDecorationTheme: const InputDecorationThemeData(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.xs)),
      ),
    ),
    tooltipTheme: const TooltipThemeData(
      preferBelow: false,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      textStyle: TextStyle(color: AppColors.onSurface, fontSize: 12),
    ),
  );
}
