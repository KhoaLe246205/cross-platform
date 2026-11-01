import 'package:flutter/material.dart';

class InteractiveItemCard extends StatefulWidget {
  final int index;
  final bool isGridMode;

  const InteractiveItemCard({super.key, required this.index, required this.isGridMode});

  @override
  State<InteractiveItemCard> createState() => _InteractiveItemCardState();
}

class _InteractiveItemCardState extends State<InteractiveItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // 1. MouseRegion: Phát hiện con trỏ chuột (Pointer Input trên Web/Desktop)
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      // 2. Chốt chặn công thái học: Đảm bảo kích thước tương tác luôn >= kMinInteractiveDimension (48dp).
      // Giúp ứng dụng thân thiện trên cả chuột lẫn thiết bị lai (Laptop Windows có màn hình cảm ứng).
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: kMinInteractiveDimension,
          minWidth: kMinInteractiveDimension,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.indigo.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? Colors.indigo : Colors.grey.shade300,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: _isHovered
                ? [const BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))]
                : [],
          ),
          // 3. InkWell: Đảm bảo hiệu ứng phản hồi chạm (Ripple effect) khi tương tác cảm ứng/click
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _isHovered ? Colors.indigo : Colors.grey.shade200,
                    foregroundColor: _isHovered ? Colors.white : Colors.black87,
                    child: Text('${widget.index + 1}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Học phần số ${widget.index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isHovered
                              ? 'Trạng thái: Đang di chuột (Hover - Pointer Input)'
                              : 'Chế độ: ${widget.isGridMode ? "Grid Card" : "List Tile (Touch >= 48dp)"}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
