import 'package:flutter/material.dart';

/// Tema principal do app de reciclagem 🌿
/// Usa tons de verde e Material 3.
class AppTheme {
  final ThemeData themeData;

  AppTheme._(ColorScheme colorScheme)
      : themeData = ThemeData(
          colorScheme: colorScheme,
          useMaterial3: true,
          scaffoldBackgroundColor: colorScheme.surface,
          appBarTheme: AppBarTheme(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 0,
            centerTitle: true,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          cardTheme: CardThemeData(
            // um pouco mais escuro que a surface
            color: colorScheme.surfaceContainerHighest,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 1,
          ),
          textTheme: TextTheme(
            headlineLarge: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            bodyMedium: TextStyle(
              color: colorScheme.onSurface,
            ),
          ),
        );

  /// Tema claro 🌞
  factory AppTheme.light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.green.shade600,
      brightness: Brightness.light,
    );
    return AppTheme._(colorScheme);
  }

  /// Tema escuro 🌙
  factory AppTheme.dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.green.shade700,
      brightness: Brightness.dark,
    );
    return AppTheme._(colorScheme);
  }
}
