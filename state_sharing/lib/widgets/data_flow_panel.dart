import 'package:flutter/material.dart';
import '../models/app_mode.dart';
import '../models/data_flow_event.dart';

/// Bảng điều khiển trực quan hóa luồng dữ liệu (Data Flow Inspector) thời gian thực.
class DataFlowPanel extends StatelessWidget {
  final StateSharingMode mode;
  final List<DataFlowEvent> recentEvents;

  const DataFlowPanel({
    super.key,
    required this.mode,
    required this.recentEvents,
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
          // Tiêu đề
          Row(
            children: [
              const Icon(Icons.alt_route, size: 18.0, color: Color(0xFF141414)),
              const SizedBox(width: 8.0),
              const Text(
                'TRỰC QUAN HÓA LUỒNG DỮ LIỆU (DATA FLOW)',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFF141414),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9ECEF),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  mode.shortName,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF343A40),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10.0),

          // Sơ đồ luồng đồ họa động theo Mode
          _buildFlowDiagram(mode),

          const SizedBox(height: 12.0),
          const Divider(color: Color(0xFFE9ECEF), height: 1.0),
          const SizedBox(height: 10.0),

          // Nhật ký tương tác luồng dữ liệu gần nhất
          const Text(
            'Nhật ký tương tác gần nhất:',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF495057),
            ),
          ),
          const SizedBox(height: 6.0),

          if (recentEvents.isEmpty)
            Container(
              padding: const EdgeInsets.all(12.0),
              alignment: Alignment.center,
              child: const Text(
                'Chưa có thao tác nào. Hãy gạt công tắc hoặc kéo thanh trượt để quan sát luồng dữ liệu!',
                style: TextStyle(fontSize: 11.0, color: Color(0xFF868E96)),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...recentEvents.take(4).map((event) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6.0),
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}:${event.timestamp.second.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 10.0,
                            fontFamily: 'Consolas',
                            color: Color(0xFF868E96),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            '${event.sourceWidget} → ${event.action}',
                            style: const TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212529),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: event.affectedWidgetCount > 5
                                ? const Color(0xFFFFEBEE)
                                : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Text(
                            '${event.affectedWidgetCount} widget ảnh hưởng',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: event.affectedWidgetCount > 5
                                  ? const Color(0xFFC62828)
                                  : const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      event.pathDescription,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontFamily: 'Consolas',
                        color: Color(0xFF495057),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildFlowDiagram(StateSharingMode mode) {
    switch (mode) {
      case StateSharingMode.propDrilling:
        return _diagramBox(
          title: 'Cơ chế Prop Drilling (Truyền 3 tầng qua Constructor)',
          steps: [
            '1. DeviceCard [Tầng 3] nhận chạm → Kích hoạt Callback onToggle',
            '2. Callback chuyển tiếp ngược: Tầng 3 ↑ Tầng 2 ↑ Tầng 1 ↑ HomeScreen (Cha)',
            '3. HomeScreen gọi setState() cập nhật mảng _devices trong RAM',
            '4. Rebuild thác đổ (Waterfall): HomeScreen ↓ Tầng 1 ↓ Tầng 2 ↓ Tầng 3',
          ],
          highlightColor: const Color(0xFFE65100),
          highlightText: 'Hạn chế: Tầng 1 và 2 không dùng data vẫn bị ép Rebuild!',
        );

      case StateSharingMode.inheritedWidget:
        return _diagramBox(
          title: 'Cơ chế InheritedWidget (Element Ancestor O(1))',
          steps: [
            '1. EcoHomeScope bao bọc toàn bộ cây giao diện ở mức Root',
            '2. DeviceCard [Tầng 3] gọi EcoHomeScope.of(context) để đăng ký phụ thuộc',
            '3. Khi state đổi, updateShouldNotify() so sánh và chỉ báo các Dependents',
            '4. Tầng 1 (Room) & Tầng 2 (Group) dùng const hoặc không phụ thuộc sẽ KHÔNG rebuild',
          ],
          highlightColor: const Color(0xFF1565C0),
          highlightText: 'Ưu điểm: Bỏ qua tầng trung gian, truy xuất O(1) qua cây Element.',
        );

      case StateSharingMode.valueNotifier:
        return _diagramBox(
          title: 'Cơ chế ValueNotifier (Reactive Granular)',
          steps: [
            '1. Trạng thái được bọc trong ValueNotifier<T> độc lập (devicesNotifier)',
            '2. Chỉ các phần tử lá (Leaf) được bọc trong ValueListenableBuilder<T>',
            '3. Khi devicesNotifier.value thay đổi, chỉ đúng vùng Builder đó tự vẽ lại',
            '4. Cả HomeScreen, Tầng 1 và Tầng 2 hoàn toàn giữ nguyên (Zero Rebuild)',
          ],
          highlightColor: const Color(0xFF2E7D32),
          highlightText: 'Tối ưu: Rebuild bị cô lập tuyệt đối tại đúng widget hiển thị.',
        );

      case StateSharingMode.changeNotifier:
        return _diagramBox(
          title: 'Cơ chế ChangeNotifier (Domain State Engine)',
          steps: [
            '1. Toàn bộ logic nghiệp vụ đóng gói trong HomeEnergyModel extends ChangeNotifier',
            '2. Giao diện gọi phương thức model.toggleDevice(id) hoặc model.toggleEcoMode()',
            '3. Model tự cập nhật và phát lệnh notifyListeners() tới các subscriber',
            '4. ListenableBuilder chỉ cập nhật các khối giao diện được gán lắng nghe model',
          ],
          highlightColor: const Color(0xFF6A1B9A),
          highlightText: 'Chuẩn công nghiệp: Tách biệt hoàn toàn Business Logic và View.',
        );
    }
  }

  Widget _diagramBox({
    required String title,
    required List<String> steps,
    required Color highlightColor,
    required String highlightText,
  }) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFDEE2E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF141414),
            ),
          ),
          const SizedBox(height: 6.0),
          ...steps.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 3.5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.0)),
                  Expanded(
                    child: Text(
                      s,
                      style: const TextStyle(fontSize: 11.0, color: Color(0xFF343A40)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: highlightColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(color: highlightColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 14.0, color: highlightColor),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(
                    highlightText,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: highlightColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
