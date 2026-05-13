import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/landing_page.dart';
import '../features/auth/admin_login_page.dart';
import '../features/auth/user_login_page.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/user/user_dashboard.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');

    final path = state.uri.toString();
    final isAuthRoute =
        path == '/' || path == '/user-login' || path == '/admin-login';

    if (token == null && !isAuthRoute) return '/';
    if (token != null && isAuthRoute) {
      return role == 'admin' ? '/admin' : '/user';
    }

    if (token != null && role == 'admin' && path == '/user') {
      return '/admin';
    }

    if (token != null && role == 'user' && path == '/admin') {
      return '/user';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingPage()),
    GoRoute(
      path: '/user-login',
      builder: (context, state) => const UserLoginPage(),
    ),
    GoRoute(
      path: '/admin-login',
      builder: (context, state) => const AdminLoginPage(),
    ),
    GoRoute(path: '/user', builder: (context, state) => const UserDashboard()),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboard(),
    ),
  ],
);
