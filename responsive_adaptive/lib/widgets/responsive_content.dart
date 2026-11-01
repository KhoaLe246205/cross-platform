import 'package:flutter/material.dart';
import '../constants/breakpoints.dart';
import 'interactive_item_card.dart';

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({super.key});

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder thực hiện bước Đo đạc (Measure) ở phạm vi vi mô (Micro Layout):
    // Nhận BoxConstraints thực tế từ Widget cha (Expanded) truyền xuống,
    // đã tự động trừ đi bề rộng của NavigationRail (nếu có ở bên trái).
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableWidth = constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thanh thông báo không gian khả dụng (đơn vị dp - Logical Pixels)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.amber.shade100,
              child: Text(
                'Không gian khả dụng (LayoutBuilder maxWidth): ${availableWidth.toInt()} dp '
                '-> Chọn bố cục: ${availableWidth < AppBreakpoints.contentSplit ? "ListView (1 cột)" : "GridView (Nhiều cột)"}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // Rẽ nhánh (Branch):
            // - Dưới 500dp: Hoán đổi cấu trúc sang ListView 1 cột (Hành vi Adaptive cục bộ).
            // - Từ 500dp trở lên: GridView tự co giãn số cột và kích thước thẻ (Hành vi kết hợp Adaptive + Responsive).
            Expanded(
              child: availableWidth < AppBreakpoints.contentSplit
                  ? _buildSingleColumnList()
                  : _buildMultiColumnGrid(availableWidth),
            ),
          ],
        );
      },
    );
  }

  // Bố cục 1: Danh sách cuộn dọc khi không gian khả dụng hẹp (< 500dp)
  Widget _buildSingleColumnList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InteractiveItemCard(index: index, isGridMode: false),
      ),
    );
  }

  // Bố cục 2: Lưới đa cột tự thích ứng khi không gian khả dụng rộng (>= 500dp)
  Widget _buildMultiColumnGrid(double availableWidth) {
    // Hành vi Responsive: Tự động tính số cột theo bội số chiều rộng khả dụng:
    // Mỗi cột tối thiểu AppBreakpoints.minCardWidth (~250dp do nhóm chọn theo công thái học thẻ).
    final int columns = (availableWidth / AppBreakpoints.minCardWidth).floor().clamp(2, 4);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.6,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => InteractiveItemCard(index: index, isGridMode: true),
    );
  }
}
