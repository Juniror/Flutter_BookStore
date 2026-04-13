import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:palette/palette.dart';

/// A singleton service for managing and persisting the application's [ThemeMode] and color palette.
class ThemeService {
  ThemeService._internal();
  static final ThemeService instance = ThemeService._internal();

  static const String _themeModeKey = 'theme_mode';
  static const String _paletteKey = 'color_palette';

  late SharedPreferences _prefs;
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
  
  /// The current color palette (defaults to a blue-centric scheme)
  final ValueNotifier<List<Color>> currentPalette = ValueNotifier<List<Color>>([
    const Color(0xFF2563EB),
    const Color(0xFF3B82F6),
    const Color(0xFF60A5FA),
  ]);

  /// Initializes the service and loads persisted settings.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Load persisted theme mode
    final savedMode = _prefs.getString(_themeModeKey);
    if (savedMode != null) {
      themeMode.value = ThemeMode.values.firstWhere(
        (m) => m.name == savedMode,
        orElse: () => ThemeMode.system,
      );
    }

    // Load persisted palette (list of int values)
    final savedPalette = _prefs.getStringList(_paletteKey);
    if (savedPalette != null && savedPalette.isNotEmpty) {
      currentPalette.value = savedPalette.map((s) => Color(int.parse(s))).toList();
    }
  }

  bool get isDarkMode {
    if (themeMode.value == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return themeMode.value == ThemeMode.dark;
  }

  Future<void> toggleTheme() async {
    if (isDarkMode) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _prefs.setString(_themeModeKey, mode.name);
  }

  /// Update the current palette and persist it.
  Future<void> setPalette(List<Color> colors) async {
    currentPalette.value = List.from(colors);
    await _prefs.setStringList(
      _paletteKey, 
      colors.map((c) => c.toARGB32().toString()).toList(),
    );
  }

  /// Generate a random coordinated color palette.
  Future<void> randomizePalette() async {
    // Generate a new random palette using the pure Dart palette package
    final palette = ColorPalette.random(5);
    
    // Manually convert each ColorModel to a Flutter Color
    final flutterColors = palette.map((cm) {
      final rgb = cm.toRgbColor();
      return Color.fromARGB(
        255, 
        rgb.red.toInt(), 
        rgb.green.toInt(), 
        rgb.blue.toInt(),
      );
    }).toList();
    
    await setPalette(flutterColors);
  }
}
