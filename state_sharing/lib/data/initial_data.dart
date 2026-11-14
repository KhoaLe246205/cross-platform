import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../models/device_item.dart';
import '../models/user_profile.dart';

class InitialData {
  static const List<String> categories = [
    'Học tập',
    'Thể thao',
    'Giải trí',
  ];

  // Alias để giữ tương thích
  static const List<String> rooms = [
    'Phòng Khách',
    'Phòng Ngủ',
    'Phòng Làm Việc',
  ];

  static List<DeviceItem> getDevices() {
    return const [
      DeviceItem(
        id: 'living_lamp',
        name: 'Đèn chùm thông minh',
        room: 'Phòng Khách',
        icon: Icons.lightbulb_outline,
        isEnabled: true,
        basePowerWatts: 45.0,
        level: 0.8,
      ),
      DeviceItem(
        id: 'living_ac',
        name: 'Điều hòa 2 chiều Inverter',
        room: 'Phòng Khách',
        icon: Icons.ac_unit_outlined,
        isEnabled: true,
        basePowerWatts: 850.0,
        level: 0.6,
      ),
      DeviceItem(
        id: 'bed_lamp',
        name: 'Đèn ngủ dịu nhẹ',
        room: 'Phòng Ngủ',
        icon: Icons.bedtime_outlined,
        isEnabled: false,
        basePowerWatts: 15.0,
        level: 0.4,
      ),
      DeviceItem(
        id: 'bed_fan',
        name: 'Quạt thông gió tự động',
        room: 'Phòng Ngủ',
        icon: Icons.air_outlined,
        isEnabled: true,
        basePowerWatts: 40.0,
        level: 0.5,
      ),
      DeviceItem(
        id: 'studio_monitor',
        name: 'Màn hình làm việc 4K',
        room: 'Phòng Làm Việc',
        icon: Icons.desktop_windows_outlined,
        isEnabled: true,
        basePowerWatts: 65.0,
        level: 0.9,
      ),
      DeviceItem(
        id: 'work_speaker',
        name: 'Loa kiểm âm Bluetooth',
        room: 'Phòng Làm Việc',
        icon: Icons.speaker_outlined,
        isEnabled: false,
        basePowerWatts: 30.0,
        level: 0.3,
      ),
    ];
  }

  static List<TaskItem> getTasks() {
    return const [
      // 1. Học tập
      TaskItem(
        id: 'task_review',
        title: 'Ôn lại bài cũ',
        category: 'Học tập',
        icon: Icons.menu_book_rounded,
        isCompleted: true,
        priority: 'Cao',
        dueDate: 'Hôm nay · 19:00',
        progress: 0.9,
      ),
      TaskItem(
        id: 'task_english',
        title: 'Học tiếng Anh',
        category: 'Học tập',
        icon: Icons.language_rounded,
        isCompleted: true,
        priority: 'Cao',
        dueDate: 'Hôm nay · 21:00',
        progress: 0.8,
      ),

      // 2. Thể thao
      TaskItem(
        id: 'task_gym',
        title: 'Gym',
        category: 'Thể thao',
        icon: Icons.fitness_center_rounded,
        isCompleted: false,
        priority: 'Trung bình',
        dueDate: 'Chiều nay · 17:00',
        progress: 0.5,
      ),
      TaskItem(
        id: 'task_running',
        title: 'Chạy bộ',
        category: 'Thể thao',
        icon: Icons.directions_run_rounded,
        isCompleted: true,
        priority: 'Trung bình',
        dueDate: 'Sáng mai · 06:00',
        progress: 0.7,
      ),

      // 3. Giải trí
      TaskItem(
        id: 'task_tiktok',
        title: 'Lướt TikTok',
        category: 'Giải trí',
        icon: Icons.smart_display_outlined,
        isCompleted: true,
        priority: 'Thấp',
        dueDate: 'Tối nay · 22:30',
        progress: 1.0,
      ),
      TaskItem(
        id: 'task_gaming',
        title: 'Chơi game',
        category: 'Giải trí',
        icon: Icons.sports_esports_rounded,
        isCompleted: false,
        priority: 'Thấp',
        dueDate: 'Cuối tuần · 20:00',
        progress: 0.3,
      ),
    ];
  }

  static UserProfile getUserProfile() {
    return const UserProfile(
      fullName: 'Lê Anh Khoa & Ngô Quang Thế',
      role: 'Quản trị viên (23KTMT1)',
      powerBudgetWatts: 100.0,
      isEcoMode: false,
    );
  }
}
