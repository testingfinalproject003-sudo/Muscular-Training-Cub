import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/animated_background.dart';
import 'login_card.dart';
import 'signup_card.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  bool _showLogin = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleCard() {
    HapticFeedback.mediumImpact();
    if (_showLogin) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      _showLogin = !_showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Text(
                'MTC',
                style: AppTextStyles.logo,
              ).animate()
                .fadeIn(duration: 800.ms)
                .slideY(begin: -0.5, end: 0, duration: 800.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 8),
              Text(
                'Muscles Training Club',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
              
              const SizedBox(height: 50),
              
              // Flip Card Container
             SizedBox(
  height: MediaQuery.of(context).size.height * 0.65,
  child: SingleChildScrollView(

                child: AnimatedBuilder(
                  animation: _flipController,
                  builder: (context, child) {
                    final angle = _flipController.value * 3.14159;
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      alignment: Alignment.center,
                      child: angle < 1.5708
                          ? const LoginCard()
                          : Transform(
                              transform: Matrix4.identity()..rotateY(3.14159),
                              alignment: Alignment.center,
                              child: const SignupCard(),
                            ),
                    );
                  },
                ),
              ).animate()
                .fadeIn(delay: 600.ms, duration: 800.ms)
                .slideY(begin: 0.3, end: 0, duration: 800.ms),
             ),
              
              const SizedBox(height: 24),
              
              // Toggle text
              GestureDetector(
                onTap: _toggleCard,
                child: RichText(
                  text: TextSpan(
                    text: _showLogin
                        ? "Don't have an account? "
                        : "Already have an account? ",
                    style: AppTextStyles.bodyMedium,
                    children: [
                      TextSpan(
                        text: _showLogin ? 'Sign Up' : 'Login',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.glowColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),
              
              const SizedBox(height: 20),
             
            ],
          ),
        ),
      ),
    );
  }
}