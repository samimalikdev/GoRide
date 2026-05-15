import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../bloc/explore_models.dart';

abstract class RideTrackingEvent extends Equatable {
  const RideTrackingEvent();

  @override
  List<Object?> get props => [];
}

class StartTrackingEvent extends RideTrackingEvent {
  final String rideId;
  final DriverModel driver;

  const StartTrackingEvent({required this.rideId, required this.driver});

  @override
  List<Object?> get props => [rideId, driver];
}

class DriverLocationUpdatedEvent extends RideTrackingEvent {
  final LatLng position;
  final int? estimatedTime;

  const DriverLocationUpdatedEvent({
    required this.position,
    this.estimatedTime,
  });

  @override
  List<Object?> get props => [position, estimatedTime];
}

class DriverArrivedEvent extends RideTrackingEvent {
  const DriverArrivedEvent();
}

class RideStartedEvent extends RideTrackingEvent {
  const RideStartedEvent();
}

class RideCompletedEvent extends RideTrackingEvent {
  final double fare;
  const RideCompletedEvent({required this.fare});

  @override
  List<Object?> get props => [fare];
}
