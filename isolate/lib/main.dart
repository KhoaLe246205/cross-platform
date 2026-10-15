import 'package:flutter/material.dart';
import 'screens/benchmark_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IsolateBenchmarkApp());
}

class IsolateBenchmarkApp extends StatelessWidget {
  const IsolateBenchmarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isolate Non-blocking UI Benchmark',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const BenchmarkScreen(),
    );
  }
}