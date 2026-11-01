/// Định nghĩa các mốc ngắt (Breakpoints) chuẩn hóa theo Material Design 3 và Nội dung.
/// Toàn bộ đơn vị tính trong Flutter là Logical Pixels (dp).
class AppBreakpoints {
  // 1. Mốc kích thước cửa sổ chuẩn Material Design 3 (Macro - MediaQuery)
  static const double compactBreakpoint = 600.0; // < 600dp: Compact; >= 600dp: Medium
  static const double mediumBreakpoint  = 840.0; // 600 - 839dp: Medium; >= 840dp: Expanded

  // 2. Mốc phân nhánh nội dung cục bộ do nhóm tự định nghĩa (Micro - LayoutBuilder)
  static const double contentSplit = 500.0;      // < 500dp: ListView 1 cột; >= 500dp: GridView
  static const double minCardWidth = 250.0;      // Bề rộng tối thiểu mỗi thẻ để tính số cột
}
