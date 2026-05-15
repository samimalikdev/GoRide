class ExploreData {
  final String userName;
  final String greeting;
  final List<CategoryModel> categories;
  final List<DriverModel> nearbyDrivers;
  final PromoModel activePromo;

  ExploreData({
    required this.userName,
    required this.greeting,
    required this.categories,
    required this.nearbyDrivers,
    required this.activePromo,
  });

  factory ExploreData.fromJson(Map<String, dynamic> json) {
    return ExploreData(
      userName: json['user']?['name'] ?? 'User',
      greeting: json['user']?['greeting'] ?? 'Hello',
      categories: (json['categories'] as List? ?? [])
          .map((c) => CategoryModel.fromJson(c))
          .toList(),
      nearbyDrivers: (json['nearbyDrivers'] as List? ?? [])
          .map((d) => DriverModel.fromJson(d))
          .toList(),
      activePromo: PromoModel.fromJson(json['activePromo'] ?? {}),
    );
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String icon;
  final String color;

  CategoryModel({required this.id, required this.name, required this.icon, required this.color});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '0xffffffff',
    );
  }
}

class DriverModel {
  final String id;
  final String name;
  final double rating;
  final String vehicle;
  final double lat;
  final double lng;
  final String? profilePic;

  DriverModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.vehicle,
    required this.lat,
    required this.lng,
    this.profilePic,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: (json['user_id'] ?? json['id'])?.toString() ?? '',
      name: json['full_name'] ?? json['name'] ?? 'Unknown Driver',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      vehicle: json['vehicle_type'] ?? json['vehicle'] ?? 'Ride',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      profilePic: json['profile_pic'] ?? json['profilePic'],
    );
  }
}

class PromoModel {
  final String title;
  final String subtitle;
  final String code;

  PromoModel({required this.title, required this.subtitle, required this.code});

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    return PromoModel(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class RideRequestResult {
  final String rideId;
  final List<DriverModel> nearbyDrivers;
  RideRequestResult({required this.rideId, required this.nearbyDrivers});
}
