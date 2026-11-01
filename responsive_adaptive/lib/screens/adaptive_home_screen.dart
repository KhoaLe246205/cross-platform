import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/breakpoints.dart';
import '../widgets/responsive_content.dart';

class AdaptiveHomeScreen extends StatefulWidget {
  const AdaptiveHomeScreen({super.key});

  @override
  State<AdaptiveHomeScreen> createState() => _AdaptiveHomeScreenState();
}

class _AdaptiveHomeScreenState extends State<AdaptiveHomeScreen> {
  int _selectedIndex = 0;

  // Trừu tượng hóa dữ liệu điều hướng (Abstract Navigation Destinations)
  static const _navItems = [
    (icon: Icons.dashboard_outlined, label: 'Bố cục (Alt+1)'),
    (icon: Icons.devices_outlined, label: 'Thiết bị (Alt+2)'),
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Measure (Macro): Lấy kích thước dp toàn bộ cửa sổ
    final Size screenSize = MediaQuery.sizeOf(context);
    final double width = screenSize.width;

    // 2. Branch (Macro): Thích ứng 3 cấp độ theo Window Size Classes chuẩn Material 3
    final bool isWideScreen = width >= AppBreakpoints.compactBreakpoint; // >= 600dp: Medium
    final bool isExpanded = width >= AppBreakpoints.mediumBreakpoint;    // >= 840dp: Expanded

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1, alt: true): () => setState(() => _selectedIndex = 0),
        const SingleActivator(LogicalKeyboardKey.digit2, alt: true): () => setState(() => _selectedIndex = 1),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Width: ${width.toInt()} dp (${isExpanded ? "Expanded" : isWideScreen ? "Medium" : "Compact"})',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            actions: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Phím tắt: Alt+1 / Alt+2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          bottomNavigationBar: isWideScreen
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (i) => setState(() => _selectedIndex = i),
                  destinations: [
                    for (final item in _navItems)
                      NavigationDestination(icon: Icon(item.icon), label: item.label),
                  ],
                ),
          body: Row(
            children: [
              if (isWideScreen) ...[
                NavigationRail(
                  extended: isExpanded,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (i) => setState(() => _selectedIndex = i),
                  labelType: isExpanded ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                  destinations: [
                    for (final item in _navItems)
                      NavigationRailDestination(icon: Icon(item.icon), label: Text(item.label)),
                  ],
                ),
                const VerticalDivider(width: 1, thickness: 1),
              ],
              Expanded(
                child: _selectedIndex == 0
                    ? const ResponsiveContent()
                    : _buildDeviceSpecs(context, screenSize, isWideScreen, isExpanded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Nội dung minh họa Tab 2: Thông số môi trường và thiết bị (tối ưu qua Record Dart 3)
  Widget _buildDeviceSpecs(BuildContext context, Size screenSize, bool isWide, bool isExpanded) {
    final theme = Theme.of(context);
    final orientation = MediaQuery.orientationOf(context);

    final specs = [
      ('Chiều rộng cửa sổ (Window Width)', '${screenSize.width.toInt()} dp (Logical Pixels)'),
      ('Chiều cao cửa sổ (Window Height)', '${screenSize.height.toInt()} dp (Logical Pixels)'),
      ('Hướng hiển thị (Orientation)', orientation == Orientation.landscape ? 'Landscape (Ngang)' : 'Portrait (Dọc)'),
      ('Phân cấp mốc ngắt (Material 3)', isExpanded ? 'Expanded (>= 840 dp)' : (isWide ? 'Medium (600 - 839 dp)' : 'Compact (< 600 dp)')),
      ('Nền tảng thực thi (Platform)', kIsWeb ? 'Web Browser' : defaultTargetPlatform.name),
      ('Mật độ hiển thị (VisualDensity)', theme.visualDensity == VisualDensity.compact ? 'VisualDensity.compact' : 'VisualDensity.standard'),
      ('Phương thức nhập liệu hỗ trợ', 'Chuột (Hover) + Phím tắt + Chạm (>= 48dp)'),
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.devices, color: theme.colorScheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Thông số Môi trường & Thiết bị',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  for (final (label, value) in specs)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: Text(label, style: const TextStyle(fontSize: 13))),
                          const SizedBox(width: 12),
                          Expanded(flex: 6, child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: theme.colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Icon(Icons.keyboard_outlined, size: 20, color: theme.colorScheme.onSecondaryContainer),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Đang xem tab Thiết bị. Dùng phím tắt Alt+1 để về tab Bố cục.',
                            style: TextStyle(fontSize: 13, color: theme.colorScheme.onSecondaryContainer),
                          ),
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
