/// User model — matches Firebase Auth user shape + role from /api/auth/session
class AppUser {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String role; // 'user', 'worker', 'admin'

  AppUser({
    this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.role = 'user',
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? map['localId'] ?? map['firebase_uid'],
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
    };
  }

  bool get isAuthenticated => uid != null && uid!.isNotEmpty;
  bool get isAdmin => role == 'admin';
  bool get isWorker => role == 'worker';
  bool get canAccessAdmin => isAdmin || isWorker;

  String get displayNameOrEmail =>
      displayName ?? email?.split('@').first ?? 'User';

  String get avatarLetter => (displayName ?? email ?? 'U').isNotEmpty
      ? (displayName ?? email ?? 'U')[0].toUpperCase()
      : 'U';

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? role,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
    );
  }
}
