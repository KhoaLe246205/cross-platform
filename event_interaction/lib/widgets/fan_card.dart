import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class FanDeviceCard extends StatefulWidget {
  final bool isOn;
  final int speed; // 1, 2, 3
  final int eventCount;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onLongPress;
  final ValueChanged<int>? onSpeedSelected;

  const FanDeviceCard({
    super.key,
    required this.isOn,
    required this.speed,
    required this.eventCount,
    required this.onTap,
    required this.onDoubleTap,
    required this.onLongPress,
    this.onSpeedSelected,
  });

  @override
  State<FanDeviceCard> createState() => _FanDeviceCardState();
}

class _FanDeviceCardState extends State<FanDeviceCard>
    with SingleTickerProviderStateMixin {
  bool _isBorderFlashing = false;
  Timer? _flashTimer;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: _getDurationForSpeed(widget.speed),
    );
    if (widget.isOn) {
      _rotationController.repeat();
    }
  }

  /// Tốc độ quay của cánh quạt tương ứng với từng cấp gió:
  /// - Cấp 1 (Gió nhẹ): 1200ms / vòng (~0.8 vòng/s) - Êm dịu, quay thong thả
  /// - Cấp 2 (Gió vừa): 500ms / vòng (2 vòng/s) - Nhanh rõ rệt
  /// - Cấp 3 (Gió mạnh): 200ms / vòng (5 vòng/s) - Cực nhanh, xé gió
  Duration _getDurationForSpeed(int speed) {
    switch (speed) {
      case 3:
        return const Duration(milliseconds: 200);
      case 2:
        return const Duration(milliseconds: 500);
      case 1:
      default:
        return const Duration(milliseconds: 1200);
    }
  }

  @override
  void didUpdateWidget(covariant FanDeviceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.eventCount != oldWidget.eventCount) {
      triggerFlash();
    }

    // ĐỒNG BỘ TỐC ĐỘ QUAY VỚI CẤP GIÓ ĐANG CHỌN
    if (widget.isOn != oldWidget.isOn || widget.speed != oldWidget.speed) {
      if (widget.isOn) {
        final newDuration = _getDurationForSpeed(widget.speed);
        _rotationController.duration = newDuration;
        // Bắt buộc gọi repeat(period: ...) để cập nhật Ticker đang chạy ngay lập tức
        _rotationController.repeat(period: newDuration);
      } else {
        _rotationController.stop();
      }
    }
  }

  void triggerFlash() {
    _flashTimer?.cancel();
    setState(() {
      _isBorderFlashing = true;
    });
    _flashTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _isBorderFlashing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isBorderFlashing
              ? const Color(0xFF0284C7)
              : widget.isOn
                  ? const Color(0xFFBAE6FD) // Viền Sky Blue nổi bật khi BẬT
                  : const Color(0xFFE2E8F0), // Slate 200 mặc định
          width: widget.isOn ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isOn
                ? const Color(0x180284C7)
                : const Color(0x080F172A),
            blurRadius: widget.isOn ? 10 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          triggerFlash();
          widget.onTap();
        },
        onDoubleTap: () {
          triggerFlash();
          widget.onDoubleTap();
        },
        onLongPress: () {
          triggerFlash();
          widget.onLongPress();
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hàng trên: Icon, Tên, Trạng thái & Tag kỹ thuật góc phải
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon quạt động cơ xoay đồng bộ theo cấp gió
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isOn
                          ? (widget.speed == 3
                              ? const Color(0xFFBAE6FD) // Cấp 3: Xanh lơ đậm
                              : widget.speed == 2
                                  ? const Color(0xFFD0EDFE) // Cấp 2: Xanh vừa
                                  : const Color(0xFFE0F2FE)) // Cấp 1: Xanh nhạt
                          : const Color(0xFFF1F5F9), // Slate 100
                      border: Border.all(
                        color: widget.isOn
                            ? (widget.speed == 3
                                ? const Color(0xFF38BDF8)
                                : widget.speed == 2
                                    ? const Color(0xFF7DD3FC)
                                    : const Color(0xFFBAE6FD))
                            : const Color(0xFFE2E8F0),
                        width: widget.isOn ? (widget.speed == 3 ? 2.0 : 1.5) : 1.0,
                      ),
                      boxShadow: widget.isOn && widget.speed == 3
                          ? const [
                              BoxShadow(
                                color: Color(0x350284C7),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationController.value * 2 * pi,
                            child: FanBladeWidget(
                              color: widget.isOn
                                  ? const Color(0xFF0284C7) // Xanh Sky Blue rực rỡ khi BẬT
                                  : const Color(0xFF94A3B8), // Xám thanh lịch khi TẮT
                              size: 26,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tên & Vị trí & Cấp độ gió
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quạt thông gió',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tốc độ: Cấp ${widget.speed}/3 (${widget.speed == 3 ? "Gió mạnh" : widget.speed == 2 ? "Gió vừa" : "Gió nhẹ"})',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Segmented Control SỐNG ĐỘNG cho Cấp 1, Cấp 2, Cấp 3 (Có thể bấm trực tiếp)
                        Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9), // Slate 100
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [1, 2, 3].map((lvl) {
                              final isCurrentLevel =
                                  widget.isOn && widget.speed == lvl;
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  triggerFlash();
                                  if (widget.onSpeedSelected != null) {
                                    widget.onSpeedSelected!(lvl);
                                  } else {
                                    widget.onDoubleTap();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: isCurrentLevel
                                        ? const Color(0xFF0284C7) // Xanh Sky sống động
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: isCurrentLevel
                                        ? const [
                                            BoxShadow(
                                              color: Color(0x330284C7),
                                              blurRadius: 4,
                                              offset: Offset(0, 1),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    'Cấp $lvl',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: isCurrentLevel
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isCurrentLevel
                                          ? Colors.white
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tag kỹ thuật tối giản góc trên bên phải - Xanh Sky tươi sáng
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: const Text(
                      'GestureDetector',
                      style: TextStyle(
                        color: Color(0xFF0369A1),
                        fontSize: 11,
                        fontFamily: 'Consolas',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Dòng text chú thích nhỏ đáy thẻ
              const Text(
                'Chạm để bật/tắt • Chạm đúp đổi cấp • Nhấn giữ về cấp 1',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget vẽ cánh quạt 4 cánh khí động học sắc nét & chân thực
class FanBladeWidget extends StatelessWidget {
  final Color color;
  final double size;

  const FanBladeWidget({super.key, required this.color, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FanBladesPainter(color: color),
      ),
    );
  }
}

class _FanBladesPainter extends CustomPainter {
  final Color color;
  _FanBladesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final bladeRadius = size.width * 0.46;
    final bladeWidth = size.width * 0.22;

    // 4 cánh quạt cong khí động học cách đều 90 độ
    for (int i = 0; i < 4; i++) {
      final angle = i * (pi / 2);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final path = Path();
      path.moveTo(0, 0);
      path.cubicTo(
        bladeWidth * 0.4,
        -bladeRadius * 0.3,
        bladeWidth * 1.1,
        -bladeRadius * 0.8,
        bladeWidth * 0.6,
        -bladeRadius,
      );
      path.quadraticBezierTo(
        0,
        -bladeRadius * 1.05,
        -bladeWidth * 0.2,
        -bladeRadius * 0.7,
      );
      path.close();

      canvas.drawPath(path, paint);
      canvas.restore();
    }

    // Trục tâm quạt hình tròn
    final hubPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.15, hubPaint);

    // Điểm tâm tạo độ sâu sắc nét
    final innerHubPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.07, innerHubPaint);
  }

  @override
  bool shouldRepaint(covariant _FanBladesPainter oldDelegate) =>
      oldDelegate.color != color;
}
