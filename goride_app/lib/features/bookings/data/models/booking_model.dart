import '../../../explore/presentation/bloc/explore_models.dart';

class BookingModel {
  final String id;
  final String pickupLocation;
  final String dropLocation;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final String status;
  final double fare;
  final String category;
  final DateTime createdAt;
  final DriverModel? driver;

  BookingModel({
    required this.id,
    required this.pickupLocation,
    required this.dropLocation,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.status,
    required this.fare,
    required this.category,
    required this.createdAt,
    this.driver,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      pickupLocation: json['pickup_location'] ?? '',
      dropLocation: json['drop_location'] ?? '',
      pickupLat: (json['pickup_latitude'] as num?)?.toDouble() ?? 0.0,
      pickupLng: (json['pickup_longitude'] as num?)?.toDouble() ?? 0.0,
      dropLat: (json['drop_latitude'] as num?)?.toDouble() ?? 0.0,
      dropLng: (json['drop_longitude'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      fare: (json['fare'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? 'Ride',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      driver: json['driver'] != null ? DriverModel.fromJson(json['driver']) : null,
    );
  }


  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final bookingDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

    if (bookingDate == today) return "Today, ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}";
    if (bookingDate == yesterday) return "Yesterday, ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}";
    return "${createdAt.day} ${_getMonth(createdAt.month)}, ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}";
  }

  static String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

