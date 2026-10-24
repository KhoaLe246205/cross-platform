// lib/presentation/controllers/booking_controller.dart
import 'package:flutter/foundation.dart';
import '../../core/mixins/validation_mixin.dart';
import '../../core/utils/result.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/lab_location.dart';
import '../../data/services/booking_service.dart';

class BookingRecord {
  final BookingModel ticket;
  final String attendee;
  final String time;

  const BookingRecord({
    required this.ticket,
    required this.attendee,
    required this.time,
  });
}

/// Controller áp dụng Mixin để tái sử dụng các hàm tiện ích log và thời gian
class BookingController extends ChangeNotifier with ValidationAndLogMixin {
  // Khởi tạo dịch vụ đặt vé và kết nối kênh nhận log lỗi
  late final BookingService _bookingService = BookingService(
    onLogRecorded: (log) {
      errorLogs.value = [log, ...errorLogs.value];
    },
  );

  // Sử dụng Named Constructor BookingModel.empty() làm trạng thái ban đầu của vé gần nhất
  BookingModel lastBookedTicket = const BookingModel.empty();

  final Map<String, LabLocation> labLocations = {
    'Hội thảo SoC & FPGA': LabLocation(name: 'Hội thảo SoC & FPGA', room: 'Hội trường A'),
    'Phòng Lab AI & IoT': LabLocation(name: 'Phòng Lab AI & IoT', room: 'Phòng Lab 204'),
    'Phòng Lab 404 (Sự cố API)': LabLocation(name: 'Phòng Lab 404 (Sự cố API)', room: 'Server 404'),
  };

  LabLocation getLocation(String labName) => labLocations.putIfAbsent(
        labName, () => LabLocation(name: labName, room: 'Phòng thực hành'));

  bool isLoading = false;
  String statusMessage = 'Hệ thống sẵn sàng nhận đặt vé';
  bool isLastActionSuccess = true;
  final List<BookingRecord> history = [];
  final ValueNotifier<List<String>> errorLogs = ValueNotifier<List<String>>([]);

  /// Tiếp nhận các lỗi ngoài dự kiến từ lưới an toàn toàn cục của ứng dụng
  void recordExternalError(String source, Object error) {
    final time = formatCurrentTime();
    errorLogs.value = ['[$time] [GomLỗi] -> [$source] $error', ...errorLogs.value];
  }

  /// Xử lý đặt vé và điều phối trạng thái giữa giao diện và dịch vụ
  Future<void> bookTicket({
    required int amount,
    required TicketType type,
    required String attendee,
    required String labEvent,
  }) async {
    // Khóa tác vụ nếu đang có yêu cầu xử lý dở dang
    if (isLoading) return;

    final location = getLocation(labEvent);

    isLoading = true;
    statusMessage = 'Đang xử lý giữ chỗ tại [$labEvent]...';
    notifyListeners();

    logInfo('BookingController', 'Người dùng $attendee yêu cầu đặt $amount vé tại $labEvent');

    final result = await _bookingService.bookTicket(
      amount: amount,
      type: type,
      location: location,
    );

    isLoading = false;

    // Xử lý kết quả bằng Dart 3 Pattern Matching trên Sealed Class Result<T>
    switch (result) {
      case Success(:final data):
        isLastActionSuccess = true;
        lastBookedTicket = data;

        // Khấu trừ số vé qua phương thức của chính LabLocation
        location.deductSeats(type, data.amount);

        final now = formatCurrentTime();
        history.insert(0, BookingRecord(ticket: data, attendee: attendee, time: now));
        statusMessage = 'Đặt thành công cho $attendee tại $labEvent (${data.amount} vé - Mã: ${data.id})';

      case Failure(:final error):
        isLastActionSuccess = false;
        statusMessage = error.message;
    }

    notifyListeners();
  }
}
