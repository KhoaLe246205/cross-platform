import 'package:flutter/material.dart';
import '../models/app_mode.dart';

/// Bảng ma trận đối chiếu khoa học giữa 4 cơ chế chia sẻ trạng thái trong Flutter.
class PerformanceComparisonTable extends StatelessWidget {
  final StateSharingMode activeMode;

  const PerformanceComparisonTable({
    super.key,
    required this.activeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFDEE2E6), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 5.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.table_chart_outlined, size: 18.0, color: Color(0xFF141414)),
              SizedBox(width: 8.0),
              Text(
                'MA TRẬN ĐỐI CHIẾU 4 CƠ CHẾ CHIA SẺ TRẠNG THÁI',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFF141414),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 36.0,
              dataRowMinHeight: 38.0,
              dataRowMaxHeight: 52.0,
              horizontalMargin: 10.0,
              columnSpacing: 16.0,
              headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F3F5)),
              columns: const [
                DataColumn(
                  label: Text('Tiêu chí so sánh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.0)),
                ),
                DataColumn(
                  label: Text('1. Prop Drilling', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.0)),
                ),
                DataColumn(
                  label: Text('2. InheritedWidget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.0)),
                ),
                DataColumn(
                  label: Text('3. ValueNotifier', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.0)),
                ),
                DataColumn(
                  label: Text('4. ChangeNotifier', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.0)),
                ),
              ],
              rows: [
                _buildRow(
                  criterion: 'Bản chất công nghệ',
                  val1: 'Constructor & Callback',
                  val2: 'Cây Element O(1) Lookup',
                  val3: 'ValueListenable (Observer)',
                  val4: 'Observable Domain Engine',
                  activeMode: activeMode,
                ),
                _buildRow(
                  criterion: 'Phạm vi Rebuild',
                  val1: 'Cả cây từ Root xuống',
                  val2: 'Các Dependents đã đăng ký',
                  val3: 'Chỉ ValueListenableBuilder',
                  val4: 'Các ListenableBuilder liên quan',
                  activeMode: activeMode,
                ),
                _buildRow(
                  criterion: 'Mã mẫu (Boilerplate)',
                  val1: 'Rất cao (Lặp ở mọi tầng)',
                  val2: 'Trung bình (Cần viết Scope)',
                  val3: 'Rất thấp (Gọn nhẹ, sẵn có)',
                  val4: 'Thấp (Chuẩn MVVM)',
                  activeMode: activeMode,
                ),
                _buildRow(
                  criterion: 'Khớp nối (Coupling)',
                  val1: 'Khớp chặt (Tight Coupling)',
                  val2: 'Phụ thuộc ngữ cảnh BuildContext',
                  val3: 'Khớp lỏng (Loose Coupling)',
                  val4: 'Tách rời tuyệt đối UI và Logic',
                  activeMode: activeMode,
                ),
                _buildRow(
                  criterion: 'Tình huống tối ưu',
                  val1: 'Widget cha - con trực tiếp (1 tầng)',
                  val2: 'Dữ liệu môi trường (Theme, Auth)',
                  val3: 'Biến đơn nguyên (Toggle, Counter)',
                  val4: 'Nghiệp vụ phức tạp (Cart, Hub)',
                  activeMode: activeMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow({
    required String criterion,
    required String val1,
    required String val2,
    required String val3,
    required String val4,
    required StateSharingMode activeMode,
  }) {
    Color getBg(StateSharingMode mode) {
      if (mode == activeMode) {
        return const Color(0xFFE8F5E9);
      }
      return Colors.transparent;
    }

    return DataRow(
      cells: [
        DataCell(Text(criterion, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.0))),
        DataCell(
          Container(
            color: getBg(StateSharingMode.propDrilling),
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: Text(val1, style: const TextStyle(fontSize: 10.5)),
          ),
        ),
        DataCell(
          Container(
            color: getBg(StateSharingMode.inheritedWidget),
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: Text(val2, style: const TextStyle(fontSize: 10.5)),
          ),
        ),
        DataCell(
          Container(
            color: getBg(StateSharingMode.valueNotifier),
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: Text(val3, style: const TextStyle(fontSize: 10.5)),
          ),
        ),
        DataCell(
          Container(
            color: getBg(StateSharingMode.changeNotifier),
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: Text(val4, style: const TextStyle(fontSize: 10.5)),
          ),
        ),
      ],
    );
  }
}
