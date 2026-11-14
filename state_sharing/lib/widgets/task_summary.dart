import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../models/rebuild_tracker.dart';
import '../models/user_profile.dart';
import '../data/initial_data.dart';
import '../state/change_notifier_state.dart';
import '../theme/app_theme.dart';
import 'rebuild_flash.dart';

/// Bảng tổng quan tiến độ công việc và nhật ký hoạt động (Task Summary & Analytics).
class TaskSummary extends StatelessWidget {
  final List<TaskItem> tasks;
  final UserProfile profile;
  final List<TaskActivity> activities;
  final VoidCallback onCompleteAll;
  final VoidCallback onResetAll;
  final bool isConnected;
  final bool isDeveloperMode;
  final bool isPropDrilling;

  const TaskSummary({
    super.key,
    required this.tasks,
    required this.profile,
    required this.activities,
    required this.onCompleteAll,
    required this.onResetAll,
    this.isConnected = true,
    this.isDeveloperMode = false,
    this.isPropDrilling = false,
  });

  @override
  Widget build(BuildContext context) {
    RebuildTracker.instance.record('TaskSummary');

    final completedCount = tasks.where((t) => t.isCompleted).length;
    final totalCount = tasks.length;
    final double completionRate = totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;
    final isAllDone = totalCount > 0 && completedCount == totalCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Thẻ Tiến độ tổng quan nổi bật (depth: 2)
        RebuildFlash(
          tag: 'TaskProgress',
          depth: 2,
          enabled: isDeveloperMode,
          borderRadius: AppRadius.radius8,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.radius8,
              border: Border.all(
                color: isAllDone ? AppColors.primaryBorder : AppColors.border,
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    Text(
                      'TIẾN ĐỘ CÔNG VIỆC',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: AppTextStyles.captionMedium.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: isAllDone ? AppColors.primaryLight : AppColors.background,
                        borderRadius: AppRadius.radius8,
                      ),
                      child: Text(
                        isAllDone ? 'Đã hoàn tất 100%' : '$completedCount/$totalCount đã xong',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: AppTextStyles.caption.copyWith(
                          color: isAllDone ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${(completionRate * 100).toInt()}%',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: AppTextStyles.h1.copyWith(
                        color: isAllDone ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Mục tiêu: $totalCount việc trong tuần',
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm + 4.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: LinearProgressIndicator(
                    value: completionRate,
                    minHeight: 6.0,
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Sparkline đồ họa tiến độ các ngày gần đây
                SizedBox(
                  height: 32.0,
                  width: double.infinity,
                  child: TaskSparklineChart(completionRate: completionRate),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // 2. Phân bổ tiến độ theo danh mục (depth: 2)
        RebuildFlash(
          tag: 'TaskDistribution',
          depth: 2,
          enabled: isDeveloperMode,
          borderRadius: AppRadius.radius8,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.radius8,
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phân bổ theo danh mục',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm + 2.0),
                ...InitialData.categories.map((cat) {
                  final catTasks = tasks.where((t) => t.category == cat);
                  final catDone = catTasks.where((t) => t.isCompleted).length;
                  final double ratio = catTasks.isNotEmpty ? (catDone / catTasks.length).clamp(0.0, 1.0) : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                cat,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: AppTextStyles.caption,
                              ),
                            ),
                            Text(
                              '$catDone/${catTasks.length} (${(ratio * 100).toInt()}%)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: AppTextStyles.captionMedium.copyWith(
                                color: ratio == 1.0 ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2.0),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 4.0,
                            backgroundColor: AppColors.background,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ratio == 1.0 ? AppColors.primary : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // 3. Nhật ký hoạt động gần nhất (depth: 2)
        RebuildFlash(
          tag: 'TaskActivityLog',
          depth: 2,
          enabled: isDeveloperMode,
          borderRadius: AppRadius.radius8,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.radius8,
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    const Text(
                      'Nhật ký hoạt động',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: AppTextStyles.bodyMedium,
                    ),
                    Wrap(
                      spacing: 4.0,
                      children: [
                        TextButton(
                          onPressed: onCompleteAll,
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            foregroundColor: AppColors.primary,
                          ),
                          child: const Text('Xong hết', style: AppTextStyles.captionMedium),
                        ),
                        TextButton(
                          onPressed: onResetAll,
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            foregroundColor: AppColors.textSecondary,
                          ),
                          child: const Text('Đặt lại', style: AppTextStyles.caption),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                if (activities.isEmpty)
                  const Text('Chưa có hoạt động nào', style: AppTextStyles.caption)
                else
                  ...activities.take(4).map(
                    (act) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(act.icon, size: 14.0, color: act.iconColor),
                          const SizedBox(width: AppSpacing.xs + 2.0),
                          Expanded(
                            child: Text(
                              act.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Biểu đồ đường nhỏ (Sparkline) tiến độ
class TaskSparklineChart extends StatelessWidget {
  final double completionRate;

  const TaskSparklineChart({
    super.key,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TaskSparklinePainter(completionRate: completionRate),
    );
  }
}

class _TaskSparklinePainter extends CustomPainter {
  final double completionRate;

  _TaskSparklinePainter({required this.completionRate});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paintFill = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final paintDot = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final rawPoints = [
      0.2,
      0.35,
      0.30,
      0.50,
      0.45,
      0.65,
      completionRate,
    ];

    final path = Path();
    final fillPath = Path();
    final double stepX = size.width / (rawPoints.length - 1);

    for (int i = 0; i < rawPoints.length; i++) {
      final x = i * stepX;
      final y = size.height - (rawPoints[i] * (size.height - 8.0) + 4.0);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      if (i == rawPoints.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
        canvas.drawCircle(Offset(x, y), 3.0, paintDot);
      }
    }

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant _TaskSparklinePainter oldDelegate) {
    return oldDelegate.completionRate != completionRate;
  }
}
