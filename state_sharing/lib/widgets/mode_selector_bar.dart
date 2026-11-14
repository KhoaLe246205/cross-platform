import 'package:flutter/material.dart';
import '../models/app_mode.dart';

/// Thanh công cụ chuyển đổi linh hoạt giữa 4 cơ chế chia sẻ trạng thái.
class ModeSelectorBar extends StatelessWidget {
  final StateSharingMode currentMode;
  final ValueChanged<StateSharingMode> onModeChanged;

  const ModeSelectorBar({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFE2E4E9), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.architecture, size: 20.0, color: Color(0xFF141414)),
              const SizedBox(width: 8.0),
              const Text(
                'CHỌN CƠ CHẾ CHIA SẺ TRẠNG THÁI',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFF141414),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  'Phạm vi Rebuild: ${currentMode.rebuildScope}',
                  style: const TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF495057),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: StateSharingMode.values.map((mode) {
                  final isSelected = mode == currentMode;
                  return InkWell(
                    onTap: () => onModeChanged(mode),
                    borderRadius: BorderRadius.circular(8.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 9.0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF141414)
                            : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF141414)
                              : const Color(0xFFDEE2E6),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getModeIcon(mode),
                            size: 15.0,
                            color: isSelected ? Colors.white : const Color(0xFF495057),
                          ),
                          const SizedBox(width: 7.0),
                          Text(
                            mode.shortName,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF212529),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 8.0),
          Text(
            currentMode.description,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF6C757D),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getModeIcon(StateSharingMode mode) {
    switch (mode) {
      case StateSharingMode.propDrilling:
        return Icons.alt_route;
      case StateSharingMode.inheritedWidget:
        return Icons.account_tree_outlined;
      case StateSharingMode.valueNotifier:
        return Icons.stream;
      case StateSharingMode.changeNotifier:
        return Icons.hub_outlined;
    }
  }
}
