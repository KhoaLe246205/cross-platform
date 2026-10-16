import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FpsMonitorPanel extends StatefulWidget {
  const FpsMonitorPanel({super.key});

  @override
  State<FpsMonitorPanel> createState() => _FpsMonitorPanelState();
}

class _FpsMonitorPanelState extends State<FpsMonitorPanel>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  int _frameCount = 0;
  DateTime _lastSampleTime = DateTime.now();
  DateTime _lastFrameTime = DateTime.now();

  double _currentFps = 60.0;
  double _minFps = 60.0;
  int _freezeMs = 0;
  List<double> _fpsHistory = List.filled(40, 60.0, growable: true);
  double _rotationAngle = 0.0;

  @override
  void initState() {
    super.initState();

    // Hàm này được gọi liên tục ở mỗi khung hình (Frame)
    _ticker = createTicker((elapsed) {
      DateTime now = DateTime.now();
      int gapMs = now.difference(_lastFrameTime).inMilliseconds;
      _lastFrameTime = now;

      // Nếu khoảng cách giữa 2 khung hình > 250ms -> Giao diện vừa bị đơ!
      if (gapMs > 250) {
        _freezeMs = gapMs;
        _currentFps = 0;
        _minFps = 0;

        int redBars = (gapMs / 250).clamp(1, 15).toInt();
        for (int i = 0; i < redBars; i++) {
          _fpsHistory.add(0);
          _fpsHistory.removeAt(0);
        }
      }

      _frameCount++;
      int diffMs = now.difference(_lastSampleTime).inMilliseconds;

      // Cập nhật chỉ số FPS mỗi 250ms
      if (diffMs >= 250) {
        if (gapMs <= 250) {
          _currentFps = (_frameCount * 1000 / diffMs).clamp(0, 240);
          if (_currentFps < _minFps) _minFps = _currentFps;
          _fpsHistory.add(_currentFps);
          _fpsHistory.removeAt(0);
        }
        _frameCount = 0;
        _lastSampleTime = now;
      }

      setState(() {
        _rotationAngle += 0.07; // Xoay bánh răng
      });
    });

    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Color _getColor(double fps) {
    if (fps < 15) return Colors.redAccent;
    if (fps < 45) return Colors.orangeAccent;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    Color fpsColor = _getColor(_currentFps);

    return Card(
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Bánh răng xoay liên tục
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: fpsColor, width: 2),
                  ),
                  child: Transform.rotate(
                    angle: _rotationAngle,
                    child: Icon(Icons.settings, size: 44, color: fpsColor),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BỘ ĐO KHUNG HÌNH THỜI GIAN THỰC',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Row(
                        children: [
                          Text(
                            '${_currentFps.toStringAsFixed(0)} FPS',
                            style: TextStyle(
                              color: fpsColor,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            'Min FPS: ${_minFps.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(width: 16),
                          if (_freezeMs > 0)
                            Text(
                              'ĐƠ UI: $_freezeMs ms!',
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _minFps = _currentFps;
                      _freezeMs = 0;
                    });
                  },
                  child: const Text('Reset Min/Freeze'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Biểu đồ cột FPS
            SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _fpsHistory.map((fps) {
                  double barHeight = (fps / 120.0).clamp(0.1, 1.0) * 60;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      height: barHeight,
                      color: _getColor(fps),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}