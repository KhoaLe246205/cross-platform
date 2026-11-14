import 'package:flutter/material.dart';
import '../models/user_profile.dart';

/// Thanh tiêu đề ứng dụng (Enterprise IoT Header) mang phong cách thương mại chuyên nghiệp.
/// Đồng bộ thời gian thực trạng thái phụ tải, chế độ Eco, kết nối mạng và người dùng.
class TopAppBar extends StatelessWidget {
  final UserProfile profile;
  final double totalPower;
  final VoidCallback onToggleEco;
  final int activeCount;
  final int totalCount;
  final VoidCallback? onTurnOffAll;

  const TopAppBar({
    super.key,
    required this.profile,
    required this.totalPower,
    required this.onToggleEco,
    this.activeCount = 0,
    this.totalCount = 6,
    this.onTurnOffAll,
  });

  @override
  Widget build(BuildContext context) {
    final loadRatio = (totalPower / profile.powerBudgetWatts).clamp(0.0, 1.0);
    final isWarning = loadRatio > 0.85;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Slate 900 đậm chất công nghệ
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo thương hiệu & Tên sản phẩm
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF334155), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 8.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.hub_rounded, color: Colors.white, size: 22.0),
          ),
          const SizedBox(width: 14.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'EcoSmart Hub',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                    ),
                    child: const Text(
                      'PRO IOT',
                      style: TextStyle(
                        fontSize: 9.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF34D399),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2.0),
              const Text(
                'Hệ thống điều khiển & tối ưu năng lượng thông minh',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Trạng thái mạng / Cloud
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6.0),
                const Text(
                  'Mesh LAN • 60 FPS',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12.0),

          // Huy hiệu công suất tiêu thụ thời gian thực
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: isWarning
                    ? const Color(0xFFEF4444).withOpacity(0.6)
                    : const Color(0xFF334155),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.electric_bolt_rounded,
                  size: 16.0,
                  color: isWarning ? const Color(0xFFF87171) : const Color(0xFFFBBF24),
                ),
                const SizedBox(width: 6.0),
                Text(
                  '${totalPower.toStringAsFixed(0)} W',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isWarning ? const Color(0xFFF87171) : Colors.white,
                  ),
                ),
                Text(
                  ' / ${profile.powerBudgetWatts.toStringAsFixed(0)} W',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12.0),

          // Huy hiệu số thiết bị hoạt động
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.devices_rounded, size: 15.0, color: Color(0xFF38BDF8)),
                const SizedBox(width: 6.0),
                Text(
                  '$activeCount/$totalCount Bật',
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF1F5F9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12.0),

          // Nút bật/tắt Eco Mode
          Tooltip(
            message: profile.isEcoMode
                ? 'Đang bật tiết kiệm điện (Giới hạn công suất tối đa 60%)'
                : 'Bật chế độ tiết kiệm điện Eco Mode',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onToggleEco,
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: profile.isEcoMode
                        ? const Color(0xFF065F46)
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: profile.isEcoMode
                          ? const Color(0xFF10B981)
                          : const Color(0xFF334155),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.eco_rounded,
                        size: 16.0,
                        color: profile.isEcoMode ? const Color(0xFF34D399) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        profile.isEcoMode ? 'Eco: BẬT' : 'Eco Mode',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: profile.isEcoMode ? const Color(0xFF34D399) : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16.0),

          // Phân cách
          Container(
            height: 28.0,
            width: 1.0,
            color: const Color(0xFF334155),
          ),

          const SizedBox(width: 16.0),

          // Avatar & Tên chủ hộ
          Row(
            children: [
              const CircleAvatar(
                radius: 17.0,
                backgroundColor: Color(0xFF3B82F6),
                child: Text(
                  'KT',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profile.fullName,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    profile.role,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
