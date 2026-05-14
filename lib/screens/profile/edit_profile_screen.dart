import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
// import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/animated_background.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  late String _gender;
  late String _fitnessGoal;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _heightController = TextEditingController(text: user?.height.toString() ?? '');
    _weightController = TextEditingController(text: user?.weight.toString() ?? '');
    _ageController = TextEditingController(text: user?.age.toString() ?? '');
    _gender = user?.gender ?? 'male';
    _fitnessGoal = user?.fitnessGoal ?? 'maintain';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user == null) return;

    final updatedUser = user.copyWith(
      name: _nameController.text.trim(),
      height: double.parse(_heightController.text),
      weight: double.parse(_weightController.text),
      age: int.parse(_ageController.text),
      gender: _gender,
      fitnessGoal: _fitnessGoal,
      updatedAt: DateTime.now(),
    );

    await authProvider.updateProfile(updatedUser);

    if (!mounted) return;
    if (authProvider.error == null) {
      context.pop();
    } else {
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
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          title: Text('Edit Profile', style: AppTextStyles.headingSmall),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'Full Name',
                    controller: _nameController,
                    validator: Validators.validateName,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Height (cm)',
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
                          controller: _weightController,
                          validator: Validators.validateWeight,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.fitness_center),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Age',
                          controller: _ageController,
                          validator: Validators.validateAge,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.cake_outlined),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          'Gender',
                          _gender,
                          ['male', 'female'],
                          (v) => setState(() => _gender = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    'Fitness Goal',
                    _fitnessGoal,
                    ['lose_weight', 'gain_muscle', 'maintain'],
                    (v) => setState(() => _fitnessGoal = v!),
                    labels: {'lose_weight': 'Lose Weight', 'gain_muscle': 'Gain Muscle', 'maintain': 'Maintain'},
                  ),
                  const SizedBox(height: 30),
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      return GradientButton(
                        text: 'SAVE CHANGES',
                        isLoading: auth.isLoading,
                        onPressed: _saveProfile,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged, {Map<String, String>? labels}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.secondaryBackground,
              style: const TextStyle(color: AppColors.textPrimary),
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(labels?[item] ?? item.toUpperCase()),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}