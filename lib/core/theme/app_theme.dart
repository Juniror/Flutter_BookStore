import 'package:flutter/material.dart';

/// Defines the application's visual identity, including light and dark theme configurations.
class AppTheme {
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color secondaryEmerald = Color(0xFF10B981);

  /// Generates a [ThemeData] based on the provided [palette] and [isDark] mode.
  static ThemeData getTheme(List<Color> palette, bool isDark) {
    if (palette.isEmpty) {
      palette = [primaryBlue, accentBlue, secondaryEmerald];
    }

    final seedColor = palette[0];
    final brightness = isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      primaryColor: seedColor,
      extensions: [
        CustomGradients(
          primary: LinearGradient(
            colors: palette.length > 1
                ? palette.take(3).toList()
                : [seedColor, seedColor.withAlpha(150)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ],
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        primary: seedColor,
        secondary: palette.length > 1
            ? palette[1]
            : (isDark ? const Color(0xFF34D399) : secondaryEmerald),
        surface: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        onSurface: isDark ? Colors.white : const Color(0xFF0F172A),
        brightness: brightness,
      ),
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      iconTheme: IconThemeData(color: seedColor, size: 24),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: seedColor,
        unselectedItemColor: isDark ? Colors.white60 : const Color(0xFF94A3B8),
        selectedIconTheme: IconThemeData(color: seedColor, size: 26),
      ),
      chipTheme: ChipThemeData(
        selectedColor: seedColor,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        labelStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          letterSpacing: -1,
        ),
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        bodyLarge: TextStyle(
          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isDark
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
    );
  }
}

/// A theme extension for storing custom header gradients.
class CustomGradients extends ThemeExtension<CustomGradients> {
  final LinearGradient primary;

  const CustomGradients({required this.primary});

  @override
  CustomGradients copyWith({LinearGradient? primary}) {
    return CustomGradients(primary: primary ?? this.primary);
  }

  @override
  CustomGradients lerp(ThemeExtension<CustomGradients>? other, double t) {
    if (other is! CustomGradients) return this;
    return CustomGradients(
      primary: LinearGradient.lerp(primary, other.primary, t)!,
    );
  }
}
