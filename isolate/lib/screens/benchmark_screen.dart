import 'package:flutter/material.dart';
import '../services/json_generator_service.dart';
import '../services/isolate_worker_service.dart';
import '../widgets/fps_monitor_panel.dart';

class BenchmarkScreen extends StatefulWidget {
  const BenchmarkScreen({super.key});

  @override
  State<BenchmarkScreen> createState() => _BenchmarkScreenState();
}

class _BenchmarkScreenState extends State<BenchmarkScreen> {
  double? _jsonFileSizeMB;
  bool _isGeneratingFile = false;
  bool _isProcessing = false;

  int _cpuIntensity = 3; // Từ 1x (~16.5 MB) đến 8x (132.1 MB)
  double _progress = 0.0;
  String _statusMessage = 'Hãy nhấn nút khởi tạo file JSON trước.';
  List<ParseBenchmarkResult> _historyResults = [];
  double _testSlider = 50.0;

  @override
  void initState() {
    super.initState();
    _checkExistingFile();
  }

  Future<void> _checkExistingFile() async {
    double? size = await JsonGeneratorService.getExistingFileSizeMB();
    if (size != null && mounted) {
      setState(() {
        _jsonFileSizeMB = size;
        _statusMessage = 'Sẵn sàng! Đã tìm thấy file JSON (${size.toStringAsFixed(1)} MB).';
      });
    }
  }

  // Tạo file JSON: Mỗi mức 1x = 60.000 bản ghi (~16.5 MB). Mức 8x = 480.000 bản ghi (132.1 MB)
  Future<void> _generateJsonFile() async {
    int totalRecords = 60000 * _cpuIntensity;

    setState(() {
      _isGeneratingFile = true;
      _statusMessage =
          'Đang tạo file JSON mức ${_cpuIntensity}x ($totalRecords bản ghi)...';
    });

    try {
      double sizeMB = await JsonGeneratorService.generateLargeJsonFile(
        recordCount: totalRecords,
      );
      setState(() {
        _jsonFileSizeMB = sizeMB;
        _statusMessage =
            'Tạo file thành công! Dung lượng: ${sizeMB.toStringAsFixed(1)} MB ($totalRecords bản ghi).';
      });
    } catch (e) {
      setState(() => _statusMessage = 'Lỗi tạo file: $e');
    } finally {
      setState(() => _isGeneratingFile = false);
    }
  }

  // 1. Chạy trên Main Thread
  Future<void> _executeMainThread() async {
    if (_jsonFileSizeMB == null) return;

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _statusMessage =
          'ĐANG CHẠY TRÊN MAIN THREAD... Quan sát bánh răng ĐỨNG HÌNH và FPS tụt về 0!';
    });

    await Future.delayed(const Duration(milliseconds: 100));

    try {
      ParseBenchmarkResult result = IsolateWorkerService.runOnMainThread(
        JsonGeneratorService.getFilePath(),
        _cpuIntensity,
      );
      setState(() {
        _historyResults.insert(0, result);
        _progress = 1.0;
        _statusMessage =
            'Hoàn tất trên Main Thread trong ${result.elapsedMs} ms (Giao diện đã bị đơ cứng!).';
      });
    } catch (e) {
      setState(() => _statusMessage = 'Lỗi: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // 2. Chạy bằng hàm compute()
  Future<void> _executeComputeIsolate() async {
    if (_jsonFileSizeMB == null) return;

    setState(() {
      _isProcessing = true;
      _progress = 0.5;
      _statusMessage = 'Đang chạy bằng hàm compute()... Giao diện xanh mượt 60+ FPS!';
    });

    try {
      ParseBenchmarkResult result = await IsolateWorkerService.runWithCompute(
        JsonGeneratorService.getFilePath(),
        _cpuIntensity,
      );
      setState(() {
        _historyResults.insert(0, result);
        _progress = 1.0;
        _statusMessage =
            'Hoàn tất bằng compute() trong ${result.elapsedMs} ms (Không rớt khung hình nào!).';
      });
    } catch (e) {
      setState(() => _statusMessage = 'Lỗi: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // 3. Chạy bằng Isolate.spawn + SendPort / ReceivePort
  Future<void> _executeSpawnIsolate() async {
    if (_jsonFileSizeMB == null) return;

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _statusMessage = 'Khởi tạo Isolate.spawn và lắng nghe qua ReceivePort...';
    });

    try {
      ParseBenchmarkResult result =
          await IsolateWorkerService.runWithSpawnAndPorts(
        filePath: JsonGeneratorService.getFilePath(),
        intensity: _cpuIntensity,
        onProgress: (prog, msg) {
          if (mounted) {
            setState(() {
              _progress = prog;
              // stream update: live progress
            });
          }
        },
      );
      setState(() {
        _historyResults.insert(0, result);
        _progress = 1.0;
        _statusMessage =
            'Hoàn tất qua SendPort/ReceivePort trong ${result.elapsedMs} ms!';
      });
    } catch (e) {
      setState(() => _statusMessage = 'Lỗi: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasFile = _jsonFileSizeMB != null;
    int estimatedMB = (_cpuIntensity * 16.5).round();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Chủ đề 03: Đa luồng với Isolates (Non-blocking UI)'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Chip(
                backgroundColor:
                    hasFile ? Colors.teal.shade900 : Colors.amber.shade900,
                label: Text(
                  hasFile
                      ? 'File JSON: ${_jsonFileSizeMB!.toStringAsFixed(1)} MB'
                      : 'Chưa tạo file JSON',
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FpsMonitorPanel(),
            const SizedBox(height: 16),

            // BƯỚC 1: TẠO FILE JSON & CHỌN ĐỘ NẶNG
            Card(
              color: const Color(0xFF1E293B),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BƯỚC 1: MỨC TẢI CPU & DỮ LIỆU (Mức ${_cpuIntensity}x = ${_cpuIntensity * 60000} bản ghi ~ $estimatedMB MB)',
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: (_isGeneratingFile || _isProcessing)
                              ? null
                              : _generateJsonFile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.storage),
                          label: Text(
                            hasFile
                                ? 'Tạo lại File JSON (~$estimatedMB MB)'
                                : 'Khởi tạo File JSON (~$estimatedMB MB)',
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _cpuIntensity.toDouble(),
                      min: 1,
                      max: 8,
                      divisions: 7,
                      label: 'Mức ${_cpuIntensity}x (~$estimatedMB MB)',
                      onChanged: (_isProcessing || _isGeneratingFile)
                          ? null
                          : (val) => setState(() => _cpuIntensity = val.toInt()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // BƯỚC 2: CHẠY SO SÁNH 3 CHẾ ĐỘ
            Card(
              color: const Color(0xFF1E293B),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BƯỚC 2: CHẠY SO SÁNH (MAIN THREAD VS ISOLATES)',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (!hasFile || _isProcessing)
                                ? null
                                : _executeMainThread,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              '1. Chạy trên Main Thread\n(Đơ cứng UI - Tụt FPS về 0)',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (!hasFile || _isProcessing)
                                ? null
                                : _executeComputeIsolate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              '2. Chạy với hàm compute()\n(Tách luồng nhanh - Mượt)',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (!hasFile || _isProcessing)
                                ? null
                                : _executeSpawnIsolate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              '3. Isolate.spawn + SendPort\n(Truyền % tiến độ Real-time)',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _isProcessing
                          ? (_progress > 0 ? _progress : null)
                          : _progress,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(_statusMessage),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Text(
                          'Kéo thử thanh trượt khi đang chạy để kiểm tra độ mượt:',
                          style: TextStyle(color: Colors.amberAccent),
                        ),
                        Expanded(
                          child: Slider(
                            value: _testSlider,
                            min: 0,
                            max: 100,
                            onChanged: (v) => setState(() => _testSlider = v),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // BẢNG LỊCH SỬ KẾT QUẢ
            Card(
              color: const Color(0xFF1E293B),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BẢNG LỊCH SỬ KẾT QUẢ ĐO LƯỜNG',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_historyResults.isEmpty)
                      const Text('Chưa có lượt chạy nào.')
                    else
                      ..._historyResults.map(
                        (res) => ListTile(
                          leading: Icon(
                            res.modeName.contains('Main Thread')
                                ? Icons.error_outline
                                : Icons.check_circle_outline,
                            color: res.modeName.contains('Main Thread')
                                ? Colors.redAccent
                                : Colors.greenAccent,
                          ),
                          title: Text(
                            res.modeName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Đã parse thành công: ${res.totalRecords} bản ghi (Dung lượng: ${res.fileSizeMB.toStringAsFixed(1)} MB)',
                          ),
                          trailing: Text(
                            '${res.elapsedMs} ms',
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}