import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/user_provider.dart';
// import 'services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error (app will run in demo mode): $e');
  }
  
 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        
        ChangeNotifierProvider(
  create: (_) {
    final auth = AuthProvider();
    auth.refreshAuthState();
    return auth;
  },
),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp.router(
        title: 'Muscles Training Club',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}