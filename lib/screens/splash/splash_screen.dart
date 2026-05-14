import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:muscular_training_club/core/constants/app_colors.dart';
import 'package:muscular_training_club/core/constants/app_text_styles.dart';
import 'package:muscular_training_club/core/widgets/animated_background.dart';
import 'package:muscular_training_club/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );
    
    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    );

    _startAnimation();
  }

  void _startAnimation() async {
  await Future.delayed(const Duration(milliseconds: 500));
  if (!mounted) return; // ✅ Guard 1
  _logoController.forward();
  
  await Future.delayed(const Duration(milliseconds: 800));
  if (!mounted) return; // ✅ Guard 2
  _textController.forward();
  
  await Future.delayed(const Duration(milliseconds: 2500));
  if (!mounted) return; // ✅ Guard 3
  
  // Store reference BEFORE async
  final authProvider = context.read<AuthProvider>();
  final prefs = await SharedPreferences.getInstance();
  
  if (!mounted) return; // ✅ Guard 4
  
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  
  if (authProvider.isAuthenticated || isLoggedIn) {
    context.go('/home');
  } else {
    context.go('/auth');
  }
}

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.accentPurple, AppColors.accentViolet],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.glowColor.withValues(alpha:0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'MTC',
                        style: AppTextStyles.orbitron.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ).animate()
                    .rotate(duration: 2000.ms, curve: Curves.easeInOut)
                    .then(delay: 500.ms),
                );
              },
            ),
            const SizedBox(height: 40),
            // Subtitle with typewriter effect
            AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _textAnimation.value,
                  child: Column(
                    children: [
                      Text(
                        'Muscles Training Club',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppColors.glowColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Train Smarter. Get Stronger.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 60),
            // Loading indicator
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withValues(alpha:0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.glowColor),
                borderRadius: BorderRadius.circular(10),
              ),
            ).animate().fadeIn(delay: 1000.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}