import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../models/rebuild_tracker.dart';
import '../state/change_notifier_state.dart';
import '../theme/app_theme.dart';
import 'task_tile.dart';
import 'rebuild_flash.dart';

/// Khối danh mục công việc (Category Section).
/// Gồm tiêu đề nhóm danh mục và danh sách các hàng công việc (Task Tiles).
class CategorySection extends StatelessWidget {
  final String categoryName;
  final List<TaskItem> tasks;
  final ValueChanged<String> onToggleTask;
  final void Function(String id, double progress) onUpdateProgress;
  final bool isConnected;
  final bool isPropDrilling;
  final TaskFlowModel? model;
  final bool isDeveloperMode;

  const CategorySection({
    super.key,
    required this.categoryName,
    required this.tasks,
    required this.onToggleTask,
    required this.onUpdateProgress,
    this.isConnected = true,
    this.isPropDrilling = false,
    this.model,
    this.isDeveloperMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isPropDrilling) {
      // Trong chế độ Prop Drilling: ghi nhận tầng trung gian CategorySection bị Rebuild lan truyền
      RebuildTracker.instance.record('cat_$categoryName');
    }

    final completedCount = tasks.where((t) => t.isCompleted).length;

    final sectionContent = Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radius8,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tiêu đề danh mục: Tên danh mục + Số lượng hoàn thành
          Row(
            children: [
              Icon(
                _getCategoryIcon(categoryName),
                size: 18.0,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: AppTextStyles.h2,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  '· $completedCount/${tasks.length} xong',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: AppTextStyles.caption.copyWith(
                    color: completedCount == tasks.length && tasks.isNotEmpty
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: completedCount == tasks.length ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Danh sách các công việc con trong danh mục
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final task = tasks[index];

              // Trong chế độ Prop Drilling: widget con phụ thuộc trực tiếp vào tham số constructor
              if (isPropDrilling || model == null) {
                return TaskTile(
                  item: task,
                  onToggle: (_) => onToggleTask(task.id),
                  onProgressChanged: (val) => onUpdateProgress(task.id, val),
                  isConnected: isConnected,
                  isDeveloperMode: isDeveloperMode,
                  isPropDrilling: isPropDrilling,
                );
              }

              // Trong chế độ InheritedWidget / Notifier: cập nhật phân mảnh tại đúng lá cây widget
              return ValueListenableBuilder<TaskItem>(
                valueListenable: model!.getTaskNotifier(task.id),
                builder: (context, liveItem, _) {
                  return TaskTile(
                    item: liveItem,
                    onToggle: (_) => onToggleTask(task.id),
                    onProgressChanged: (val) => onUpdateProgress(task.id, val),
                    isConnected: isConnected,
                    isDeveloperMode: isDeveloperMode,
                    isPropDrilling: false,
                  );
                },
              );
            },
          ),
        ],
      ),
    );

    return RebuildFlash(
      tag: 'cat_$categoryName',
      depth: 2, // Độ sâu tầng nhóm (2)
      enabled: isDeveloperMode && isPropDrilling,
      borderRadius: AppRadius.radius8,
      child: sectionContent,
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Học tập':
      case 'Học tập & Đồ án':
        return Icons.school_outlined;
      case 'Thể thao':
      case 'Việc cá nhân & Thể thao':
        return Icons.fitness_center_outlined;
      case 'Giải trí':
        return Icons.sports_esports_outlined;
      case 'Mua sắm & Sinh hoạt':
        return Icons.shopping_basket_outlined;
      default:
        return Icons.checklist_rtl_rounded;
    }
  }
}

// Alias tương thích ngược
typedef RoomSection = CategorySection;
