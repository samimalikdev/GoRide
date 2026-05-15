import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ToggleOnlineEvent extends HomeEvent {
  final bool isOnline;
  final double? lat;
  final double? lng;
  ToggleOnlineEvent({required this.isOnline, this.lat, this.lng});

  @override
  List<Object?> get props => [isOnline, lat, lng];
}

class FetchDriverStatusEvent extends HomeEvent {}

class InitSocketEvent extends HomeEvent {}

class NewRideRequestReceivedEvent extends HomeEvent {
  final Map<String, dynamic> rideData;
  NewRideRequestReceivedEvent({required this.rideData});

  @override
  List<Object?> get props => [rideData];
}

class SubmitVerificationEvent extends HomeEvent {
  final String fullName;
  final String dateOfBirth;
  final String vehicleModel;
  final String vehicleType;
  final String city;
  final String postalCode;
  final double latitude;
  final double longitude;
  final Map<String, String?> documentPaths;

  SubmitVerificationEvent({
    required this.fullName,
    required this.dateOfBirth,
    required this.vehicleModel,
    required this.vehicleType,
    required this.city,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.documentPaths,
  });

  @override
  List<Object?> get props => [fullName, dateOfBirth, vehicleModel, vehicleType, city, postalCode, latitude, longitude, documentPaths];
}

class AcceptRideEvent extends HomeEvent {
  final String rideId;
  AcceptRideEvent({required this.rideId});

  @override
  List<Object?> get props => [rideId];
}

class CheckActiveRideEvent extends HomeEvent {}

class HomeRideCancelledEvent extends HomeEvent {
  final Map<String, dynamic> rideData;
  HomeRideCancelledEvent({required this.rideData});

  @override
  List<Object?> get props => [rideData];
}

class RideConfirmedByPassengerEvent extends HomeEvent {
  final Map<String, dynamic> rideData;
  RideConfirmedByPassengerEvent({required this.rideData});

  @override
  List<Object?> get props => [rideData];
}
