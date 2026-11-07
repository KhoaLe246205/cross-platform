import 'package:flutter/material.dart';
import '../models/event_log.dart';
import '../models/ram_state.dart';
import '../widgets/event_console.dart';
import '../widgets/fan_card.dart';
import '../widgets/lamp_card.dart';
import '../widgets/pipeline_flow.dart';
import '../widgets/pump_card.dart';
import '../widgets/state_comparison.dart';

/// Màn hình chính Smart Home Dashboard
/// Thiết kế tinh gọn như sản phẩm thương mại bàn giao khách hàng.
/// Các công cụ kiểm chứng lý thuyết (Luồng 4 bước, So sánh RAM vs UI, Thí nghiệm Quên setState)
/// được ẩn gọn gàng vào "Chế độ Dev" bên cột phải, bật/tắt bằng nút trên Header.
class SmartHomeDashboardScreen extends StatefulWidget {
  const SmartHomeDashboardScreen({super.key});

  @override
  State<SmartHomeDashboardScreen> createState() =>
      _SmartHomeDashboardScreenState();
}

class _SmartHomeDashboardScreenState extends State<SmartHomeDashboardScreen> {
  // Trạng thái mở / đóng Chế độ Dev (Mặc định đóng)
  bool _isDevModeOpen = false;

  // 1. Controller quản lý RAM State độc lập (ValueNotifier)
  final RamStateController _ramController = RamStateController();

  // 2. Controller quản lý Dải luồng 4 bước
  final PipelineController _pipelineController = PipelineController();

  // 3. Trạng thái hiển thị thực tế trên UI (Chỉ cập nhật khi gọi setState())
  bool _uiLampOn = false;
  double _uiLampBrightness = 0.8;

  bool _uiFanOn = false;
  int _uiFanSpeed = 1;

  bool _uiPumpOn = false;
  String _uiPumpMode = 'Thủ công';

  // 4. Biến cờ mô phỏng lỗi "Quên gọi setState()"
  bool _simulateForgetSetState = false;

  // 5. Bộ đếm số lần build()
  int _totalBuildCount = 0;
  int _lampBuildCount = 0;
  int _fanBuildCount = 0;
  int _pumpBuildCount = 0;

  // 6. Danh sách nhật ký sự kiện thời gian thực
  final List<EventLogItem> _logs = [];

  @override
  void initState() {
    super.initState();
    _addLog(
      widgetName: 'Hệ thống',
      callback: 'initState()',
      result: 'Hệ thống Smart Home sẵn sàng kết nối',
      type: EventLogType.system,
    );
  }

  @override
  void dispose() {
    _ramController.dispose();
    _pipelineController.dispose();
    super.dispose();
  }

  // Helper thêm log
  void _addLog({
    required String widgetName,
    required String callback,
    required String result,
    required EventLogType type,
  }) {
    setState(() {
      _logs.add(
        EventLogItem(
          timestamp: DateTime.now(),
          widgetName: widgetName,
          callback: callback,
          result: result,
          type: type,
        ),
      );
    });
  }

  // Đồng bộ UI từ RAM khi gọi setState()
  void _syncUiFromRam() {
    final ram = _ramController.value;
    _uiLampOn = ram.lampOn;
    _uiLampBrightness = ram.lampBrightness;
    _uiFanOn = ram.fanOn;
    _uiFanSpeed = ram.fanSpeed;
    _uiPumpOn = ram.pumpOn;
    _uiPumpMode = ram.pumpMode;
    _totalBuildCount++;
  }

  // ===========================================================================
  // THIẾT BỊ 1: ĐÈN (InkWell) - onTap & onLongPress
  // ===========================================================================
  void _handleLampTap() {
    final newOn = !_ramController.value.lampOn;
    _ramController.updateLamp(isOn: newOn);

    _pipelineController.trigger(
      eventName: 'Chạm Đèn (Tap)',
      callbackName: 'InkWell.onTap',
      forgetSetState: _simulateForgetSetState,
    );

    if (_simulateForgetSetState) {
      _addLog(
        widgetName: 'InkWell',
        callback: 'onTap',
        result:
            'lampOn = $newOn trong RAM (QUÊN setState -> Thẻ Đèn vẫn hiện ${_uiLampOn ? "BẬT" : "TẮT"}!)',
        type: EventLogType.warning,
      );
    } else {
      setState(() {
        _syncUiFromRam();
        _lampBuildCount++;
      });
      _addLog(
        widgetName: 'InkWell',
        callback: 'onTap',
        result: newOn ? 'Bật Đèn thông minh' : 'Tắt Đèn thông minh',
        type: EventLogType.tap,
      );
    }
  }

  void _handleLampLongPress() {
    _pipelineController.trigger(
      eventName: 'Nhấn giữ Đèn (>= 500ms)',
      callbackName: 'InkWell.onLongPress',
      forgetSetState: false,
    );
    _addLog(
      widgetName: 'InkWell',
      callback: 'onLongPress',
      result: 'Mở bảng điều chỉnh độ sáng đèn',
      type: EventLogType.longPress,
    );
  }

  void _handleLampBrightnessChanged(double val) {
    _ramController.updateLamp(brightness: val, incrementEvent: false);
    if (!_simulateForgetSetState) {
      setState(() {
        _uiLampBrightness = val;
      });
    }
  }

  void _handleLampBrightnessChangeEnd(double val) {
    _ramController.updateLamp(brightness: val, incrementEvent: true);
    final percent = (val * 100).toInt();

    _pipelineController.trigger(
      eventName: 'Thả Slider (Slide End)',
      callbackName: 'Slider.onChangeEnd',
      forgetSetState: _simulateForgetSetState,
    );

    if (_simulateForgetSetState) {
      _addLog(
        widgetName: 'Slider',
        callback: 'onChangeEnd',
        result:
            'Độ sáng đổi thành $percent% trong RAM (QUÊN setState -> UI không đổi!)',
        type: EventLogType.warning,
      );
    } else {
      setState(() {
        _syncUiFromRam();
        _lampBuildCount++;
      });
      _addLog(
        widgetName: 'Slider',
        callback: 'onChangeEnd',
        result: 'Cài đặt độ sáng đèn: $percent%',
        type: EventLogType.onChanged,
      );
    }
  }

  // ===========================================================================
  // THIẾT BỊ 2: QUẠT (GestureDetector) - onTap, onDoubleTap, onLongPress
  // ===========================================================================
  void _handleFanTap() {
    final newOn = !_ramController.value.fanOn;
    _ramController.updateFan(isOn: newOn);

    _pipelineController.trigger(
      eventName: 'Chạm Quạt (Tap)',
      callbackName: 'GestureDetector.onTap',
      forgetSetState: _simulateForgetSetState,
    );

    if (_simulateForgetSetState) {
      _addLog(
        widgetName: 'GestureDetector',
        callback: 'onTap',
        result:
            'fanOn = $newOn trong RAM (QUÊN setState -> UI Quạt đứng yên!)',
        type: EventLogType.warning,
      );
    } else {
      setState(() {
        _syncUiFromRam();
        _fanBuildCount++;
      });
      _addLog(
        widgetName: 'GestureDetector',
        callback: 'onTap',
        result: newOn ? 'Bật Quạt thông gió' : 'Tắt Quạt thông gió',
        type: EventLogType.tap,
      );
    }
  }

  void _handleFanDoubleTap() {
    final currentSpeed = _ramController.value.fanSpeed;
    final nextSpeed = currentSpeed >= 3 ? 1 : currentSpeed + 1;
    _ramController.updateFan(speed: nextSpeed, isOn: true);

    _pipelineController.trigger(
      eventName: 'Chạm đúp Quạt (Double Tap)',
      callbackName: 'GestureDetector.onDoubleTap',
      forgetSetState: _simulateForgetSetState,
    );

    if (_simulateForgetSetState) {
      _addLog(
        widgetName: 'GestureDetector',
        callback: 'onDoubleTap',
        result:
            'Đổi tốc độ sang Cấp $nextSpeed trong RAM (QUÊN setState -> UI giữ Cấp $_uiFanSpeed)',
        type: EventLogType.warning,
      );
    } else {
      setState(() {
        _syncUiFromRam();
        _fanBuildCount++;
      });
      _addLog(
        widgetName: 'GestureDetector',
        callback: 'onDoubleTap',
        result: 'Tăng tốc độ Quạt: Cấp $currentSpeed ➔ Cấp $nextSpeed',
        type: EventLogType.doubleTap,
      );
    }
  }

  void _handleFanLongPress() {
    _ramController.updateFan(speed: 1);

    _pipelineController.trigger(
      eventName: 'Nhấn giữ Quạt (>= 500ms)',
      callbackName: 'GestureDetector.onLongPress',
      forgetSetState: _simulateForgetSetState,
    );

    if (_simulateForgetSetState) {
      _addLog(
        widgetName: 'GestureDetector',
        callback: 'onLongPress',
        result: 'Đặt lại tốc độ Quạt về Cấp 1 trong RAM (QUÊN setState)',
        type: EventLogType.warning,
      );
    } else {
      setState(() {
        _syncUiFromRam();
        _fanBuildCount++;
      });
      _addLog(
        widgetName: 'GestureDetector',
        callback: 'onLongPress',
        result: 'Đã đặt lại tốc độ Quạt về Cấp 1',
        type: EventLogType.longPress,
      );
    }
  }

  void _handleFanSpeedSelected(int speed) {
    if (_ramController.value.fanSpeed == speed && _ramController.value.fanOn) {
      return;
    }
    _ramController.updateFan(speed: speed, isOn: true);

    _pipelineController.trigger(
      eventName: 'Chọn tốc độ Quạt (Cấp $speed)',
      callbackName: 'GestureDetector.onSpeedSelected',
      forgetSetState: _simulateForgetSetState,
    );

    if (_simulateForgetSetState) {
      _addLog(
        widgetName: 'GestureDetector',
        callback: 'onTap',
        result:
            'Đổi tốc độ sang Cấp $speed trong RAM (QUÊN setState -> UI giữ Cấp $_uiFanSpeed)',
        type: EventLogType.warning,
      );
    } else {
      setState(() {
        _syncUiFromRam();
        _fanBuildCount++;
      });
      _addLog(
        widgetName: 'GestureDetector',
        callback: 'onTap',
        result:
            'Đã chọn tốc độ Quạt: Cấp $speed (${speed == 3 ? "Gió mạnh" : speed == 2 ? "Gió vừa" : "Gió nhẹ"})',
        type: EventLogType.tap,
      );
    }
  }

  // ===========================================================================
  // THIẾT BỊ 3: MÁY BƠM (ElevatedButton + Switch) - onPressed & onChanged
  // ===========================================================================
  void _handlePumpTogglePower() {
    final newOn = !_ramController.value.pumpOn;
    _ramController.updatePump(isOn: newOn);

    _pipelineController.trigger(
      eventName: 'Bấm nút Bơm',
      callbackName: 'ElevatedButton.onPressed',
      forgetSetState: _simulateForgetSetState,
    );

    if (_simulateForgetSetState) {
      _addLog(
        widgetName: 'ElevatedButton',
        callback: 'onPressed',
        result:
            'pumpOn = $newOn trong RAM (QUÊN setState -> Máy bơm trên UI chưa đổi)',
        type: EventLogType.warning,
      );
    } else {
      setState(() {
        _syncUiFromRam();
        _pumpBuildCount++;
      });
      _addLog(
        widgetName: 'ElevatedButton',
        callback: 'onPressed',
        result: newOn ? 'Bật máy bơm tưới cây' : 'Dừng máy bơm tưới cây',
        type: EventLogType.onPressed,
      );
    }
  }

  void _handlePumpToggleMode(bool isAuto) {
    final modeStr = isAuto ? 'Tự động' : 'Thủ công';
    _ramController.updatePump(mode: modeStr);

    _pipelineController.trigger(
      eventName: 'Gạt công tắc Bơm',
      callbackName: 'Switch.onChanged',
      forgetSetState: _simulateForgetSetState,
    );

    if (_simulateForgetSetState) {
      _addLog(
        widgetName: 'Switch',
        callback: 'onChanged',
        result:
            'pumpMode = $modeStr trong RAM (QUÊN setState -> Switch trên UI chưa nhảy)',
        type: EventLogType.warning,
      );
    } else {
      setState(() {
        _syncUiFromRam();
        _pumpBuildCount++;
      });
      _addLog(
        widgetName: 'Switch',
        callback: 'onChanged',
        result: 'Chuyển chế độ máy bơm sang: $modeStr',
        type: EventLogType.onChanged,
      );
    }
  }

  // ===========================================================================
  // NÚT CHUNG TRÊN HEADER: BẬT TẤT CẢ / TẮT TẤT CẢ / ĐẶT LẠI
  // ===========================================================================
  void _turnOnAll() {
    _ramController.turnOnAll();
    _pipelineController.trigger(
      eventName: 'Bật tất cả',
      callbackName: 'ElevatedButton.onPressed',
      forgetSetState: _simulateForgetSetState,
    );

    if (_simulateForgetSetState) {
      _addLog(
        widgetName: 'Điều khiển chung',
        callback: 'onPressed',
        result: 'Bật tất cả trong RAM (QUÊN setState -> UI không đổi!)',
        type: EventLogType.warning,
      );
    } else {
      setState(() {
        _syncUiFromRam();
      });
      _addLog(
        widgetName: 'Điều khiển chung',
        callback: 'onPressed',
        result: 'Đã bật toàn bộ thiết bị',
        type: EventLogType.onPressed,
      );
    }
  }

  void _turnOffAll() {
    _ramController.turnOffAll();
    _pipelineController.trigger(
      eventName: 'Tắt tất cả',
      callbackName: 'ElevatedButton.onPressed',
      forgetSetState: _simulateForgetSetState,
    );

    if (_simulateForgetSetState) {
      _addLog(
        widgetName: 'Điều khiển chung',
        callback: 'onPressed',
        result: 'Tắt tất cả trong RAM (QUÊN setState -> UI không đổi!)',
        type: EventLogType.warning,
      );
    } else {
      setState(() {
        _syncUiFromRam();
      });
      _addLog(
        widgetName: 'Điều khiển chung',
        callback: 'onPressed',
        result: 'Đã tắt toàn bộ thiết bị',
        type: EventLogType.onPressed,
      );
    }
  }

  void _resetAll() {
    _ramController.resetAll();
    _pipelineController.trigger(
      eventName: 'Đặt lại',
      callbackName: 'OutlinedButton.onPressed',
      forgetSetState: false,
    );

    setState(() {
      _syncUiFromRam();
      _totalBuildCount = 0;
      _lampBuildCount = 0;
      _fanBuildCount = 0;
      _pumpBuildCount = 0;
    });

    _addLog(
      widgetName: 'Điều khiển chung',
      callback: 'onPressed',
      result: 'Đặt lại trạng thái toàn bộ thiết bị về mặc định',
      type: EventLogType.system,
    );
  }

  // ===========================================================================
  // CƯỠNG CHẾ GỌI SETSTATE() ĐỒNG BỘ UI VỚI RAM
  // ===========================================================================
  void _forceRebuildFromRam() {
    setState(() {
      _syncUiFromRam();
    });
    _pipelineController.forceCompleteRebuild();
    _addLog(
      widgetName: 'Framework',
      callback: 'setState()',
      result: 'Đã gọi setState() thủ công ➔ Đồng bộ UI thành công (Khớp RAM)',
      type: EventLogType.system,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAnyUiActive = _uiLampOn || _uiFanOn || _uiPumpOn;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50 sạch sẽ, sáng rõ
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.home_rounded, color: Color(0xFF0284C7), size: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                'Smart Home',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: Color(0xFF10B981)),
                    SizedBox(width: 5),
                    Text(
                      'Trực tuyến',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nút Bật tất cả - MÀU SẮC SỐNG ĐỘNG (Xanh Emerald)
                FilledButton.icon(
                  onPressed: _turnOnAll,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shadowColor: const Color(0x6010B981),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7)),
                  ),
                  icon: const Icon(Icons.power_settings_new_rounded,
                      size: 15, color: Colors.white),
                  label: const Text(
                    'Bật tất cả',
                    style:
                        TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 6),

                // Nút Tắt tất cả - MÀU SẮC SỐNG ĐỘNG (Đỏ Coral rực rỡ khi active)
                FilledButton.icon(
                  onPressed: hasAnyUiActive ? _turnOffAll : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: hasAnyUiActive
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFF1F5F9),
                    foregroundColor: hasAnyUiActive
                        ? Colors.white
                        : const Color(0xFF94A3B8),
                    disabledBackgroundColor: const Color(0xFFF1F5F9),
                    disabledForegroundColor: const Color(0xFF94A3B8),
                    elevation: hasAnyUiActive ? 1 : 0,
                    shadowColor: const Color(0x60EF4444),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                      side: BorderSide(
                        color: hasAnyUiActive
                            ? Colors.transparent
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  icon: Icon(
                    Icons.power_off_rounded,
                    size: 15,
                    color: hasAnyUiActive
                        ? Colors.white
                        : const Color(0xFF94A3B8),
                  ),
                  label: const Text(
                    'Tắt tất cả',
                    style:
                        TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 6),

                // Nút Đặt lại - Tươi sáng, thanh lịch
                OutlinedButton.icon(
                  onPressed: _resetAll,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF475569),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7)),
                  ),
                  icon: const Icon(Icons.refresh_rounded,
                      size: 14, color: Color(0xFF64748B)),
                  label: const Text(
                    'Đặt lại',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),

                // CÔNG TẮC BẬT / TẮT SETSTATE: ON / OFF TRỰC TIẾP TRÊN HEADER
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: _simulateForgetSetState
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: _simulateForgetSetState
                          ? const Color(0xFFFECACA)
                          : const Color(0xFFA7F3D0),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _simulateForgetSetState
                            ? Icons.error_outline_rounded
                            : Icons.check_circle_rounded,
                        size: 15,
                        color: _simulateForgetSetState
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _simulateForgetSetState ? 'setState: Off' : 'setState: On',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _simulateForgetSetState
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF065F46),
                          fontFamily: 'Consolas',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Switch(
                        key: const Key('switch_forget_setstate_header'),
                        value: !_simulateForgetSetState,
                        onChanged: (val) {
                          setState(() {
                            _simulateForgetSetState = !val;
                            if (val) {
                              _syncUiFromRam();
                              _pipelineController.forceCompleteRebuild();
                            }
                          });
                          _addLog(
                            widgetName: 'Thử nghiệm',
                            callback: 'onChanged',
                            result: val
                                ? 'setState: On (Đã gọi setState() đồng bộ UI khớp RAM)'
                                : 'setState: Off (Mô phỏng quên setState -> UI đứng yên!)',
                            type: val
                                ? EventLogType.onChanged
                                : EventLogType.warning,
                          );
                        },
                        activeThumbColor: const Color(0xFF10B981),
                        activeTrackColor: const Color(0xFFA7F3D0),
                        inactiveThumbColor: const Color(0xFFEF4444),
                        inactiveTrackColor: const Color(0xFFFECACA),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // NÚT BẬT / TẮT CHẾ ĐỘ DEV - Màu tím Vivid Violet
                FilledButton.icon(
                  key: const Key('btn_toggle_dev_mode'),
                  onPressed: () {
                    setState(() {
                      _isDevModeOpen = !_isDevModeOpen;
                    });
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _isDevModeOpen
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFFF5F3FF),
                    foregroundColor: _isDevModeOpen
                        ? Colors.white
                        : const Color(0xFF7C3AED),
                    side: BorderSide(
                      color: _isDevModeOpen
                          ? Colors.transparent
                          : const Color(0xFFDDD6FE),
                    ),
                    elevation: _isDevModeOpen ? 1 : 0,
                    shadowColor: const Color(0x607C3AED),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7)),
                  ),
                  icon: Icon(
                    _isDevModeOpen
                        ? Icons.developer_mode_rounded
                        : Icons.tune_rounded,
                    size: 15,
                    color: _isDevModeOpen
                        ? Colors.white
                        : const Color(0xFF7C3AED),
                  ),
                  label: Text(
                    _isDevModeOpen ? 'Dev [BẬT]' : 'Dev',
                    style: const TextStyle(
                        fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 14),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;

              // 1. CỘT TRÁI: 3 THẺ THIẾT BỊ
              final leftColumn = SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LampDeviceCard(
                      isOn: _uiLampOn,
                      brightness: _uiLampBrightness,
                      eventCount: _ramController.value.lampEventCount,
                      onTap: _handleLampTap,
                      onLongPress: _handleLampLongPress,
                      onBrightnessChanged: _handleLampBrightnessChanged,
                      onBrightnessChangeEnd: _handleLampBrightnessChangeEnd,
                    ),
                    const SizedBox(height: 12),
                    FanDeviceCard(
                      isOn: _uiFanOn,
                      speed: _uiFanSpeed,
                      eventCount: _ramController.value.fanEventCount,
                      onTap: _handleFanTap,
                      onDoubleTap: _handleFanDoubleTap,
                      onLongPress: _handleFanLongPress,
                      onSpeedSelected: _handleFanSpeedSelected,
                    ),
                    const SizedBox(height: 12),
                    PumpDeviceCard(
                      isOn: _uiPumpOn,
                      mode: _uiPumpMode,
                      eventCount: _ramController.value.pumpEventCount,
                      onTogglePower: _handlePumpTogglePower,
                      onToggleMode: _handlePumpToggleMode,
                    ),
                  ],
                ),
              );

              // 2. CỘT PHẢI: KHI DEV ĐÓNG THÌ HIỆN LOGGER, KHI DEV BẬT THÌ HIỆN 3 KHỐI DEV + LOGGER
              Widget rightColumn;
              if (!_isDevModeOpen) {
                // Chế độ sạch: Chỉ hiện Nhật ký sự kiện
                rightColumn = EventConsoleWidget(
                  logs: _logs,
                  onClear: () {
                    setState(() {
                      _logs.clear();
                    });
                  },
                );
              } else {
                // Chế độ Dev: Hiện Dải luồng 4 bước + So sánh RAM vs UI + Thí nghiệm setState + Logger
                rightColumn = SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Chế độ Dev
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFDDD6FE)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0C7C3AED),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.developer_mode_rounded,
                                color: Color(0xFF7C3AED), size: 16),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Chế độ Dev: Kiểm chứng State & Luồng sự kiện',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isDevModeOpen = false;
                                });
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.close_rounded,
                                    size: 16, color: Color(0xFF64748B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Khối 1: Dải luồng 4 bước
                      PipelineFlowWidget(controller: _pipelineController),
                      const SizedBox(height: 10),

                      // Khối 2 & 3: So sánh RAM vs UI & Thí nghiệm setState
                      StateComparisonPanel(
                        ramController: _ramController,
                        simulateForgetSetState: _simulateForgetSetState,
                        onToggleForgetSetState: (val) {
                          setState(() {
                            _simulateForgetSetState = val;
                          });
                          _addLog(
                            widgetName: 'Thử nghiệm',
                            callback: 'onChanged',
                            result:
                                'Chế độ Quên setState(): ${_simulateForgetSetState ? "BẬT (Mô phỏng lỗi)" : "TẮT (Chuẩn)"}',
                            type: _simulateForgetSetState
                                ? EventLogType.warning
                                : EventLogType.onChanged,
                          );
                        },
                        onForceSetState: _forceRebuildFromRam,
                        uiLampOn: _uiLampOn,
                        uiLampBrightness: _uiLampBrightness,
                        uiFanOn: _uiFanOn,
                        uiFanSpeed: _uiFanSpeed,
                        uiPumpOn: _uiPumpOn,
                        uiPumpMode: _uiPumpMode,
                        totalBuildCount: _totalBuildCount,
                        lampBuildCount: _lampBuildCount,
                        fanBuildCount: _fanBuildCount,
                        pumpBuildCount: _pumpBuildCount,
                      ),
                      const SizedBox(height: 10),

                      // Khối 4: Logger nhỏ gọn ở cuối
                      SizedBox(
                        height: 220,
                        child: EventConsoleWidget(
                          logs: _logs,
                          onClear: () {
                            setState(() {
                              _logs.clear();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (isWide) {
                // Bố cục 2 cột song song trên màn hình rộng
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: leftColumn),
                    const SizedBox(width: 16),
                    Expanded(flex: 5, child: rightColumn),
                  ],
                );
              } else {
                // Màn hình hẹp: Xếp dọc
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      leftColumn,
                      const SizedBox(height: 14),
                      rightColumn,
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
