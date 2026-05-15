import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import '../../../../../core/services/socket_service.dart';
import 'ride_tracking_event.dart';
import 'ride_tracking_state.dart';

class RideTrackingBloc extends Bloc<RideTrackingEvent, RideTrackingState> {
  final SocketService _socketService;
  LatLng? _pickupLocation;

  RideTrackingBloc({required SocketService socketService}) : _socketService = socketService, super(RideTrackingInitial()) {
    on<StartTrackingEvent>(_onStartTracking);
    on<DriverLocationUpdatedEvent>(_onLocationUpdated);
    on<DriverArrivedEvent>(_onDriverArrived);
    on<RideStartedEvent>(_onRideStarted);
    on<RideCompletedEvent>(_onRideCompleted);
  }

  void _onStartTracking(
    StartTrackingEvent event,
    Emitter<RideTrackingState> emit,
  ) {
    print(
      " RIDER_TRACKING_BLOC: Starting tracking for ride ${event.rideId}",
    );
    _socketService.joinRide(event.rideId);


    emit(
      RideTrackingActive(
        driverPosition: LatLng(event.driver.lat, event.driver.lng),
        statusMessage: "Driver is on the way...",
      ),
    );

    _socketService.onDriverLocationUpdate((data) {
      if (data != null && data['lat'] != null && data['lng'] != null) {
        add(
          DriverLocationUpdatedEvent(
            position: LatLng(
              (data['lat'] as num).toDouble(),
              (data['lng'] as num).toDouble(),
            ),
            estimatedTime: data['estimatedTime'] as int?,
          ),
        );
      }
    });

    _socketService.onDriverArrived((_) {
      add(const DriverArrivedEvent());
    });

    _socketService.onRideStarted((_) {
      add(const RideStartedEvent());
    });

    _socketService.onRideCompleted((data) {
      final fare = (data?['fare'] as num?)?.toDouble() ?? 0.0;
      add(RideCompletedEvent(fare: fare));
    });
  }

  void _onLocationUpdated(
    DriverLocationUpdatedEvent event,
    Emitter<RideTrackingState> emit,
  ) {
    if (state is RideTrackingActive) {
      final currentState = state as RideTrackingActive;



      String message = "Driver is arriving...";
      if (event.estimatedTime != null) {
        message = "Driver is arriving in ${event.estimatedTime} mins";
      } else {
        message = "Driver is nearby";
      }

      emit(
        currentState.copyWith(
          driverPosition: event.position,
          statusMessage: message,
        ),
      );
    }
  }

  void _onDriverArrived(
    DriverArrivedEvent event,
    Emitter<RideTrackingState> emit,
  ) {
    if (state is RideTrackingActive) {
      final currentState = state as RideTrackingActive;
      emit(
        currentState.copyWith(
          statusMessage: "Driver has arrived!",
          hasArrived: true,
        ),
      );
    }
  }

  void _onRideStarted(RideStartedEvent event, Emitter<RideTrackingState> emit) {
    if (state is RideTrackingActive) {
      final currentState = state as RideTrackingActive;
      emit(
        currentState.copyWith(
          statusMessage: "Ride in progress",
          isStarted: true,
        ),
      );
    }
  }

  void _onRideCompleted(
    RideCompletedEvent event,
    Emitter<RideTrackingState> emit,
  ) {
    if (state is RideTrackingActive) {
      final currentState = state as RideTrackingActive;
      emit(
        currentState.copyWith(
          statusMessage: "Ride completed!",
          isCompleted: true,
          fare: event.fare,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    print(" RIDER_TRACKING_BLOC: Closing");
    _socketService.stopLocationUpdates();
    _socketService.stopArrivalListener();
    _socketService.stopConfirmationListener();
    _socketService.stopCancellationListener();
    _socketService.stopRideStartedListener();
    _socketService.stopRideCompletedListener();
    return super.close();
  }
}
