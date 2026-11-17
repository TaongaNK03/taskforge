/// User profile model — stores user preferences and settings.
class UserProfile {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final DateTime createdAt;
  final int dailyGoal; // target tasks per day
  final String preferredStartTime; // e.g. "08:00"
  final String preferredEndTime; // e.g. "17:00"
  final bool notificationsEnabled;
  final String themeMode; // "system", "light", "dark"

  const UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    required this.createdAt,
    this.dailyGoal = 5,
    this.preferredStartTime = '08:00',
    this.preferredEndTime = '17:00',
    this.notificationsEnabled = false,
    this.themeMode = 'system',
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      dailyGoal: map['daily_goal'] as int? ?? 5,
      preferredStartTime: map['preferred_start_time'] as String? ?? '08:00',
      preferredEndTime: map['preferred_end_time'] as String? ?? '17:00',
      notificationsEnabled: (map['notifications_enabled'] as int? ?? 0) == 1,
      themeMode: map['theme_mode'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'created_at': createdAt.millisecondsSinceEpoch,
      'daily_goal': dailyGoal,
      'preferred_start_time': preferredStartTime,
      'preferred_end_time': preferredEndTime,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
      'theme_mode': themeMode,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    int? dailyGoal,
    String? preferredStartTime,
    String? preferredEndTime,
    bool? notificationsEnabled,
    String? themeMode,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      preferredStartTime: preferredStartTime ?? this.preferredStartTime,
      preferredEndTime: preferredEndTime ?? this.preferredEndTime,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
