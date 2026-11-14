import 'package:flutter/material.dart';
import '../models/device_item.dart';
import '../models/user_profile.dart';
import '../data/initial_data.dart';
import '../state/change_notifier_state.dart';

/// Bảng điều khiển phân tích năng lượng và quản trị thông minh (Energy & Smart Hub Panel).
/// Hiển thị trực quan dữ liệu tiêu thụ, phân bổ công suất theo khu vực và nhật ký điều khiển.
class EnergyAnalyticsPanel extends StatelessWidget {
  final List<DeviceItem> devices;
  final UserProfile profile;
  final List<SmartHomeActivity> activities;
  final VoidCallback onTurnOffAll;
  final VoidCallback onTurnOnAll;
  final VoidCallback onToggleEco;

  const EnergyAnalyticsPanel({
    super.key,
    required this.devices,
    required this.profile,
    required this.activities,
    required this.onTurnOffAll,
    required this.onTurnOnAll,
    required this.onToggleEco,
  });

  @override
  Widget build(BuildContext context) {
    final totalPower = devices.fold(0.0, (s, d) => s + d.currentPowerWatts);
    final activeCount = devices.where((d) => d.isEnabled).length;
    final budget = profile.powerBudgetWatts;
    final loadRatio = budget > 0 ? (totalPower / budget).clamp(0.0, 1.0) : 0.0;
    final dailyCost = (totalPower * 24 / 1000) * 2500; // Ước tính 2,500đ/kWh

    Color loadColor = const Color(0xFF10B981);
    String loadStatus = 'Mức tiêu thụ tối ưu • Chuẩn A+';
    if (loadRatio > 0.85) {
      loadColor = const Color(0xFFEF4444);
      loadStatus = 'Cảnh báo phụ tải cao • Gần ngưỡng ngắt';
    } else if (loadRatio > 0.60) {
      loadColor = const Color(0xFFF59E0B);
      loadStatus = 'Mức tiêu thụ bình thường • Chuẩn B';
    }

    return Column(
      children: [
        // 1. Thẻ Giám sát công suất & Ngân sách điện
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 10.0,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7.0),
                    decoration: BoxDecoration(
                      color: loadColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(Icons.speed_rounded, size: 18.0, color: loadColor),
                  ),
                  const SizedBox(width: 10.0),
                  const Expanded(
                    child: Text(
                      'Tải điện hệ thống thời gian thực',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: loadColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      '${(loadRatio * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w800,
                        color: loadColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14.0),

              // Chỉ số to Watts
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    totalPower.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.w900,
                      color: loadColor,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  const Text(
                    'Watts',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Ngân sách: ${budget.toStringAsFixed(0)} W',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Dự tính: ~${_formatCurrency(dailyCost)} / ngày',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10.0),

              // Thanh tiến trình công suất
              ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: LinearProgressIndicator(
                  value: loadRatio,
                  minHeight: 8.0,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(loadColor),
                ),
              ),

              const SizedBox(height: 8.0),

              Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 14.0, color: loadColor),
                  const SizedBox(width: 6.0),
                  Text(
                    loadStatus,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: loadColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14.0),

        // 2. Thẻ Phân bổ công suất theo phòng
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 10.0,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.pie_chart_outline_rounded, size: 17.0, color: Color(0xFF3B82F6)),
                  SizedBox(width: 8.0),
                  Text(
                    'Phân bổ phụ tải theo khu vực',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              ...InitialData.rooms.map((room) {
                final roomDevs = devices.where((d) => d.room == room);
                final roomPower = roomDevs.fold(0.0, (s, d) => s + d.currentPowerWatts);
                final share = totalPower > 0 ? (roomPower / totalPower) : 0.0;
                final roomColor = _getRoomColor(room);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            room,
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                          Text(
                            '${roomPower.toStringAsFixed(0)} W (${(share * 100).toStringAsFixed(0)}%)',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: roomPower > 0 ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: LinearProgressIndicator(
                          value: share,
                          minHeight: 5.0,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation<Color>(roomColor),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 14.0),

        // 3. Nút Thao tác điều khiển toàn hệ thống
        Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 10.0,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.touch_app_rounded, size: 17.0, color: Color(0xFF0D9488)),
                  SizedBox(width: 8.0),
                  Text(
                    'Điều khiển nhanh toàn hệ thống',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: activeCount > 0 ? onTurnOffAll : null,
                      icon: const Icon(Icons.power_settings_new, size: 16.0),
                      label: const Text('Tắt tất cả'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: activeCount < devices.length ? onTurnOnAll : null,
                      icon: const Icon(Icons.power_rounded, size: 16.0),
                      label: const Text('Bật tất cả'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0D9488),
                        side: const BorderSide(color: Color(0xFFA7F3D0)),
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14.0),

        // 4. Nhật ký hoạt động người dùng (Customer Activity Log)
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 10.0,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.history_rounded, size: 17.0, color: Color(0xFF64748B)),
                  const SizedBox(width: 8.0),
                  const Text(
                    'Nhật ký hoạt động thông minh',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${activities.length} sự kiện',
                    style: const TextStyle(
                      fontSize: 11.0,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              if (activities.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      'Chưa có thao tác nào được thực hiện',
                      style: TextStyle(fontSize: 12.0, color: Color(0xFF94A3B8)),
                    ),
                  ),
                )
              else
                ...activities.take(5).map((act) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: act.iconColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(act.icon, size: 14.0, color: act.iconColor),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                act.title,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                act.description,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          act.timeFormatted,
                          style: const TextStyle(
                            fontSize: 10.0,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Color _getRoomColor(String room) {
    switch (room) {
      case 'Phòng Khách':
        return const Color(0xFF0284C7);
      case 'Phòng Ngủ':
        return const Color(0xFF8B5CF6);
      case 'Phòng Làm Việc':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _formatCurrency(double amount) {
    final int val = amount.round();
    return '${val.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} ₫';
  }
}
