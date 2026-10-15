# Cross-Platform Application Development

Kho lưu trữ tổng hợp các bài tập, đồ án và chuyên đề môn **Lập Trình Đa Nền Tảng (Cross-Platform Programming)**.

**Tác giả:** Lê Anh Khoa  
**Nền tảng sử dụng:** Dart & Flutter  

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
