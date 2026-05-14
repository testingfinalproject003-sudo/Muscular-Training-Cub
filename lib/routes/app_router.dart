import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/workout/workout_planner_screen.dart';
import '../screens/workout/workout_detail_screen.dart';
import '../screens/workout/active_workout_screen.dart';
import '../screens/workout/create_workout_screen.dart';
import '../screens/workout/workout_history_screen.dart';
import '../screens/exercise_library/exercise_library_screen.dart';
import '../screens/exercise_library/exercise_detail_screen.dart';
import '../screens/tracking/progress_screen.dart';
import '../screens/tracking/charts_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/bmi_screen.dart';
import '../screens/ai/ai_coach_screen.dart';
import '../screens/workout/workout_generator_screen.dart';
import '../screens/diet/diet_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const WorkoutPlannerScreen(),
          ),
          GoRoute(
            path: '/home/workout',
            builder: (context, state) => const WorkoutPlannerScreen(),
          ),
          GoRoute(
            path: '/home/library',
            builder: (context, state) => const ExerciseLibraryScreen(),
          ),
          GoRoute(
            path: '/home/progress',
            builder: (context, state) => const ProgressScreen(),
          ),
          GoRoute(
            path: '/home/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/workout/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return WorkoutDetailScreen(workoutId: id);
        },
      ),
      GoRoute(
        path: '/active-workout/:workoutId',
        builder: (context, state) {
          final workoutId = state.pathParameters['workoutId']!;
          return ActiveWorkoutScreen(workoutId: workoutId);
        },
      ),
      GoRoute(
        path: '/create-workout',
        builder: (context, state) => const CreateWorkoutScreen(),
      ),
      GoRoute(
        path: '/exercise/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ExerciseDetailScreen(exerciseId: id);
        },
      ),
      GoRoute(
        path: '/ai-coach',
        builder: (context, state) => const AICoachScreen(),
      ),
      GoRoute(
        path: '/workout-generator',
        builder: (context, state) => const WorkoutGeneratorScreen(),
      ),
      GoRoute(
        path: '/diet',
        builder: (context, state) => const DietScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/bmi',
        builder: (context, state) => const BMIScreen(),
      ),
      GoRoute(
        path: '/charts',
        builder: (context, state) => const ChartsScreen(),
      ),
      // NEW: Workout History Screen
      GoRoute(
        path: '/workout-history',
        builder: (context, state) => const WorkoutHistoryScreen(),
      ),
    ],
  );
}