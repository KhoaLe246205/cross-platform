import 'package:flutter/material.dart';

/// Mô hình lưu trữ dữ liệu thực tế trong bộ nhớ RAM (Decoupled RAM Store)
/// Cho phép giao diện kiểm chứng:
/// - Khi quên setState(): Biến trong RAM thay đổi ngay lập tức,
///   nhưng Widget Tree không được đánh dấu Dirty nên Giao diện đứng yên.
class RamState {
  // Trạng thái Đèn (InkWell)
  final bool lampOn;
  final double lampBrightness;
  final int lampEventCount;

  // Trạng thái Quạt (GestureDetector)
  final bool fanOn;
  final int fanSpeed; // 1, 2, 3
  final int fanEventCount;

  // Trạng thái Máy bơm (ElevatedButton + Switch)
  final bool pumpOn;
  final String pumpMode; // 'Thủ công' hoặc 'Tự động'
  final int pumpEventCount;

  const RamState({
    this.lampOn = false,
    this.lampBrightness = 0.8,
    this.lampEventCount = 0,
    this.fanOn = false,
    this.fanSpeed = 1,
    this.fanEventCount = 0,
    this.pumpOn = false,
    this.pumpMode = 'Thủ công',
    this.pumpEventCount = 0,
  });

  RamState copyWith({
    bool? lampOn,
    double? lampBrightness,
    int? lampEventCount,
    bool? fanOn,
    int? fanSpeed,
    int? fanEventCount,
    bool? pumpOn,
    String? pumpMode,
    int? pumpEventCount,
  }) {
    return RamState(
      lampOn: lampOn ?? this.lampOn,
      lampBrightness: lampBrightness ?? this.lampBrightness,
      lampEventCount: lampEventCount ?? this.lampEventCount,
      fanOn: fanOn ?? this.fanOn,
      fanSpeed: fanSpeed ?? this.fanSpeed,
      fanEventCount: fanEventCount ?? this.fanEventCount,
      pumpOn: pumpOn ?? this.pumpOn,
      pumpMode: pumpMode ?? this.pumpMode,
      pumpEventCount: pumpEventCount ?? this.pumpEventCount,
    );
  }
}

/// Controller quản lý RAM State tách rời độc lập, phát tín hiệu bằng ValueNotifier
class RamStateController extends ValueNotifier<RamState> {
  RamStateController() : super(const RamState());

  void updateLamp({bool? isOn, double? brightness, bool incrementEvent = true}) {
    value = value.copyWith(
      lampOn: isOn ?? value.lampOn,
      lampBrightness: brightness ?? value.lampBrightness,
      lampEventCount: incrementEvent ? value.lampEventCount + 1 : value.lampEventCount,
    );
  }

  void updateFan({bool? isOn, int? speed, bool incrementEvent = true}) {
    value = value.copyWith(
      fanOn: isOn ?? value.fanOn,
      fanSpeed: speed ?? value.fanSpeed,
      fanEventCount: incrementEvent ? value.fanEventCount + 1 : value.fanEventCount,
    );
  }

  void updatePump({bool? isOn, String? mode, bool incrementEvent = true}) {
    value = value.copyWith(
      pumpOn: isOn ?? value.pumpOn,
      pumpMode: mode ?? value.pumpMode,
      pumpEventCount: incrementEvent ? value.pumpEventCount + 1 : value.pumpEventCount,
    );
  }

  void turnOnAll() {
    value = value.copyWith(
      lampOn: true,
      fanOn: true,
      pumpOn: true,
      lampEventCount: value.lampEventCount + 1,
      fanEventCount: value.fanEventCount + 1,
      pumpEventCount: value.pumpEventCount + 1,
    );
  }

  void turnOffAll() {
    value = value.copyWith(
      lampOn: false,
      fanOn: false,
      pumpOn: false,
      lampEventCount: value.lampEventCount + 1,
      fanEventCount: value.fanEventCount + 1,
      pumpEventCount: value.pumpEventCount + 1,
    );
  }

  void resetAll() {
    value = const RamState();
  }
}
