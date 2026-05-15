import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:goride_driver_app/core/services/socket_service.dart';
import 'package:goride_driver_app/core/services/api_service.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/ride_event.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/ride_state.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  final SocketService socketService;
  final ApiService apiService;
  StreamSubscription<Position>? _positionSubscription;
  String? _currentRideId;

  RideBloc({required this.socketService, required this.apiService}) : super(RideTrackingInitial()) {
    
    socketService.onRideConfirmed((data) {
      if (isClosed) return;
      print(" SOCKET EVENT: ride_confirmed | DATA: $data");
      if (data != null) {
        final rideId = data['rideId']?.toString() ?? '';
        add(SocketRideConfirmedEvent(rideId: rideId));
      }
    });

    socketService.onDriverRejected((data) {
      if (isClosed) return;
      print("SOCKET EVENT: driver_rejected | DATA: $data");
      if (data != null) {
        add(SocketDriverRejectedEvent(
          rideId: data['rideId']?.toString() ?? '',
          message: data['message']?.toString() ?? 'User rejected the ride.',
        ));
      }
    });

    socketService.onRideCancelled((data) {
      if (isClosed) return;
      print(" SOCKET EVENT: ride_cancelled | DATA: $data");
      if (data != null) {
        add(SocketRideCancelledEvent(
          rideId: data['rideId']?.toString() ?? '',
          message: data['message']?.toString() ?? 'The ride was cancelled.',
        ));
      }
    });

    on<InitRideTrackingEvent>((event, emit) {
      _currentRideId = event.rideId;
      socketService.connect();
      socketService.joinRide(event.rideId);
      
      emit(WaitingForRiderConfirmation());

      socketService.onDriverLocationUpdate((data) {
        if (isClosed) return;
        if (data != null) {
          add(LocationUpdatedInternalEvent(
            location: LatLng(data['lat'], data['lng'])
          ));
        }
      });

      socketService.onDriverArrived((_) {
        if (isClosed) return;
        add(ArrivedInternalEvent());
      });

      socketService.onRideStarted((_) {
        if (isClosed) return;
        add(StartRideEvent(rideId: event.rideId));
      });

      socketService.onRideCompleted((_) {
        if (isClosed) return;
        add(CompleteRideEvent(rideId: event.rideId));
      });
    });

    on<LocationUpdatedInternalEvent>((event, emit) {
      emit(RideLocationUpdate(location: event.location));
    });


    on<ArrivedInternalEvent>((event, emit) {
      emit(RideArrived());
    });

    on<CancelRideEvent>((event, emit) async {
      print("BLOC: CancelRideEvent received for ride ${event.rideId}");
      _stopLocationTracking();
      try {
        final response = await apiService.post('/rides/cancel', {
          'rideId': event.rideId,
        });
        print("BLOC: Cancel API Response: $response");
        emit(RideCancelled(message: "You have cancelled the ride."));
      } catch (e) {
        print("BLOC: Cancel API Error: $e");
        emit(RideError(message: "Failed to cancel ride: ${e.toString()}"));
      }
    });

    on<SocketRideConfirmedEvent>((event, emit) {
      print("RIDE CONFIRMED EVENT RECEIVED IN BLOC");
      emit(RideConfirmed(rideId: event.rideId));
      _startLocationTracking(event.rideId);
    });

    on<SocketDriverRejectedEvent>((event, emit) {
      _stopLocationTracking();
      emit(DriverRejected(message: event.message));
    });

    on<DriverArrivedAtPickupEvent>((event, emit) async {
      print("BLOC: DriverArrivedAtPickupEvent for ride ${event.rideId}");
      try {
        await apiService.post('/rides/arrive', {'rideId': event.rideId});
        emit(RideArrived());
      } catch (e) {
        emit(RideError(message: "Failed to notify arrival: ${e.toString()}"));
      }
    });

    on<StartRideEvent>((event, emit) async {
      print(" BLOC: StartRideEvent for ride ${event.rideId}");
      try {
        if (state is! RideStarted) {
           await apiService.post('/rides/start', {'rideId': event.rideId});
        }
        emit(RideStarted());
      } catch (e) {
        emit(RideError(message: "Failed to start ride: ${e.toString()}"));
      }
    });

    on<CompleteRideEvent>((event, emit) async {
      print("BLOC: CompleteRideEvent for ride ${event.rideId}");
      try {
        await apiService.post('/rides/complete', {'rideId': event.rideId});
        emit(RideCompleted());
      } catch (e) {
        emit(RideError(message: "Failed to complete ride: ${e.toString()}"));
      }
    });

    on<SocketRideCancelledEvent>((event, emit) {
      print("BLOC: SocketRideCancelledEvent received");
      _stopLocationTracking();
      emit(RideCancelled(message: event.message));
    });
  }

  void _startLocationTracking(String rideId) async {
    try {
      _stopLocationTracking(); 
      print("STARTING REAL-TIME LOCATION TRACKING FOR RIDE: $rideId");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        print("GPS Permission Granted. Starting stream...");
        _positionSubscription = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5, 
          ),
        ).listen((Position position) {
          print(" REAL GPS UPDATE: ${position.latitude}, ${position.longitude}");
          
          socketService.updateLocation(rideId, position.latitude, position.longitude);

          add(LocationUpdatedInternalEvent(
            location: LatLng(position.latitude, position.longitude)
          ));
        }, onError: (error) {
          print(" GPS Stream Error: $error");
        });
      } else {
        print(" LOCATION PERMISSION DENIED");
      }
    } catch (e) {
      print(" CRITICAL ERROR in _startLocationTracking: $e");
    }
  }

  void _stopLocationTracking() {
    print("STOPPING LOCATION TRACKING");
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }


  @override
  Future<void> close() {
    print("RIDE_BLOC: Closing and cleaning up socket listeners");
    _stopLocationTracking();
    socketService.clearCallbacks('ride_confirmed');
    socketService.clearCallbacks('driver_location_update');
    socketService.clearCallbacks('driver_arrived');
    socketService.clearCallbacks('ride_cancelled');
    socketService.clearCallbacks('driver_rejected');
    return super.close();
  }
}
