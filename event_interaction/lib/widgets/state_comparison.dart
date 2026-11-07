import 'package:flutter/material.dart';
import '../models/ram_state.dart';

class StateComparisonPanel extends StatelessWidget {
  final RamStateController ramController;
  final bool simulateForgetSetState;
  final ValueChanged<bool> onToggleForgetSetState;
  final VoidCallback onForceSetState;

  // Trạng thái thực tế mà UI đang render
  final bool uiLampOn;
  final double uiLampBrightness;
  final bool uiFanOn;
  final int uiFanSpeed;
  final bool uiPumpOn;
  final String uiPumpMode;

  // Bộ đếm build()
  final int totalBuildCount;
  final int lampBuildCount;
  final int fanBuildCount;
  final int pumpBuildCount;

  const StateComparisonPanel({
    super.key,
    required this.ramController,
    required this.simulateForgetSetState,
    required this.onToggleForgetSetState,
    required this.onForceSetState,
    required this.uiLampOn,
    required this.uiLampBrightness,
    required this.uiFanOn,
    required this.uiFanSpeed,
    required this.uiPumpOn,
    required this.uiPumpMode,
    required this.totalBuildCount,
    required this.lampBuildCount,
    required this.fanBuildCount,
    required this.pumpBuildCount,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RamState>(
      valueListenable: ramController,
      builder: (context, ram, _) {
        final lampMismatch = ram.lampOn != uiLampOn ||
            (ram.lampOn && (ram.lampBrightness - uiLampBrightness).abs() > 0.05);
        final fanMismatch = ram.fanOn != uiFanOn ||
            (ram.fanOn && ram.fanSpeed != uiFanSpeed);
        final pumpMismatch = ram.pumpOn != uiPumpOn ||
            (ram.pumpOn && ram.pumpMode != uiPumpMode);
        final hasAnyMismatch = lampMismatch || fanMismatch || pumpMismatch;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasAnyMismatch
                  ? const Color(0xFFFCA5A5)
                  : const Color(0xFFE2E8F0),
              width: hasAnyMismatch ? 1.5 : 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x080F172A),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. THANH ĐIỀU KHIỂN THÍ NGHIỆM "QUÊN SETSTATE" & NÚT GỌI THỦ CÔNG
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: simulateForgetSetState
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: simulateForgetSetState
                        ? const Color(0xFFFECACA)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Switch(
                      key: const Key('switch_forget_setstate'),
                      value: !simulateForgetSetState,
                      onChanged: (val) => onToggleForgetSetState(!val),
                      activeThumbColor: const Color(0xFF10B981),
                      activeTrackColor: const Color(0xFFA7F3D0),
                      inactiveThumbColor: const Color(0xFFEF4444),
                      inactiveTrackColor: const Color(0xFFFECACA),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Text(
                                simulateForgetSetState
                                    ? 'setState: Off'
                                    : 'setState: On',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: simulateForgetSetState
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF059669),
                                  fontFamily: 'Consolas',
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: simulateForgetSetState
                                      ? const Color(0xFFFEE2E2)
                                      : const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: simulateForgetSetState
                                        ? const Color(0xFFFECACA)
                                        : const Color(0xFFA7F3D0),
                                  ),
                                ),
                                child: Text(
                                  simulateForgetSetState
                                      ? 'QUÊN SETSTATE'
                                      : 'ĐANG GỌI SETSTATE',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: simulateForgetSetState
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF059669),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            simulateForgetSetState
                                ? 'Tương tác đổi RAM nhưng KHÔNG Rebuild UI ➔ Giao diện đứng yên!'
                                : 'Chuẩn: setState() thông báo Dirty ➔ UI = f(State)',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: simulateForgetSetState
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF64748B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Nút "Gọi setState() ngay" - MÀU SẮC SỐNG ĐỘNG
                    FilledButton.icon(
                      onPressed: onForceSetState,
                      style: FilledButton.styleFrom(
                        backgroundColor: hasAnyMismatch
                            ? const Color(0xFFF59E0B) // Amber rực rỡ khi lệch pha
                            : const Color(0xFF2563EB), // Xanh dương sống động
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shadowColor: hasAnyMismatch
                            ? const Color(0x60F59E0B)
                            : const Color(0x602563EB),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.flash_on_rounded, size: 14),
                      label: Text(
                        hasAnyMismatch ? 'Đồng bộ UI ngay!' : 'Gọi setState()',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 2. HAI CỘT SO SÁNH: BIẾN TRONG RAM vs GIAO DIỆN HIỂN THỊ
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cột trái: Biến State trong RAM
                  Expanded(
                    child: _buildPane(
                      title: 'Biến State trong RAM',
                      subtitle: 'Đọc độc lập từ ValueNotifier',
                      headerColor: const Color(0xFF0284C7),
                      icon: Icons.memory_rounded,
                      children: [
                        _buildRamRow(
                          label: '💡 Đèn',
                          code: 'lampOn = ${ram.lampOn}',
                          detail: '${(ram.lampBrightness * 100).toInt()}% độ sáng',
                          isActive: ram.lampOn,
                        ),
                        const Divider(color: Color(0xFFE2E8F0), height: 10),
                        _buildRamRow(
                          label: '🌀 Quạt',
                          code: 'fanOn = ${ram.fanOn}',
                          detail: 'Cấp ${ram.fanSpeed}',
                          isActive: ram.fanOn,
                        ),
                        const Divider(color: Color(0xFFE2E8F0), height: 10),
                        _buildRamRow(
                          label: '💧 Máy bơm',
                          code: 'pumpOn = ${ram.pumpOn}',
                          detail: ram.pumpMode,
                          isActive: ram.pumpOn,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Cột phải: Giao diện hiển thị trên màn hình
                  Expanded(
                    child: _buildPane(
                      title: 'Giao diện hiển thị (UI)',
                      subtitle: 'Trạng thái thẻ hiển thị thực tế',
                      headerColor: hasAnyMismatch
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF059669),
                      icon: Icons.screenshot_monitor_rounded,
                      children: [
                        _buildUiRow(
                          label: '💡 Thẻ Đèn',
                          displayText: uiLampOn
                              ? 'BẬT (${(uiLampBrightness * 100).toInt()}%)'
                              : 'TẮT',
                          isMismatch: lampMismatch,
                          isActive: uiLampOn,
                        ),
                        const Divider(color: Color(0xFFE2E8F0), height: 10),
                        _buildUiRow(
                          label: '🌀 Thẻ Quạt',
                          displayText: uiFanOn
                              ? 'BẬT (Cấp $uiFanSpeed)'
                              : 'TẮT',
                          isMismatch: fanMismatch,
                          isActive: uiFanOn,
                        ),
                        const Divider(color: Color(0xFFE2E8F0), height: 10),
                        _buildUiRow(
                          label: '💧 Thẻ Bơm',
                          displayText: uiPumpOn
                              ? 'BẬT ($uiPumpMode)'
                              : 'TẮT',
                          isMismatch: pumpMismatch,
                          isActive: uiPumpOn,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 3. BỘ ĐẾM BUILD() VÀ CẢNH BÁO LỆCH PHA
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: hasAnyMismatch
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasAnyMismatch
                        ? const Color(0xFFFECACA)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasAnyMismatch
                          ? Icons.sync_problem_rounded
                          : Icons.check_circle_rounded,
                      size: 16,
                      color: hasAnyMismatch
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        hasAnyMismatch
                            ? '⚠️ LỆCH PHA: RAM đã đổi nhưng UI chưa Rebuild (Cần gọi setState!)'
                            : '✅ Đồng bộ hoàn toàn: UI = f(State) phản ánh chính xác RAM',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: hasAnyMismatch
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF059669),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge tổng số lần build()
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        'Số lần build(): $totalBuildCount',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                          fontFamily: 'Consolas',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPane({
    required String title,
    required String subtitle,
    required Color headerColor,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: headerColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: headerColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRamRow({
    required String label,
    required String code,
    required String detail,
    required bool isActive,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155)),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                code,
                style: TextStyle(
                  fontSize: 10.5,
                  fontFamily: 'Consolas',
                  color: isActive ? const Color(0xFF059669) : const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isActive ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            detail,
            style: TextStyle(
              fontSize: 10.5,
              color: isActive ? const Color(0xFF059669) : const Color(0xFF64748B),
              fontFamily: 'Consolas',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUiRow({
    required String label,
    required String displayText,
    required bool isMismatch,
    required bool isActive,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155)),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                displayText,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: isMismatch
                      ? const Color(0xFFDC2626)
                      : isActive
                          ? const Color(0xFF0284C7)
                          : const Color(0xFF64748B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          decoration: BoxDecoration(
            color: isMismatch
                ? const Color(0xFFFEF2F2)
                : const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isMismatch ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0),
              width: 1,
            ),
          ),
          child: Text(
            isMismatch ? 'LỆCH PHA!' : 'KHỚP RAM',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: isMismatch ? const Color(0xFFDC2626) : const Color(0xFF059669),
            ),
          ),
        ),
      ],
    );
  }
}
