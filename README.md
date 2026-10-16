# Cross-Platform Application Development

Kho lưu trữ tổng hợp các bài tập, đồ án và chuyên đề môn **Lập Trình Đa Nền Tảng (Cross-Platform Programming)**.

**Nền tảng sử dụng:** Dart & Flutter (Windows Native Desktop)

---

## Phân công công việc

| TT | HỌ VÀ TÊN | VAI TRÒ & NỘI DUNG CÔNG VIỆC THEO WBS | ĐÓNG GÓP |
|:---:|:---|:---|:---:|
| 1 | **Lê Anh Khoa** | • **Business Logic (Chính):** Thuật toán bóc tách JSON lớn & tính toán FLOPS (SensorRecord); Hiện thực đa luồng với compute() và Isolate.spawn() + Ports; Kỹ thuật Throttling và chống rò rỉ RAM.<br>• **Database / File I/O:** Xây dựng JsonGeneratorService sinh & đọc ngầm tập tin 16.5MB – 132.1MB; Tối ưu luồng ghi đĩa với flush().<br>• **Báo cáo & Git:** Quản trị Git Repo; Soạn thảo Báo cáo phần *Cơ sở lý thuyết Event Loop / Isolate & Kiến trúc hệ thống*. | 50% |
| 2 | **Ngô Quang Thế** | • **UI Design (Chính):** Thiết kế BenchmarkScreen (Bảng điều khiển, slider tải) và FpsMonitorPanel (Hoạt ảnh bánh răng, biểu đồ FPS thời gian thực).<br>• **State Management & Tích hợp:** Quản lý state luồng dữ liệu tiến độ (0% – 100%) và thuật toán bắt treo UI (freezeMs); **Tích hợp gọi Isolate vào UI**.<br>• **Slide & Live Demo:** Thiết kế Slide báo cáo; Soạn thảo Báo cáo phần *Thiết kế Giao diện & Kịch bản thực nghiệm*; Trực tiếp thực hiện Live Demo trên Windows. | 50% |

---

## Danh mục chuyên đề

| Thư mục | Chủ đề | Mô tả tóm tắt | Công nghệ chính |
|:---|:---|:---|:---|
| [`isolate/`](./isolate) | **Chủ đề 03: Đa luồng với Isolates** | Tối ưu hiệu năng xử lý tác vụ CPU-bound nặng mà không gây nghẽn luồng giao diện (Non-blocking UI), tích hợp bộ đo FPS thời gian thực. | Dart Isolates, `compute()`, `SendPort`/`ReceivePort`, Flutter Widgets |

---

## Cấu trúc thư mục

```text
cross-platform/
├── README.md               # Tài liệu tổng quan kho lưu trữ
└── isolate/                # Mã nguồn chuyên đề 03 về Đa luồng & Isolates
    ├── README.md           # Hướng dẫn chi tiết chuyên đề Isolate
    ├── pubspec.yaml        # Cấu hình dự án Flutter
    ├── lib/                # Mã nguồn ứng dụng
    └── windows/            # Cấu hình Windows desktop
```
