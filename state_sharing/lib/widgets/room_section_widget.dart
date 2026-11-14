import 'package:flutter/material.dart';
import '../models/device_item.dart';
import '../state/value_notifier_state.dart';
import 'device_group_widget.dart';

/// Khu vực quản lý một phòng trong nhà thông minh.
class RoomSectionWidget extends StatelessWidget {
  final String roomName;
  final List<DeviceItem> devices;
  final ValueNotifierHomeState? vnState;
  final ValueChanged<String> onToggleDevice;
  final void Function(String id, double level) onUpdateLevel;

  const RoomSectionWidget({
    super.key,
    required this.roomName,
    required this.devices,
    this.vnState,
    required this.onToggleDevice,
    required this.onUpdateLevel,
  });

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const SizedBox.shrink();
    }

    final roomPower = devices.fold(0.0, (sum, d) => sum + d.currentPowerWatts);
    final activeCount = devices.where((d) => d.isEnabled).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
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
          // Tiêu đề phòng: Tên phòng, Biểu tượng, Công suất phòng, Số lượng thiết bị
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  _getRoomIcon(roomName),
                  size: 20.0,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    roomName,
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '$activeCount/${devices.length} thiết bị đang bật',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: activeCount > 0 ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: activeCount > 0 ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt,
                      size: 14.0,
                      color: activeCount > 0 ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '${roomPower.toStringAsFixed(0)} W',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: activeCount > 0 ? const Color(0xFF059669) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14.0),

          // Lưới các thiết bị trong phòng
          DeviceGroupWidget(
            room: roomName,
            devices: devices,
            vnState: vnState,
            onToggleDevice: onToggleDevice,
            onUpdateLevel: onUpdateLevel,
          ),
        ],
      ),
    );
  }

  IconData _getRoomIcon(String room) {
    switch (room) {
      case 'Phòng Khách':
        return Icons.weekend_rounded;
      case 'Phòng Ngủ':
        return Icons.bed_rounded;
      case 'Phòng Làm Việc':
        return Icons.laptop_mac_rounded;
      default:
        return Icons.meeting_room_rounded;
    }
  }
}
