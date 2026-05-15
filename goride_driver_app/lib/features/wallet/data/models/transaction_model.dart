class TransactionModel {
  final String id;
  final String title;
  final String subTitle;
  final double amount;
  final String date;
  final bool isNegative;

  TransactionModel({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.amount,
    required this.date,
    required this.isNegative,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      title: json['type'] == 'ride_fee' ? 'Ride Payment' : 
             json['type'] == 'payout' ? 'Withdrawal' : 'Wallet Topup',
      subTitle: json['description'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      date: json['created_at'] ?? '',
      isNegative: json['type'] == 'payout' || json['type'] == 'platform_fee',
    );
  }
}
