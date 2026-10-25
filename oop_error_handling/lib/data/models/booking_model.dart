// lib/data/models/booking_model.dart
import '../../core/error/app_exception.dart';

enum TicketType { standard, vip }

/// Model quản lý dữ liệu vé sự kiện
class BookingModel {
  static const String defaultLabEvent = 'Hội thảo SoC & FPGA';

  final String id;
  final int amount; // Số lượng vé dạng số nguyên (int)
  final TicketType type;
  final String labEvent;

  const BookingModel({
    required this.id,
    required this.amount,
    required this.type,
    this.labEvent = defaultLabEvent,
  });

  // 1. Named Constructor: Khởi tạo vé rỗng mặc định linh hoạt
  const BookingModel.empty()
      : id = 'N/A',
        amount = 0,
        type = TicketType.standard,
        labEvent = 'Chưa có thông tin';

  // 2. Factory Constructor: Áp dụng Dart 3 Pattern Matching để chuyển đổi từ Map/JSON
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    if (json case {'id': final id, 'amount': int amount}) {
      try {
        final rawType = json['type']?.toString() ?? 'standard';
        return BookingModel(
          id: '$id',
          amount: amount,
          type: TicketType.values.byName(rawType),
          labEvent: (json['labEvent'] as String?) ?? defaultLabEvent,
        );
      } on ArgumentError {
        throw DataFormatException('Loại vé "${json['type']}" không tồn tại');
      } on TypeError {
        throw const DataFormatException('Dữ liệu JSON sai kiểu dữ liệu');
      }
    }
    throw const DataFormatException('Dữ liệu máy chủ bị lỗi');
  }
}
