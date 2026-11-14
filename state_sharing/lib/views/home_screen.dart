import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_mode.dart';
import '../models/task_item.dart';
import '../models/rebuild_tracker.dart';
import '../data/initial_data.dart';
import '../state/change_notifier_state.dart';
import '../state/inherited_state.dart';
import '../theme/app_theme.dart';
import '../widgets/quick_filter_bar.dart';
import '../widgets/category_section.dart';
import '../widgets/task_summary.dart';
import '../widgets/rebuild_flash.dart';
import '../widgets/developer_status_bar.dart';

/// Màn hình chính của ứng dụng TaskFlow (To-Do List Hub).
/// Thể hiện trực quan bài học kiến trúc chia sẻ trạng thái:
/// - Prop Drilling: Check 1 công việc làm toàn bộ danh sách và màn hình Rebuild lan truyền.
/// - InheritedWidget: Check 1 công việc chỉ đúng thẻ đó, tab danh mục và thanh tiến độ Rebuild cục bộ O(1).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TaskFlowModel _model;
  bool _isConnected = true;
  StateSharingMode _currentMode = StateSharingMode.inheritedWidget; // Mặc định ở bản 2 tối ưu
  bool _isDeveloperMode = false; // Mặc định TẮT Chế độ Developer

  @override
  void initState() {
    super.initState();
    _model = TaskFlowModel();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _toggleConnectionSimulation() {
    setState(() {
      _isConnected = !_isConnected;
    });
  }

  void _toggleDeveloperMode() {
    setState(() {
      _isDeveloperMode = !_isDeveloperMode;
      RebuildTracker.instance.reset();
    });
  }

  void _onModeChanged(StateSharingMode newMode) {
    setState(() {
      _currentMode = newMode;
      RebuildTracker.instance.reset();
    });
  }

  void _onResetTracker() {
    RebuildTracker.instance.reset();
  }

  void _handleToggleTask(String id) {
    if (_currentMode == StateSharingMode.propDrilling) {
      // PHIÊN BẢN 1 (Prop Drilling):
      // Buộc phải gọi setState() tại HomeScreen gốc → Kéo theo toàn bộ 14 widget trên cây build lại!
      setState(() {
        RebuildTracker.instance.record('HomeScreen');
        _model.toggleTask(id);
      });
    } else {
      // PHIÊN BẢN 2 (InheritedWidget & Notifier):
      // Tuyệt đối KHÔNG gọi setState() tại HomeScreen!
      // Chỉ cập nhật model & ValueNotifier tại lá cây → Đúng 1 widget tương ứng build lại!
      _model.toggleTask(id);
    }
  }

  void _handleUpdateProgress(String id, double progress) {
    if (_currentMode == StateSharingMode.propDrilling) {
      setState(() {
        RebuildTracker.instance.record('HomeScreen');
        _model.updateProgress(id, progress);
      });
    } else {
      _model.updateProgress(id, progress);
    }
  }

  void _handleCompleteAll() {
    if (_currentMode == StateSharingMode.propDrilling) {
      setState(() {
        _model.completeAll();
      });
    } else {
      _model.completeAll();
    }
  }

  void _handleResetAll() {
    if (_currentMode == StateSharingMode.propDrilling) {
      setState(() {
        _model.resetAll();
      });
    } else {
      _model.resetAll();
    }
  }

  void _handleApplyPreset(String preset) {
    if (_currentMode == StateSharingMode.propDrilling) {
      setState(() {
        _model.applyFilterPreset(preset);
      });
    } else {
      _model.applyFilterPreset(preset);
    }
  }

  void _handleToggleFocus() {
    if (_currentMode == StateSharingMode.propDrilling) {
      setState(() {
        _model.toggleFocusMode();
      });
    } else {
      _model.toggleFocusMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentMode == StateSharingMode.propDrilling) {
      RebuildTracker.instance.record('HomeScreen');
    }

    final isProp = _currentMode == StateSharingMode.propDrilling;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyD, control: true): _toggleDeveloperMode,
      },
      child: Focus(
        autofocus: true,
        child: TaskScope(
          tasks: _model.tasks,
          userProfile: _model.profile,
          isFocusMode: _model.profile.isEcoMode,
          onToggleTask: _handleToggleTask,
          onUpdateProgress: _handleUpdateProgress,
          onToggleFocus: _handleToggleFocus,
          model: _model,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: RebuildFlash(
                tag: 'HomeScreen',
                depth: 0, // Độ sâu tầng gốc (0): Màn hình chính
                enabled: _isDeveloperMode && isProp,
                borderRadius: BorderRadius.zero,
                child: Column(
                  children: [
                    // 1. Header tinh gọn chuẩn ứng dụng thương mại
                    _buildHeader(_model.profile.fullName),

                    // 2. Nội dung chính: 2 cột (Cột trái: Danh sách việc, Cột phải: Tổng quan tiến độ)
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isTwoColumn = constraints.maxWidth >= 900;

                          final leftColumn = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Thanh lọc nhanh theo danh mục (depth: 1)
                              ListenableBuilder(
                                listenable: _model,
                                builder: (context, _) {
                                  return QuickFilterBar(
                                    onSelectPreset: _handleApplyPreset,
                                    isConnected: _isConnected,
                                    isDeveloperMode: _isDeveloperMode,
                                    isPropDrilling: isProp,
                                  );
                                },
                              ),

                              const SizedBox(height: AppSpacing.md),

                              // Bộ lọc danh mục công việc (Tabs) (depth: 1)
                              ListenableBuilder(
                                listenable: _model,
                                builder: (context, _) {
                                  return _buildCategoryFilterTabs(
                                    _model.selectedCategoryFilter,
                                    _model.tasks,
                                  );
                                },
                              ),

                              const SizedBox(height: AppSpacing.md),

                              // Danh sách các khối danh mục và thẻ công việc (depth: 1)
                              _buildCategorySections(
                                _model.selectedCategoryFilter,
                                _model.tasks,
                                isProp,
                              ),
                            ],
                          );

                          final rightColumn = ListenableBuilder(
                            listenable: _model,
                            builder: (context, _) {
                              return TaskSummary(
                                tasks: _model.tasks,
                                profile: _model.profile,
                                activities: _model.activities,
                                onCompleteAll: _handleCompleteAll,
                                onResetAll: _handleResetAll,
                                isConnected: _isConnected,
                                isDeveloperMode: _isDeveloperMode,
                                isPropDrilling: isProp,
                              );
                            },
                          );

                          if (isTwoColumn) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Cột trái: Lọc nhanh, Tabs danh mục, Thẻ việc
                                  Expanded(
                                    flex: 62,
                                    child: Scrollbar(
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: leftColumn,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: AppSpacing.lg),

                                  // Cột phải: Tiến độ công việc, Phân bổ & Hoạt động
                                  Expanded(
                                    flex: 38,
                                    child: Scrollbar(
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: rightColumn,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Bố cục 1 cột khi co nhỏ cửa sổ Desktop dưới 900px
                            return Scrollbar(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.md,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    leftColumn,
                                    const SizedBox(height: AppSpacing.lg),
                                    rightColumn,
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    // 3. Thanh trạng thái mảnh ở đáy cửa sổ (32px), chỉ hiện khi bật Developer Mode
                    if (_isDeveloperMode)
                      DeveloperStatusBar(
                        currentMode: _currentMode,
                        onModeChanged: _onModeChanged,
                        onResetTracker: _onResetTracker,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Header tinh gọn: Tên app TaskFlow + Trạng thái đồng bộ + Chế độ Developer + Tài khoản
  Widget _buildHeader(String userName) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md - 2.0,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 1150;

          const titleWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 22.0, color: AppColors.primary),
              SizedBox(width: 8.0),
              Text(
                'TaskFlow',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: AppTextStyles.h2,
              ),
            ],
          );

          final connectionStatusWidget = Tooltip(
            message: 'Bấm để mô phỏng ngắt / kết nối Cloud',
            preferBelow: false,
            waitDuration: const Duration(milliseconds: 600),
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            textStyle: AppTextStyles.caption.copyWith(color: Colors.white),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: AppRadius.radius8,
            ),
            child: InkWell(
              onTap: _toggleConnectionSimulation,
              borderRadius: AppRadius.radius8,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        color: _isConnected ? AppColors.connected : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs + 2.0),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240.0),
                      child: Text(
                        _isConnected ? 'Đã đồng bộ Cloud · 12 ms' : 'Ngoại tuyến · nhấn để kết nối lại',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: AppTextStyles.caption.copyWith(
                          color: _isConnected ? AppColors.textSecondary : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          // Nút bật/tắt Chế độ So sánh Rebuild (Ctrl+D)
          final devModeButton = Tooltip(
            message: 'Chế độ Developer / So sánh Rebuild (Ctrl+D)',
            preferBelow: false,
            waitDuration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            textStyle: AppTextStyles.caption.copyWith(color: Colors.white),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: AppRadius.radius8,
            ),
            child: InkWell(
              onTap: _toggleDeveloperMode,
              borderRadius: AppRadius.radius8,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: _isDeveloperMode ? AppColors.primaryLight : Colors.transparent,
                  borderRadius: AppRadius.radius8,
                  border: Border.all(
                    color: _isDeveloperMode ? AppColors.primary : AppColors.border,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.developer_mode_outlined,
                      size: 16.0,
                      color: _isDeveloperMode ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      _isDeveloperMode ? 'So sánh Rebuild: BẬT' : 'So sánh Rebuild',
                      style: AppTextStyles.captionMedium.copyWith(
                        color: _isDeveloperMode ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: _isDeveloperMode ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          final userWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 13.0,
                backgroundColor: AppColors.background,
                child: Text(
                  'KT',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: AppTextStyles.captionMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 11.0,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isCompact ? 160.0 : 220.0),
                child: Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: AppTextStyles.body,
                ),
              ),
            ],
          );

          if (!isCompact) {
            return Row(
              children: [
                titleWidget,
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: connectionStatusWidget,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                devModeButton,
                const SizedBox(width: AppSpacing.sm),
                userWidget,
              ],
            );
          } else {
            return Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                titleWidget,
                connectionStatusWidget,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    devModeButton,
                    const SizedBox(width: AppSpacing.sm),
                    userWidget,
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  /// Bộ lọc danh mục công việc dạng Tabs phẳng
  Widget _buildCategoryFilterTabs(String selectedCategory, List<TaskItem> allTasks) {
    RebuildTracker.instance.record('CategoryFilterTabs');
    final categoryOptions = ['Tất cả', ...InitialData.categories];

    final tabsContent = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categoryOptions.map((cat) {
          final isSelected = cat == selectedCategory;
          final int count;
          final int completedCount;

          if (cat == 'Tất cả') {
            count = allTasks.length;
            completedCount = allTasks.where((t) => t.isCompleted).length;
          } else {
            final inCat = allTasks.where((t) => t.category == cat);
            count = inCat.length;
            completedCount = inCat.where((t) => t.isCompleted).length;
          }

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: InkWell(
              onTap: () {
                setState(() {
                  _model.setCategoryFilter(cat);
                });
              },
              borderRadius: AppRadius.radius8,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 4.0,
                  vertical: AppSpacing.xs + 2.0,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLight : AppColors.surface,
                  borderRadius: AppRadius.radius8,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cat,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: AppTextStyles.captionMedium.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs + 2.0),
                    Text(
                      '$completedCount/$count',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );

    return RebuildFlash(
      tag: 'CategoryFilterTabs',
      depth: 1, // Độ sâu tầng tab lọc (1)
      enabled: _isDeveloperMode,
      borderRadius: AppRadius.radius8,
      child: tabsContent,
    );
  }

  /// Danh sách các khối danh mục và các hàng thẻ công việc (depth: 1)
  Widget _buildCategorySections(
    String selectedCategory,
    List<TaskItem> tasks,
    bool isPropDrilling,
  ) {
    final Widget sectionsWidget;

    if (selectedCategory == 'Tất cả') {
      sectionsWidget = Column(
        children: InitialData.categories.map((cat) {
          final catTasks = tasks.where((t) => t.category == cat).toList();
          return CategorySection(
            categoryName: cat,
            tasks: catTasks,
            onToggleTask: _handleToggleTask,
            onUpdateProgress: _handleUpdateProgress,
            isConnected: _isConnected,
            isPropDrilling: isPropDrilling,
            model: _model,
            isDeveloperMode: _isDeveloperMode,
          );
        }).toList(),
      );
    } else {
      final catTasks = tasks.where((t) => t.category == selectedCategory).toList();
      sectionsWidget = CategorySection(
        categoryName: selectedCategory,
        tasks: catTasks,
        onToggleTask: _handleToggleTask,
        onUpdateProgress: _handleUpdateProgress,
        isConnected: _isConnected,
        isPropDrilling: isPropDrilling,
        model: _model,
        isDeveloperMode: _isDeveloperMode,
      );
    }

    return RebuildFlash(
      tag: 'CategoryList',
      depth: 1, // Độ sâu danh sách nhóm (1)
      enabled: _isDeveloperMode && isPropDrilling,
      borderRadius: AppRadius.radius8,
      child: sectionsWidget,
    );
  }
}
