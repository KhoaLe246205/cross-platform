import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EcoSmartHomeApp());
}

/// Ứng dụng Quản lý Ngôi nhà Thông minh & Năng lượng (EcoSmart Home Hub).
/// Thiết kế phẳng chuẩn Designer dành cho Desktop / Web / Tablet.
class EcoSmartHomeApp extends StatelessWidget {
  const EcoSmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoSmart Hub - Điều Khiển & Quản Lý Năng Lượng',
      debugShowCheckedModeBanner: false,
      theme: getAppTheme(),
      home: const HomeScreen(),
    );
  }
}
