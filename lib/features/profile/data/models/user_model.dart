class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'user', 'helpdesk', 'technical_support', 'admin'
  final String? avatar;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    role: json['role'],
    avatar: json['avatar'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'avatar': avatar,
  };

  bool get isAdmin => role == 'admin';
  bool get isHelpdesk => role == 'helpdesk' || role == 'admin';
  bool get isTechnicalSupport => role == 'technical_support';
  bool get isStaff =>
      role == 'helpdesk' || role == 'admin' || role == 'technical_support';
  bool get isUser => role == 'user';
}
