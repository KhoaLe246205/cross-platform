import 'package:flutter/material.dart';
import '../models/device_item.dart';
import '../models/rebuild_tracker.dart';
import '../theme/app_theme.dart';
import 'rebuild_flash.dart';

/// Hàng/thẻ thiết bị thông minh chuẩn thiết kế phẳng (Device Tile).
/// Thiết kế phẳng, viền xám mảnh 1px, dùng icon đơn sắc, không đổ bóng nặng hay nền pastel.
/// Co giãn linh hoạt theo chiều rộng, không bao giờ tràn nội dung hay đè chữ.
class DeviceTile extends StatefulWidget {
  final DeviceItem item;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onLevelChanged;
  final bool isConnected;
  final bool isDeveloperMode;
  final bool showRebuildBadge;

  const DeviceTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onLevelChanged,
    this.isConnected = true,
    this.isDeveloperMode = false,
    this.showRebuildBadge = false,
  });

  @override
  State<DeviceTile> createState() => _DeviceTileState();
}

class _DeviceTileState extends State<DeviceTile> {
  bool _isHovered = false;
  bool _isProcessing = false;

  void _handleToggle(bool value) async {
    if (!widget.isConnected || _isProcessing) return;

    // Giả lập độ trễ xử lý phản hồi phần cứng (180ms)
    setState(() => _isProcessing = true);
    widget.onToggle(value);
    await Future.delayed(const Duration(milliseconds: 180));
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    RebuildTracker.instance.record(widget.item.id);

    final item = widget.item;
    final isOnline = widget.isConnected;
    final isActive = isOnline && item.isEnabled;

    // Icon đơn sắc: Thiết bị bật = màu nhấn; thiết bị tắt/mất mạng = xám trung tính
    final Color iconColor = !isOnline
        ? AppColors.textMuted
        : (isActive ? AppColors.primary : AppColors.textSecondary);

    final tileContent = MouseRegion(
      cursor: isOnline ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: !isOnline ? 0.55 : (isActive ? 1.0 : 0.75),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 4.0,
          ),
          decoration: BoxDecoration(
            color: _isHovered && isOnline ? AppColors.surfaceHover : AppColors.surface,
            borderRadius: AppRadius.radius8,
            border: Border.all(
              color: _isHovered && isOnline ? AppColors.borderHover : AppColors.border,
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dòng 1: Icon đơn sắc + Tên thiết bị · Công suất + Công tắc / Loading
              Row(
                children: [
                  Icon(
                    item.icon,
                    size: 20.0,
                    color: iconColor,
                  ),
                  const SizedBox(width: AppSpacing.sm + 4.0),

                  // Tên thiết bị · Công suất hiển thị liền kề trong Expanded
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: item.name,
                                style: AppTextStyles.body.copyWith(
                                  color: !isOnline
                                      ? AppColors.textMuted
                                      : (isActive
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary),
                                ),
                              ),
                              TextSpan(
                                text: !isOnline
                                    ? ' · Mất kết nối'
                                    : (isActive
                                        ? ' · ${item.currentPowerWatts.toStringAsFixed(1)} W'
                                        : ' · Tắt'),
                                style: AppTextStyles.caption.copyWith(
                                  color: !isOnline
                                      ? AppColors.error
                                      : (isActive
                                          ? AppColors.textSecondary
                                          : AppColors.textMuted),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          !isOnline ? 'Không phản hồi từ thiết bị' : item.statusDisplay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  // Trạng thái thao tác: Loading nhỏ khi đang chuyển đổi hoặc Switch phẳng
                  if (_isProcessing)
                    const SizedBox(
                      width: 28.0,
                      height: 28.0,
                      child: Center(
                        child: SizedBox(
                          width: 14.0,
                          height: 14.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 28.0,
                      child: Switch(
                        value: isActive,
                        onChanged: isOnline ? _handleToggle : null,
                        activeColor: AppColors.primary,
                        activeTrackColor: AppColors.primaryBorder,
                        inactiveThumbColor: AppColors.textMuted,
                        inactiveTrackColor: AppColors.border,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),

              // Dòng 2: Thanh trượt tinh chỉnh thông số (Độ sáng / Nhiệt độ / Âm lượng)
              if (isActive) ...[
                const SizedBox(height: AppSpacing.xs),
                _buildSliderControl(context, item),
              ],
            ],
          ),
        ),
      ),
    );

    return RebuildFlash(
      tag: widget.item.id,
      enabled: widget.isDeveloperMode,
      borderRadius: AppRadius.radius8,
      child: tileContent,
    );
  }

  Widget _buildSliderControl(BuildContext context, DeviceItem item) {
    // Điều hòa Inverter: Nút tinh chỉnh nhiệt độ và thanh trượt
    if (item.id.contains('ac')) {
      final currentTemp = 16 + (item.level * 14).round(); // 16 - 30 độ C
      return Row(
        children: [
          _buildStepButton(
            icon: Icons.remove,
            onPressed: currentTemp > 16
                ? () {
                    final newLevel = ((currentTemp - 1) - 16) / 14.0;
                    widget.onLevelChanged(newLevel.clamp(0.0, 1.0));
                  }
                : null,
          ),
          Expanded(
            child: SliderTheme(
              data: Theme.of(context).sliderTheme,
              child: Slider(
                value: item.level,
                min: 0.0,
                max: 1.0,
                divisions: 14,
                onChanged: widget.onLevelChanged,
              ),
            ),
          ),
          _buildStepButton(
            icon: Icons.add,
            onPressed: currentTemp < 30
                ? () {
                    final newLevel = ((currentTemp + 1) - 16) / 14.0;
                    widget.onLevelChanged(newLevel.clamp(0.0, 1.0));
                  }
                : null,
          ),
          const SizedBox(width: AppSpacing.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 44.0),
            child: Text(
              '$currentTemp°C',
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: AppTextStyles.captionMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      );
    }

    // Các thiết bị khác (Đèn, Loa, Màn hình, Máy lọc): Thanh trượt tỉ lệ % duy nhất 1 màu nhấn
    return Row(
      children: [
        Expanded(
          child: SliderTheme(
            data: Theme.of(context).sliderTheme,
            child: Slider(
              value: item.level,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              onChanged: widget.onLevelChanged,
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 36.0),
          child: Text(
            '${(item.level * 100).toInt()}%',
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: AppTextStyles.captionMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: AppRadius.radius8,
      child: Container(
        width: 26.0,
        height: 26.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onPressed != null ? AppColors.surfaceHover : AppColors.background,
          borderRadius: AppRadius.radius8,
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Icon(
          icon,
          size: 14.0,
          color: onPressed != null ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }
}
