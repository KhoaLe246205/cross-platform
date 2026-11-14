import 'app_mode.dart';

/// Đại diện cho một sự kiện luồng dữ liệu khi có tương tác người dùng.
class DataFlowEvent {
  final DateTime timestamp;
  final String sourceWidget;
  final String action;
  final String pathDescription;
  final StateSharingMode mode;
  final int affectedWidgetCount;

  const DataFlowEvent({
    required this.timestamp,
    required this.sourceWidget,
    required this.action,
    required this.pathDescription,
    required this.mode,
    required this.affectedWidgetCount,
  });
}
