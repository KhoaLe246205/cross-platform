import 'package:flutter/material.dart';

/// Huy hiệu đếm số lần Rebuild của Widget.
/// Hiển thị trực quan, nhỏ gọn, không gây tràn layout.
class RebuildBadge extends StatelessWidget {
  final int count;
  final String label;
  final bool isVisible;

  const RebuildBadge({
    super.key,
    required this.count,
    this.label = 'Rebuild',
    this.isVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    Color textColor;
    Color bgColor;
    Color borderColor;

    if (count <= 1) {
      textColor = const Color(0xFF1B5E20);
      bgColor = const Color(0xFFE8F5E9);
      borderColor = const Color(0xFFA5D6A7);
    } else if (count <= 5) {
      textColor = const Color(0xFFE65100);
      bgColor = const Color(0xFFFFF3E0);
      borderColor = const Color(0xFFFFCC80);
    } else {
      textColor = const Color(0xFFB71C1C);
      bgColor = const Color(0xFFFFEBEE);
      borderColor = const Color(0xFFEF9A9A);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: borderColor, width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.refresh,
            size: 11.0,
            color: textColor,
          ),
          const SizedBox(width: 3.5),
          Text(
            '$label: $count',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
