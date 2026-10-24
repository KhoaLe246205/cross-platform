// lib/presentation/pages/demo_page.dart
import 'package:flutter/material.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/lab_location.dart';
import '../controllers/booking_controller.dart';

class DemoPage extends StatefulWidget {
  final BookingController controller;
  const DemoPage({super.key, required this.controller});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final TextEditingController _amountCtrl = TextEditingController(text: '2');
  final TextEditingController _nameCtrl = TextEditingController(text: 'Lê Anh Khoa');
  TicketType _selectedType = TicketType.standard;
  String _selectedLab = 'Hội thảo SoC & FPGA';

  final List<String> _attendees = [
    'Lê Anh Khoa',
    'Ngô Quang Thế',
    'Khách mời VIP 01',
    'Thành viên Lab',
  ];

  final List<String> _labs = [
    'Hội thảo SoC & FPGA',
    'Phòng Lab AI & IoT',
    'Phòng Lab 404 (Sự cố API)',
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submitBooking() {
    // Ngăn chặn Race Condition nếu đang trong quá trình gửi yêu cầu
    if (widget.controller.isLoading) return;

    final amount = int.tryParse(_amountCtrl.text.trim()) ?? 0;
    final attendeeName = _nameCtrl.text.trim().isEmpty ? 'Khách chưa đặt tên' : _nameCtrl.text.trim();

    if (!_attendees.contains(attendeeName)) {
      setState(() => _attendees.insert(0, attendeeName));
    }

    widget.controller.bookTicket(
      amount: amount,
      type: _selectedType,
      attendee: attendeeName,
      labEvent: _selectedLab,
    );
  }

  void _runScenario(String amount, TicketType type, {String? attendee, String? labEvent}) {
    if (widget.controller.isLoading) return;
    setState(() {
      _amountCtrl.text = amount;
      _selectedType = type;
      if (attendee != null && attendee.isNotEmpty) _nameCtrl.text = attendee;
      if (labEvent != null && labEvent.isNotEmpty) _selectedLab = labEvent;
    });
    _submitBooking();
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildHeaderCard() {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final loc = widget.controller.getLocation(_selectedLab);
        final ctrl = widget.controller;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(loc.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(loc.room, style: const TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${loc.availableSeats} ghế', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text('Còn trống tại phòng / Tổng 50', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _badge('Tiêu chuẩn: ${loc.availableStandardSeats}/${LabLocation.maxStandardSeats}', Colors.cyanAccent),
                  const SizedBox(width: 8),
                  _badge('VIP: ${loc.availableVipSeats}/${LabLocation.maxVipSeats}', Colors.amberAccent),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(
                      ctrl.isLoading
                          ? Icons.sync
                          : (ctrl.isLastActionSuccess ? Icons.check_circle_outline : Icons.error_outline),
                      color: ctrl.isLastActionSuccess ? Colors.greenAccent : Colors.amberAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(ctrl.statusMessage, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Họ và tên người đăng ký', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              hintText: 'Nhập họ và tên người đặt vé...',
              prefixIcon: const Icon(Icons.person_outline),
              suffixIcon: _nameCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _nameCtrl.clear()),
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Gợi ý nhanh:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _attendees.map((name) {
                      final isSelected = _nameCtrl.text.trim() == name;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          label: Text(name, style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFF0F172A) : Colors.black87,
                          )),
                          backgroundColor: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
                          side: BorderSide(color: isSelected ? const Color(0xFF0F172A) : Colors.grey.shade300),
                          onPressed: () => setState(() => _nameCtrl.text = name),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Địa điểm Sự kiện / Phòng Lab (Mỗi nơi 50 vé riêng biệt)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _labs.map((lab) {
                final isSelected = _selectedLab == lab;
                final isErrLab = lab.contains('404');
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(
                      isErrLab ? Icons.warning_amber_rounded : Icons.domain_rounded,
                      size: 16,
                      color: isSelected
                          ? (isErrLab ? Colors.red.shade800 : const Color(0xFF0F172A))
                          : Colors.grey,
                    ),
                    label: Text(
                      lab,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? (isErrLab ? Colors.red.shade900 : const Color(0xFF0F172A))
                            : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: isErrLab ? Colors.red.shade100 : Colors.blue.shade100,
                    onSelected: (_) => setState(() => _selectedLab = lab),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Hạng vé tham dự', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              final loc = widget.controller.getLocation(_selectedLab);
              return Row(
                children: [
                  Expanded(
                    child: _TicketTierCard(
                      title: 'Tiêu chuẩn',
                      subtitle: 'Còn lại: ${loc.availableStandardSeats}/${LabLocation.maxStandardSeats} vé',
                      icon: Icons.local_activity_outlined,
                      isSelected: _selectedType == TicketType.standard,
                      onTap: () => setState(() => _selectedType = TicketType.standard),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TicketTierCard(
                      title: 'Hạng VIP',
                      subtitle: 'Còn lại: ${loc.availableVipSeats}/${LabLocation.maxVipSeats} vé',
                      icon: Icons.star_outline_rounded,
                      isSelected: _selectedType == TicketType.vip,
                      onTap: () => setState(() => _selectedType = TicketType.vip),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Số lượng vé (nguyên dương)',
                    prefixIcon: const Icon(Icons.people_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: ListenableBuilder(
                    listenable: widget.controller,
                    builder: (context, _) {
                      final isLoading = widget.controller.isLoading;
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        // Khóa nút bấm khi đang tải để chống race condition
                        onPressed: isLoading ? null : _submitBooking,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Xác nhận đặt', style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestScenarios() {
    final scenarios = [
      ('Đặt 2 vé chuẩn (Hợp lệ)', () => _runScenario('2', TicketType.standard, labEvent: 'Hội thảo SoC & FPGA')),
      ('Số vé âm (-1) • Mixin kiểm tra', () => _runScenario('-1', TicketType.standard)),
      ('Vượt chỗ chuẩn (50 vé > 35) • Lỗi số lượng', () => _runScenario('50', TicketType.standard)),
      ('Vượt vé VIP (16 vé > 15) • Lỗi số lượng VIP', () => _runScenario('16', TicketType.vip)),
      ('Đặt 15 vé VIP • Lỗi mạng', () => _runScenario('15', TicketType.vip, labEvent: 'Hội thảo SoC & FPGA')),
      ('Phòng Lab 404 • Lỗi JSON (Factory Constructor)', () => _runScenario('1', TicketType.standard, labEvent: 'Phòng Lab 404 (Sự cố API)')),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bộ dữ liệu kiểm thử nhanh:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: scenarios
                .map((s) => ActionChip(
                      label: Text(s.$1, style: const TextStyle(fontSize: 12)),
                      onPressed: s.$2,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text('Danh sách vé đã đặt thành công', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            // Hiển thị trạng thái khởi tạo từ BookingModel.empty()
            ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) {
                final lastTicket = widget.controller.lastBookedTicket;
                if (lastTicket.id == 'N/A') {
                  return Text(
                    '(Trạng thái: ${lastTicket.labEvent})',
                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                  );
                }
                return Text(
                  '(Gần nhất: ${lastTicket.id})',
                  style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final records = widget.controller.history;
            if (records.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Text('Chưa có lịch sử đặt vé nào.', style: TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
              );
            }
            return Column(
              children: records.map((item) {
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(Icons.bookmark_added_outlined, color: Color(0xFF0F172A), size: 18),
                    ),
                    title: Text('Người đăng ký: ${item.attendee}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    subtitle: Text(
                      '${item.time} • ${item.ticket.labEvent} • Mã: ${item.ticket.id} (${item.ticket.type == TicketType.standard ? "Vé tiêu chuẩn" : "Vé VIP"})',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Text('${item.ticket.amount} vé', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 14)),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorLogPanel() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0B0F19),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.terminal_rounded, color: Colors.cyanAccent, size: 16),
                  SizedBox(width: 6),
                  Text('NHẬT KÝ NGOẠI LỆ TẬP TRUNG (ERROR WRAPPER)', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
              InkWell(
                onTap: () => widget.controller.errorLogs.value = [],
                child: const Text('Làm sạch', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 12),
          Expanded(
            child: ValueListenableBuilder<List<String>>(
              valueListenable: widget.controller.errorLogs,
              builder: (context, logs, _) {
                if (logs.isEmpty) {
                  return const Center(
                    child: Text('Hệ thống an toàn. Chưa ghi nhận ngoại lệ nào.', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  );
                }
                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(logs[index], style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontFamily: 'monospace')),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.confirmation_number_outlined, size: 22),
            SizedBox(width: 8),
            Text('Smart Booking System', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 16),
                  _buildBookingForm(),
                  const SizedBox(height: 14),
                  _buildTestScenarios(),
                  const SizedBox(height: 16),
                  _buildBookingHistory(),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildErrorLogPanel(),
          ),
        ],
      ),
    );
  }
}

class _TicketTierCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TicketTierCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF0F172A) : Colors.grey.shade600, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? const Color(0xFF0F172A) : Colors.black87,
                    ),
                  ),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
