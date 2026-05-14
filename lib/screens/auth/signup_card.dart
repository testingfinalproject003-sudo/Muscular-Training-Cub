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

class SignupCard extends StatefulWidget {
  const SignupCard({super.key});

  @override
  State<SignupCard> createState() => _SignupCardState();
}

class _SignupCardState extends State<SignupCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  
  String _gender = 'male';
  String _fitnessGoal = 'maintain';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    
    HapticFeedback.mediumImpact();
    
    final authProvider = context.read<AuthProvider>();
    await authProvider.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      height: double.parse(_heightController.text),
      weight: double.parse(_weightController.text),
      age: int.parse(_ageController.text),
      gender: _gender,
      fitnessGoal: _fitnessGoal,
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Get Started',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Create your account to begin',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Full Name',
                hint: 'Enter your name',
                controller: _nameController,
                validator: Validators.validateName,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email',
                hint: 'Enter your email',
                controller: _emailController,
                validator: Validators.validateEmail,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Password',
                hint: 'Min 8 chars, 1 uppercase, 1 number',
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Height (cm)',
                      hint: '175',
                      controller: _heightController,
                      validator: Validators.validateHeight,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.height),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Weight (kg)',
                      hint: '70',
                      controller: _weightController,
                      validator: Validators.validateWeight,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.fitness_center),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Age',
                      hint: '25',
                      controller: _ageController,
                      validator: Validators.validateAge,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.cake_outlined),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gender',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha:0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _gender,
                              isExpanded: true,
                              dropdownColor: AppColors.secondaryBackground,
                              style: const TextStyle(color: AppColors.textPrimary),
                              items: ['male', 'female'].map((g) => DropdownMenuItem(
                                value: g,
                                child: Text(g.toUpperCase()),
                              )).toList(),
                              onChanged: (v) => setState(() => _gender = v!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fitness Goal',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _fitnessGoal,
                        isExpanded: true,
                        dropdownColor: AppColors.secondaryBackground,
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: [
                          DropdownMenuItem(value: 'lose_weight', child: Text('Lose Weight')),
                          DropdownMenuItem(value: 'gain_muscle', child: Text('Gain Muscle')),
                          DropdownMenuItem(value: 'maintain', child: Text('Maintain')),
                        ],
                        onChanged: (v) => setState(() => _fitnessGoal = v!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return GradientButton(
                    text: 'SIGN UP',
                    isLoading: auth.isLoading,
                    onPressed: _signUp,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}