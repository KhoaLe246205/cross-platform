# Cross-Platform Application Development

Kho lưu trữ tổng hợp các bài tập, đồ án và chuyên đề môn **Lập Trình Đa Nền Tảng (Cross-Platform Programming)**.

**Nền tảng sử dụng:** Dart & Flutter (Windows Native Desktop & Mobile)  
**Khoa:** Điện Tử và Trí Tuệ Nhân Tạo – Trường Đại học Bách Khoa, Đại học Đà Nẵng  
**Giảng viên hướng dẫn:** ThS. Nguyễn Duy Nhật Viễn  

---

## Phân công công việc tổng thể

| TT | HỌ VÀ TÊN | MSSV | VAI TRÒ CHÍNH THEO WBS | ĐÓNG GÓP |
|:---:|:---|:---:|:---|:---:|
| 1 | **Lê Anh Khoa** | 106230016 | • **OOP & Error Handling:** OOP Core & Architecture, Cây phân cấp `AppException`, Sealed Class `Result<T>`, Fail-safe `errorWrapper<T>`, Lớp bất biến `BookingModel`, Slide Beamer XeLaTeX.<br>• **Isolates:** Business Logic bóc tách JSON lớn & tính toán FLOPS (`SensorRecord`), đa luồng với `compute()` và `Isolate.spawn() + Ports`, `JsonGeneratorService`.<br>• **Responsive & Adaptive UI:** Cơ sở lý thuyết Responsive vs Adaptive, cơ chế `MediaQuery.sizeOf(context)` & `InheritedModel`, `LayoutBuilder` & `BoxConstraints`, Breakpoints M3, Báo cáo Word & Slide XeLaTeX.<br>• **Sự kiện & Tương tác:** Thiết kế kiến trúc bộ nhớ RAM (`RamState`), thanh điều khiển chung (`ControlBar`), bảng nhật ký sự kiện (`EventConsole`), thẻ Máy bơm & kiểm chứng `setState()`, Báo cáo README & Slide XeLaTeX Phần III & IV.<br>• **Quản trị Repo:** Quản trị GitHub Repository, cấu trúc thư mục và tài liệu báo cáo. | 50% |
| 2 | **Ngô Quang Thế** | 106230028 | • **OOP & Error Handling:** Thiết kế giao diện `DemoPage`, Quản lý trạng thái đa tầng với `BookingController` & `ListenableBuilder`, Lưới an toàn toàn cục 2 lớp (`FlutterError` + `PlatformDispatcher`), Reusable Mixin `ValidationAndLogMixin`, Kịch bản Live Demo.<br>• **Isolates:** Thiết kế `BenchmarkScreen` & `FpsMonitorPanel` (bánh răng quay, biểu đồ FPS thời gian thực), State Management luồng dữ liệu tiến độ (0% – 100%), Slide Beamer XeLaTeX, Trực tiếp Live Demo.<br>• **Responsive & Adaptive UI:** Thiết kế kiến trúc `AdaptiveHomeScreen` (Scaffold, NavRail/NavBar), Input Modalities (Touch $\ge 48\text{dp}$, `MouseRegion` hover, `Shortcuts` & `Actions` 1/2/3/4), `VisualDensity.adaptivePlatformDensity`, Live Demo.<br>• **Sự kiện & Tương tác:** Nghiên cứu cơ chế Callback, thuộc tính `onPressed`, `onTap`; đối chiếu `GestureDetector` vs `InkWell`; lập trình thẻ Đèn (InkWell) và thẻ Quạt (GestureDetector); Slide XeLaTeX Phần I & II và bộ ảnh thực nghiệm UI. | 50% |

---

## Danh mục chuyên đề

| Thư mục | Chuyên đề | Mô tả tóm tắt | Công nghệ chính |
|:---|:---|:---|:---|
| [`oop_error_handling/`](./oop_error_handling) | **OOP nâng cao & Xử lý ngoại lệ tập trung** | Xây dựng module quản lý dữ liệu an toàn, loại bỏ crash và cách ly lỗi đa tầng; ứng dụng Sealed Class, Pattern Matching, Reusable Mixin, Fail-safe Wrapper và Global Safety Net. | Dart 3 OOP (Factory, Mixin, Reified Generics, Sealed class), Custom Exception, Result Pattern, Global Safety Net, ListenableBuilder |
| [`isolate/`](./isolate) | **Đa luồng với Isolates** | Tối ưu hiệu năng xử lý tác vụ CPU-bound nặng mà không gây nghẽn luồng giao diện (Non-blocking UI), tích hợp bộ đo FPS thời gian thực. | Dart Isolates, `compute()`, `SendPort`/`ReceivePort`, Flutter Widgets |
| [`responsive_adaptive/`](./responsive_adaptive) | **Thiết kế Giao diện Đa nền tảng (Responsive & Adaptive UI)** | Tối ưu hóa không gian hiển thị và phương thức tương tác đa nền tảng; phối hợp MediaQuery sizeOf, LayoutBuilder, Breakpoints M3, Input Modalities (Touch $\ge 48\text{dp}$, MouseRegion hover, Shortcuts 1/2/3/4) và AdaptivePlatformDensity. | Flutter Widgets (MediaQuery, LayoutBuilder, NavigationRail, NavigationBar, Shortcuts, Actions, FocusScope, MouseRegion, InkWell), Material Design 3 Window Size Classes |
| [`event_interaction/`](./event_interaction) | **Sự kiện và tương tác người dùng trong giao diện** | Xây dựng bảng điều khiển thiết bị thực nghiệm tương tác sự kiện và quản lý trạng thái; cơ chế Callback, GestureDetector 3 cử chỉ, InkWell splash, khóa nút onPressed: null, và kiểm chứng hiện tượng lệch đồng bộ giữa RAM và UI khi tắt setState(). | Flutter Widgets (InkWell, GestureDetector, ElevatedButton, Switch, setState, VoidCallback, ValueChanged), Dart OOP Model |

---

## Cấu trúc thư mục kho lưu trữ

```text
cross-platform/
├── README.md                      # Tài liệu tổng quan kho lưu trữ
├── oop_error_handling/            # OOP nâng cao & Xử lý ngoại lệ tập trung
│   ├── README.md                  # Hướng dẫn & Báo cáo chi tiết chuyên đề OOP & Error Handling
│   ├── pubspec.yaml               # Cấu hình dự án Flutter & dependencies
│   ├── analysis_options.yaml      # Cấu hình linter Effective Dart
│   ├── lib/                       # Mã nguồn ứng dụng (Core, Data, Presentation)
│   ├── assets/images/             # Sơ đồ kiến trúc, luồng dữ liệu & ảnh minh chứng UI
│   ├── docs/                      # Slide thuyết trình Beamer (XeLaTeX PDF & TeX)
│   └── windows/                   # Cấu hình Windows desktop native C++
├── isolate/                       # Đa luồng & Isolates Benchmark
│   ├── README.md                  # Hướng dẫn & Báo cáo chi tiết chuyên đề Isolate
│   ├── pubspec.yaml               # Cấu hình dự án Flutter & dependencies
│   ├── analysis_options.yaml      # Cấu hình linter Effective Dart (100% clean)
│   ├── lib/                       # Mã nguồn ứng dụng Isolate Benchmark
│   ├── assets/images/             # Sơ đồ kiến trúc độc lập bộ nhớ & ảnh chụp thực tế UI
│   ├── docs/                      # Slide thuyết trình Beamer (XeLaTeX PDF & TeX)
│   └── windows/                   # Cấu hình Windows desktop native C++
├── responsive_adaptive/           # Thiết kế Giao diện Đa nền tảng: Responsive & Adaptive UI
│   ├── README.md                  # Báo cáo toàn diện & hướng dẫn chi tiết chuyên đề Responsive/Adaptive
│   ├── pubspec.yaml               # Cấu hình dự án Flutter & dependencies
│   ├── analysis_options.yaml      # Cấu hình linter Effective Dart (100% clean)
│   ├── lib/                       # Mã nguồn ứng dụng (Constants, Screens, Widgets)
│   ├── docs/                      # Slide thuyết trình Beamer (XeLaTeX PDF & TeX)
│   └── windows/                   # Cấu hình Windows desktop native C++
└── event_interaction/             # Sự kiện và tương tác người dùng trong giao diện
    ├── README.md                  # Báo cáo chi tiết & kịch bản thực nghiệm chuyên đề Event & Interaction
    ├── pubspec.yaml               # Cấu hình dự án Flutter & dependencies
    ├── analysis_options.yaml      # Cấu hình linter Effective Dart (100% clean)
    ├── lib/                       # Mã nguồn ứng dụng (Models, Views, Widgets, Data)
    ├── assets/images/             # Sơ đồ luồng sự kiện và kiến trúc tương tác
    ├── docs/                      # Slide thuyết trình Beamer (XeLaTeX PDF 23 trang & TeX)
    └── windows/                   # Cấu hình Windows desktop native C++
```
