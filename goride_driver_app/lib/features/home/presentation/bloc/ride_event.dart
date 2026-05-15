import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class RideEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitRideTrackingEvent extends RideEvent {
  final String rideId;
  InitRideTrackingEvent({required this.rideId});
  @override
  List<Object?> get props => [rideId];
}

class LocationUpdatedInternalEvent extends RideEvent {
  final LatLng location;
  LocationUpdatedInternalEvent({required this.location});
  @override
  List<Object?> get props => [location];
}

class ArrivedInternalEvent extends RideEvent {}

class CancelRideEvent extends RideEvent {
  final String rideId;
  CancelRideEvent({required this.rideId});
  @override
  List<Object?> get props => [rideId];
}

class SocketRideConfirmedEvent extends RideEvent {
  final String rideId;
  SocketRideConfirmedEvent({required this.rideId});
  @override
  List<Object?> get props => [rideId];
}

class SocketDriverRejectedEvent extends RideEvent {
  final String rideId;
  final String message;
  SocketDriverRejectedEvent({required this.rideId, required this.message});
  @override
  List<Object?> get props => [rideId, message];
}

class DriverArrivedAtPickupEvent extends RideEvent {
  final String rideId;
  DriverArrivedAtPickupEvent({required this.rideId});
  @override
  List<Object?> get props => [rideId];
}

class SocketRideCancelledEvent extends RideEvent {
  final String rideId;
  final String message;
  SocketRideCancelledEvent({required this.rideId, required this.message});
  @override
  List<Object?> get props => [rideId, message];
}

class StartRideEvent extends RideEvent {
  final String rideId;
  StartRideEvent({required this.rideId});
  @override
  List<Object?> get props => [rideId];
}

class CompleteRideEvent extends RideEvent {
  final String rideId;
  CompleteRideEvent({required this.rideId});
  @override
  List<Object?> get props => [rideId];
}

