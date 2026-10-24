// lib/data/services/booking_service.dart
import '../../core/error/app_exception.dart';
import '../../core/mixins/validation_mixin.dart';
import '../../core/utils/result.dart';
import '../models/booking_model.dart';
import '../models/lab_location.dart';

/// Module quản lý dữ liệu đặt vé
/// Áp dụng Mixin để tái sử dụng logic kiểm tra tính hợp lệ và ghi log
class BookingService with ValidationAndLogMixin {
  final void Function(String log)? onLogRecorded;

  BookingService({this.onLogRecorded});

  /// HÀM BAO BỌC (WRAPPER FUNCTION): Bắt và gom lỗi tập trung
  /// Áp dụng kỹ thuật Generics `<T>` và cấu trúc try-catch-finally
  Future<Result<T>> errorWrapper<T>(
    Future<T> Function() action, {
    String actionName = 'Tác vụ',
  }) async {
    logInfo('Wrapper', 'Bắt đầu thực thi: $actionName');
    try {
      final data = await action();
      return Result.success(data);
    } on AppException catch (e) {
      _recordError(e.toString());
      return Result.failure(e);
    } catch (e, stackTrace) {
      // Tách biệt: Thông báo thân thiện cho người dùng trên UI, chi tiết kỹ thuật thô đưa vào log kèm StackTrace
      _recordError('Ngoại lệ hệ thống chưa bắt: $e\n$stackTrace');
      const friendlyErr = UnknownException('Đã có lỗi xảy ra trong quá trình xử lý, vui lòng thử lại.');
      return Result.failure(friendlyErr);
    } finally {
      // Khối finally luôn thực thi để giải phóng tài nguyên và in log kết thúc
      logInfo('Wrapper', 'Hoàn tất phiên xử lý: $actionName');
    }
  }

  void _recordError(String errorMsg) {
    final time = formatCurrentTime();
    onLogRecorded?.call('[$time] [GomLỗi] -> $errorMsg');
  }

  /// Xử lý đặt vé: Nhận đối tượng LabLocation để kiểm tra hạn mức chỗ ngồi
  Future<Result<BookingModel>> bookTicket({
    required int amount,
    required TicketType type,
    required LabLocation location,
  }) {
    return errorWrapper<BookingModel>(
      () async {
        // 1. Áp dụng Mixin kiểm tra số lượng vé hợp lệ (> 0)
        validateTicketCount(amount);

        // 2. Kiểm tra số lượng ghế trống theo quy định của phòng lab
        location.checkAvailability(type, amount);

        // 3. Giả lập độ trễ mạng
        await Future.delayed(const Duration(milliseconds: 500));

        // 4. Giả lập lỗi API trả về JSON hỏng khi chọn Phòng Lab 404
        if (location.name.contains('404')) {
          final corruptedJson = {'invalid_key': 'corrupted_payload'};
          return BookingModel.fromJson(corruptedJson);
        }

        // 5. Giả lập lỗi mất kết nối máy chủ khi đặt số vé VIP lớn (> 10 vé)
        if (type == TicketType.vip && amount > 10) {
          throw const NetworkException('Mất kết nối tới máy chủ xác thực đặc quyền vé VIP');
        }

        // 6. Thành công: Giả lập phản hồi JSON từ máy chủ
        final responseData = {
          'id': type == TicketType.vip ? 'VIP_999' : 'STD_888',
          'amount': amount,
          'type': type.name,
          'labEvent': location.name,
        };

        return BookingModel.fromJson(responseData);
      },
      actionName: 'Đặt vé [${location.name}]',
    );
  }
}
