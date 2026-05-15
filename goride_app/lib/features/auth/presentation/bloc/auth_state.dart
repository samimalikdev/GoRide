import 'package:equatable/equatable.dart';
import 'package:goride_app/core/models/user_model.dart';

abstract class AuthState extends Equatable {
  UserModel? get currentUser {
    if (this is AuthAuthenticated) return (this as AuthAuthenticated).user;
    if (this is AuthMfaStatus) return (this as AuthMfaStatus).user;
    if (this is AuthLoading) return (this as AuthLoading).user;
    if (this is AuthError) return (this as AuthError).user;
    if (this is AuthMfaRequired) return (this as AuthMfaRequired).user;
    if (this is AuthMfaSetupRequired) return (this as AuthMfaSetupRequired).user;
    return null;
  }

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final UserModel? user;
  AuthLoading({this.user});

  @override
  List<Object?> get props => [user];
}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  final UserModel? user;

  AuthError({required this.message, this.user});

  @override
  List<Object?> get props => [message, user];
}

class AuthMfaRequired extends AuthState {
  final String factorId;
  final String challengeId;
  final UserModel? user;

  AuthMfaRequired({required this.factorId, required this.challengeId, this.user});

  @override
  List<Object?> get props => [factorId, challengeId, user];
}

class AuthMfaSetupRequired extends AuthState {
  final UserModel user;
  final String qrCode;
  final String secret;
  final String factorId;
  final String challengeId;

  AuthMfaSetupRequired({
    required this.user,
    required this.qrCode,
    required this.secret,
    required this.factorId,
    required this.challengeId,
  });

  @override
  List<Object?> get props => [user, qrCode, secret, factorId, challengeId];
}

class AuthMfaStatus extends AuthState {
  final UserModel user;
  final List<dynamic> factors;
  final bool isEnabled;

  AuthMfaStatus({
    required this.user,
    required this.factors,
    required this.isEnabled,
  });

  @override
  List<Object?> get props => [user, factors, isEnabled];
}
