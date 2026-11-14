import 'package:flutter/material.dart';

/// Đại diện cho một thiết bị IoT trong ngôi nhà thông minh.
class DeviceItem {
  final String id;
  final String name;
  final String room;
  final IconData icon;
  final bool isEnabled;
  final double basePowerWatts;
  final double level; // 0.0 - 1.0 (độ sáng đèn, nhiệt độ điều hòa, âm lượng loa,...)

  const DeviceItem({
    required this.id,
    required this.name,
    required this.room,
    required this.icon,
    required this.isEnabled,
    required this.basePowerWatts,
    this.level = 0.5,
  });

  /// Tính công suất thực tế dựa trên trạng thái bật/tắt và mức điều chỉnh (level).
  double get currentPowerWatts {
    if (!isEnabled) return 0.0;
    // Công suất dao động từ 40% đến 100% theo thanh trượt level
    return basePowerWatts * (0.4 + 0.6 * level);
  }

  /// Mô tả trạng thái thân thiện cho người dùng trên giao diện
  String get statusDisplay {
    if (!isEnabled) return 'Đang tắt';
    if (id.contains('ac')) {
      final temp = 16 + (level * 14).round(); // 16 - 30 độ C
      return 'Làm mát • $temp°C';
    }
    if (id.contains('lamp')) {
      return 'Độ sáng ${(level * 100).round()}%';
    }
    if (id.contains('speaker')) {
      return 'Âm lượng ${(level * 100).round()}%';
    }
    if (id.contains('purifier')) {
      return 'Lọc HEPA • ${(level * 100).round()}%';
    }
    if (id.contains('monitor')) {
      return 'Độ sáng ${(level * 100).round()}%';
    }
    return 'Mức ${(level * 100).round()}%';
  }

  DeviceItem copyWith({
    String? id,
    String? name,
    String? room,
    IconData? icon,
    bool? isEnabled,
    double? basePowerWatts,
    double? level,
  }) {
    return DeviceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      room: room ?? this.room,
      icon: icon ?? this.icon,
      isEnabled: isEnabled ?? this.isEnabled,
      basePowerWatts: basePowerWatts ?? this.basePowerWatts,
      level: level ?? this.level,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          room == other.room &&
          isEnabled == other.isEnabled &&
          basePowerWatts == other.basePowerWatts &&
          level == other.level;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      room.hashCode ^
      isEnabled.hashCode ^
      basePowerWatts.hashCode ^
      level.hashCode;
}
