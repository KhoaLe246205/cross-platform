import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../models/device_item.dart';
import '../models/user_profile.dart';
import '../data/initial_data.dart';

/// Bản ghi lịch sử thao tác công việc (Activity Log)
class TaskActivity {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;

  const TaskActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    this.iconColor = const Color(0xFF10B981),
  });

  String get timeFormatted {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}

// Alias tương thích
typedef SmartHomeActivity = TaskActivity;

/// Mô hình quản lý trạng thái tập trung (Domain State Engine) của ứng dụng TaskFlow.
/// Đóng gói toàn bộ danh sách công việc, bộ lọc danh mục và ValueNotifier cho từng task.
class TaskFlowModel extends ChangeNotifier {
  List<TaskItem> _tasks;
  UserProfile _userProfile;
  String _selectedCategoryFilter = 'Tất cả';
  final List<TaskActivity> _activities = [];
  final Map<String, ValueNotifier<TaskItem>> _taskNotifiers = {};

  TaskFlowModel({
    List<TaskItem>? initialTasks,
    UserProfile? initialProfile,
  })  : _tasks = initialTasks ?? InitialData.getTasks(),
        _userProfile = initialProfile ?? InitialData.getUserProfile() {
    _addInitialActivities();
    _syncTaskNotifiers();
  }

  void _syncTaskNotifiers() {
    for (final task in _tasks) {
      if (_taskNotifiers.containsKey(task.id)) {
        _taskNotifiers[task.id]!.value = task;
      } else {
        _taskNotifiers[task.id] = ValueNotifier<TaskItem>(task);
      }
    }
  }

  ValueNotifier<TaskItem> getTaskNotifier(String id) {
    if (!_taskNotifiers.containsKey(id)) {
      final t = _tasks.firstWhere(
        (task) => task.id == id,
        orElse: () => _tasks.first,
      );
      _taskNotifiers[id] = ValueNotifier<TaskItem>(t);
    }
    return _taskNotifiers[id]!;
  }

  void _addInitialActivities() {
    _activities.add(
      TaskActivity(
        id: 'init_1',
        title: 'Hệ thống TaskFlow sẵn sàng',
        description: 'Đã tải 6 công việc trọng tâm trong tuần',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        icon: Icons.check_circle_outline,
        iconColor: const Color(0xFF10B981),
      ),
    );
  }

  // --- GETTERS DÀNH CHO WIDGETS ---

  List<TaskItem> get tasks => List.unmodifiable(_tasks);
  UserProfile get profile => _userProfile;
  bool get isEcoMode => _userProfile.isEcoMode;
  String get selectedCategoryFilter => _selectedCategoryFilter;
  List<TaskActivity> get activities => List.unmodifiable(_activities);

  // --- TƯƠNG THÍCH NGƯỢC (LEGACY COMPATIBILITY) ---
  List<DeviceItem> _legacyDevices = InitialData.getDevices();
  List<DeviceItem> get devices => _legacyDevices;
  void toggleDevice(String id) {
    _legacyDevices = _legacyDevices.map((d) {
      if (d.id == id) return d.copyWith(isEnabled: !d.isEnabled);
      return d;
    }).toList();
    notifyListeners();
  }
  void updateLevel(String id, double level) {
    _legacyDevices = _legacyDevices.map((d) {
      if (d.id == id) return d.copyWith(level: level);
      return d;
    }).toList();
    notifyListeners();
  }
  void toggleEcoMode() {
    toggleFocusMode();
    final newEco = isEcoMode;
    if (newEco) {
      _legacyDevices = _legacyDevices.map((d) {
        if (d.isEnabled && d.level > 0.6) {
          return d.copyWith(level: 0.6);
        }
        return d;
      }).toList();
    }
    notifyListeners();
  }
  double get totalPowerWatts => _legacyDevices.fold(0.0, (sum, d) => sum + d.currentPowerWatts);
  double get powerBudgetWatts => 2500.0;
  bool get isOverBudget => totalPowerWatts > powerBudgetWatts;
  ValueNotifier<DeviceItem> getDeviceNotifier(String id) {
    final dev = _legacyDevices.firstWhere((d) => d.id == id, orElse: () => _legacyDevices.first);
    return ValueNotifier<DeviceItem>(dev);
  }

  List<TaskItem> get filteredTasks {
    if (_selectedCategoryFilter == 'Tất cả') {
      return _tasks;
    }
    return _tasks.where((t) => t.category == _selectedCategoryFilter).toList();
  }

  List<TaskItem> tasksInCategory(String category) {
    return _tasks.where((t) => t.category == category).toList();
  }

  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get totalCount => _tasks.length;

  double get completionRate {
    if (_tasks.isEmpty) return 0.0;
    return (completedCount / totalCount).clamp(0.0, 1.0);
  }

  int completedCountInCategory(String category) {
    return tasksInCategory(category).where((t) => t.isCompleted).length;
  }

  // --- HÀM THAO TÁC THAY ĐỔI TRẠNG THÁI (ACTIONS) ---

  void setCategoryFilter(String category) {
    if (_selectedCategoryFilter != category) {
      _selectedCategoryFilter = category;
      notifyListeners();
    }
  }

  /// Bật/tắt trạng thái hoàn thành của 1 công việc
  void toggleTask(String id) {
    TaskItem? targetTask;
    _tasks = _tasks.map((item) {
      if (item.id == id) {
        final updated = item.copyWith(isCompleted: !item.isCompleted);
        targetTask = updated;
        return updated;
      }
      return item;
    }).toList();

    _syncTaskNotifiers();

    if (targetTask != null) {
      _logActivity(
        title: '${targetTask!.title}: ${targetTask!.isCompleted ? "Đã xong" : "Chưa xong"}',
        description: 'Danh mục: ${targetTask!.category} • Ưu tiên ${targetTask!.priority}',
        icon: targetTask!.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
        iconColor: targetTask!.isCompleted ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
      );
    }

    notifyListeners();
  }

  void updateProgress(String id, double progress) {
    _tasks = _tasks.map((item) {
      if (item.id == id) {
        return item.copyWith(progress: progress);
      }
      return item;
    }).toList();

    _syncTaskNotifiers();
    notifyListeners();
  }

  void completeAll() {
    _tasks = _tasks.map((t) => t.copyWith(isCompleted: true)).toList();
    _syncTaskNotifiers();
    _logActivity(
      title: 'Đã hoàn thành toàn bộ',
      description: 'Đánh dấu tất cả công việc đã hoàn tất',
      icon: Icons.done_all_rounded,
      iconColor: const Color(0xFF10B981),
    );
    notifyListeners();
  }

  void resetAll() {
    _tasks = _tasks.map((t) => t.copyWith(isCompleted: false)).toList();
    _syncTaskNotifiers();
    _logActivity(
      title: 'Đặt lại toàn bộ công việc',
      description: 'Chuyển toàn bộ danh sách về trạng thái chưa hoàn thành',
      icon: Icons.restart_alt_rounded,
      iconColor: const Color(0xFFF59E0B),
    );
    notifyListeners();
  }

  void toggleFocusMode() {
    _userProfile = _userProfile.copyWith(isEcoMode: !_userProfile.isEcoMode);
    _logActivity(
      title: _userProfile.isEcoMode ? 'Bật Chế độ Tập trung' : 'Tắt Chế độ Tập trung',
      description: _userProfile.isEcoMode
          ? 'Ưu tiên hiển thị các việc cấp thiết'
          : 'Hiển thị toàn bộ công việc thường nhật',
      icon: Icons.filter_center_focus_rounded,
      iconColor: _userProfile.isEcoMode ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
    );
    notifyListeners();
  }

  void applyFilterPreset(String preset) {
    switch (preset) {
      case 'today':
      case 'all':
        _selectedCategoryFilter = 'Tất cả';
        break;
      case 'study':
        _selectedCategoryFilter = 'Học tập';
        break;
      case 'sport':
      case 'personal':
        _selectedCategoryFilter = 'Thể thao';
        break;
      case 'entertain':
        _selectedCategoryFilter = 'Giải trí';
        break;
    }
    notifyListeners();
  }

  void _logActivity({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    _activities.insert(
      0,
      TaskActivity(
        id: 'act_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        timestamp: DateTime.now(),
        icon: icon,
        iconColor: iconColor,
      ),
    );
    if (_activities.length > 20) {
      _activities.removeLast();
    }
  }

  @override
  void dispose() {
    for (final notifier in _taskNotifiers.values) {
      notifier.dispose();
    }
    _taskNotifiers.clear();
    super.dispose();
  }
}

// Alias để giữ tương thích
typedef HomeEnergyModel = TaskFlowModel;
