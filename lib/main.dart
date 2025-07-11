import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/routes/app_router.dart';
import 'dependency_injection.dart' as di;
import 'package:provider/provider.dart';
import 'presentation/admin/controllers/admin_menu_controller.dart';
import 'presentation/home/controllers/home_menu_controller.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://nsqisssjauoycsxzounm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5zcWlzc3NqYXVveWNzeHpvdW5tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIyMjE4MzQsImV4cCI6MjA2Nzc5NzgzNH0.Y3TzKEu3t5xYiCMW7rPhI4Ol1cj-xsXogLfQyND1hDs',
  );
  di.init();
  runApp(DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AdminMenuController>()),
        ChangeNotifierProvider(create: (_) => di.sl<HomeMenuController>()),
      ],
      child: MaterialApp(
        title: 'Digital Menu',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/',
        builder: DevicePreview.appBuilder,
        locale: DevicePreview.locale(context),
      ),
    );
  }
}
