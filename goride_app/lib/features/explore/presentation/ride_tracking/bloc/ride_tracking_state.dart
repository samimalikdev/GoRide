import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class RideTrackingState extends Equatable {
  const RideTrackingState();

  @override
  List<Object?> get props => [];
}

class RideTrackingInitial extends RideTrackingState {}

class RideTrackingActive extends RideTrackingState {
  final LatLng driverPosition;
  final String statusMessage;
  final bool hasArrived;
  final bool isStarted;
  final bool isCompleted;
  final double fare;

  const RideTrackingActive({
    required this.driverPosition,
    required this.statusMessage,
    this.hasArrived = false,
    this.isStarted = false,
    this.isCompleted = false,
    this.fare = 0.0,
  });

  RideTrackingActive copyWith({
    LatLng? driverPosition,
    String? statusMessage,
    bool? hasArrived,
    bool? isStarted,
    bool? isCompleted,
    double? fare,
  }) {
    return RideTrackingActive(
      driverPosition: driverPosition ?? this.driverPosition,
      statusMessage: statusMessage ?? this.statusMessage,
      hasArrived: hasArrived ?? this.hasArrived,
      isStarted: isStarted ?? this.isStarted,
      isCompleted: isCompleted ?? this.isCompleted,
      fare: fare ?? this.fare,
    );
  }

  @override
  List<Object?> get props => [
    driverPosition,
    statusMessage,
    hasArrived,
    isStarted,
    isCompleted,
    fare,
  ];
}
