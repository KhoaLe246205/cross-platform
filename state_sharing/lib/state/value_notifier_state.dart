import 'package:flutter/material.dart';
import '../models/device_item.dart';
import '../models/user_profile.dart';
import '../data/initial_data.dart';

/// Quản lý trạng thái phân mảnh (Granular Reactive State) sử dụng ValueNotifier<T>.
/// Cho phép các widget con chỉ bọc ValueListenableBuilder ở đúng thành phần cần hiển thị lại.
class ValueNotifierHomeState {
  final ValueNotifier<List<DeviceItem>> devicesNotifier;
  final ValueNotifier<UserProfile> profileNotifier;
  final ValueNotifier<bool> ecoNotifier;
  final Map<String, ValueNotifier<DeviceItem>> _deviceItemNotifiers = {};

  ValueNotifierHomeState({
    List<DeviceItem>? initialDevices,
    UserProfile? initialProfile,
  })  : devicesNotifier = ValueNotifier<List<DeviceItem>>(
          initialDevices ?? InitialData.getDevices(),
        ),
        profileNotifier = ValueNotifier<UserProfile>(
          initialProfile ?? InitialData.getUserProfile(),
        ),
        ecoNotifier = ValueNotifier<bool>(
          (initialProfile ?? InitialData.getUserProfile()).isEcoMode,
        ) {
    _initDeviceNotifiers(devicesNotifier.value);
  }

  void _initDeviceNotifiers(List<DeviceItem> items) {
    for (final item in items) {
      _deviceItemNotifiers[item.id] = ValueNotifier<DeviceItem>(item);
    }
  }

  /// Lấy ValueNotifier riêng biệt của từng thiết bị để bọc ValueListenableBuilder tại lá cây.
  ValueNotifier<DeviceItem> getDeviceNotifier(String id) {
    if (!_deviceItemNotifiers.containsKey(id)) {
      final item = devicesNotifier.value.firstWhere(
        (d) => d.id == id,
        orElse: () => InitialData.getDevices().first,
      );
      _deviceItemNotifiers[id] = ValueNotifier<DeviceItem>(item);
    }
    return _deviceItemNotifiers[id]!;
  }

  /// Tính tổng công suất tiêu thụ hiện tại (Watts).
  double get totalPowerWatts {
    return devicesNotifier.value.fold(
      0.0,
      (sum, item) => sum + item.currentPowerWatts,
    );
  }

  /// Bật/tắt một thiết bị và phát thông báo giá trị mới.
  void toggleDevice(String id) {
    final currentList = devicesNotifier.value;
    DeviceItem? updatedDevice;

    final updatedList = currentList.map((item) {
      if (item.id == id) {
        updatedDevice = item.copyWith(isEnabled: !item.isEnabled);
        return updatedDevice!;
      }
      return item;
    }).toList();

    devicesNotifier.value = updatedList;
    if (updatedDevice != null && _deviceItemNotifiers.containsKey(id)) {
      _deviceItemNotifiers[id]!.value = updatedDevice!;
    }
  }

  /// Cập nhật mức độ hoạt động (slider level: độ sáng, âm lượng, nhiệt độ).
  void updateLevel(String id, double level) {
    final currentList = devicesNotifier.value;
    DeviceItem? updatedDevice;

    final updatedList = currentList.map((item) {
      if (item.id == id) {
        updatedDevice = item.copyWith(level: level);
        return updatedDevice!;
      }
      return item;
    }).toList();

    devicesNotifier.value = updatedList;
    if (updatedDevice != null && _deviceItemNotifiers.containsKey(id)) {
      _deviceItemNotifiers[id]!.value = updatedDevice!;
    }
  }

  /// Bật/tắt chế độ tiết kiệm năng lượng Eco Mode.
  void toggleEcoMode() {
    final newEco = !ecoNotifier.value;
    ecoNotifier.value = newEco;
    profileNotifier.value = profileNotifier.value.copyWith(isEcoMode: newEco);

    if (newEco) {
      // Khi bật Eco Mode: tự động hạ công suất các thiết bị đang bật xuống mức tối đa 60%
      final currentList = devicesNotifier.value;
      final updatedList = currentList.map((item) {
        if (item.isEnabled && item.level > 0.6) {
          final updated = item.copyWith(level: 0.6);
          if (_deviceItemNotifiers.containsKey(item.id)) {
            _deviceItemNotifiers[item.id]!.value = updated;
          }
          return updated;
        }
        return item;
      }).toList();
      devicesNotifier.value = updatedList;
    }
  }

  /// Đặt lại toàn bộ dữ liệu về trạng thái ban đầu.
  void reset() {
    final initDevs = InitialData.getDevices();
    devicesNotifier.value = initDevs;
    for (final item in initDevs) {
      if (_deviceItemNotifiers.containsKey(item.id)) {
        _deviceItemNotifiers[item.id]!.value = item;
      }
    }
    final defProfile = InitialData.getUserProfile();
    profileNotifier.value = defProfile;
    ecoNotifier.value = defProfile.isEcoMode;
  }

  void dispose() {
    devicesNotifier.dispose();
    profileNotifier.dispose();
    ecoNotifier.dispose();
    for (final notifier in _deviceItemNotifiers.values) {
      notifier.dispose();
    }
    _deviceItemNotifiers.clear();
  }
}
