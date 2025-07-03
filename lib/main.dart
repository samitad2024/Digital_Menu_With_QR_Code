import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'presentation/routes/app_router.dart';
import 'dependency_injection.dart' as di;
import 'package:provider/provider.dart';
import 'presentation/admin/controllers/admin_menu_controller.dart';
import 'presentation/home/controllers/home_menu_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  di.init();
  runApp(const MyApp());
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
      ),
    );
  }
}
