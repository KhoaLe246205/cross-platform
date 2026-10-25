import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

class JsonGeneratorService {
  static String getFilePath() {
    return '${Directory.systemTemp.path}\\large_benchmark_data.json';
  }

  static Future<double?> getExistingFileSizeMB() async {
    File file = File(getFilePath());
    if (await file.exists()) {
      int bytes = await file.length();
      if (bytes > 1024 * 1024) {
        return bytes / (1024 * 1024);
      }
    }
    return null;
  }

  // Tạo file JSON có cấu trúc đầy đủ (Đạt đúng 132.1 MB ở mức 8x = 480.000 bản ghi)
  static Future<double> generateLargeJsonFile({required int recordCount}) async {
    String path = getFilePath();

    return await Isolate.run(() async {
      File file = File(path);
      IOSink sink = file.openWrite();
      StringBuffer buffer = StringBuffer('[\n');

      for (int i = 0; i < recordCount; i++) {
        Map<String, dynamic> record = {
          'id': i + 1,
          'deviceCode': 'DEV-NODE-${(i % 500).toString().padLeft(4, '0')}',
          'timestamp': '2026-10-15T09:44:${(i % 60).toString().padLeft(2, '0')}.000Z',
          'readings': [
            12.45 + (i % 10),
            98.76 - (i % 7),
            45.12 * ((i % 5) + 1),
            33.89 + (i % 13),
            77.11 - (i % 9),
            64.20 + (i % 4),
          ],
          'metadata': {
            'location': 'Da Nang Data Center - Rack ${(i % 20) + 1}',
            'status': i % 3 == 0 ? 'ACTIVE' : 'CALIBRATING',
            'firmware': 'v4.12.8-enterprise-build-$i',
            'checksum': 'SHA256-${(i * 987654321).toRadixString(16)}',
          }
        };

        String jsonLine = jsonEncode(record);
        if (i < recordCount - 1) {
          buffer.write('$jsonLine,\n');
        } else {
          buffer.write('$jsonLine\n');
        }

        if (i % 2000 == 0) {
          sink.write(buffer.toString());
          buffer.clear();
        }
      }

      buffer.write(']');
      sink.write(buffer.toString());

      await sink.flush();
      await sink.close();

      int sizeBytes = await file.length();
      return sizeBytes / (1024 * 1024);
    });
  }
}