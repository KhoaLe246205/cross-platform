import 'package:flutter/material.dart';
import '../models/app_mode.dart';
import '../models/rebuild_tracker.dart';
import '../theme/app_theme.dart';
import 'rebuild_flash.dart';

/// Thanh trạng thái mảnh ở đáy cửa sổ (cao đúng 32px), chỉ xuất hiện khi Chế độ Developer được bật.
/// Gồm:
/// 1. SegmentedButton nhỏ: Prop Drilling | InheritedWidget.
/// 2. Tooltip duy nhất cho icon (i) cạnh bộ chuyển phiên bản, mô tả 1 câu ngắn gọn.
/// 3. Chữ "Build: N" hiển thị tổng số lần build thời gian thực.
/// 4. Icon reset không chữ (tooltip "Đặt lại bộ đếm").
class DeveloperStatusBar extends StatelessWidget {
  final StateSharingMode currentMode;
  final ValueChanged<StateSharingMode> onModeChanged;
  final VoidCallback onResetTracker;

  const DeveloperStatusBar({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    required this.onResetTracker,
  });

  @override
  Widget build(BuildContext context) {
    final isProp = currentMode == StateSharingMode.propDrilling;

    return Container(
      height: 32.0,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // 1. Nhãn DEV MODE
          const Icon(
            Icons.terminal_rounded,
            size: 14.0,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          const Text(
            'DEV',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Vạch ngăn cách
          Container(
            height: 14.0,
            width: 1.0,
            color: AppColors.border,
          ),
          const SizedBox(width: AppSpacing.sm),

          // 2. SegmentedButton nhỏ: Prop Drilling | InheritedWidget
          SegmentedButton<StateSharingMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment<StateSharingMode>(
                value: StateSharingMode.propDrilling,
                label: Text(
                  'Prop Drilling',
                  style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500),
                ),
              ),
              ButtonSegment<StateSharingMode>(
                value: StateSharingMode.inheritedWidget,
                label: Text(
                  'InheritedWidget',
                  style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500),
                ),
              ),
            ],
            selected: {currentMode},
            onSelectionChanged: (set) => onModeChanged(set.first),
            style: ButtonStyle(
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.xs),

          // 3. Tooltip duy nhất cho icon (i) cạnh bộ chuyển phiên bản, mô tả 1 câu ngắn
          Tooltip(
            message: isProp
                ? 'Prop Drilling: State đặt ở gốc HomeScreen, kích hoạt setState() làm rebuild lan truyền toàn bộ 14 widget trên cây.'
                : 'InheritedWidget: Tra cứu O(1) qua Context, chỉ rebuild đúng widget tiêu thụ dữ liệu mà không lan truyền lên cha.',
            preferBelow: false,
            waitDuration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            textStyle: AppTextStyles.caption.copyWith(color: Colors.white),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: AppRadius.radius8,
            ),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.info_outline_rounded,
                size: 15.0,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const Spacer(),

          // 4. Số tổng build: bỏ nền đỏ và icon cảnh báo, dùng chữ xám đậm;
          // số tổng build đổi sang màu accent trong 600ms mỗi lần tăng, hiển thị dạng "Build: 537 (+14)"
          ListenableBuilder(
            listenable: RebuildTracker.instance,
            builder: (context, _) {
              return _BuildCountIndicator(
                totalBuilds: RebuildTracker.instance.totalRebuilds,
                isProp: isProp,
              );
            },
          ),

          const SizedBox(width: AppSpacing.xs + 2.0),

          // 5. Nút đóng băng nháy để chụp ảnh (Freeze for Screenshot)
          StatefulBuilder(
            builder: (context, setBtnState) {
              final isFrozen = RebuildFlash.freezeForScreenshot;
              return Tooltip(
                message: isFrozen
                    ? 'Đang ĐÓNG BĂNG nháy để chụp ảnh (Nhấn để tắt)'
                    : 'Đóng băng hiệu ứng nháy để chụp ảnh (Freeze)',
                preferBelow: false,
                waitDuration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                textStyle: AppTextStyles.caption.copyWith(color: Colors.white),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: AppRadius.radius8,
                ),
                child: InkWell(
                  onTap: () {
                    setBtnState(() {
                      RebuildFlash.freezeForScreenshot = !RebuildFlash.freezeForScreenshot;
                    });
                  },
                  borderRadius: BorderRadius.circular(4.0),
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: isFrozen ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4.0),
                      border: isFrozen ? Border.all(color: AppColors.primary, width: 1.0) : null,
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 15.0,
                      color: isFrozen ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: AppSpacing.xs),

          // 6. Icon reset không chữ (tooltip "Đặt lại bộ đếm")
          Tooltip(
            message: 'Đặt lại bộ đếm',
            preferBelow: false,
            waitDuration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            textStyle: AppTextStyles.caption.copyWith(color: Colors.white),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: AppRadius.radius8,
            ),
            child: InkWell(
              onTap: onResetTracker,
              borderRadius: BorderRadius.circular(4.0),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.restart_alt_rounded,
                  size: 15.0,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget hiển thị tổng số lượt build trên thanh đáy:
/// - Chữ xám đậm (#374151)
/// - Đổi sang màu accent (#0F766E) trong 600ms mỗi lần tăng
/// - Định dạng: "Build: 537 (+14)" (Prop Drilling) hoặc "Build: 538 (+1)" (InheritedWidget)
class _BuildCountIndicator extends StatefulWidget {
  final int totalBuilds;
  final bool isProp;

  const _BuildCountIndicator({
    required this.totalBuilds,
    required this.isProp,
  });

  @override
  State<_BuildCountIndicator> createState() => _BuildCountIndicatorState();
}

class _BuildCountIndicatorState extends State<_BuildCountIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _colorAnimation;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _lastCount = widget.totalBuilds;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 1.0, // Mặc định ở trạng thái tĩnh (xám đậm)
    );
    _colorAnimation = ColorTween(
      begin: const Color(0xFF0F766E), // Đổi sang accent khi tăng
      end: const Color(0xFF374151),   // Chữ xám đậm
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant _BuildCountIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.totalBuilds > _lastCount) {
      _lastCount = widget.totalBuilds;
      _controller.forward(from: 0.0);
    } else {
      _lastCount = widget.totalBuilds;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delta = widget.isProp ? '+14' : '+1';

    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.5),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1.0,
            ),
          ),
          child: Text(
            'Build: ${widget.totalBuilds} ($delta)',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: _colorAnimation.value,
            ),
          ),
        );
      },
    );
  }
}
