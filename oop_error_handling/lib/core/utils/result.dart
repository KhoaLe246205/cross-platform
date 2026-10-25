// lib/core/utils/result.dart
import '../error/app_exception.dart';

/// Lớp Generic sử dụng Sealed Class trong Dart 3
/// Bắt buộc xử lý triệt để hai nhánh Success và Failure qua Pattern Matching
sealed class Result<T> {
  const Result();

  // Redirecting factory constructors: tên gọi rõ nghĩa, trả về thể hiện của Success hoặc Failure
  factory Result.success(T data) = Success<T>;
  factory Result.failure(AppException error) = Failure<T>;
}

/// Trạng thái thực thi thành công chứa dữ liệu trả về
final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Trạng thái thực thi thất bại chứa thông tin ngoại lệ
final class Failure<T> extends Result<T> {
  final AppException error;
  const Failure(this.error);
}
