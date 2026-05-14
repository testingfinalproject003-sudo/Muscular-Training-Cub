import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final double borderRadius;
  final List<Color>? gradientColors;
  final bool isLoading;
  final Widget? icon;
  final TextStyle? textStyle;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width = double.infinity,
    this.height = 56,
    this.borderRadius = 16,
    this.gradientColors,
    this.isLoading = false,
    this.icon,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : () {
        HapticFeedback.mediumImpact();
        onPressed?.call();
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors ?? [
              AppColors.accentPurple,
              AppColors.accentViolet,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: (gradientColors?.first ?? AppColors.accentPurple).withValues(alpha:0.4),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.textPrimary,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: textStyle ?? const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}