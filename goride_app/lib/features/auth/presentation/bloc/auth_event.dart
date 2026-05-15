import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String fullName;

  SignUpEvent({required this.email, required this.password, required this.fullName});

  @override
  List<Object?> get props => [email, password, fullName];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthSession extends AuthEvent {}

class VerifyMfaEvent extends AuthEvent {
  final String factorId;
  final String challengeId;
  final String code;

  VerifyMfaEvent({
    required this.factorId,
    required this.challengeId,
    required this.code,
  });

  @override
  List<Object?> get props => [factorId, challengeId, code];
}

class EnrollMfaEvent extends AuthEvent {}

class GetMfaStatusEvent extends AuthEvent {}

class UnenrollMfaEvent extends AuthEvent {
  final String factorId;
  UnenrollMfaEvent(this.factorId);

  @override
  List<Object?> get props => [factorId];
}

class ChallengeMfaEvent extends AuthEvent {
  final String factorId;
  final dynamic user;

  ChallengeMfaEvent({required this.factorId, required this.user});

  @override
  List<Object?> get props => [factorId, user];
}

class UpdateProfileEvent extends AuthEvent {
  final String fullName;
  final String? profilePicBase64;

  UpdateProfileEvent({required this.fullName, this.profilePicBase64});

  @override
  List<Object?> get props => [fullName, profilePicBase64];
}

