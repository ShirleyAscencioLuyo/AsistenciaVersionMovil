import 'package:go_router/go_router.dart';
import 'package:scavontime/features/auth/auth.dart';
import 'package:scavontime/features/assistance/assistance.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ///* Auth Routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    ///* assistance Routes
    GoRoute(
      path: '/',
      builder: (context, state) => const AssistanceScreen(),
    ),
    GoRoute(
      path: '/student_screen',
      name: StudentScreen.name,
      builder: (context, state) => const StudentScreen(),
    ),
    GoRoute(
      path: '/teacher_screen',
      name: TeacherScreen.name,
      builder: (context, state) => const TeacherScreen(),
    ),
    GoRoute(
      path: '/student-assistance',
      name: StudentAssistanceScreen.name,
      builder: (context, state) => const StudentAssistanceScreen(),
    ),
    GoRoute(
      path: '/teacher-assistance',
      name: TeacherAssistanceScreen.name,
      builder: (context, state) => const TeacherAssistanceScreen(),
    ),
    GoRoute(
      path: '/ui-controls',
      name: UiControlsScreen.name,
      builder: (context, state) => const UiControlsScreen(),
    ),
    GoRoute(
      path: '/theme-changer',
      name: ThemeChangerScreen.name,
      builder: (context, state) => const ThemeChangerScreen(),
    ),
    GoRoute(
      path: '/tutorial',
      name: AppTutorialScreen.name,
      builder: (context, state) => const AppTutorialScreen(),
    ),
    GoRoute(
      path: '/snackbars',
      name: SnackbarScreen.name,
      builder: (context, state) => const SnackbarScreen(),
    ),
  ],
);
