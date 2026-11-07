import 'package:flutter/material.dart';

/// Mô hình dữ liệu Thiết bị Nhà thông minh (Smart Home Device)
/// Đại diện cho TRẠNG THÁI (State) được lưu giữ trong RAM qua thời gian: UI = f(State)
class DeviceModel {
  final String id;
  final String name;
  final String location;
  final IconData icon;
  final Color activeColor;

  // CÁC BIẾN TRẠNG THÁI (State Variables)
  bool isActive; // Bật / Tắt thiết bị
  double level; // 0.0 -> 1.0 (Độ sáng đèn, tốc độ quạt, lưu lượng máy bơm)
  int tapCount; // Số lần tương tác với thiết bị
  String mode; // Chế độ hoạt động (VD: Tiêu chuẩn, Tăng áp, Tiết kiệm)

  DeviceModel({
    required this.id,
    required this.name,
    required this.location,
    required this.icon,
    required this.activeColor,
    this.isActive = false,
    this.level = 0.5,
    this.tapCount = 0,
    this.mode = 'Tiêu chuẩn',
  });

  /// Nhãn hiển thị giá trị mức độ theo từng loại thiết bị
  String get levelLabel {
    final percent = (level * 100).toInt();
    if (id.startsWith('LIGHT')) {
      return 'Độ sáng: $percent%';
    } else if (id.startsWith('FAN')) {
      int speed = (level * 3).ceil().clamp(1, 3);
      return 'Tốc độ: Cấp $speed ($percent%)';
    } else {
      return 'Lưu lượng: ${(level * 10).toStringAsFixed(1)} L/phút';
    }
  }
}
