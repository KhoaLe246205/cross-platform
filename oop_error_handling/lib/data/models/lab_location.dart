// lib/data/models/lab_location.dart
import '../../core/error/app_exception.dart';
import 'booking_model.dart';

/// Model quản lý thông tin và số lượng chỗ ngồi của từng địa điểm / Phòng Lab
class LabLocation {
  final String name;
  final String room;
  int availableVipSeats;
  int availableStandardSeats;

  static const int maxVipSeats = 15;
  static const int maxStandardSeats = 35;

  LabLocation({
    required this.name,
    required this.room,
    this.availableVipSeats = maxVipSeats,
    this.availableStandardSeats = maxStandardSeats,
  });

  int get availableSeats => availableVipSeats + availableStandardSeats;

  /// Kiểm tra số lượng vé còn trống theo từng hạng vé
  void checkAvailability(TicketType type, int amount) {
    if (type == TicketType.vip && amount > availableVipSeats) {
      throw BusinessLogicException(
        'Không đủ vé VIP tại [$name]! (Yêu cầu: $amount vé, Còn lại: $availableVipSeats/$maxVipSeats vé VIP)',
      );
    }
    if (type == TicketType.standard && amount > availableStandardSeats) {
      throw BusinessLogicException(
        'Không đủ vé Tiêu chuẩn tại [$name]! (Yêu cầu: $amount vé, Còn lại: $availableStandardSeats/$maxStandardSeats vé Tiêu chuẩn)',
      );
    }
  }

  /// Khấu trừ số lượng chỗ ngồi sau khi đặt thành công
  void deductSeats(TicketType type, int amount) {
    if (type == TicketType.vip) {
      availableVipSeats -= amount;
    } else {
      availableStandardSeats -= amount;
    }
  }
}
