import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/supabase_client.dart';
import '../providers/auth_provider.dart';
import '../views/intro/intro_screen.dart';
import '../views/prototype/prototype_shell.dart';
import '../views/admin/admin_shell.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/dashboard/dashboard_shell.dart';
import '../views/volunteer/volunteer_shell.dart';

enum AppRole { volunteer, ngoAdmin }

class AppRouter {
  static const intro = '/';
  static const prototype = '/prototype';
  static const login = '/login';
  static const register = '/register';
  static const volunteer = '/volunteer';
  static const admin = '/admin';
  static const dashboard = '/dashboard';

  static GoRouter build(AuthState auth) {
    return GoRouter(
      initialLocation: intro,
      refreshListenable: auth,
      redirect: (context, state) {
        // Demo / prototype mode (no Supabase keys): keep the app navigable.
        if (!AppSupabase.isInitialized) {
          final ok = state.matchedLocation == intro ||
              state.matchedLocation == prototype ||
              state.matchedLocation == login ||
              state.matchedLocation == register;
          return ok ? null : prototype;
        }

        final isAuthed = auth.session != null;
        final isPublicRoute = state.matchedLocation == intro ||
            state.matchedLocation == prototype ||
            state.matchedLocation == login ||
            state.matchedLocation == register;

        if (!isAuthed) {
          return isPublicRoute ? null : login;
        }

        if (isPublicRoute) {
          // Default landing: role based; fall back to volunteer shell.
          final role = auth.role;
          if (role == AppRole.ngoAdmin) return admin;
          return volunteer;
        }

        // Role gates
        final role = auth.role;
        final isAdminRoute = state.matchedLocation.startsWith(admin);
        if (isAdminRoute && role != AppRole.ngoAdmin) return volunteer;

        return null;
      },
      routes: [
        GoRoute(
          path: intro,
          builder: (context, state) => const IntroScreen(),
        ),
        GoRoute(
          path: prototype,
          builder: (context, state) => const PrototypeShell(),
        ),
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: volunteer,
          builder: (context, state) => const VolunteerShell(),
        ),
        GoRoute(
          path: dashboard,
          builder: (context, state) => const DashboardShell(),
        ),
        GoRoute(
          path: admin,
          builder: (context, state) => const AdminShell(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text(state.error.toString())),
      ),
    );
  }
}

