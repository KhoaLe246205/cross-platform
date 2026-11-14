import 'package:flutter/material.dart';
import '../data/initial_data.dart';
import '../models/device_item.dart';

/// Thanh lọc thiết bị theo từng phòng (Room Filter Tabs).
class RoomFilterBar extends StatelessWidget {
  final String selectedRoom;
  final ValueChanged<String> onSelectRoom;
  final List<DeviceItem> allDevices;

  const RoomFilterBar({
    super.key,
    required this.selectedRoom,
    required this.onSelectRoom,
    required this.allDevices,
  });

  @override
  Widget build(BuildContext context) {
    final roomOptions = ['Tất cả', ...InitialData.rooms];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: roomOptions.map((room) {
          final isSelected = room == selectedRoom;
          final int count;
          final int activeCount;

          if (room == 'Tất cả') {
            count = allDevices.length;
            activeCount = allDevices.where((d) => d.isEnabled).length;
          } else {
            final devicesInThisRoom = allDevices.where((d) => d.room == room);
            count = devicesInThisRoom.length;
            activeCount = devicesInThisRoom.where((d) => d.isEnabled).length;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelectRoom(room),
                borderRadius: BorderRadius.circular(10.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: Color(0x1F0F172A),
                              blurRadius: 6.0,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getRoomIcon(room),
                        size: 15.0,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        room,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : (activeCount > 0
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          '$activeCount/$count',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : (activeCount > 0
                                    ? const Color(0xFF166534)
                                    : const Color(0xFF64748B)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getRoomIcon(String room) {
    switch (room) {
      case 'Phòng Khách':
        return Icons.weekend_outlined;
      case 'Phòng Ngủ':
        return Icons.bed_outlined;
      case 'Phòng Làm Việc':
        return Icons.laptop_chromebook_outlined;
      default:
        return Icons.dashboard_outlined;
    }
  }
}
