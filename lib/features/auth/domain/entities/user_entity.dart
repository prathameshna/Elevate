/// Domain entity representing the authenticated user.
class UserEntity {
  final String id;
  final String fullName;
  final String email;
  final String plan; // 'pro' | 'free' | 'team'

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.plan,
  });

  /// Returns the user's initials (up to 2 characters).
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get isPro => plan.toLowerCase() == 'pro';
}
