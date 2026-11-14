import 'package:flutter/material.dart';
import '../models/rebuild_tracker.dart';
import '../theme/app_theme.dart';
import 'rebuild_flash.dart';

/// Thanh lọc nhanh theo danh mục công việc (Quick Filter Bar).
class QuickFilterBar extends StatelessWidget {
  final void Function(String preset) onSelectPreset;
  final bool isConnected;
  final bool isDeveloperMode;
  final bool isPropDrilling;

  const QuickFilterBar({
    super.key,
    required this.onSelectPreset,
    this.isConnected = true,
    this.isDeveloperMode = false,
    this.isPropDrilling = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPropDrilling) {
      RebuildTracker.instance.record('QuickFilterBar');
    }

    final barContent = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2.0,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radius8,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs + 2.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Tiêu đề nhỏ
          Text(
            'Lọc nhanh:',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: AppTextStyles.captionMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          // Các chip lọc
          _FilterChip(
            label: 'Tất cả việc',
            icon: Icons.all_inbox_rounded,
            onTap: isConnected ? () => onSelectPreset('today') : null,
          ),
          _FilterChip(
            label: 'Học tập',
            icon: Icons.school_outlined,
            onTap: isConnected ? () => onSelectPreset('study') : null,
          ),
          _FilterChip(
            label: 'Thể thao',
            icon: Icons.fitness_center_outlined,
            onTap: isConnected ? () => onSelectPreset('sport') : null,
          ),
          _FilterChip(
            label: 'Giải trí',
            icon: Icons.sports_esports_outlined,
            onTap: isConnected ? () => onSelectPreset('entertain') : null,
          ),
        ],
      ),
    );

    return RebuildFlash(
      tag: 'QuickFilterBar',
      depth: 1, // Độ sâu tầng tab lọc (1)
      enabled: isDeveloperMode && isPropDrilling,
      borderRadius: AppRadius.radius8,
      child: barContent,
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 4.0,
            vertical: AppSpacing.xs + 2.0,
          ),
          decoration: BoxDecoration(
            color: _isHovered && isEnabled ? AppColors.surfaceHover : AppColors.surface,
            borderRadius: AppRadius.radius8,
            border: Border.all(
              color: _isHovered && isEnabled ? AppColors.borderHover : AppColors.border,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 15.0,
                color: isEnabled ? AppColors.textPrimary : AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs + 2.0),
              Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: AppTextStyles.captionMedium.copyWith(
                  color: isEnabled ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Alias tương thích ngược
typedef SceneBar = QuickFilterBar;
