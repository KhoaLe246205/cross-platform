import 'package:flutter/material.dart';
import '../models/device_item.dart';
import '../models/rebuild_tracker.dart';
import '../state/change_notifier_state.dart';
import '../theme/app_theme.dart';
import 'device_tile.dart';
import 'rebuild_flash.dart';

/// Khối phòng (Room Section) - Cấp 1 trong hệ thống phân cấp 2 cấp thẻ phẳng.
/// Gồm tiêu đề phòng và danh sách các hàng thiết bị (Device Tile).
/// Không có chip công suất ở tiêu đề, chống tràn tuyệt đối khi thu hẹp cửa sổ.
class RoomSection extends StatelessWidget {
  final String roomName;
  final List<DeviceItem> devices;
  final ValueChanged<String> onToggleDevice;
  final void Function(String id, double level) onUpdateLevel;
  final bool isConnected;
  final bool isPropDrilling;
  final HomeEnergyModel? model;
  final bool isDeveloperMode;
  final bool showRebuildBadge;

  const RoomSection({
    super.key,
    required this.roomName,
    required this.devices,
    required this.onToggleDevice,
    required this.onUpdateLevel,
    this.isConnected = true,
    this.isPropDrilling = false,
    this.model,
    this.isDeveloperMode = false,
    this.showRebuildBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isPropDrilling) {
      // Trong chế độ Prop Drilling: ghi nhận tầng trung gian RoomSection bị Rebuild lan truyền
      RebuildTracker.instance.record('room_$roomName');
    }

    final activeCount = devices.where((d) => d.isEnabled).length;

    final sectionContent = Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radius8,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tiêu đề khối phòng: Tên phòng và số lượng thiết bị (co giãn an toàn bằng Flexible)
          Row(
            children: [
              Icon(
                _getRoomIcon(roomName),
                size: 18.0,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  roomName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: AppTextStyles.h2,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  '· ${devices.length} thiết bị ($activeCount đang bật)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Cấp 2: Danh sách các hàng thiết bị (Device Tiles)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: devices.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final device = devices[index];

              // Trong chế độ Prop Drilling: widget con phụ thuộc trực tiếp vào tham số constructor của cha
              if (isPropDrilling || model == null) {
                return DeviceTile(
                  item: device,
                  onToggle: (_) => onToggleDevice(device.id),
                  onLevelChanged: (val) => onUpdateLevel(device.id, val),
                  isConnected: isConnected,
                  isDeveloperMode: isDeveloperMode,
                );
              }

              // Trong chế độ InheritedWidget / Notifier: cập nhật phân mảnh tại đúng lá cây widget
              return ValueListenableBuilder<DeviceItem>(
                valueListenable: model!.getDeviceNotifier(device.id),
                builder: (context, liveItem, _) {
                  return DeviceTile(
                    item: liveItem,
                    onToggle: (_) => onToggleDevice(device.id),
                    onLevelChanged: (val) => onUpdateLevel(device.id, val),
                    isConnected: isConnected,
                    isDeveloperMode: isDeveloperMode,
                  );
                },
              );
            },
          ),
        ],
      ),
    );

    return RebuildFlash(
      tag: 'room_$roomName',
      enabled: isDeveloperMode && isPropDrilling,
      borderRadius: AppRadius.radius8,
      child: sectionContent,
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
        return Icons.meeting_room_outlined;
    }
  }
}
