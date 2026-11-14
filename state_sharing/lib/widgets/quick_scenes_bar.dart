import 'package:flutter/material.dart';

/// Thanh phím tắt kịch bản thông minh (Quick Scenes Bar).
/// Người dùng kích hoạt các tình huống sử dụng thực tế chỉ bằng một lần chạm.
class QuickScenesBar extends StatelessWidget {
  final void Function(String sceneId) onSelectScene;
  final bool isEcoActive;

  const QuickScenesBar({
    super.key,
    required this.onSelectScene,
    this.isEcoActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 16.0, color: Color(0xFF1E293B)),
              const SizedBox(width: 8.0),
              const Text(
                'Kịch bản thông minh một chạm',
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Text(
                'Tự động đồng bộ các phòng',
                style: TextStyle(
                  fontSize: 11.0,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: _SceneButton(
                  icon: Icons.home_rounded,
                  title: 'Về nhà',
                  subtitle: 'Bật phòng khách 70%',
                  color: const Color(0xFF3B82F6),
                  onTap: () => onSelectScene('welcome'),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _SceneButton(
                  icon: Icons.exit_to_app_rounded,
                  title: 'Rời nhà',
                  subtitle: 'Tắt hết an toàn',
                  color: const Color(0xFF64748B),
                  onTap: () => onSelectScene('away'),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _SceneButton(
                  icon: Icons.bedtime_rounded,
                  title: 'Ban đêm',
                  subtitle: 'Đèn ngủ 20% & AC êm',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => onSelectScene('night'),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _SceneButton(
                  icon: Icons.eco_rounded,
                  title: 'Tiết kiệm Eco',
                  subtitle: 'Giới hạn tải 60%',
                  color: const Color(0xFF10B981),
                  isActive: isEcoActive,
                  onTap: () => onSelectScene('eco'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SceneButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isActive;

  const _SceneButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.12) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: isActive ? color : const Color(0xFFE2E8F0),
              width: isActive ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(icon, size: 18.0, color: color),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: isActive ? color : const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10.0,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
