import 'package:flutter/material.dart';
import '../models/device_item.dart';
import '../models/rebuild_tracker.dart';
import '../models/user_profile.dart';
import '../data/initial_data.dart';
import '../state/change_notifier_state.dart';
import '../theme/app_theme.dart';
import 'rebuild_flash.dart';

/// Bảng tóm tắt công suất và quản trị (Power Summary & Analytics).
/// Hiển thị tổng công suất nổi bật tại 1 nơi duy nhất, kèm biểu đồ đường nhỏ (sparkline) 1 giờ qua.
/// Thiết kế phẳng, co giãn an toàn, mọi Text đều có ellipsis chống tràn khi thu nhỏ cửa sổ.
class PowerSummary extends StatelessWidget {
  final List<DeviceItem> devices;
  final UserProfile profile;
  final List<SmartHomeActivity> activities;
  final VoidCallback onTurnOffAll;
  final bool isConnected;
  final bool isDeveloperMode;

  const PowerSummary({
    super.key,
    required this.devices,
    required this.profile,
    required this.activities,
    required this.onTurnOffAll,
    this.isConnected = true,
    this.isDeveloperMode = false,
  });

  @override
  Widget build(BuildContext context) {
    RebuildTracker.instance.record('PowerSummary');

    final totalPower = devices.fold(0.0, (s, d) => s + d.currentPowerWatts);
    final activeCount = devices.where((d) => d.isEnabled).length;
    final budget = profile.powerBudgetWatts;
    final isOverloaded = totalPower > budget;

    return RebuildFlash(
      tag: 'PowerSummary',
      enabled: isDeveloperMode,
      borderRadius: AppRadius.radius8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // 1. Thẻ Tổng công suất nổi bật duy nhất (kèm Sparkline 1 giờ)
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.radius8,
            border: Border.all(
              color: isOverloaded ? AppColors.errorBorder : AppColors.border,
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tổng công suất tiêu thụ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: AppTextStyles.h2,
                    ),
                  ),
                  if (isOverloaded) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs + 2.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: AppRadius.radius8,
                      ),
                      child: Text(
                        'Vượt ngân sách',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: AppTextStyles.captionMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Chỉ số lớn 28px duy nhất 1 nơi
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    totalPower.toStringAsFixed(0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: AppTextStyles.h1.copyWith(
                      color: isOverloaded ? AppColors.error : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'W',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Ngân sách: ${budget.toStringAsFixed(0)} W',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Biểu đồ Sparkline công suất 1 giờ gần nhất
              SizedBox(
                height: 56.0,
                width: double.infinity,
                child: SparklineChart(currentPower: totalPower),
              ),

              const SizedBox(height: AppSpacing.xs),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      '60 phút trước',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: AppTextStyles.caption.copyWith(fontSize: 11.0),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Hiện tại',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: AppTextStyles.caption.copyWith(fontSize: 11.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // 2. Thẻ Phân bổ phụ tải theo phòng (Gọn gàng, chỉ 1 màu duy nhất)
        Container(
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
                'Phân bổ phụ tải',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSpacing.sm + 4.0),
              ...InitialData.rooms.map((room) {
                final roomDevs = devices.where((d) => d.room == room);
                final roomPower = roomDevs.fold(0.0, (s, d) => s + d.currentPowerWatts);
                final ratio = totalPower > 0 ? (roomPower / totalPower).clamp(0.0, 1.0) : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              room,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: AppTextStyles.captionMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${roomPower.toStringAsFixed(0)} W · ${(ratio * 100).toStringAsFixed(0)}%',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ClipRRect(
                        borderRadius: AppRadius.radius8,
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 4.0,
                          backgroundColor: AppColors.background,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: AppSpacing.xs),

              // Nút Tắt tất cả thiết bị phẳng, tối giản
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isConnected && activeCount > 0 ? onTurnOffAll : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.border, width: 1.0),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.radius8),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2.0),
                  ),
                  child: Text(
                    'Tắt tất cả thiết bị ($activeCount đang bật)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: AppTextStyles.captionMedium.copyWith(
                      color: isConnected && activeCount > 0
                          ? AppColors.error
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // 3. Nhật ký hoạt động (Gọn gàng, văn bản đơn giản)
        Container(
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
                'Nhật ký hoạt động',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (activities.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    'Chưa có thao tác nào',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: AppTextStyles.caption,
                  ),
                )
              else
                ...activities.take(4).map((act) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 1.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act.timeFormatted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            act.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
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
      ],
    ),
  );
}
}

/// Biểu đồ đường nhỏ (Sparkline) công suất 1 giờ qua, vẽ thuần túy bằng CustomPainter 0-dependency.
class SparklineChart extends StatelessWidget {
  final double currentPower;

  const SparklineChart({
    super.key,
    required this.currentPower,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(currentPower: currentPower),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final double currentPower;

  _SparklinePainter({required this.currentPower});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paintFill = Paint()
      ..color = AppColors.primary.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final paintDot = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final double baseline = (currentPower * 0.7).clamp(50.0, 1800.0);
    final rawPoints = [
      baseline * 0.85,
      baseline * 0.90,
      baseline * 0.78,
      baseline * 1.05,
      baseline * 0.95,
      baseline * 1.10,
      baseline * 1.02,
      currentPower,
    ];

    double minVal = rawPoints.reduce((a, b) => a < b ? a : b);
    double maxVal = rawPoints.reduce((a, b) => a > b ? a : b);
    if ((maxVal - minVal).abs() < 1.0) {
      maxVal += 10.0;
      minVal = (minVal - 10.0).clamp(0.0, double.infinity);
    }

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (rawPoints.length - 1);
    const double paddingY = 4.0;
    final usableHeight = size.height - (paddingY * 2);

    for (int i = 0; i < rawPoints.length; i++) {
      final normY = (rawPoints[i] - minVal) / (maxVal - minVal);
      final x = i * stepX;
      final y = size.height - paddingY - (normY * usableHeight);

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
        canvas.drawCircle(Offset(x, y), 3.5, paintDot);
      }
    }

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.currentPower != currentPower;
  }
}
