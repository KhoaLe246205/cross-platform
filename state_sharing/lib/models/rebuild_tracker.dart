import 'package:flutter/widgets.dart';

/// Bộ theo dõi và ghi nhận số lần rebuild của từng thành phần widget trên cây giao diện.
class RebuildTracker with ChangeNotifier {
  static final RebuildTracker instance = RebuildTracker._internal();
  RebuildTracker._internal();

  final Map<String, int> _counts = {};
  final List<String> _recentRebuilds = [];
  bool _notificationScheduled = false;

  int getCount(String widgetId) => _counts[widgetId] ?? 0;

  int get totalRebuilds => _counts.values.fold(0, (sum, count) => sum + count);

  Map<String, int> get allCounts => Map.unmodifiable(_counts);

  List<String> get recentRebuilds => List.unmodifiable(_recentRebuilds);

  int record(String widgetId) {
    final next = (_counts[widgetId] ?? 0) + 1;
    _counts[widgetId] = next;
    _recentRebuilds.insert(0, widgetId);
    if (_recentRebuilds.length > 20) {
      _recentRebuilds.removeLast();
    }
    // Lên lịch thông báo sau khi hoàn thành frame vẽ để cập nhật các thanh thống kê mà không vi phạm quy tắc build()
    if (!_notificationScheduled) {
      _notificationScheduled = true;
      try {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _notificationScheduled = false;
          notifyListeners();
        });
      } catch (_) {
        // Dự phòng cho môi trường unit test thuần túy không có WidgetsBinding
        _notificationScheduled = false;
        notifyListeners();
      }
    }
    return next;
  }

  void reset() {
    _counts.clear();
    _recentRebuilds.clear();
    notifyListeners();
  }
}
