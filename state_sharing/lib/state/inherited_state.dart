import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../models/user_profile.dart';
import 'change_notifier_state.dart';

/// Triển khai cơ chế chia sẻ trạng thái bằng InheritedWidget trong TaskFlow.
/// Cung cấp dữ liệu danh sách công việc và hàm thao tác xuống toàn bộ cây con với độ phức tạp O(1) qua Context.
class TaskScope extends InheritedWidget {
  final List<TaskItem> tasks;
  final UserProfile userProfile;
  final bool isFocusMode;
  final ValueChanged<String> onToggleTask;
  final void Function(String id, double progress) onUpdateProgress;
  final VoidCallback? onToggleFocus;
  final TaskFlowModel? model;

  const TaskScope({
    super.key,
    required this.tasks,
    required this.userProfile,
    this.isFocusMode = false,
    required this.onToggleTask,
    required this.onUpdateProgress,
    this.onToggleFocus,
    this.model,
    required super.child,
  });

  static TaskScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TaskScope>();
    assert(scope != null, 'Không tìm thấy TaskScope trong cây ngữ cảnh BuildContext');
    return scope!;
  }

  static TaskScope read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<TaskScope>();
    assert(scope != null, 'Không tìm thấy TaskScope trong cây ngữ cảnh BuildContext');
    return scope!;
  }

  @override
  bool updateShouldNotify(TaskScope oldWidget) {
    return tasks != oldWidget.tasks ||
        userProfile != oldWidget.userProfile ||
        isFocusMode != oldWidget.isFocusMode ||
        model != oldWidget.model;
  }
}

// Alias để giữ tương thích
typedef EcoHomeScope = TaskScope;
