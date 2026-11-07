import 'dart:async';
import 'package:flutter/material.dart';

class PipelineState {
  final int activeStep; // 0: idle, 1: Event, 2: Callback, 3: State Update, 4: Rebuild UI
  final bool isHalted; // Bị ngắt do quên setState()
  final String label;

  const PipelineState({
    this.activeStep = 0,
    this.isHalted = false,
    this.label = 'Chờ tương tác từ người dùng...',
  });
}

class PipelineController extends ValueNotifier<PipelineState> {
  Timer? _stepTimer1;
  Timer? _stepTimer2;
  Timer? _stepTimer3;
  Timer? _resetTimer;

  PipelineController() : super(const PipelineState());

  void trigger({
    required String eventName,
    required String callbackName,
    required bool forgetSetState,
  }) {
    _stepTimer1?.cancel();
    _stepTimer2?.cancel();
    _stepTimer3?.cancel();
    _resetTimer?.cancel();

    // Bước 1: Tiếp nhận sự kiện
    value = PipelineState(
      activeStep: 1,
      isHalted: false,
      label: '1. Tiếp nhận sự kiện: $eventName',
    );

    // Bước 2: Kích hoạt Callback
    _stepTimer1 = Timer(const Duration(milliseconds: 140), () {
      value = PipelineState(
        activeStep: 2,
        isHalted: false,
        label: '2. Thực thi Callback: $callbackName()',
      );

      if (forgetSetState) {
        // DỪNG LẠI! Quên setState() nên chu trình bị đứt đoạn
        _stepTimer2 = Timer(const Duration(milliseconds: 180), () {
          value = const PipelineState(
            activeStep: 2,
            isHalted: true,
            label: 'Quên gọi setState() -> Bỏ qua bước 3 & 4!',
          );
        });
      } else {
        // Bước 3: Cập nhật State trong RAM & Đánh dấu Dirty
        _stepTimer2 = Timer(const Duration(milliseconds: 150), () {
          value = const PipelineState(
            activeStep: 3,
            isHalted: false,
            label: '3. Cập nhật State -> Đánh dấu cờ Dirty (markNeedsBuild)',
          );

          // Bước 4: Build lại UI
          _stepTimer3 = Timer(const Duration(milliseconds: 150), () {
            value = const PipelineState(
              activeStep: 4,
              isHalted: false,
              label: '4. Flutter gọi build() -> Dựng lại UI trên màn hình!',
            );

            // Tự động chuyển về trạng thái sẵn sàng sau 2 giây
            _resetTimer = Timer(const Duration(milliseconds: 2200), () {
              value = const PipelineState(
                activeStep: 0,
                isHalted: false,
                label: 'Hệ thống sẵn sàng (Chờ sự kiện tiếp theo)',
              );
            });
          });
        });
      }
    });
  }

  void forceCompleteRebuild() {
    _stepTimer1?.cancel();
    _stepTimer2?.cancel();
    _stepTimer3?.cancel();
    _resetTimer?.cancel();

    value = const PipelineState(
      activeStep: 4,
      isHalted: false,
      label: 'Đã gọi setState() thủ công -> Rebuild UI thành công!',
    );

    _resetTimer = Timer(const Duration(milliseconds: 2000), () {
      value = const PipelineState(
        activeStep: 0,
        isHalted: false,
        label: 'Hệ thống sẵn sàng (Chờ sự kiện tiếp theo)',
      );
    });
  }

  @override
  void dispose() {
    _stepTimer1?.cancel();
    _stepTimer2?.cancel();
    _stepTimer3?.cancel();
    _resetTimer?.cancel();
    super.dispose();
  }
}

class PipelineFlowWidget extends StatelessWidget {
  final PipelineController controller;

  const PipelineFlowWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PipelineState>(
      valueListenable: controller,
      builder: (context, state, _) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: state.isHalted
                  ? const Color(0xFFFCA5A5)
                  : const Color(0xFFE2E8F0),
              width: 1.0,
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
              // Header
              Row(
                children: [
                  const Icon(Icons.account_tree_rounded,
                      size: 16, color: Color(0xFF0284C7)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Luồng sự kiện 4 bước (Event Pipeline)',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: state.isHalted
                          ? const Color(0xFFFEF2F2)
                          : state.activeStep > 0
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: state.isHalted
                            ? const Color(0xFFFECACA)
                            : state.activeStep > 0
                                ? const Color(0xFFBFDBFE)
                                : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      state.isHalted
                          ? 'ĐỨT ĐOẠN'
                          : state.activeStep > 0
                              ? 'BƯỚC ${state.activeStep}/4'
                              : 'IDLE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: state.isHalted
                            ? const Color(0xFFDC2626)
                            : state.activeStep > 0
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF64748B),
                        fontFamily: 'Consolas',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4 Hộp đại diện 4 bước
              LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStepBox(
                          stepNumber: 1,
                          title: '1. Event',
                          subtitle: 'Cử chỉ chạm',
                          icon: Icons.touch_app_rounded,
                          isActive: state.activeStep >= 1,
                          isCurrent: state.activeStep == 1,
                          isHalted: false,
                        ),
                      ),
                      _buildArrow(
                          active: state.activeStep >= 2,
                          isHalted: state.isHalted && state.activeStep == 2),
                      Expanded(
                        child: _buildStepBox(
                          stepNumber: 2,
                          title: '2. Callback',
                          subtitle: 'Hàm xử lý',
                          icon: Icons.code_rounded,
                          isActive: state.activeStep >= 2,
                          isCurrent: state.activeStep == 2,
                          isHalted: state.isHalted,
                        ),
                      ),
                      _buildArrow(
                          active: state.activeStep >= 3,
                          isHalted: state.isHalted),
                      Expanded(
                        child: _buildStepBox(
                          stepNumber: 3,
                          title: '3. State',
                          subtitle: 'Gắn cờ Dirty',
                          icon: Icons.memory_rounded,
                          isActive: state.activeStep >= 3,
                          isCurrent: state.activeStep == 3,
                          isHalted: state.isHalted,
                        ),
                      ),
                      _buildArrow(active: state.activeStep >= 4),
                      Expanded(
                        child: _buildStepBox(
                          stepNumber: 4,
                          title: '4. Rebuild',
                          subtitle: 'build() UI',
                          icon: Icons.draw_rounded,
                          isActive: state.activeStep >= 4,
                          isCurrent: state.activeStep == 4,
                          isHalted: state.isHalted,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),

              // Dòng ghi chú giải thích
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: state.isHalted
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: state.isHalted
                        ? const Color(0xFFFECACA)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.isHalted
                          ? Icons.warning_amber_rounded
                          : Icons.info_outline_rounded,
                      size: 15,
                      color: state.isHalted
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF0284C7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: state.isHalted
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF0F172A),
                          fontWeight: state.isHalted
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontFamily: 'Consolas',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildStepBox({
    required int stepNumber,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required bool isCurrent,
    required bool isHalted,
  }) {
    Color borderColor;
    Color bgColor;
    Color iconColor;
    Color titleColor;

    if (isHalted && stepNumber >= 3) {
      borderColor = const Color(0xFFFECACA);
      bgColor = const Color(0xFFFEF2F2);
      iconColor = const Color(0xFFDC2626);
      titleColor = const Color(0xFFDC2626);
    } else if (isHalted && stepNumber == 2) {
      borderColor = const Color(0xFFF87171);
      bgColor = const Color(0xFFFEF2F2);
      iconColor = const Color(0xFFDC2626);
      titleColor = const Color(0xFFDC2626);
    } else if (isActive) {
      if (stepNumber == 1) {
        borderColor = const Color(0xFF86EFAC);
        bgColor = const Color(0xFFF0FDF4);
        iconColor = const Color(0xFF16A34A);
        titleColor = const Color(0xFF16A34A);
      } else if (stepNumber == 2) {
        borderColor = const Color(0xFF7DD3FC);
        bgColor = const Color(0xFFF0F9FF);
        iconColor = const Color(0xFF0284C7);
        titleColor = const Color(0xFF0284C7);
      } else if (stepNumber == 3) {
        borderColor = const Color(0xFFD8B4FE);
        bgColor = const Color(0xFFFAF5FF);
        iconColor = const Color(0xFF9333EA);
        titleColor = const Color(0xFF9333EA);
      } else {
        borderColor = const Color(0xFF93C5FD);
        bgColor = const Color(0xFFEFF6FF);
        iconColor = const Color(0xFF2563EB);
        titleColor = const Color(0xFF2563EB);
      }
    } else {
      borderColor = const Color(0xFFE2E8F0);
      bgColor = const Color(0xFFF8FAFC);
      iconColor = const Color(0xFF94A3B8);
      titleColor = const Color(0xFF64748B);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: isCurrent ? 1.5 : 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9,
              color: isHalted && stepNumber >= 3
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildArrow({required bool active, bool isHalted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Icon(
        Icons.chevron_right_rounded,
        size: 16,
        color: isHalted
            ? const Color(0xFFEF4444)
            : active
                ? const Color(0xFF0284C7)
                : const Color(0xFFCBD5E1),
      ),
    );
  }
}
