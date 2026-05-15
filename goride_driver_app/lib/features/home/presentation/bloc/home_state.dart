import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  final bool isOnline;
  final String verificationStatus;

  const HomeState({
    this.isOnline = false,
    this.verificationStatus = 'pending',
  });

  @override
  List<Object?> get props => [isOnline, verificationStatus];
}

class HomeInitial extends HomeState {
  const HomeInitial() : super();
}

class HomeLoading extends HomeState {
  const HomeLoading({super.isOnline, super.verificationStatus});
}

class HomeStatusUpdated extends HomeState {
  final Map<String, dynamic> driverData;
  const HomeStatusUpdated({
    required super.isOnline,
    required super.verificationStatus,
    this.driverData = const {},
  });

  @override
  List<Object?> get props => [isOnline, verificationStatus, driverData];
}

class HomeRideAccepted extends HomeState {
  final Map<String, dynamic> rideData;
  const HomeRideAccepted({
    required this.rideData,
    super.isOnline,
    super.verificationStatus,
  });

  @override
  List<Object?> get props => [isOnline, verificationStatus, rideData];
}

class HomeWaitingForConfirmation extends HomeState {
  final String rideId;
  const HomeWaitingForConfirmation({
    required this.rideId,
    super.isOnline,
    super.verificationStatus,
  });

  @override
  List<Object?> get props => [isOnline, verificationStatus, rideId];
}

class HomeNewRideRequest extends HomeState {
  final Map<String, dynamic> rideData;
  const HomeNewRideRequest({
    required this.rideData,
    super.isOnline,
    super.verificationStatus,
  });

  @override
  List<Object?> get props => [isOnline, verificationStatus, rideData];
}

class HomeError extends HomeState {
  final String message;
  const HomeError({
    required this.message,
    super.isOnline,
    super.verificationStatus,
  });

  @override
  List<Object?> get props => [isOnline, verificationStatus, message];
}

class HomeRideCancelled extends HomeState {
  final String message;
  const HomeRideCancelled({
    required this.message,
    super.isOnline,
    super.verificationStatus,
  });

  @override
  List<Object?> get props => [isOnline, verificationStatus, message];
}
