import 'package:flutter/material.dart';

class GlobalControlBar extends StatelessWidget {
  final bool hasAnyActive;
  final bool allActive;
  final VoidCallback onTurnOnAll;
  final VoidCallback? onTurnOffAll;
  final VoidCallback onResetAll;

  const GlobalControlBar({
    super.key,
    required this.hasAnyActive,
    required this.allActive,
    required this.onTurnOnAll,
    required this.onTurnOffAll,
    required this.onResetAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Slate 800
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          // Tiêu đề & Chip Widget chứng minh lý thuyết Slide 6
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune_rounded,
                    color: Color(0xFF38BDF8), size: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                'Điều khiển nhanh',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Nhóm 3 nút bấm
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Nút Bật tất cả
              ElevatedButton.icon(
                onPressed: onTurnOnAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981), // Emerald Green
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.power_settings_new_rounded, size: 15),
                label: const Text(
                  'Bật tất cả',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),

              // 2. Nút Tắt tất cả (vô hiệu hóa khi tất cả đang tắt -> onPressed: null)
              ElevatedButton.icon(
                onPressed: onTurnOffAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444), // Coral Red
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF334155),
                  disabledForegroundColor: const Color(0xFF64748B),
                  elevation: hasAnyActive ? 2 : 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.power_off_rounded, size: 15),
                label: const Text(
                  'Tắt tất cả',
                  style: TextStyle(
                      fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),

              // 3. Nút Đặt lại
              OutlinedButton.icon(
                onPressed: onResetAll,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE2E8F0),
                  side: const BorderSide(color: Color(0xFF475569)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 15),
                label: const Text(
                  'Đặt lại',
                  style: TextStyle(fontSize: 11.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
