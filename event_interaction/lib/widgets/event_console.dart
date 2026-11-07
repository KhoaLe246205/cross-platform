import 'package:flutter/material.dart';
import '../models/event_log.dart';

class EventConsoleWidget extends StatefulWidget {
  final List<EventLogItem> logs;
  final VoidCallback onClear;

  const EventConsoleWidget({
    super.key,
    required this.logs,
    required this.onClear,
  });

  @override
  State<EventConsoleWidget> createState() => _EventConsoleWidgetState();
}

class _EventConsoleWidgetState extends State<EventConsoleWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant EventConsoleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logs.length > oldWidget.logs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header phẳng, sạch sẽ, tươi sáng
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC), // Slate 50
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                const Icon(Icons.terminal_rounded,
                    color: Color(0xFF0284C7), size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Nhật ký sự kiện',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 8),

                // Nhãn Realtime sống động
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                          radius: 3, backgroundColor: Color(0xFF10B981)),
                      SizedBox(width: 4.5),
                      Text(
                        'Realtime',
                        style: TextStyle(
                          color: Color(0xFF059669),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Consolas',
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Đếm số dòng log
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    '${widget.logs.length} dòng',
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Consolas',
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Nút Xóa log - Màu đỏ sống động
                InkWell(
                  onTap: widget.logs.isEmpty ? null : widget.onClear,
                  borderRadius: BorderRadius.circular(5),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 14,
                          color: widget.logs.isEmpty
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Xóa log',
                          style: TextStyle(
                            color: widget.logs.isEmpty
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFFEF4444),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Log List body
          Expanded(
            child: widget.logs.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 28, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 8),
                        Text(
                          'Chưa có sự kiện nào.\nHãy tương tác với các thiết bị bên trái để xem nhật ký!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    itemCount: widget.logs.length,
                    itemBuilder: (context, index) {
                      final item = widget.logs[index];
                      final isWarning = item.type == EventLogType.warning;

                      Color tagBg;
                      Color tagBorder;
                      Color tagText;

                      if (item.widgetName.contains('InkWell')) {
                        tagBg = const Color(0xFFFEF3C7);
                        tagBorder = const Color(0xFFFDE68A);
                        tagText = const Color(0xFFB45309);
                      } else if (item.widgetName.contains('GestureDetector')) {
                        tagBg = const Color(0xFFE0F2FE);
                        tagBorder = const Color(0xFFBAE6FD);
                        tagText = const Color(0xFF0369A1);
                      } else if (item.widgetName.contains('ElevatedButton')) {
                        tagBg = const Color(0xFFDBEAFE);
                        tagBorder = const Color(0xFFBFDBFE);
                        tagText = const Color(0xFF1D4ED8);
                      } else if (item.widgetName.contains('Switch')) {
                        tagBg = const Color(0xFFEDE9FE);
                        tagBorder = const Color(0xFFDDD6FE);
                        tagText = const Color(0xFF6D28D9);
                      } else if (item.widgetName.contains('Thử nghiệm')) {
                        tagBg = const Color(0xFFFEF2F2);
                        tagBorder = const Color(0xFFFECACA);
                        tagText = const Color(0xFFDC2626);
                      } else {
                        tagBg = const Color(0xFFF1F5F9);
                        tagBorder = const Color(0xFFE2E8F0);
                        tagText = const Color(0xFF334155);
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.timeFormatted,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 10.5,
                                    fontFamily: 'Consolas',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: tagBg,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: tagBorder),
                                  ),
                                  child: Text(
                                    item.widgetName,
                                    style: TextStyle(
                                      color: tagText,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Consolas',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Text(
                                    item.callback,
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Consolas',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3.5),
                            Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Text(
                                item.result,
                                style: TextStyle(
                                  color: isWarning
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF1E293B),
                                  fontSize: 11.5,
                                  fontWeight: isWarning
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontFamily: 'Consolas',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
