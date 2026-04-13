import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/pages/login_page.dart';
import 'core/navigation/main_navigator.dart';
import 'features/auth/services/auth_service.dart';
import 'core/theme/theme_service.dart';

/// Application entry point. Performs initialization and runs the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ThemeService.instance.init();
  runApp(const MyApp());
}

/// The root widget of the Book Library application.
/// Manages theme and sets up the initial navigation.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeMode,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<List<Color>>(
          valueListenable: ThemeService.instance.currentPalette,
          builder: (context, currentPalette, child) {
            return MaterialApp(
              title: 'Book Library',
              debugShowCheckedModeBanner: false,
              themeMode: themeMode,
              theme: AppTheme.getTheme(currentPalette, false),
              darkTheme: AppTheme.getTheme(currentPalette, true),
              home: AuthService.currentUser != null
                  ? const MainNavigator()
                  : const LoginPage(),
            );
          },
        );
      },
    );
  }
}
