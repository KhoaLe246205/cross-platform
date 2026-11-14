/// Đại diện cho hồ sơ người dùng điều khiển hệ thống nhà thông minh.
class UserProfile {
  final String fullName;
  final String role;
  final double powerBudgetWatts;
  final bool isEcoMode;

  const UserProfile({
    required this.fullName,
    required this.role,
    this.powerBudgetWatts = 3200.0,
    this.isEcoMode = false,
  });

  UserProfile copyWith({
    String? fullName,
    String? role,
    double? powerBudgetWatts,
    bool? isEcoMode,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      powerBudgetWatts: powerBudgetWatts ?? this.powerBudgetWatts,
      isEcoMode: isEcoMode ?? this.isEcoMode,
    );
  }
}
