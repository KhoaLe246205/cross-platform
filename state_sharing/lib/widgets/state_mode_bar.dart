import 'package:flutter/material.dart';
import '../models/app_mode.dart';
import '../models/rebuild_tracker.dart';
import '../theme/app_theme.dart';

/// Thanh công cụ chuyển đổi phương thức truyền dữ liệu & chia sẻ trạng thái.
/// Thiết kế 2 tầng chuẩn Senior Flutter UI: triệt tiêu hoàn toàn RenderFlex overflow,
/// hỗ trợ mọi kích thước cửa sổ và mọi textScaleFactor (1.0 - 1.3+).
class StateModeBar extends StatelessWidget {
  final StateSharingMode currentMode;
  final ValueChanged<StateSharingMode> onModeChanged;
  final bool showRebuildBadge;
  final ValueChanged<bool> onToggleRebuildBadge;
  final VoidCallback onResetTracker;

  const StateModeBar({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    required this.showRebuildBadge,
    required this.onToggleRebuildBadge,
    required this.onResetTracker,
  });

  @override
  Widget build(BuildContext context) {
    final isProp = currentMode == StateSharingMode.propDrilling;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radius8,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // TẦNG 1: Dòng nhãn tiêu đề
          const Row(
            children: [
              Icon(
                Icons.alt_route_rounded,
                size: 18.0,
                color: AppColors.textPrimary,
              ),
              SizedBox(width: AppSpacing.xs + 2.0),
              Expanded(
                child: Text(
                  'Cơ chế truyền dữ liệu:',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: AppTextStyles.captionMedium,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs + 2.0),

          // TẦNG 1: 2 nút chọn phiên bản (Rút gọn nhãn, giãn đều 50/50, minWidth an toàn)
          Container(
            height: 36.0,
            width: double.infinity,
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadius.radius8,
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildModeButton(
                    title: '1. Prop Drilling',
                    isSelected: isProp,
                    activeColor: const Color(0xFFD97706),
                    onTap: () => onModeChanged(StateSharingMode.propDrilling),
                  ),
                ),
                const SizedBox(width: 4.0),
                Expanded(
                  child: _buildModeButton(
                    title: '2. InheritedWidget',
                    isSelected: !isProp,
                    activeColor: AppColors.primary,
                    onTap: () => onModeChanged(StateSharingMode.inheritedWidget),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // TẦNG 2: Nhóm hành động căn phải bằng Wrap (Tự ngắt dòng khi chật)
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.end,
              children: [
                // Badge riêng ghi chú đặc tính số lượt build của phiên bản
                Container(
                  height: 32.0,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isProp ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDFA),
                    borderRadius: AppRadius.radius8,
                    border: Border.all(
                      color: isProp ? const Color(0xFFFDE68A) : const Color(0xFF99F6E4),
                    ),
                  ),
                  child: Text(
                    isProp ? 'Lan truyền · 14 build' : 'Cục bộ · 1 build (Tối ưu)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isProp ? const Color(0xFFD97706) : AppColors.primary,
                    ),
                  ),
                ),

                // Nút Reset đếm
                OutlinedButton.icon(
                  onPressed: onResetTracker,
                  icon: const Icon(Icons.restart_alt_rounded, size: 14.0),
                  label: const Text(
                    'Reset đếm',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    minimumSize: const Size(96.0, 32.0),
                    textStyle: AppTextStyles.captionMedium,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radius8,
                    ),
                  ),
                ),

                // Nút Bật/Tắt hiển thị huy hiệu Rebuild
                InkWell(
                  onTap: () => onToggleRebuildBadge(!showRebuildBadge),
                  borderRadius: AppRadius.radius8,
                  child: Container(
                    height: 32.0,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: showRebuildBadge ? AppColors.surfaceHover : Colors.transparent,
                      borderRadius: AppRadius.radius8,
                      border: Border.all(
                        color: showRebuildBadge ? AppColors.borderHover : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          showRebuildBadge ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 14.0,
                          color: showRebuildBadge ? AppColors.primary : AppColors.textMuted,
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          showRebuildBadge ? 'Hiện Badge' : 'Ẩn Badge',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: AppTextStyles.caption.copyWith(
                            color: showRebuildBadge ? AppColors.primary : AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Huy hiệu tổng số lượt Rebuild ghi nhận được
                ListenableBuilder(
                  listenable: RebuildTracker.instance,
                  builder: (context, _) {
                    final total = RebuildTracker.instance.totalRebuilds;
                    return Container(
                      height: 32.0,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.radius8,
                        border: Border.all(
                          color: isProp ? const Color(0xFFFDE68A) : const Color(0xFF99F6E4),
                        ),
                      ),
                      child: Text(
                        'Tổng: $total',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: isProp ? const Color(0xFFD97706) : AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // TẦNG 3: Hộp mô tả trực quan đối chiếu 2 phiên bản (tự xuống dòng, maxLines 2)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs + 3.0,
            ),
            decoration: BoxDecoration(
              color: isProp ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDFA),
              borderRadius: AppRadius.radius8,
              border: Border.all(
                color: isProp ? const Color(0xFFFDE68A) : const Color(0xFF99F6E4),
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isProp ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                  size: 16.0,
                  color: isProp ? const Color(0xFFD97706) : AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    isProp
                        ? 'Phiên bản 1 (Prop Drilling): State đặt tại HomeScreen. Bật/tắt 1 đèn kích hoạt setState() ở gốc → Toàn bộ 14 widget trên màn hình bị Rebuild lan truyền.'
                        : 'Phiên bản 2 (InheritedWidget & Notifier): Tra cứu O(1) qua Context. Bật/tắt 1 đèn chỉ làm đúng 1 widget lá tương ứng build lại (Tối ưu 92,9% chi phí render).',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: AppTextStyles.caption.copyWith(
                      color: isProp ? const Color(0xFF92400E) : const Color(0xFF115E59),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String title,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6.0),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 3.0,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6.0,
              height: 6.0,
              decoration: BoxDecoration(
                color: isSelected ? activeColor : AppColors.textMuted,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6.0),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
