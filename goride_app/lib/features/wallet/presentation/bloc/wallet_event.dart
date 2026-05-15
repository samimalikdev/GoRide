abstract class WalletEvent {
  const WalletEvent();
}

class FetchWalletData extends WalletEvent {
  final String userId;
  FetchWalletData({required this.userId});
}

class TopUpWallet extends WalletEvent {
  final String userId;
  final double amount;
  TopUpWallet({required this.userId, required this.amount});
}
