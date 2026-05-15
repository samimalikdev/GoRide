import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goride_app/core/services/api_service.dart';
import 'package:goride_app/core/services/socket_service.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'explore_event.dart';
import 'explore_state.dart';
import 'explore_models.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final ApiService apiService;
  final SocketService socketService;
  final AuthBloc authBloc;

  ExploreBloc({
    required this.apiService, 
    required this.socketService,
    required this.authBloc,
  }) : super(ExploreInitial()) {
    
    socketService.onRideAccepted((data) {
      print(" SOCKET EVENT: ride_accepted | DATA: $data");
      if (data != null && data['driver'] != null) {
        try {
          final driver = DriverModel.fromJson(data['driver']);
          add(SocketRideAcceptedEvent(
            rideId: data['rideId']?.toString() ?? '',
            driver: driver,
          ));
        } catch (e) {
          print(" Error parsing driver in onRideAccepted: $e");
        }
      }
    });

    socketService.onRideConfirmed((data) {
      print(" SOCKET EVENT: ride_confirmed | DATA: $data");
    });

    socketService.onRideCompleted((data) {
      print(" SOCKET EVENT: ride_completed | DATA: $data");
      add(SocketRideCompletedEvent(
        rideId: data?['rideId']?.toString() ?? '',
      ));
    });

    socketService.onRideCancelled((data) {
      print(" SOCKET EVENT: ride_cancelled | DATA: $data");
      add(SocketRideCancelledEvent(
        rideId: data?['rideId']?.toString() ?? '',
        message: data?['message']?.toString() ?? 'Ride was cancelled.',
      ));
    });

    on<GetExploreDataEvent>((event, emit) async {
      emit(ExploreLoading());
      try {
        final queryParams = <String, String>{};
        if (event.lat != null) queryParams['lat'] = event.lat!.toString();
        if (event.lng != null) queryParams['lng'] = event.lng!.toString();

        final response = await apiService.get('/explore/data', query: queryParams);
        final data = ExploreData.fromJson(response['data'] ?? response);
        emit(ExploreLoaded(data: data));
      } catch (e) {
        emit(ExploreError(message: e.toString()));
      }
    });

    on<RequestRideEvent>((event, emit) async {
      emit(RideRequestLoading());
      try {
        final response = await apiService.post('/rides/request', {
          'userId': event.userId,
          'pickupLocation': event.pickupLocation,
          'dropLocation': event.dropLocation,
          'category': event.category,
          'fare': event.fare,
          'pickupLatitude': event.pickupLatitude,
          'pickupLongitude': event.pickupLongitude,
          'dropLatitude': event.dropLatitude,
          'dropLongitude': event.dropLongitude,
        });

        final rideId = (response['ride']?['id'] ?? response['data']?['ride']?['id'] ?? '').toString();
        final nearbyDrivers = (response['nearbyDrivers'] as List? ?? response['data']?['nearbyDrivers'] as List? ?? [])
            .map((d) => DriverModel.fromJson(d))
            .toList();

        if (rideId.isEmpty) {
          throw Exception("Failed to get ride ID from server");
        }

        socketService.joinRide(rideId);
        
        emit(RideRequestSuccess(
          drivers: nearbyDrivers,
          rideId: rideId,
        ));
      } catch (e) {
        emit(RideRequestError(message: e.toString()));
      }
    });

    on<SocketRideAcceptedEvent>((event, emit) {
      emit(RideProposed(driver: event.driver, rideId: event.rideId));
    });

    on<ConfirmRideEvent>((event, emit) async {
      try {
        final response = await apiService.post('/rides/confirm', {
          'rideId': event.rideId,
        });
        
        final data = response['data'] ?? response;
        final driver = DriverModel.fromJson(data['driver']);
        
        emit(RideAccepted(
          driver: driver, 
          rideId: event.rideId,
          pickupLocation: LatLng(
            (data['pickup_latitude'] as num).toDouble(),
            (data['pickup_longitude'] as num).toDouble(),
          ),
          dropLocation: LatLng(
            (data['drop_latitude'] as num).toDouble(),
            (data['drop_longitude'] as num).toDouble(),
          ),
        ));
      } catch (e) {
        emit(ExploreError(message: "Failed to confirm ride: ${e.toString()}"));
      }
    });

    on<RejectDriverEvent>((event, emit) async {
      try {
        await apiService.post('/rides/reject', {
          'rideId': event.rideId,
        });
        emit(ExploreInitial()); 
        add(const GetExploreDataEvent());
      } catch (e) {
        emit(ExploreError(message: "Failed to reject driver: ${e.toString()}"));
      }
    });

    on<SocketRideCancelledEvent>((event, emit) {
      emit(RideCancelled(message: event.message));
    });

    on<CheckActiveRideEvent>((event, emit) async {
      final user = authBloc.state.currentUser;
      if (user == null) return;

      try {
        final response = await apiService.get('/rides/active', query: {'userId': user.id});
        if (response['status'] == 'success' && response['data'] != null) {
          final data = response['data'];
          final status = data['status'];
          final driver = data['driver'] != null ? DriverModel.fromJson(data['driver']) : null;
          final rideId = data['id'].toString();

          socketService.connect(apiService.baseUrl.replaceFirst('/api', ''));
          socketService.joinRide(rideId);

          if (status == 'driver_assigned') {
            if (driver != null) emit(RideProposed(driver: driver, rideId: rideId));
          } else if (status == 'accepted' || status == 'started' || status == 'arrived' || status == 'driver_arrived') {
            if (driver != null) {
              double pLat = (data['pickup_latitude'] ?? 31.5691901).toDouble();
              double pLng = (data['pickup_longitude'] ?? 74.3824455).toDouble();
              double dLat = (data['drop_latitude'] ?? 31.469).toDouble();
              double dLng = (data['drop_longitude'] ?? 74.282).toDouble();

              if (pLat == 0) pLat = 31.5691901;
              if (pLng == 0) pLng = 74.3824455;
              if (dLat == 0) dLat = 31.469;
              if (dLng == 0) dLng = 74.282;

              emit(RideAccepted(
                driver: driver, 
                rideId: rideId,
                pickupLocation: LatLng(pLat, pLng),
                dropLocation: LatLng(dLat, dLng),
              ));
            }
          } else if (status == 'pending') {
            emit(RideRequestSuccess(drivers: [], rideId: rideId));
          }
        }
      } catch (e) {
        print("EXPLORE_BLOC: Error checking active ride: $e");
      }
    });

    on<SocketRideCompletedEvent>((event, emit) {
      emit(ExploreInitial()); 
      add(const GetExploreDataEvent());
    });

    on<UserCancelRideEvent>((event, emit) async {
      try {
        await apiService.post('/rides/cancel', {'rideId': event.rideId});
        emit( RideCancelled(message: "You have cancelled the ride."));
      } catch (e) {
        emit(ExploreError(message: "Failed to cancel ride: ${e.toString()}"));
      }
    });
  }
}
