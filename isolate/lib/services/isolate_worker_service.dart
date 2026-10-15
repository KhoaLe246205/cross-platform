import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../models/sensor_record.dart';

class ParseBenchmarkResult {
  final int totalRecords;
  final int elapsedMs;
  final double fileSizeMB;
  final String modeName;

  ParseBenchmarkResult({
    required this.totalRecords,
    required this.elapsedMs,
    required this.fileSizeMB,
    required this.modeName,
  });
}

// =========================================================================
// HÀM XỬ LÝ NẶNG DÙNG CHO MAIN THREAD VÀ COMPUTE()
// Nhận vào 1 Map cơ bản gồm: 'filePath' và 'intensity' (Hệ số tải CPU)
// =========================================================================
ParseBenchmarkResult heavyParseTask(Map<String, dynamic> args) {
  String filePath = args['filePath'];
  int intensity = args['intensity'];

  Stopwatch stopwatch = Stopwatch()..start();

  // 1. Đọc file JSON và giải mã
  File file = File(filePath);
  double fileSizeMB = file.lengthSync() / (1024 * 1024);
  String rawJson = file.readAsStringSync();
  List<dynamic> decodedList = jsonDecode(rawJson);

  // 2. Chạy vòng lặp bóc tách & tính toán nặng trên CPU theo hệ số tải
  for (int pass = 0; pass < intensity; pass++) {
    for (int i = 0; i < decodedList.length; i++) {
      SensorRecord.parseAndCalculate(decodedList[i]);
    }
  }

  stopwatch.stop();

  return ParseBenchmarkResult(
    totalRecords: decodedList.length,
    elapsedMs: stopwatch.elapsedMilliseconds,
    fileSizeMB: fileSizeMB,
    modeName: 'Hàm compute() (Short-lived Isolate)',
  );
}

// =========================================================================
// HÀM CHẠY TRONG ISOLATE.SPAWN (Giao tiếp qua SendPort)
// =========================================================================
void spawnIsolateEntry(Map<String, dynamic> args) {
  SendPort sendPort = args['sendPort'];
  String filePath = args['filePath'];
  int intensity = args['intensity'];

  Stopwatch stopwatch = Stopwatch()..start();

  try {
    File file = File(filePath);
    double fileSizeMB = file.lengthSync() / (1024 * 1024);

    sendPort.send({
      'type': 'progress',
      'progress': 0.1,
      'message': 'Đang đọc & giải mã file JSON (${fileSizeMB.toStringAsFixed(1)} MB) trong Isolate...'
    });

    String rawJson = file.readAsStringSync();
    List<dynamic> decodedList = jsonDecode(rawJson);

    int totalSteps = decodedList.length * intensity;
    int currentStep = 0;
    // Chỉ gửi tin nhắn tối đa khoảng 20 lần trong suốt quá trình để không làm nghẽn UI
    int stepInterval = (totalSteps ~/ 20).clamp(5000, 1000000);

    for (int pass = 0; pass < intensity; pass++) {
      for (int i = 0; i < decodedList.length; i++) {
        SensorRecord.parseAndCalculate(decodedList[i]);
        currentStep++;

        if (currentStep % stepInterval == 0) {
          double progress = 0.1 + 0.9 * (currentStep / totalSteps);
          sendPort.send({
            'type': 'progress',
            'progress': progress,
            'message': 'Đang xử lý: $currentStep / $totalSteps bước tính toán...',
          });
        }
      }
    }

    stopwatch.stop();

    // Báo hoàn thành về Main Thread
    sendPort.send({
      'type': 'done',
      'totalRecords': decodedList.length,
      'elapsedMs': stopwatch.elapsedMilliseconds,
      'fileSizeMB': fileSizeMB,
    });
  } catch (e) {
    sendPort.send({'type': 'error', 'error': e.toString()});
  }
}

// =========================================================================
// CLASS ĐỂ GIAO DIỆN GỌI 3 CHẾ ĐỘ
// =========================================================================
class IsolateWorkerService {
  // CÁCH 1: Chạy trực tiếp trên Main Thread (Đơ cứng UI - FPS tụt về 0)
  static ParseBenchmarkResult runOnMainThread(String filePath, int intensity) {
    ParseBenchmarkResult res = heavyParseTask({
      'filePath': filePath,
      'intensity': intensity,
    });
    return ParseBenchmarkResult(
      totalRecords: res.totalRecords,
      elapsedMs: res.elapsedMs,
      fileSizeMB: res.fileSizeMB,
      modeName: 'Main Thread (Single-Thread - Gây nghẽn UI)',
    );
  }

  // CÁCH 2: Chạy bằng hàm compute() (Xanh mượt 60+ FPS)
  static Future<ParseBenchmarkResult> runWithCompute(
      String filePath, int intensity) async {
    return await compute(heavyParseTask, {
      'filePath': filePath,
      'intensity': intensity,
    });
  }

  // CÁCH 3: Chạy bằng Isolate.spawn + SendPort / ReceivePort (Xanh mượt 60+ FPS)
  static Future<ParseBenchmarkResult> runWithSpawnAndPorts({
    required String filePath,
    required int intensity,
    required Function(double progress, String status) onProgress,
  }) async {
    ReceivePort receivePort = ReceivePort();

    Isolate workerIsolate = await Isolate.spawn(
      spawnIsolateEntry,
      {
        'sendPort': receivePort.sendPort,
        'filePath': filePath,
        'intensity': intensity,
      },
    );

    await for (var msg in receivePort) {
      String type = msg['type'];

      if (type == 'progress') {
        onProgress(msg['progress'], msg['message']);
      } else if (type == 'done') {
        receivePort.close();
        workerIsolate.kill(priority: Isolate.immediate);
        return ParseBenchmarkResult(
          totalRecords: msg['totalRecords'],
          elapsedMs: msg['elapsedMs'],
          fileSizeMB: msg['fileSizeMB'],
          modeName: 'Isolate.spawn + SendPort/ReceivePort',
        );
      } else if (type == 'error') {
        receivePort.close();
        workerIsolate.kill(priority: Isolate.immediate);
        throw Exception(msg['error']);
      }
    }
    throw Exception('Isolate đã đóng bất ngờ');
  }
}