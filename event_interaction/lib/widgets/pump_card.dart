import 'dart:async';
import 'package:flutter/material.dart';

class PumpDeviceCard extends StatefulWidget {
  final bool isOn;
  final String mode; // 'Thủ công' hoặc 'Tự động'
  final int eventCount;
  final VoidCallback onTogglePower;
  final ValueChanged<bool> onToggleMode;

  const PumpDeviceCard({
    super.key,
    required this.isOn,
    required this.mode,
    required this.eventCount,
    required this.onTogglePower,
    required this.onToggleMode,
  });

  @override
  State<PumpDeviceCard> createState() => _PumpDeviceCardState();
}

class _PumpDeviceCardState extends State<PumpDeviceCard>
    with SingleTickerProviderStateMixin {
  bool _isBorderFlashing = false;
  Timer? _flashTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.10).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isOn) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PumpDeviceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.eventCount != oldWidget.eventCount) {
      triggerFlash();
    }

    if (widget.isOn != oldWidget.isOn) {
      if (widget.isOn) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
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
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAuto = widget.mode == 'Tự động';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isBorderFlashing
              ? const Color(0xFF2563EB)
              : widget.isOn
                  ? const Color(0xFFBFDBFE) // Viền Ocean Blue khi BẬT
                  : const Color(0xFFE2E8F0), // Slate 200 mặc định
          width: widget.isOn ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isOn
                ? const Color(0x182563EB)
                : const Color(0x080F172A),
            blurRadius: widget.isOn ? 10 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hàng trên: Icon, Tên, Trạng thái & Tag kỹ thuật góc phải
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Giọt nước với nhịp đập Pulse khi bơm đang chạy
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isOn
                        ? const Color(0xFFDBEAFE) // Blue 100
                        : const Color(0xFFF1F5F9), // Slate 100
                    border: Border.all(
                      color: widget.isOn
                          ? const Color(0xFFBFDBFE)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Center(
                    child: ScaleTransition(
                      scale: widget.isOn
                          ? _pulseAnimation
                          : const AlwaysStoppedAnimation(1.0),
                      child: Icon(
                        Icons.water_drop_rounded,
                        color: widget.isOn
                            ? const Color(0xFF2563EB) // Xanh nước biển rực rỡ khi BẬT
                            : const Color(0xFF94A3B8), // Xám khi TẮT
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Tên & Vị trí & Trạng thái
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Máy bơm tưới cây',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ban công • Chế độ: ${widget.mode}',
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
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.isOn ? 'ĐANG BƠM NƯỚC' : 'ĐANG NGỪNG',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: widget.isOn
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tag kỹ thuật tối giản góc trên bên phải - Xanh dương sống động
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Text(
                    'ElevatedButton + Switch',
                    style: TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontSize: 11,
                      fontFamily: 'Consolas',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Controls: NÚT BẬT/DỪNG BƠM MÀU SẮC SỐNG ĐỘNG & Công tắc chế độ
            Row(
              children: [
                // Nút Bật/Dừng bơm - Đỏ rực rỡ khi dừng, Xanh dương đậm khi bật
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      triggerFlash();
                      widget.onTogglePower();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.isOn
                          ? const Color(0xFFEF4444) // Đỏ Coral sống động khi đang chạy
                          : const Color(0xFF2563EB), // Xanh dương sống động khi tắt
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shadowColor: widget.isOn
                          ? const Color(0x60EF4444)
                          : const Color(0x602563EB),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    icon: Icon(
                      widget.isOn
                          ? Icons.stop_circle_rounded
                          : Icons.play_circle_filled_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      widget.isOn ? 'Dừng bơm' : 'Bật bơm',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Switch chế độ Thủ công / Tự động - Sống động
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: isAuto
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: isAuto
                          ? const Color(0xFFBFDBFE)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isAuto ? 'Tự động' : 'Thủ công',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isAuto ? FontWeight.w700 : FontWeight.w500,
                          color: isAuto
                              ? const Color(0xFF1D4ED8)
                              : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Switch(
                        value: isAuto,
                        onChanged: (val) {
                          triggerFlash();
                          widget.onToggleMode(val);
                        },
                        activeThumbColor: const Color(0xFF2563EB),
                        activeTrackColor: const Color(0xFFBFDBFE),
                        inactiveThumbColor: const Color(0xFF94A3B8),
                        inactiveTrackColor: const Color(0xFFE2E8F0),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Dòng text chú thích nhỏ đáy thẻ
            const Text(
              'Bấm nút để bật/tắt • Gạt công tắc để đổi chế độ',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
