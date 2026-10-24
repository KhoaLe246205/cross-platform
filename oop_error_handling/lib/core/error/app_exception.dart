// lib/core/error/app_exception.dart

/// Lớp cơ sở định nghĩa ngoại lệ tùy biến (Custom Exception)
abstract class AppException implements Exception {
  final String message;
  final String code;

  const AppException(this.message, {required this.code});

  @override
  String toString() => '[$code] $message';
}

/// Ngoại lệ mất kết nối mạng hoặc máy chủ không phản hồi
class NetworkException extends AppException {
  const NetworkException(super.message) : super(code: 'NET_ERR');
}

/// Ngoại lệ định dạng dữ liệu (Parse Map/JSON thất bại, sai cấu trúc)
class DataFormatException extends AppException {
  const DataFormatException(super.message) : super(code: 'PARSE_ERR');
}

/// Ngoại lệ quy tắc nghiệp vụ (Vượt hạn mức số lượng vé, không hợp lệ)
class BusinessLogicException extends AppException {
  const BusinessLogicException(super.message) : super(code: 'BIZ_ERR');
}

/// Ngoại lệ cho các lỗi hệ thống không lường trước
class UnknownException extends AppException {
  const UnknownException(super.message) : super(code: 'UNKNOWN_ERR');
}
