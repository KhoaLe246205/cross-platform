import 'package:flutter/material.dart';
import '../models/app_mode.dart';

/// Thanh chân trang (Enterprise IoT Footer) hiển thị trạng thái vận hành hệ thống.
class BottomSummaryBar extends StatelessWidget {
  final StateSharingMode? currentMode;
  final VoidCallback? onResetRebuildCount;
  final VoidCallback? onResetAllData;

  const BottomSummaryBar({
    super.key,
    this.currentMode,
    this.onResetRebuildCount,
    this.onResetAllData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(
          top: BorderSide(color: Color(0xFF1E293B), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, size: 14.0, color: Color(0xFF10B981)),
          const SizedBox(width: 8.0),
          const Text(
            'EcoSmart IoT Hub Core v2.4 • Chuẩn kết nối Matter & Thread',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_tethering, size: 12.0, color: Color(0xFF38BDF8)),
                SizedBox(width: 6.0),
                Text(
                  'Mesh Sync: 60 FPS • Độ trễ 12ms',
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          const Text(
            'Bản quyền © 2026 EcoSmart Solution',
            style: TextStyle(
              fontSize: 11.0,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
