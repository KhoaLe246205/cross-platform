/// Enum đại diện cho 4 cơ chế chia sẻ trạng thái trong Flutter.
enum StateSharingMode {
  propDrilling,
  inheritedWidget,
  valueNotifier,
  changeNotifier,
}

extension StateSharingModeExt on StateSharingMode {
  String get title {
    switch (this) {
      case StateSharingMode.propDrilling:
        return '1. Prop Drilling (Constructor & Callback)';
      case StateSharingMode.inheritedWidget:
        return '2. InheritedWidget (Element Ancestor Lookup)';
      case StateSharingMode.valueNotifier:
        return '3. ValueNotifier (Reactive Granular)';
      case StateSharingMode.changeNotifier:
        return '4. ChangeNotifier (Domain State Engine)';
    }
  }

  String get shortName {
    switch (this) {
      case StateSharingMode.propDrilling:
        return 'Prop Drilling';
      case StateSharingMode.inheritedWidget:
        return 'InheritedWidget';
      case StateSharingMode.valueNotifier:
        return 'ValueNotifier';
      case StateSharingMode.changeNotifier:
        return 'ChangeNotifier';
    }
  }

  String get description {
    switch (this) {
      case StateSharingMode.propDrilling:
        return 'Truyền dữ liệu xuống qua Constructor và truyền sự kiện ngược lên qua Callback. Gây ra hiện tượng Rebuild dây chuyền qua tất cả widget trung gian.';
      case StateSharingMode.inheritedWidget:
        return 'Cung cấp cơ chế tìm kiếm tổ tiên O(1) qua cây Element. Cho phép widget con trực tiếp đọc dữ liệu mà không cần tầng trung gian làm cầu nối.';
      case StateSharingMode.valueNotifier:
        return 'Quản lý giá trị đơn nguyên theo mô hình Observable. Chỉ tái tạo duy nhất vùng bao bọc ValueListenableBuilder tại lá cây widget.';
      case StateSharingMode.changeNotifier:
        return 'Đóng gói toàn bộ logic nghiệp vụ (Domain Model) và phát thông báo đa trường qua notifyListeners(). Tách biệt hoàn toàn Business Logic và UI.';
    }
  }

  String get rebuildScope {
    switch (this) {
      case StateSharingMode.propDrilling:
        return 'Toàn bộ cây (Cha + Trung gian + Con)';
      case StateSharingMode.inheritedWidget:
        return 'Chỉ các widget đăng ký phụ thuộc (Dependents)';
      case StateSharingMode.valueNotifier:
        return 'Cục bộ tại ValueListenableBuilder';
      case StateSharingMode.changeNotifier:
        return 'Chỉ các widget lắng nghe (ListenableBuilder)';
    }
  }

  String get boilerplateRating {
    switch (this) {
      case StateSharingMode.propDrilling:
        return 'Rất cao (Tham số lặp lại ở mọi tầng)';
      case StateSharingMode.inheritedWidget:
        return 'Trung bình (Cần viết lớp InheritedWidget)';
      case StateSharingMode.valueNotifier:
        return 'Thấp (Cú pháp gọn gàng, sẵn có trong Flutter)';
      case StateSharingMode.changeNotifier:
        return 'Thấp - Trung bình (Chuẩn kiến trúc MVVM)';
    }
  }
}
