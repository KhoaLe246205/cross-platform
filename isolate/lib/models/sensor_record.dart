import 'dart:math';

class SensorRecord {
  final int id;
  final String deviceCode;

  SensorRecord(this.id, this.deviceCode);

  // Hàm cơ bản: Đọc Map từ JSON và chạy vòng lặp toán học nặng trên CPU
  static SensorRecord parseAndCalculate(Map<String, dynamic> json) {
    int id = json['id'];
    String code = json['deviceCode'];
    List<dynamic> readings = json['readings'];

    // Giữ nguyên công thức toán học chuẩn của bản gốc để vắt kiệt 1 nhân CPU i7-13th H
    // mà không làm tràn bộ nhớ RAM (không gây giật lag cho các Isolate khác)
    double acc = 0.0;
    for (int round = 0; round < 25; round++) {
      for (int i = 0; i < readings.length; i++) {
        double val = (readings[i] as num).toDouble();
        acc += sqrt(val.abs() + round) * sin(val) * cos(val / (round + 1));
      }
    }

    // Gán nhẹ vào điều kiện không bao giờ xảy ra nhưng KHÔNG dùng print()
    if (acc == 123456789.987) {
      return SensorRecord(-1, '');
    }

    return SensorRecord(id, code);
  }
}