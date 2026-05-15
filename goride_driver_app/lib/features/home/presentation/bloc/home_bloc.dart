import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goride_driver_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/home_event.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/home_state.dart';
import 'package:goride_driver_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goride_driver_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:goride_driver_app/core/services/api_service.dart';
import 'package:goride_driver_app/core/services/socket_service.dart';

import 'dart:async';
import 'package:geolocator/geolocator.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ApiService apiService;
  final AuthBloc authBloc;
  final SocketService socketService;
  StreamSubscription<Position>? _positionSubscription;

  HomeBloc({
    required this.apiService, 
    required this.authBloc,
    required this.socketService,
  }) : super(HomeInitial()) {
    
    authBloc.stream.listen((authState) {
      if (authState is AuthUnauthenticated) {
        _stopLocationUpdates();
      }
    });
    on<InitSocketEvent>((event, emit) {
      final user = authBloc.state.currentUser;
      if (user != null) {
        print("HOME_BLOC: Initializing socket for user ${user.id}");
        socketService.connect();
        socketService.joinDriverRoom(user.id);
        
        socketService.onNewRideRequest((rideData) {
          add(NewRideRequestReceivedEvent(rideData: rideData));
        });

        socketService.onRideCancelled((data) {
          add(HomeRideCancelledEvent(rideData: data ?? {}));
        });

        socketService.onRideCancelledGlobal((data) {
          add(HomeRideCancelledEvent(rideData: data ?? {}));
        });
      }
    });

    on<NewRideRequestReceivedEvent>((event, emit) {
      print("HOME_BLOC: New ride request received event in Bloc");
      emit(HomeNewRideRequest(
        rideData: event.rideData,
        isOnline: state.isOnline,
        verificationStatus: state.verificationStatus,
      ));
    });

    on<HomeRideCancelledEvent>((event, emit) {
      print("HOME_BLOC: Ride cancelled event in Bloc");
      emit(HomeRideCancelled(
        message: event.rideData['message'] ?? 'The ride was cancelled.',
        isOnline: state.isOnline,
        verificationStatus: state.verificationStatus,
      ));
    });

    on<FetchDriverStatusEvent>((event, emit) async {
      final user = authBloc.state.currentUser;
      if (user == null) return;

      emit(HomeLoading(isOnline: state.isOnline, verificationStatus: state.verificationStatus));
      try {
        final response = await apiService.get('/drivers/status');
        final data = response['data'];
        final isOnline = data['is_online'] ?? false;
        if (isOnline) {
          _startLocationUpdates();
        }

        emit(HomeStatusUpdated(
          isOnline: isOnline,
          verificationStatus: data['status'] ?? 'pending',
          driverData: data,
        ));
      } catch (e) {
        emit(HomeError(
          message: 'Status Fetch Error: $e',
          isOnline: state.isOnline,
          verificationStatus: state.verificationStatus,
        ));
      }
    });

    on<ToggleOnlineEvent>((event, emit) async {
      final user = authBloc.state.currentUser;
      if (user == null) return;

      final previousState = state;
      emit(HomeLoading(isOnline: state.isOnline, verificationStatus: state.verificationStatus));
      try {
        final response = await apiService.post('/drivers/toggle-online', {
          'isOnline': event.isOnline,
          'latitude': event.lat,
          'longitude': event.lng,
        });

        final data = response['data'];
        
        if (event.isOnline) {
          _startLocationUpdates();
        } else {
          _stopLocationUpdates();
        }

        emit(HomeStatusUpdated(
          isOnline: event.isOnline,
          verificationStatus: 'approved',
          driverData: data,
        ));
      } catch (e) {
        emit(HomeError(
          message: 'Toggle Error: $e',
          isOnline: state.isOnline,
          verificationStatus: state.verificationStatus,
        ));
        if (previousState is HomeStatusUpdated) emit(previousState);
      }
    });

    on<SubmitVerificationEvent>((event, emit) async {
      final user = authBloc.state.currentUser;
      if (user == null) return;

      emit(HomeLoading(isOnline: state.isOnline, verificationStatus: state.verificationStatus));
      try {
        final Map<String, String> files = {};
        for (var entry in event.documentPaths.entries) {
          if (entry.value != null) {
            files[entry.key] = entry.value!;
          }
        }

        final Map<String, String> documentUrls = {};
        for (var fileEntry in files.entries) {
          final uploadRes = await apiService.multipart(
            '/drivers/upload-document', 
            {'docType': fileEntry.key}, 
            {'document': fileEntry.value}
          );
          documentUrls[fileEntry.key] = uploadRes['data']['url'];
        }

        final response = await apiService.post('/drivers/submit-verification', {
          'fullName': event.fullName,
          'dateOfBirth': event.dateOfBirth,
          'vehicleModel': event.vehicleModel,
          'vehicleType': event.vehicleType,
          'documentUrls': documentUrls,
          'city': event.city,
          'postalCode': event.postalCode,
          'latitude': event.latitude,
          'longitude': event.longitude,
        });

        final data = response['data'];
        emit(HomeStatusUpdated(
          isOnline: false,
          verificationStatus: data['status'] ?? 'pending',
          driverData: data,
        ));
      } catch (e) {
        emit(HomeError(
          message: 'Submission Error: $e',
          isOnline: state.isOnline,
          verificationStatus: state.verificationStatus,
        ));
      }
    });

    on<AcceptRideEvent>((event, emit) async {
      final user = authBloc.state.currentUser;
      if (user == null) return;

      emit(HomeLoading(isOnline: state.isOnline, verificationStatus: state.verificationStatus));
      try {
        final response = await apiService.post('/rides/accept', {
          'rideId': event.rideId,
          'driverId': user.id,
        });

        final data = response['data'];
        
        socketService.joinRide(event.rideId);
        
        socketService.onRideConfirmed((confirmData) {
          add(RideConfirmedByPassengerEvent(rideData: confirmData ?? data));
        });

        emit(HomeWaitingForConfirmation(
          rideId: event.rideId,
          isOnline: state.isOnline,
          verificationStatus: state.verificationStatus,
        ));
      } catch (e) {
        emit(HomeError(
          message: 'Accept Error: $e',
          isOnline: state.isOnline,
          verificationStatus: state.verificationStatus,
        ));
      }
    });

    on<RideConfirmedByPassengerEvent>((event, emit) {
      emit(HomeRideAccepted(
        rideData: event.rideData,
        isOnline: state.isOnline,
        verificationStatus: state.verificationStatus,
      ));
    });

    on<CheckActiveRideEvent>((event, emit) async {
      final user = authBloc.state.currentUser;
      if (user == null) return;

      try {
        final response = await apiService.get('/rides/active', query: {'driverId': user.id});
        if (response['status'] == 'success' && response['data'] != null) {
          final data = response['data'];
          final status = data['status'];
          final rideId = data['id'].toString();

          socketService.joinRide(rideId);

          if (status == 'driver_assigned') {
            socketService.onRideConfirmed((confirmData) {
              add(RideConfirmedByPassengerEvent(rideData: confirmData ?? data));
            });
            
            emit(HomeWaitingForConfirmation(
              rideId: rideId,
              isOnline: state.isOnline,
              verificationStatus: state.verificationStatus,
            ));
          } else {
            emit(HomeRideAccepted(
              rideData: data,
              isOnline: state.isOnline,
              verificationStatus: state.verificationStatus,
            ));
          }
        }
      } catch (e) {
        print("HOME_BLOC: Error checking active ride: $e");
      }
    });
  }

  void _startLocationUpdates() {
    _stopLocationUpdates(); 
    print("HOME_BLOC: Starting background location updates...");
    
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, 
      ),
    ).listen((Position position) {
      print("HOME_BLOC: Background Location Update: ${position.latitude}, ${position.longitude}");
      
      apiService.post('/drivers/toggle-online', {
        'isOnline': true,
        'latitude': position.latitude,
        'longitude': position.longitude,
      }).catchError((e) {
        print("HOME_BLOC: Failed to update background location: $e");
      });
    });
  }

  void _stopLocationUpdates() {
    print("HOME_BLOC: Stopping location updates.");
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  Future<void> close() {
    _stopLocationUpdates();
    return super.close();
  }
}
