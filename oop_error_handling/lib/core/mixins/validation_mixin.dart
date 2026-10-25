// lib/core/mixins/validation_mixin.dart
import 'package:flutter/foundation.dart';
import '../error/app_exception.dart';

/// Mixin: Tái sử dụng tính năng kiểm tra tính hợp lệ, định dạng thời gian và in log
/// Được chia sẻ và tái sử dụng ngang giữa BookingService và BookingController
mixin ValidationAndLogMixin {
  /// Kiểm tra số lượng vé phải là số nguyên dương (> 0)
  void validateTicketCount(int count) {
    if (count <= 0) {
      throw const BusinessLogicException('Số lượng vé phải lớn hơn 0');
    }
  }

  /// Định dạng mốc thời gian chuẩn (HH:mm:ss) dùng chung toàn hệ thống
  String formatCurrentTime() {
    return DateTime.now().toIso8601String().substring(11, 19);
  }

  /// Tự động in log chuẩn hóa với mốc thời gian
  void logInfo(String tag, String message) {
    debugPrint('[${formatCurrentTime()}] [INFO] [$tag]: $message');
  }
}
