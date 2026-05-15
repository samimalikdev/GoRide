import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? profilePic;
  final String? token;
  final bool isMfaVerified;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.profilePic,
    this.token,
    this.isMfaVerified = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json;
    final session = json['session'];
    final metadata = user['user_metadata'] ?? {};
    
    return UserModel(
      id: user['id'] ?? '',
      email: user['email'] ?? '',
      fullName: metadata['full_name'] ?? json['fullName'] ?? 'GoRide User',
      profilePic: metadata['profile_pic'] ?? json['profilePic'],
      token: session != null ? session['access_token'] : (json['access_token'] ?? json['token']),
      isMfaVerified: json['isMfaVerified'] ?? (json['mfaRequired'] == true ? false : true),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? profilePic,
    String? token,
    bool? isMfaVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profilePic: profilePic ?? this.profilePic,
      token: token ?? this.token,
      isMfaVerified: isMfaVerified ?? this.isMfaVerified,
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
    };
  }

  @override
  List<Object?> get props => [id, email, fullName, profilePic, token, isMfaVerified];
}
