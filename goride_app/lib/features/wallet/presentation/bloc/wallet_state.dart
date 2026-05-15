import '../../data/models/transaction_model.dart';

abstract class WalletState {
  const WalletState();
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final double balance;
  final List<TransactionModel> transactions;
  const WalletLoaded({required this.balance, required this.transactions});
}

class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);
}

class TopUpSuccess extends WalletState {
  final String message;
  const TopUpSuccess(this.message);
}
