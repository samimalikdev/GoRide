import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class FetchWalletData extends WalletEvent {
  final String userId;
  const FetchWalletData(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RequestPayout extends WalletEvent {
  final String userId;
  final double amount;
  const RequestPayout({required this.userId, required this.amount});

  @override
  List<Object?> get props => [userId, amount];
}
