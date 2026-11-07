import 'package:flutter/material.dart';
import '../models/device_model.dart';

/// Dữ liệu mẫu 3 thiết bị Nhà Thông Minh Mini
/// Khớp chuẩn xác theo yêu cầu đề tài:
/// 1. Đèn phòng khách
/// 2. Quạt thông gió
/// 3. Máy bơm tưới cây
List<DeviceModel> getSampleDevices() {
  return [
    DeviceModel(
      id: 'LIGHT-01',
      name: 'Đèn phòng khách',
      location: 'Khu vực tiếp khách',
      icon: Icons.lightbulb_rounded,
      activeColor: const Color(0xFFF59E0B), // Vàng Amber ấm áp
      isActive: true,
      level: 0.8,
      tapCount: 3,
      mode: 'Ánh sáng ấm',
    ),
    DeviceModel(
      id: 'FAN-01',
      name: 'Quạt thông gió',
      location: 'Phòng khách / Bếp',
      icon: Icons.air_rounded,
      activeColor: const Color(0xFF06B6D4), // Xanh Cyan mát mẻ
      isActive: false,
      level: 0.4,
      tapCount: 1,
      mode: 'Gió tự nhiên',
    ),
    DeviceModel(
      id: 'PUMP-01',
      name: 'Máy bơm tưới cây',
      location: 'Ban công / Sân vườn',
      icon: Icons.water_drop_rounded,
      activeColor: const Color(0xFF3B82F6), // Xanh dương tươi mát
      isActive: false,
      level: 0.6,
      tapCount: 0,
      mode: 'Tưới nhỏ giọt',
    ),
  ];
}
