import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../models/rebuild_tracker.dart';
import '../theme/app_theme.dart';
import 'rebuild_flash.dart';

/// Hàng/thẻ công việc thông minh chuẩn thiết kế phẳng (Task Tile).
/// Là StatelessWidget: CHỈ rebuild khi có tương tác dữ liệu thực tế (bấm chọn/sửa trạng thái).
/// Hiệu ứng rê chuột (Hover) được cô lập bên trong widget con riêng biệt, tuyệt đối KHÔNG kích hoạt build lại TaskTile.
class TaskTile extends StatelessWidget {
  final TaskItem item;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onProgressChanged;
  final bool isConnected;
  final bool isDeveloperMode;
  final bool isPropDrilling;

  const TaskTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onProgressChanged,
    this.isConnected = true,
    this.isDeveloperMode = false,
    this.isPropDrilling = false,
  });

  @override
  Widget build(BuildContext context) {
    // Chỉ ghi nhận Rebuild khi chính TaskTile được dựng lại từ State cha/Notifier
    RebuildTracker.instance.record(item.id);

    final isDone = item.isCompleted;

    final tileContent = _HoverableTileContainer(
      isDone: isDone,
      child: Row(
        children: [
          // 1. Ô Checkbox phẳng chuẩn
          InkWell(
            onTap: isConnected ? () => onToggle(!isDone) : null,
            borderRadius: BorderRadius.circular(4.0),
            child: Container(
              width: 20.0,
              height: 20.0,
              decoration: BoxDecoration(
                color: isDone ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(
                  color: isDone ? AppColors.primary : AppColors.textMuted,
                  width: 1.5,
                ),
              ),
              child: isDone
                  ? const Icon(
                      Icons.check,
                      size: 14.0,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: AppSpacing.sm + 4.0),

          // 2. Icon danh mục công việc
          Icon(
            item.icon,
            size: 18.0,
            color: isDone ? AppColors.textMuted : AppColors.primary,
          ),

          const SizedBox(width: AppSpacing.sm),

          // 3. Tiêu đề công việc + Thời hạn & Danh mục
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDone ? AppColors.textMuted : AppColors.textPrimary,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2.0),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.dueDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: AppTextStyles.caption.copyWith(
                          color: isDone ? AppColors.textMuted : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    const Text('·', style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(width: 6.0),
                    Flexible(
                      child: Text(
                        item.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // 4. Nhãn ưu tiên trung tính: chữ xám #4B5563 + chấm nhỏ đậm/nhạt theo mức độ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5.0,
                  height: 5.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getPriorityDotColor(item.priority),
                  ),
                ),
                const SizedBox(width: 5.0),
                Text(
                  item.priority,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: const TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return RebuildFlash(
      tag: item.id,
      enabled: isDeveloperMode,
      depth: 3, // Độ sâu tầng lá (3) cho thẻ công việc
      showPlusOne: true, // Hiển thị chữ "+1" xám 11px mờ dần cùng hiệu ứng nháy
      borderRadius: AppRadius.radius8,
      child: tileContent,
    );
  }

  Color _getPriorityDotColor(String priority) {
    switch (priority) {
      case 'Cao':
        return const Color(0xFF111827); // Đậm
      case 'Trung bình':
        return const Color(0xFF6B7280); // Vừa
      case 'Thấp':
      default:
        return const Color(0xFF9CA3AF); // Nhạt
    }
  }
}

/// Khối bọc hiệu ứng Hover nội bộ:
/// Tách riêng trạng thái rê chuột để KHÔNG làm kích hoạt hàm build() của TaskTile.
class _HoverableTileContainer extends StatefulWidget {
  final bool isDone;
  final Widget child;

  const _HoverableTileContainer({
    required this.isDone,
    required this.child,
  });

  @override
  State<_HoverableTileContainer> createState() => _HoverableTileContainerState();
}

class _HoverableTileContainerState extends State<_HoverableTileContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: widget.isDone ? 0.65 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 4.0,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.surfaceHover : AppColors.surface,
            borderRadius: AppRadius.radius8,
            border: Border.all(
              color: _isHovered ? AppColors.borderHover : AppColors.border,
              width: 1.0,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// Alias để tương thích ngược
typedef DeviceTile = TaskTile;
