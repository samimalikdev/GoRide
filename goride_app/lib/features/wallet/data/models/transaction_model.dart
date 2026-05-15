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
    final type = json['type']; 
    final category = json['category'];
    
    return TransactionModel(
      id: json['id'],
      title: category == 'ride_payment' ? "Ride Payment" : 
             category == 'ride_earning' ? "Ride Earnings" :
             category == 'topup' ? "Wallet Top-up" : "Transaction",
      subTitle: json['description'] ?? "No description",
      amount: (json['amount'] as num).toDouble(),
      date: json['created_at'],
      isNegative: type == 'debit',
    );
  }
}
