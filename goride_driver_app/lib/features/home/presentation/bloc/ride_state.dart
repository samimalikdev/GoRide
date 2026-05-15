import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class RideState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RideTrackingInitial extends RideState {}

class WaitingForRiderConfirmation extends RideState {}

class RideLocationUpdate extends RideState {
  final LatLng location;
  RideLocationUpdate({required this.location});
  @override
  List<Object?> get props => [location];
}

class RideArrived extends RideState {}

class RideConfirmed extends RideState {
  final String rideId;
  RideConfirmed({required this.rideId});
  @override
  List<Object?> get props => [rideId];
}

class RideCancelled extends RideState {
  final String message;
  RideCancelled({required this.message});
  @override
  List<Object?> get props => [message];
}

class DriverRejected extends RideState {
  final String message;
  DriverRejected({required this.message});
  @override
  List<Object?> get props => [message];
}

class RideError extends RideState {
  final String message;
  RideError({required this.message});
  @override
  List<Object?> get props => [message];
}

class RideStarted extends RideState {}

class RideCompleted extends RideState {}
