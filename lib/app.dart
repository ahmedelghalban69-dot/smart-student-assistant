import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/subjects/presentation/subjects_screen.dart';
import 'features/subjects/presentation/subject_detail_screen.dart';
import 'features/tasks/presentation/tasks_screen.dart';
import 'features/planner/presentation/planner_screen.dart';
import 'features/timer/presentation/timer_screen.dart';
import 'features/ai_assistant/presentation/ai_screen.dart';
import 'features/library/presentation/library_screen.dart';
import 'features/search/presentation/search_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/profile/presentation/stats_screen.dart';
import 'shared/widgets/main_scaffold.dart';

final _router = GoRouter(
  initialLocation: '/onboarding',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool('onboarded') ?? false;
    final loggedIn = Supabase.instance.client.auth.currentUser != null;

    final loc = state.matchedLocation;
    if (!onboarded && loc != '/onboarding') return '/onboarding';
    if (onboarded && !loggedIn && loc != '/login') return '/login';
    if (loggedIn && (loc == '/login' || loc == '/onboarding')) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/planner', builder: (_, __) => const PlannerScreen()),
        GoRoute(path: '/subjects', builder: (_, __) => const SubjectsScreen()),
        GoRoute(path: '/ai', builder: (_, __) => const AIScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),
    GoRoute(
      path: '/subjects/:id',
      builder: (_, s) => SubjectDetailScreen(subjectId: s.pathParameters['id']!),
    ),
    GoRoute(path: '/tasks', builder: (_, __) => const TasksScreen()),
    GoRoute(path: '/timer', builder: (_, __) => const StudyTimerScreen()),
    GoRoute(path: '/library', builder: (_, __) => const LibraryScreen()),
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
    GoRoute(path: '/stats', builder: (_, __) => const StatsScreen()),
  ],
);

class SmartStudentApp extends StatelessWidget {
  const SmartStudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'مساعد الطالب الذكي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}
