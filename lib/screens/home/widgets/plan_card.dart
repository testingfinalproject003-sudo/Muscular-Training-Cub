import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../models/ai_plan_model.dart';
import '../../../services/plan_service.dart';

class PlanCard extends StatefulWidget {
  final AIPlanModel plan;

  const PlanCard({super.key, required this.plan});

  @override
  State<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {
  bool _isExpanded = false;
  final PlanService _planService = PlanService();

  @override
  Widget build(BuildContext context) {
    final isPending = widget.plan.status == PlanStatus.pending;
    final isAccepted = widget.plan.status == PlanStatus.accepted;

    return GlassCard(
      enableGlow: isAccepted,
      glowColor: _getGlowColor(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor().withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(),
                  color: _getTypeColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plan.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getStatusText(),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: _getStatusColor(),
                      ),
                    ),
                  ],
                ),
              ),
              if (isPending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Preview or Full Content
          if (!_isExpanded) ...[
            Text(
              '${widget.plan.content.substring(0, 
                widget.plan.content.length > 100 ? 100 : widget.plan.content.length
              )}...',
              style: AppTextStyles.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _isExpanded = true),
              child: Text(
                'View Full Plan',
                style: TextStyle(color: AppColors.glowColor),
              ),
            ),
          ] else ...[
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: MarkdownBody(
                  data: widget.plan.content,
                  styleSheet: MarkdownStyleSheet(
                    h1: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
                    h2: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimary),
                    p: AppTextStyles.bodyLarge.copyWith(height: 1.6),
                    listBullet: AppTextStyles.bodyLarge.copyWith(color: AppColors.glowColor),
                    tableHead: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.glowColor,
                    ),
                    tableBody: AppTextStyles.bodyMedium,
                    blockquote: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _isExpanded = false),
              child: Text(
                'Show Less',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],

          // Action Buttons for Pending Plans
          if (isPending) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptPlan(),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success.withValues(alpha:0.2),
                      foregroundColor: AppColors.success,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectPlan(),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error.withValues(alpha:0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Accepted Plan Actions
          if (isAccepted) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _markCompleted(),
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text('Mark Completed'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: BorderSide(color: AppColors.success.withValues(alpha:0.3)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (widget.plan.type) {
      case PlanType.workout:
        return AppColors.accentPurple;
      case PlanType.diet:
        return AppColors.success;
      case PlanType.general:
        return AppColors.accentViolet;
    }
  }

  Color _getGlowColor() {
    switch (widget.plan.status) {
      case PlanStatus.pending:
        return AppColors.warning;
      case PlanStatus.accepted:
        return AppColors.success;
      default:
        return AppColors.accentViolet;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.plan.type) {
      case PlanType.workout:
        return Icons.fitness_center;
      case PlanType.diet:
        return Icons.restaurant_menu;
      case PlanType.general:
        return Icons.auto_awesome;
    }
  }

  String _getStatusText() {
    switch (widget.plan.status) {
      case PlanStatus.pending:
        return 'Pending Approval';
      case PlanStatus.accepted:
        return 'Active Plan';
      case PlanStatus.rejected:
        return 'Declined';
      case PlanStatus.completed:
        return 'Completed';
    }
  }

  Color _getStatusColor() {
    switch (widget.plan.status) {
      case PlanStatus.pending:
        return AppColors.warning;
      case PlanStatus.accepted:
        return AppColors.success;
      case PlanStatus.rejected:
        return AppColors.error;
      case PlanStatus.completed:
        return AppColors.textSecondary;
    }
  }

  Future<void> _acceptPlan() async {
    HapticFeedback.mediumImpact();
    try {
      await _planService.acceptPlan(widget.plan.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan accepted! Let\'s get to work! 💪'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to accept plan');
    }
  }

  Future<void> _rejectPlan() async {
    HapticFeedback.mediumImpact();
    try {
      await _planService.rejectPlan(widget.plan.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan declined'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to decline plan');
    }
  }

  Future<void> _markCompleted() async {
    HapticFeedback.mediumImpact();
    try {
      await _planService.completePlan(widget.plan.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Congratulations! Plan completed! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to complete plan');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}