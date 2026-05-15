import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'explore_models.dart';

abstract class ExploreState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {}

class ExploreLoading extends ExploreState {}

class ExploreLoaded extends ExploreState {
  final ExploreData data;
  ExploreLoaded({required this.data});
  @override
  List<Object?> get props => [data];
}

class ExploreError extends ExploreState {
  final String message;
  ExploreError({required this.message});
  @override
  List<Object?> get props => [message];
}

class RideRequestLoading extends ExploreState {}

class RideRequestSuccess extends ExploreState {
  final List<DriverModel> drivers;
  final String? rideId;
  RideRequestSuccess({required this.drivers, this.rideId});
  @override
  List<Object?> get props => [drivers, rideId];
}

class RideProposed extends ExploreState {
  final DriverModel driver;
  final String rideId;
  RideProposed({required this.driver, required this.rideId});
  @override
  List<Object?> get props => [driver, rideId];
}

class RideAccepted extends ExploreState {
  final DriverModel driver;
  final String rideId;
  final LatLng pickupLocation;
  final LatLng dropLocation;

  RideAccepted({
    required this.driver, 
    required this.rideId,
    required this.pickupLocation,
    required this.dropLocation,
  });

  @override
  List<Object?> get props => [driver, rideId, pickupLocation, dropLocation];
}

class RideRequestError extends ExploreState {
  final String message;
  RideRequestError({required this.message});
  @override
  List<Object?> get props => [message];
}

class RideCancelled extends ExploreState {
  final String message;
  RideCancelled({required this.message});
  @override
  List<Object?> get props => [message];
}
