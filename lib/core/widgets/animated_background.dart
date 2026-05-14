import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final int orbCount;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.orbCount = 5,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final List<OrbData> _orbs = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _animations = [];

    for (int i = 0; i < widget.orbCount; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: 10 + _random.nextInt(20)),
      );
      
      final animation = Tween<double>(begin: 0, end: 2 * pi).animate(
        CurvedAnimation(parent: controller, curve: Curves.linear),
      );
      
      _controllers.add(controller);
      _animations.add(animation);
      
      _orbs.add(OrbData(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 100 + _random.nextDouble() * 200,
        color: [
          AppColors.accentPurple.withValues(alpha:0.15),
          AppColors.accentViolet.withValues(alpha:0.1),
          AppColors.glowColor.withValues(alpha:0.08),
        ][_random.nextInt(3)],
        speed: 0.3 + _random.nextDouble() * 0.7,
        offset: _random.nextDouble() * 2 * pi,
      ));
      
      controller.repeat();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Base background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBackground,
                  AppColors.secondaryBackground,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Animated orbs
          ...List.generate(widget.orbCount, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                final orb = _orbs[index];
                final anim = _animations[index].value;
                
                return Positioned(
                  left: (orb.x + sin(anim * orb.speed + orb.offset) * 0.1) *
                      MediaQuery.of(context).size.width -
                      orb.size / 2,
                  top: (orb.y + cos(anim * orb.speed + orb.offset) * 0.1) *
                      MediaQuery.of(context).size.height -
                      orb.size / 2,
                  child: Container(
                    width: orb.size,
                    height: orb.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: orb.color,
                    ),
                  ),
                );
              },
            );
          }),
          // Content
          widget.child,
        ],
      ),
    );
  }
}

class OrbData {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double speed;
  final double offset;

  OrbData({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
    required this.offset,
  });
}