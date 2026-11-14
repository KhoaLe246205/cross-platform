import 'package:flutter/material.dart';
import '../models/device_item.dart';
import '../state/value_notifier_state.dart';
import 'device_card_widget.dart';

/// Nhóm thiết bị trong một khu vực phòng.
/// Trong mô hình chia sẻ trạng thái, đóng vai trò là một container trung gian.
class DeviceGroupWidget extends StatelessWidget {
  final String room;
  final List<DeviceItem> devices;
  final ValueNotifierHomeState? vnState;
  final ValueChanged<String> onToggleDevice;
  final void Function(String id, double level) onUpdateLevel;

  const DeviceGroupWidget({
    super.key,
    required this.room,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        if (isWide && devices.length > 1) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: devices.map((device) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: _buildDeviceCard(device),
                ),
              );
            }).toList(),
          );
        }

        return Column(
          children: devices.map((device) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _buildDeviceCard(device),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDeviceCard(DeviceItem device) {
    if (vnState != null) {
      return ValueListenableBuilder<DeviceItem>(
        valueListenable: vnState!.getDeviceNotifier(device.id),
        builder: (context, liveItem, _) {
          return DeviceCardWidget(
            item: liveItem,
            onToggle: (bool val) => onToggleDevice(device.id),
            onLevelChanged: (double val) => onUpdateLevel(device.id, val),
          );
        },
      );
    }

    return DeviceCardWidget(
      item: device,
      onToggle: (bool val) => onToggleDevice(device.id),
      onLevelChanged: (double val) => onUpdateLevel(device.id, val),
    );
  }
}
