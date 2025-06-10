class EnterModel {
  final int? id;
  final String? username;
  final String? password;
  final bool? isSuperUser;

  EnterModel({
    this.id,
    this.username,
    this.password,
    this.isSuperUser,
  });

  factory EnterModel.fromJson(Map<String, dynamic> json) {
    return EnterModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      isSuperUser: json['is_superuser'] ?? false,
    );
  }

  // Nesneyi JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'is_superuser': isSuperUser,
    };
  }
}
