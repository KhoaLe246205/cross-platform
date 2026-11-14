import 'package:flutter/material.dart';

/// Bảng màu đen xám đơn giản theo chuẩn thiết kế tối giản (Monochrome & Neutral Greys)
class AppColors {
  // Một màu nhấn duy nhất #0F766E
  static const Color primary = Color(0xFF0F766E); // Accent #0F766E
  static const Color primaryHover = Color(0xFF115E59); // Teal-800
  static const Color primaryLight = Color(0xFFF0FDFA); // Teal-50
  static const Color primaryBorder = Color(0xFF99F6E4); // Teal-200

  // Thang màu trung tính theo yêu cầu: nền #FFFFFF, viền #E5E7EB, chữ #111827 / #4B5563
  static const Color background = Color(0xFFFFFFFF); // Nền app #FFFFFF
  static const Color surface = Color(0xFFFFFFFF); // Bề mặt thẻ #FFFFFF
  static const Color surfaceHover = Color(0xFFF9FAFB); // Trạng thái hover nhẹ
  static const Color border = Color(0xFFE5E7EB); // Viền #E5E7EB
  static const Color borderHover = Color(0xFFD1D5DB); // Viền khi hover

  // Phân cấp kiểu chữ
  static const Color textPrimary = Color(0xFF111827); // Chữ chính #111827
  static const Color textSecondary = Color(0xFF4B5563); // Chữ phụ #4B5563
  static const Color textMuted = Color(0xFF9CA3AF); // Chữ gợi ý / mờ

  // Trạng thái trung tính (không dùng đỏ cảnh báo gây cảm giác lỗi)
  static const Color error = Color(0xFF6B7280);
  static const Color errorLight = Color(0xFFF3F4F6);
  static const Color errorBorder = Color(0xFFE5E7EB);

  // Trạng thái kết nối (đồng bộ màu accent)
  static const Color connected = Color(0xFF0F766E);
}

/// Thang khoảng cách chuẩn 4/8/16/24 (Spacing Scale)
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
}

/// Bán kính bo góc duy nhất 8px cho toàn bộ hệ thống
class AppRadius {
  static const double r8 = 8.0;
  static final BorderRadius radius8 = BorderRadius.circular(8.0);
}

/// Hệ thống Typography: 1 font duy nhất, tối đa 4 cỡ chữ (12 / 14 / 16 / 28)
class AppTextStyles {
  static const String fontFamily = 'Segoe UI';
  static const List<String> fontFallbacks = [
    'Inter',
    'Be Vietnam Pro',
    'Roboto',
    'Arial',
    'sans-serif'
  ];

  // Cỡ 28: Tổng công suất, số liệu trọng tâm
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // Cỡ 16: Tiêu đề khối phòng, tiêu đề section
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );

  // Cỡ 14: Tên thiết bị, nhãn điều khiển, văn bản nội dung
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Cỡ 12: Chữ phụ, công suất watt, nhãn thời gian (tương phản cao >= 4.5:1)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle captionMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallbacks,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );
}

/// Cấu hình ThemeData chuẩn Material 3 phẳng và nhất quán
ThemeData getAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: AppTextStyles.fontFamily,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.error,
      brightness: Brightness.light,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1.0,
      space: 1.0,
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.border,
      thumbColor: AppColors.primary,
      overlayColor: Color(0x1F0F766E),
      trackHeight: 3.0,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 14.0),
    ),
  );
}
