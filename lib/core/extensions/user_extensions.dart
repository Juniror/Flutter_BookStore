import 'package:firebase_auth/firebase_auth.dart';

extension UserExtensions on User? {
  /// Returns the display name, or the email username (before @), or 'Reader' as a final fallback.
  /// Standardizes the "xxxx@gmail.com" requirement globally.
  String get displayNameOrEmail {
    if (this == null) return 'Reader';
    final name = this?.displayName;
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return this?.email?.split('@').first ?? 'Reader';
  }

  /// Returns the first letter of the display name or email for profile initials.
  String get initials {
    final name = displayNameOrEmail;
    return name.isNotEmpty ? name[0].toUpperCase() : 'R';
  }
}
