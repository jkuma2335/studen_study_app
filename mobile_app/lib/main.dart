import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:calendar_view/calendar_view.dart' as calendar_view;
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/theme/theme_provider.dart';
import 'package:mobile_app/core/auth_state.dart';
import 'package:mobile_app/features/auth/screens/login_screen.dart';
import 'package:mobile_app/features/auth/screens/signup_screen.dart';
import 'package:mobile_app/features/auth/screens/splash_screen.dart';
import 'package:mobile_app/features/notes/domain/note_model.dart';
import 'package:mobile_app/features/notes/screens/note_editor_screen.dart';
import 'package:mobile_app/features/subjects/domain/subject.dart';
import 'package:mobile_app/home_screen.dart';
import 'package:mobile_app/features/subjects/presentation/screens/subject_detail_screen.dart';
import 'package:mobile_app/features/subjects/presentation/screens/add_subject_screen.dart';
import 'package:mobile_app/features/calendar/screens/calendar_screen.dart';
import 'package:mobile_app/features/timer/screens/timer_screen.dart';
import 'package:mobile_app/core/services/notification_service.dart';
import 'package:mobile_app/features/assignments/presentation/screens/add_edit_assignment_screen.dart';
import 'package:mobile_app/features/assignments/presentation/screens/assignment_detail_screen.dart';
import 'package:mobile_app/features/assignments/domain/assignment.dart';
import 'package:mobile_app/features/planner/domain/study_session.dart' as planner;
import 'package:mobile_app/features/analytics/screens/analytics_screen.dart';
import 'package:mobile_app/features/flashcards/screens/flashcard_decks_screen.dart';
import 'package:mobile_app/features/flashcards/screens/flashcard_deck_detail_screen.dart';
import 'package:mobile_app/features/flashcards/screens/flashcard_study_screen.dart';
import 'package:mobile_app/features/quiz/screens/quiz_screen.dart';

void main() async {
  // 1. Wake up hardware bindings (Crucial for plugins)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize notification service and request permissions
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Note: Offline sync (Isar) is only available on mobile/desktop, not web
  // For mobile builds, initialize DatabaseService, ConnectivityService, SyncManager

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Create router with authentication guarding
GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = ref.read(authProvider);
      final location = state.matchedLocation;
      final isGoingToSplash = location == '/';
      final isGoingToLogin = location == '/login';
      final isGoingToSignup = location == '/signup';
      
      // Public routes that don't require authentication
      final publicRoutes = ['/', '/login', '/signup'];
      final isPublicRoute = publicRoutes.contains(location);

      // If not logged in and trying to access a protected route, redirect to splash
      if (!isLoggedIn && !isPublicRoute) {
        return '/';
      }

      // If logged in and going to splash/login/signup, redirect to home
      if (isLoggedIn && (isGoingToSplash || isGoingToLogin || isGoingToSignup)) {
        return '/home';
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Splash screen (first screen users see)
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      // Home screen (main app)
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'subjects/add', // Becomes /subjects/add
            builder: (context, state) => const AddSubjectScreen(),
          ),
          GoRoute(
            path: 'analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: 'flashcards',
            builder: (context, state) => const FlashcardDecksScreen(),
          ),
          GoRoute(
            path: 'flashcards/deck/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return FlashcardDeckDetailScreen(deckId: id);
            },
          ),
          GoRoute(
            path: 'flashcards/study/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return FlashcardStudyScreen(deckId: id);
            },
          ),
          GoRoute(
            path: 'quiz/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return QuizScreen(quizId: id);
            },
          ),
          GoRoute(
            path: 'subjects/details', // Becomes /subjects/details
            builder: (context, state) {
              final subject = state.extra as Subject;
              return SubjectDetailScreen(subject: subject);
            },
          ),
          GoRoute(
            path: 'subjects/edit', // Becomes /home/subjects/edit
            builder: (context, state) {
              final subject = state.extra as Subject;
              return AddSubjectScreen(existingSubject: subject);
            },
          ),
          GoRoute(
            path: 'notes/editor', // Becomes /notes/editor
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              final note = extra['note'] as Note?;
              final subjectId = extra['subjectId'] as String;
              return NoteEditorScreen(
                subjectId: subjectId,
                existingNote: note,
              );
            },
          ),
          GoRoute(
            path: 'assignments/add',
            builder: (context, state) => const AddEditAssignmentScreen(),
          ),
          GoRoute(
            path: 'assignments/edit',
            builder: (context, state) {
              final assignment = state.extra as Assignment;
              return AddEditAssignmentScreen(assignment: assignment);
            },
          ),
          GoRoute(
            path: 'assignments/details',
            builder: (context, state) {
              final assignment = state.extra as Assignment;
              return AssignmentDetailScreen(assignment: assignment);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/timer',
        builder: (context, state) {
          // Check if extra is a StudySession (from planner) or Subject (legacy)
          final extra = state.extra;
          if (extra is planner.StudySession) {
            return TimerScreen(plannerSession: extra);
          } else if (extra is Subject) {
            return TimerScreen(subject: extra);
          }
          return const TimerScreen();
        },
      ),
      // Assignment routes (top-level for easy access)
      GoRoute(
        path: '/assignments/add',
        builder: (context, state) => const AddEditAssignmentScreen(),
      ),
      GoRoute(
        path: '/assignments/edit',
        builder: (context, state) {
          final assignment = state.extra as Assignment;
          return AddEditAssignmentScreen(assignment: assignment);
        },
      ),
      GoRoute(
        path: '/assignments/details',
        builder: (context, state) {
          final assignment = state.extra as Assignment;
          return AssignmentDetailScreen(assignment: assignment);
        },
      ),
      // Subject routes (top-level for easy access)
      GoRoute(
        path: '/subjects/add',
        builder: (context, state) => const AddSubjectScreen(),
      ),
      GoRoute(
        path: '/subjects/details',
        builder: (context, state) {
          final subject = state.extra as Subject;
          return SubjectDetailScreen(subject: subject);
        },
      ),
      GoRoute(
        path: '/subjects/edit',
        builder: (context, state) {
          final subject = state.extra as Subject;
          return AddSubjectScreen(existingSubject: subject);
        },
      ),
      // Notes routes (top-level for easy access)
      GoRoute(
        path: '/notes/editor',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final note = extra['note'] as Note?;
          final subjectId = extra['subjectId'] as String;
          return NoteEditorScreen(
            subjectId: subjectId,
            existingNote: note,
          );
        },
      ),
    ],
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize auth status check on app start
    ref.read(authProvider.notifier).checkLoginStatus();
    
    // Watch auth state to rebuild router when it changes
    ref.watch(authProvider);
    
    // Watch theme mode to rebuild when theme changes
    final themeMode = ref.watch(themeModeProvider);
    
    final router = createRouter(ref);

    return calendar_view.CalendarControllerProvider(
      controller: calendar_view.EventController(),
      child: MaterialApp.router(
        title: 'SmartStudy',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FlutterQuillLocalizations.delegate, // The critical missing piece
        ],
        supportedLocales: const [
          Locale('en', 'US'), // English
        ],
      ),
    );
  }
}
