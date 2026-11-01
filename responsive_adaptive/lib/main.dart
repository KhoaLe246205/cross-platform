import 'package:flutter/material.dart';
import 'screens/adaptive_home_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chủ đề 3: Responsive & Adaptive UI',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        // Tự động điều chỉnh mật độ hiển thị theo nền tảng (Desktop compact, Mobile standard)
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AdaptiveHomeScreen(),
    );
  }
}
