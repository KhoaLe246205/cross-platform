import 'package:flutter/material.dart';
import '../models/rebuild_tracker.dart';
import '../theme/app_theme.dart';
import 'rebuild_flash.dart';

/// Thanh kịch bản một chạm (Scene Bar) kết hợp công tắc chế độ Eco.
/// Toàn bộ thành phần nằm trong Wrap, co giãn tự do, triệt tiêu hoàn toàn lỗi RenderFlex overflow.
class SceneBar extends StatelessWidget {
  final void Function(String sceneId) onSelectScene;
  final bool isEcoMode;
  final VoidCallback onToggleEco;
  final bool isConnected;
  final bool isDeveloperMode;
  final bool isPropDrilling;

  const SceneBar({
    super.key,
    required this.onSelectScene,
    required this.isEcoMode,
    required this.onToggleEco,
    this.isConnected = true,
    this.isDeveloperMode = false,
    this.isPropDrilling = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPropDrilling) {
      RebuildTracker.instance.record('SceneBar');
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
            'Kịch bản:',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: AppTextStyles.captionMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          // Các chip kịch bản
          _SceneChip(
            label: 'Về nhà',
            icon: Icons.home_outlined,
            onTap: isConnected ? () => onSelectScene('welcome') : null,
          ),
          _SceneChip(
            label: 'Rời nhà',
            icon: Icons.logout_outlined,
            onTap: isConnected ? () => onSelectScene('away') : null,
          ),
          _SceneChip(
            label: 'Ban đêm',
            icon: Icons.bedtime_outlined,
            onTap: isConnected ? () => onSelectScene('night') : null,
          ),

          // Vạch ngăn cách mảnh
          Container(
            height: 16.0,
            width: 1.0,
            color: AppColors.border,
          ),

          // Công tắc Eco Mode
          MouseRegion(
            cursor: isConnected ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.eco_outlined,
                  size: 16.0,
                  color: isEcoMode ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    'Eco Mode',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: AppTextStyles.captionMedium.copyWith(
                      color: isEcoMode ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                SizedBox(
                  height: 24.0,
                  child: Switch(
                    value: isEcoMode,
                    onChanged: isConnected ? (_) => onToggleEco() : null,
                    activeColor: AppColors.primary,
                    activeTrackColor: AppColors.primaryBorder,
                    inactiveThumbColor: AppColors.textMuted,
                    inactiveTrackColor: AppColors.border,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return RebuildFlash(
      tag: 'SceneBar',
      enabled: isDeveloperMode && isPropDrilling,
      borderRadius: AppRadius.radius8,
      child: barContent,
    );
  }
}

class _SceneChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _SceneChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_SceneChip> createState() => _SceneChipState();
}

class _SceneChipState extends State<_SceneChip> {
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
