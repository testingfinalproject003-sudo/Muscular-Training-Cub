import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
// import '../../core/constants/app_text_styles.dart';
// import '../../core/widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;
  
  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.fitness_center, label: 'Workout', path: '/home/workout'),
    _NavItem(icon: Icons.library_books, label: 'Library', path: '/home/library'),
    _NavItem(icon: Icons.home, label: 'Home', path: '/home'),
    _NavItem(icon: Icons.trending_up, label: 'Progress', path: '/home/progress'),
    _NavItem(icon: Icons.person, label: 'Profile', path: '/home/profile'),
  ];

  void _onTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
    context.go(_navItems[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    _currentIndex = _navItems.indexWhere((item) => location.startsWith(item.path));
    if (_currentIndex == -1) _currentIndex = 2;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground.withValues(alpha:0.9),
          border: const Border(
            top: BorderSide(color: AppColors.border),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final isSelected = _currentIndex == index;
                return GestureDetector(
                  onTap: () => _onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentPurple.withValues(alpha:0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _navItems[index].icon,
                          color: isSelected ? AppColors.glowColor : AppColors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _navItems[index].label,
                          style: TextStyle(
                            color: isSelected ? AppColors.glowColor : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  
  _NavItem({required this.icon, required this.label, required this.path});
}