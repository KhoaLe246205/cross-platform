# Cross-Platform Application Development

Kho lưu trữ tổng hợp các bài tập, đồ án và chuyên đề môn **Lập Trình Đa Nền Tảng (Cross-Platform Programming)**.

**Nền tảng sử dụng:** Dart & Flutter (Windows Native Desktop & Mobile)  
**Khoa:** Điện Tử và Trí Tuệ Nhân Tạo – Trường Đại học Bách Khoa, Đại học Đà Nẵng  
**Giảng viên hướng dẫn:** ThS. Nguyễn Duy Nhật Viễn  

---

## Phân công công việc tổng thể

| TT | HỌ VÀ TÊN | MSSV | VAI TRÒ CHÍNH THEO WBS | ĐÓNG GÓP |
|:---:|:---|:---:|:---|:---:|
| 1 | **Lê Anh Khoa** | 106230016 | • **Chủ đề 01 (OOP & Error Handling):** OOP Core & Architecture, Cây phân cấp `AppException`, Sealed Class `Result<T>`, Fail-safe `errorWrapper<T>`, Lớp bất biến `BookingModel`, Slide Beamer XeLaTeX.<br>• **Chủ đề 03 (Isolates):** Business Logic bóc tách JSON lớn & tính toán FLOPS (`SensorRecord`), đa luồng với `compute()` và `Isolate.spawn() + Ports`, `JsonGeneratorService`.<br>• **Quản trị Repo:** Quản trị GitHub Repository, cấu trúc thư mục và tài liệu báo cáo. | 50% |
| 2 | **Ngô Quang Thế** | 106230028 | • **Chủ đề 01 (OOP & Error Handling):** Thiết kế giao diện `DemoPage`, Quản lý trạng thái đa tầng với `BookingController` & `ListenableBuilder`, Lưới an toàn toàn cục 2 lớp (`FlutterError` + `PlatformDispatcher`), Reusable Mixin `ValidationAndLogMixin`, Kịch bản Live Demo.<br>• **Chủ đề 03 (Isolates):** Thiết kế `BenchmarkScreen` & `FpsMonitorPanel` (bánh răng quay, biểu đồ FPS thời gian thực), State Management luồng dữ liệu tiến độ (0% – 100%), Trực tiếp Live Demo. | 50% |

---

## Danh mục chuyên đề

| Thư mục | Chủ đề | Mô tả tóm tắt | Công nghệ chính |
|:---|:---|:---|:---|
| [`oop_error_handling/`](./oop_error_handling) | **Chủ đề 01: OOP nâng cao & Xử lý ngoại lệ tập trung** | Xây dựng module quản lý dữ liệu an toàn, loại bỏ crash và cách ly lỗi đa tầng; ứng dụng Sealed Class, Pattern Matching, Reusable Mixin, Fail-safe Wrapper và Global Safety Net. | Dart 3 OOP (Factory, Mixin, Reified Generics, Sealed class), Custom Exception, Result Pattern, Global Safety Net, ListenableBuilder |
| [`isolate/`](./isolate) | **Chủ đề 03: Đa luồng với Isolates** | Tối ưu hiệu năng xử lý tác vụ CPU-bound nặng mà không gây nghẽn luồng giao diện (Non-blocking UI), tích hợp bộ đo FPS thời gian thực. | Dart Isolates, `compute()`, `SendPort`/`ReceivePort`, Flutter Widgets |

---

## Cấu trúc thư mục kho lưu trữ

```text
cross-platform/
├── README.md                      # Tài liệu tổng quan kho lưu trữ
├── oop_error_handling/            # Chuyên đề 01: OOP nâng cao & Xử lý ngoại lệ tập trung
│   ├── README.md                  # Hướng dẫn & Báo cáo chi tiết chuyên đề OOP & Error Handling
│   ├── pubspec.yaml               # Cấu hình dự án Flutter & dependencies
│   ├── analysis_options.yaml      # Cấu hình linter Effective Dart
│   ├── lib/                       # Mã nguồn ứng dụng (Core, Data, Presentation)
│   ├── assets/images/             # Sơ đồ kiến trúc, luồng dữ liệu & ảnh minh chứng UI
│   ├── docs/                      # Slide thuyết trình Beamer (XeLaTeX PDF & TeX)
│   └── windows/                   # Cấu hình Windows desktop native C++
└── isolate/                       # Chuyên đề 03: Đa luồng & Isolates Benchmark
    ├── README.md                  # Hướng dẫn & Báo cáo chi tiết chuyên đề Isolate
    ├── pubspec.yaml               # Cấu hình dự án Flutter & dependencies
    ├── lib/                       # Mã nguồn ứng dụng Isolate Benchmark
    ├── assets/images/             # Sơ đồ kiến trúc độc lập bộ nhớ Isolate
    └── windows/                   # Cấu hình Windows desktop native C++
```
