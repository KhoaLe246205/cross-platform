import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget hiệu ứng nhấp nháy thị giác khi Rebuild (Rebuild Flash) chuẩn thiết kế cao cấp:
/// 1. Trạng thái nghỉ trung tính: không can thiệp màu nền hoặc viền gốc.
/// 2. Khi build() chạy: overlay nền accent (#0F766E) opacity 0.14 + viền accent 1.5px,
///    mờ về 0 trong 600ms (Curves.easeOut), vẽ bằng DecorationPosition.foreground để không đổi layout.
/// 3. Controller khởi tạo value = 1.0 để không nháy lúc mở app.
/// 4. Nháy lan theo độ sâu cây widget: delay = 60ms × depth.
/// 5. Hỗ trợ hiển thị chữ "+1" xám 11px mờ dần cùng hiệu ứng nháy trên thẻ công việc.
/// 6. Chỉ hoạt động khi chế độ so sánh (Developer Mode) BẬT; khi tắt thì trả về child trực tiếp.
class RebuildFlash extends StatefulWidget {
  /// Cờ hỗ trợ chụp ảnh màn hình: khi bật (true), hiệu ứng nhấp nháy sẽ được giữ cố định
  /// ở mức sáng đỉnh (overlay 0.14 + viền 1.5px + chữ "+1") để người dùng chụp ảnh/cắt ảnh dễ dàng.
  static bool freezeForScreenshot = false;

  final Widget child;
  final bool enabled;
  final int depth;
  final BorderRadius? borderRadius;
  final String? tag;
  final bool showPlusOne;
  final bool isPropDrilling; // Giữ để tương thích ngược tham số

  const RebuildFlash({
    super.key,
    required this.child,
    this.enabled = true,
    this.depth = 0,
    this.borderRadius,
    this.tag,
    this.showPlusOne = false,
    this.isPropDrilling = false,
  });

  @override
  State<RebuildFlash> createState() => _RebuildFlashState();
}

class _RebuildFlashState extends State<RebuildFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isFirstBuild = true;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    // Controller khởi tạo value = 1.0 để không nháy lúc mở app (opacity = 0)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 1.0,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleFlash() {
    _delayTimer?.cancel();

    // Nếu đang bật chế độ đóng băng để chụp ảnh: giữ nguyên ở đỉnh (progress = 1.0)
    if (RebuildFlash.freezeForScreenshot) {
      _controller.value = 0.0;
      return;
    }

    final delayMs = 60 * widget.depth;
    if (delayMs > 0) {
      _delayTimer = Timer(Duration(milliseconds: delayMs), () {
        if (mounted && widget.enabled) {
          _controller.forward(from: 0.0);
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.enabled) {
          _controller.forward(from: 0.0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 4. Chỉ hoạt động khi chế độ Developer BẬT; khi tắt thì không nháy, giao diện sạch
    if (!widget.enabled) {
      return widget.child;
    }

    if (_isFirstBuild) {
      _isFirstBuild = false;
      // Bỏ qua lần build đầu tiên khi mở app để không bị nháy
    } else {
      _scheduleFlash();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, animChild) {
        final progress = 1.0 - _animation.value;
        if (progress <= 0.001) {
          return animChild!;
        }

        // Overlay nền accent opacity 0.14 + viền accent 1.5px
        final overlayColor = AppColors.primary.withValues(alpha: 0.14 * progress);
        final borderColor = AppColors.primary.withValues(alpha: progress);

        Widget flashWidget = DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            color: overlayColor,
            borderRadius: widget.borderRadius ?? AppRadius.radius8,
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: animChild,
        );

        // 5. Chữ "+1" xám 11px mờ dần cùng hiệu ứng nháy
        if (widget.showPlusOne && progress > 0.01) {
          flashWidget = Stack(
            clipBehavior: Clip.none,
            children: [
              flashWidget,
              Positioned(
                top: 8.0,
                right: 12.0,
                child: Opacity(
                  opacity: progress,
                  child: const Text(
                    '+1',
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B5563), // Chữ xám 11px chuẩn
                      fontFamily: AppTextStyles.fontFamily,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return flashWidget;
      },
      child: widget.child,
    );
  }
}
