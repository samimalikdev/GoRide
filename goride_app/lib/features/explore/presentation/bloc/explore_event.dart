import 'package:equatable/equatable.dart';
import 'explore_models.dart';

abstract class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object?> get props => [];
}

class GetExploreDataEvent extends ExploreEvent {
  final double? lat;
  final double? lng;
  const GetExploreDataEvent({this.lat, this.lng});

  @override
  List<Object?> get props => [lat, lng];
}

class RequestRideEvent extends ExploreEvent {
  final String userId;
  final String pickupLocation;
  final String dropLocation;
  final String category;
  final double fare;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropLatitude;
  final double? dropLongitude;

  const RequestRideEvent({
    required this.userId,
    required this.pickupLocation,
    required this.dropLocation,
    required this.category,
    required this.fare,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropLatitude,
    this.dropLongitude,
  });

  @override
  List<Object?> get props => [
        userId,
        pickupLocation,
        dropLocation,
        category,
        fare,
        pickupLatitude,
        pickupLongitude,
        dropLatitude,
        dropLongitude,
      ];
}

class SocketRideAcceptedEvent extends ExploreEvent {
  final String rideId;
  final DriverModel driver;

  const SocketRideAcceptedEvent({required this.rideId, required this.driver});

  @override
  List<Object?> get props => [rideId, driver];
}

class SocketRideCancelledEvent extends ExploreEvent {
  final String rideId;
  final String message;

  const SocketRideCancelledEvent({required this.rideId, required this.message});

  @override
  List<Object?> get props => [rideId, message];
}

class ConfirmRideEvent extends ExploreEvent {
  final String rideId;
  const ConfirmRideEvent({required this.rideId});
  @override
  List<Object?> get props => [rideId];
}

class RejectDriverEvent extends ExploreEvent {
  final String rideId;
  const RejectDriverEvent({required this.rideId});
  @override
  List<Object?> get props => [rideId];
}

class SocketRideConfirmedEvent extends ExploreEvent {
  final String rideId;
  final DriverModel driver;
  const SocketRideConfirmedEvent({required this.rideId, required this.driver});
  @override
  List<Object?> get props => [rideId, driver];
}

class CheckActiveRideEvent extends ExploreEvent {
  const CheckActiveRideEvent();
}

class UserCancelRideEvent extends ExploreEvent {
  final String rideId;
  const UserCancelRideEvent({required this.rideId});
  @override
  List<Object?> get props => [rideId];
}

class SocketRideCompletedEvent extends ExploreEvent {
  final String rideId;
  const SocketRideCompletedEvent({required this.rideId});
  @override
  List<Object?> get props => [rideId];
}
