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

class LogModel {
  final String operation;
  final String method;
  final String name;
  final DateTime datetime;
  final String username;
  final bool isSuperuser;

  LogModel({
    required this.operation,
    required this.method,
    required this.name,
    required this.datetime,
    required this.username,
    required this.isSuperuser,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      operation: json['operation'] ?? '',
      method: json['method'] ?? '',
      name: json['name'] ?? '',
      datetime: DateTime.parse(json['datetime']),
      username: json['user']['username'] ?? '',
      isSuperuser: json['user']['is_superuser'] ?? false,
    );
  }
}
