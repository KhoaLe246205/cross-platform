import 'dart:async';
import 'package:flutter/material.dart';

class LampDeviceCard extends StatefulWidget {
  final bool isOn;
  final double brightness;
  final int eventCount;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<double> onBrightnessChanged;
  final ValueChanged<double> onBrightnessChangeEnd;

  const LampDeviceCard({
    super.key,
    required this.isOn,
    required this.brightness,
    required this.eventCount,
    required this.onTap,
    required this.onLongPress,
    required this.onBrightnessChanged,
    required this.onBrightnessChangeEnd,
  });

  @override
  State<LampDeviceCard> createState() => _LampDeviceCardState();
}

class _LampDeviceCardState extends State<LampDeviceCard> {
  bool _isBorderFlashing = false;
  Timer? _flashTimer;

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
  void didUpdateWidget(covariant LampDeviceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.eventCount != oldWidget.eventCount) {
      triggerFlash();
    }
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  void _showBrightnessModal(BuildContext context) {
    double tempBrightness = widget.brightness;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.tune_rounded,
                            color: Color(0xFFD97706), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Cài đặt độ sáng đèn',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Text(
                            '${(tempBrightness * 100).toInt()}%',
                            style: const TextStyle(
                              color: Color(0xFFB45309),
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Consolas',
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Kéo thanh trượt để điều chỉnh cường độ ánh sáng mong muốn.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                    ),
                    const SizedBox(height: 16),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFFF59E0B),
                        inactiveTrackColor: const Color(0xFFE2E8F0),
                        thumbColor: const Color(0xFFD97706),
                        overlayColor: const Color(0x29F59E0B),
                      ),
                      child: Slider(
                        value: tempBrightness,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        onChanged: (val) {
                          setModalState(() {
                            tempBrightness = val;
                          });
                          widget.onBrightnessChanged(val);
                        },
                        onChangeEnd: (val) {
                          widget.onBrightnessChangeEnd(val);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shadowColor: const Color(0x60F59E0B),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Xác nhận & Đóng',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
              ? const Color(0xFFF59E0B)
              : widget.isOn
                  ? const Color(0xFFFCD34D) // Viền vàng Amber ấm áp khi BẬT
                  : const Color(0xFFE2E8F0), // Slate 200 mặc định
          width: widget.isOn ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isOn
                ? const Color(0x18F59E0B)
                : const Color(0x080F172A),
            blurRadius: widget.isOn ? 10 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFFF59E0B).withAlpha(25),
          highlightColor: const Color(0xFFF59E0B).withAlpha(15),
          onTap: () {
            triggerFlash();
            widget.onTap();
          },
          onLongPress: () {
            triggerFlash();
            widget.onLongPress();
            _showBrightnessModal(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hàng trên: Icon, Tên, Trạng thái & Tag kỹ thuật ở góc phải
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon đèn sáng vàng sống động khi BẬT
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isOn
                            ? const Color(0xFFFEF3C7) // Amber 100
                            : const Color(0xFFF1F5F9), // Slate 100
                        border: Border.all(
                          color: widget.isOn
                              ? const Color(0xFFFDE68A)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Icon(
                        Icons.lightbulb_rounded,
                        color: widget.isOn
                            ? const Color(0xFFD97706) // Vàng ấm sống động
                            : const Color(0xFF94A3B8), // Xám thanh lịch khi tắt
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tên & Vị trí & Trạng thái
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Đèn thông minh',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Phòng khách • Độ sáng: ${(widget.brightness * 100).toInt()}%',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 3,
                                backgroundColor: widget.isOn
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.isOn ? 'ĐANG BẬT' : 'ĐANG TẮT',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: widget.isOn
                                      ? const Color(0xFF059669)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Tag kỹ thuật tối giản góc trên bên phải - Tươi sáng
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Text(
                        'InkWell',
                        style: TextStyle(
                          color: Color(0xFFB45309),
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
                  'Chạm để bật/tắt • Nhấn giữ để chỉnh độ sáng',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
