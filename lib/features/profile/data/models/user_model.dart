class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatar': avatar,
    };
  }

  // Getters untuk mempermudah pengecekan Role di UI
  bool get isAdmin => role == 'admin';
  bool get isHelpdesk => role == 'helpdesk';
  bool get isTechnicalSupport => role == 'technical_support';
  bool get isUser => role == 'user';

  // Staff adalah Admin, Helpdesk, atau Technical Support
  bool get isStaff => isAdmin || isHelpdesk || isTechnicalSupport;
  
  // Role yang berhak melakukan "Assign" (Menugaskan Teknisi)
  bool get canAssign => isAdmin || isHelpdesk;
}
