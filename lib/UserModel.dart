class UserModel {
  final String? username, email;
  final int? missions, medals, streak, level, xp;

  UserModel({
    this.username,
    this.email,
    this.missions,
    this.medals,
    this.streak,
    this.level,
    this.xp,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] as String?,
      email: map['email'] as String?,
      missions: map['missions'] as int?,
      medals: map['medals'] as int?,
      streak: map['streak'] as int?,
      level: map['level'] as int?,
      xp: map['xp'] as int?,
    );
  }
}
