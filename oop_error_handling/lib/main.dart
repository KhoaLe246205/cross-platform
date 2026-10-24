// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'presentation/controllers/booking_controller.dart';
import 'presentation/pages/demo_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = BookingController();

  // LƯỚI AN TOÀN TOÀN CỤC (GLOBAL SAFETY NET):
  // Bắt mọi lỗi Framework hoặc Platform chưa được xử lý, gom vào Nhật ký thay vì làm app sập đột ngột
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details); // In lỗi ra console để hỗ trợ debug
    controller.recordExternalError('FlutterFramework', details.exception);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    controller.recordExternalError('PlatformDispatcher', error);
    return true; // Trả về true để xác nhận đã bắt lỗi, ngăn hệ thống dừng đột ngột (crash)
  };

  runApp(MyApp(controller: controller));
}

class MyApp extends StatelessWidget {
  final BookingController controller;

  const MyApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Booking System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F172A)),
        useMaterial3: true,
      ),
      home: DemoPage(controller: controller),
    );
  }
}
