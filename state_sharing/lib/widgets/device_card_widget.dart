import 'package:flutter/material.dart';
import '../models/device_item.dart';

/// Thẻ điều khiển thiết bị thông minh (Smart Device Card) cấp thương mại.
/// Tự động cập nhật giao diện sống động khi trạng thái thay đổi mà không gây rườm rà.
class DeviceCardWidget extends StatelessWidget {
  final DeviceItem item;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onLevelChanged;

  const DeviceCardWidget({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = item.isEnabled;
    final accentColor = _getDeviceAccentColor(item.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isActive ? accentColor.withOpacity(0.35) : const Color(0xFFE2E8F0),
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.08),
                  blurRadius: 12.0,
                  offset: const Offset(0, 4),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 4.0,
                  offset: Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dòng 1: Icon, Tên thiết bị, Vị trí phòng và Công tắc bật/tắt
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: isActive ? accentColor.withOpacity(0.12) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  item.icon,
                  size: 20.0,
                  color: isActive ? accentColor : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: isActive ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.0),
                    Row(
                      children: [
                        Text(
                          item.room,
                          style: const TextStyle(
                            fontSize: 11.0,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Container(
                          width: 3.0,
                          height: 3.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFFCBD5E1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          item.statusDisplay,
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: isActive ? accentColor : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: item.isEnabled,
                onChanged: onToggle,
                activeColor: accentColor,
                activeTrackColor: accentColor.withOpacity(0.2),
                inactiveThumbColor: const Color(0xFF94A3B8),
                inactiveTrackColor: const Color(0xFFE2E8F0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          // Dòng 2: Chỉ số công suất tiêu thụ thực tế
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.bolt_rounded,
                  size: 15.0,
                  color: isActive ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 6.0),
                Text(
                  isActive ? 'Công suất thực tế:' : 'Trạng thái:',
                  style: const TextStyle(
                    fontSize: 11.0,
                    color: Color(0xFF64748B),
                  ),
                ),
                const Spacer(),
                Text(
                  isActive ? '${item.currentPowerWatts.toStringAsFixed(1)} W' : '0.0 W (Nghỉ)',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10.0),

          // Dòng 3: Thanh trượt tinh chỉnh thông số (Độ sáng / Nhiệt độ / Âm lượng)
          _buildSpecializedControl(context, accentColor),
        ],
      ),
    );
  }

  Widget _buildSpecializedControl(BuildContext context, Color accentColor) {
    final isActive = item.isEnabled;

    // Thiết kế riêng cho Điều hòa: Có nút tăng giảm nhiệt độ trực quan
    if (item.id.contains('ac')) {
      final currentTemp = 16 + (item.level * 14).round(); // 16 đến 30 độ C
      return Row(
        children: [
          IconButton(
            onPressed: isActive && currentTemp > 16
                ? () {
                    final newLevel = ((currentTemp - 1) - 16) / 14.0;
                    onLevelChanged(newLevel.clamp(0.0, 1.0));
                  }
                : null,
            icon: const Icon(Icons.remove_circle_outline, size: 20.0),
            color: const Color(0xFF64748B),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                activeTrackColor: accentColor,
                inactiveTrackColor: const Color(0xFFE2E8F0),
                thumbColor: accentColor,
              ),
              child: Slider(
                value: item.level,
                min: 0.0,
                max: 1.0,
                divisions: 14,
                onChanged: isActive ? onLevelChanged : null,
              ),
            ),
          ),
          IconButton(
            onPressed: isActive && currentTemp < 30
                ? () {
                    final newLevel = ((currentTemp + 1) - 16) / 14.0;
                    onLevelChanged(newLevel.clamp(0.0, 1.0));
                  }
                : null,
            icon: const Icon(Icons.add_circle_outline, size: 20.0),
            color: const Color(0xFF64748B),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      );
    }

    // Các thiết bị khác (Đèn, Loa, Màn hình, Máy lọc): Dùng slider chuẩn kèm %
    return Row(
      children: [
        Icon(
          _getControlIcon(item.id),
          size: 15.0,
          color: isActive ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
              activeTrackColor: accentColor,
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: accentColor,
            ),
            child: Slider(
              value: item.level,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              onChanged: isActive ? onLevelChanged : null,
            ),
          ),
        ),
        SizedBox(
          width: 38.0,
          child: Text(
            '${(item.level * 100).toInt()}%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isActive ? const Color(0xFF334155) : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ],
    );
  }

  Color _getDeviceAccentColor(String id) {
    if (id.contains('lamp')) return const Color(0xFFF59E0B); // Vàng ấm
    if (id.contains('ac')) return const Color(0xFF0284C7); // Xanh dương mát
    if (id.contains('speaker')) return const Color(0xFF8B5CF6); // Tím thư giãn
    if (id.contains('monitor')) return const Color(0xFF3B82F6); // Xanh công nghệ
    if (id.contains('purifier')) return const Color(0xFF10B981); // Xanh lá sạch
    return const Color(0xFF0D9488);
  }

  IconData _getControlIcon(String id) {
    if (id.contains('lamp')) return Icons.brightness_6_rounded;
    if (id.contains('speaker')) return Icons.volume_up_rounded;
    if (id.contains('purifier')) return Icons.speed_rounded;
    return Icons.tune_rounded;
  }
}
