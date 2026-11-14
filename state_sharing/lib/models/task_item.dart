import 'package:flutter/material.dart';

/// Đại diện cho một công việc trong ứng dụng TaskFlow (To-Do List).
class TaskItem {
  final String id;
  final String title;
  final String category;
  final IconData icon;
  final bool isCompleted;
  final String priority; // 'Cao', 'Trung bình', 'Thấp'
  final String dueDate;
  final double progress; // 0.0 - 1.0 (tiến độ chi tiết của task)

  const TaskItem({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.isCompleted,
    required this.priority,
    required this.dueDate,
    this.progress = 1.0,
  });

  Color get priorityColor {
    switch (priority) {
      case 'Cao':
        return const Color(0xFFEF4444); // Đỏ cảnh báo
      case 'Trung bình':
        return const Color(0xFFF59E0B); // Vàng hổ phách
      case 'Thấp':
      default:
        return const Color(0xFF10B981); // Xanh ngọc
    }
  }

  String get statusDisplay {
    if (isCompleted) return 'Đã hoàn thành';
    return '$dueDate · Ưu tiên $priority';
  }

  TaskItem copyWith({
    String? id,
    String? title,
    String? category,
    IconData? icon,
    bool? isCompleted,
    String? priority,
    String? dueDate,
    double? progress,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      progress: progress ?? this.progress,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          category == other.category &&
          isCompleted == other.isCompleted &&
          priority == other.priority &&
          dueDate == other.dueDate &&
          progress == other.progress;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      category.hashCode ^
      isCompleted.hashCode ^
      priority.hashCode ^
      dueDate.hashCode ^
      progress.hashCode;
}
