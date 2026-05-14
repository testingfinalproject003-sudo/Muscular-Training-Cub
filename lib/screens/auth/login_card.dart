import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    HapticFeedback.mediumImpact();
    
    final authProvider = context.read<AuthProvider>();
    await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    
    if (!mounted) return;
    
    if (authProvider.isAuthenticated) {
      context.go('/home');
    } else if (authProvider.error != null) {
      _showError(authProvider.error!);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error.withValues(alpha:0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      enableGlow: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome Back',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Login to continue your fitness journey',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 28),
            CustomTextField(
              label: 'Email',
              hint: 'Enter your email',
              controller: _emailController,
              validator: Validators.validateEmail,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Password',
              hint: 'Enter your password',
              controller: _passwordController,
              validator: Validators.validatePassword,
              obscureText: _obscurePassword,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot Password?',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.glowColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return GradientButton(
                  text: 'LOGIN',
                  isLoading: auth.isLoading,
                  onPressed: _login,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}