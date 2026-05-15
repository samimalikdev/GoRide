class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? profilePic;
  final String? token;
  final bool isMfaVerified;
  final String? role;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.profilePic,
    this.token,
    this.isMfaVerified = false,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['user_metadata'] ?? {};
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? metadata['full_name'],
      profilePic: json['profilePic'] ?? metadata['profile_pic'],
      token: json['token'],
      isMfaVerified: json['isMfaVerified'] ?? false,
      role: json['role'] ?? metadata['user_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'profilePic': profilePic,
      'token': token,
      'isMfaVerified': isMfaVerified,
      'role': role,
    };
  }
}
