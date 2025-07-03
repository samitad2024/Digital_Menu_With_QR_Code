import 'package:flutter/material.dart';
import '../home/views/home_page.dart';
import '../admin/views/admin_dashboard_screen.dart';
import '../admin/views/admin_login_screen.dart';
import '../admin/views/admin_menu_item_form_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/admin':
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case '/admin/login':
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());
      case '/admin/menu_item_form':
        return MaterialPageRoute(
            builder: (_) => const AdminMenuItemFormScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
