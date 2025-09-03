import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/routes/app_router.dart';
import 'dependency_injection.dart' as di;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/admin/controllers/admin_menu_controller.dart';
import 'presentation/home/controllers/home_menu_controller.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';

// Riverpod providers (use ChangeNotifierProvider for existing ChangeNotifier classes)
final adminMenuControllerProvider = ChangeNotifierProvider<AdminMenuController>(
    (ref) => di.sl<AdminMenuController>());
final homeMenuControllerProvider = ChangeNotifierProvider<HomeMenuController>(
    (ref) => di.sl<HomeMenuController>());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://nsqisssjauoycsxzounm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5zcWlzc3NqYXVveWNzeHpvdW5tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIyMjE4MzQsImV4cCI6MjA2Nzc5NzgzNH0.Y3TzKEu3t5xYiCMW7rPhI4Ol1cj-xsXogLfQyND1hDs',
  );
  di.init();
  runApp(ProviderScope(
    child: DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Food color palette
    const Color primaryRed = Color(0xFFEE341B); // #EE341B
    const Color accentOrange = Color(0xFFFD9C02); // #FD9C02
    const Color accentYellow = Color.fromRGBO(235, 224, 163, 1); // #FDD813
    const Color accentGreen = Color(0xFFB6D53C); // #B6D53C
    const Color darkBrown = Color(0xFF4E2E1E); // for text/icons

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryRed,
      onPrimary: Colors.white,
      secondary: accentOrange,
      onSecondary: Colors.white,
      error: Colors.red.shade700,
      onError: Colors.white,
      background: accentYellow,
      onBackground: darkBrown,
      surface: Colors.white,
      onSurface: darkBrown,
    );

    return MaterialApp(
      title: 'Digital Menu',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: accentYellow,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          elevation: 2,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentOrange,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryRed,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentGreen,
          foregroundColor: darkBrown,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          shadowColor: accentOrange.withOpacity(0.2),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: accentYellow.withOpacity(0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accentOrange),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryRed, width: 2),
          ),
          labelStyle: const TextStyle(color: darkBrown),
        ),
        textTheme: const TextTheme(
          headlineLarge:
              TextStyle(color: Color(0xFFEE341B), fontWeight: FontWeight.bold),
          headlineMedium:
              TextStyle(color: Color(0xFFFD9C02), fontWeight: FontWeight.bold),
          titleLarge:
              TextStyle(color: Color(0xFF4E2E1E), fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Color(0xFF4E2E1E)),
          bodyMedium: TextStyle(color: Color(0xFF4E2E1E)),
        ),
      ),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/',
      builder: DevicePreview.appBuilder,
      locale: DevicePreview.locale(context),
    );
  }
}

// NOTE: Providers moved to top of file above main()
