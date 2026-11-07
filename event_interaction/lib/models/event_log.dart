import 'package:flutter/material.dart';

enum EventLogType {
  tap,
  doubleTap,
  longPress,
  onPressed,
  onChanged,
  warning,
  system,
}

class EventLogItem {
  final DateTime timestamp;
  final String widgetName;
  final String callback;
  final String result;
  final EventLogType type;

  const EventLogItem({
    required this.timestamp,
    required this.widgetName,
    required this.callback,
    required this.result,
    required this.type,
  });

  Color get color {
    switch (type) {
      case EventLogType.tap:
        return const Color(0xFF10B981); // Xanh lá / Teal
      case EventLogType.doubleTap:
        return const Color(0xFFA855F7); // Tím Purple
      case EventLogType.longPress:
        return const Color(0xFFF59E0B); // Cam Amber
      case EventLogType.onPressed:
        return const Color(0xFF3B82F6); // Xanh dương Blue
      case EventLogType.onChanged:
        return const Color(0xFF06B6D4); // Cyan
      case EventLogType.warning:
        return const Color(0xFFEF4444); // Đỏ Red
      case EventLogType.system:
        return const Color(0xFF94A3B8); // Xám Slate
    }
  }

  String get timeFormatted {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    final ms = (timestamp.millisecond ~/ 100).toString();
    return '$h:$m:$s.$ms';
  }
}
