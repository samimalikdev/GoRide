import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/ride_event.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/ride_state.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../bloc/ride_bloc.dart';
import '../../../../injection_container.dart';
import 'package:goride_driver_app/features/auth/presentation/bloc/auth_bloc.dart' as goride_auth;
import 'package:goride_driver_app/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:goride_driver_app/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:goride_driver_app/features/call/presentation/pages/call_page.dart';
import 'package:goride_driver_app/features/call/presentation/bloc/call_bloc.dart';
import 'package:goride_driver_app/features/chat/presentation/pages/chat_detail_page.dart';

class ActiveRidePage extends StatefulWidget {
  final Map<String, dynamic> rideData;

  const ActiveRidePage({super.key, required this.rideData});

  @override
  State<ActiveRidePage> createState() => _ActiveRidePageState();
}

class _ActiveRidePageState extends State<ActiveRidePage> {
  LatLng? _driverLocation;
  late LatLng _pickupLocation;
  late LatLng _dropLocation;
  String _status = "Waiting for User...";
  final MapController _mapController = MapController();
  bool _isConfirmed = false;
  bool _isArrived = false;
  bool _isStarted = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    print("DEBUG: ActiveRidePage rideData: ${widget.rideData}");
    double lat =
        (widget.rideData['pickupLat'] ??
                widget.rideData['pickup_latitude'] ??
                31.5691901)
            .toDouble();
    double lng =
        (widget.rideData['pickupLng'] ??
                widget.rideData['pickup_longitude'] ??
                74.3824455)
            .toDouble();
    if (lat == 0) lat = 31.5691901;
    if (lng == 0) lng = 74.3824455;
    _pickupLocation = LatLng(lat, lng);

    double dLat =
        (widget.rideData['dropLat'] ??
                widget.rideData['drop_latitude'] ??
                31.469)
            .toDouble();
    double dLng =
        (widget.rideData['dropLng'] ??
                widget.rideData['drop_longitude'] ??
                74.282)
            .toDouble();
    if (dLat == 0) dLat = 31.469;
    if (dLng == 0) dLng = 74.282;
    _dropLocation = LatLng(dLat, dLng);
    _driverLocation = _pickupLocation;

    final status = (widget.rideData['status'] ?? "").toString().toLowerCase();
    if (status == 'accepted' || status == 'driver_arrived' || status == 'started') {
      _isConfirmed = true;
      _status = "Heading to Pickup";
    }
    if (status == 'driver_arrived') {
      _isArrived = true;
      _status = "Arrived at Pickup";
    }
    if (status == 'started') {
      _isArrived = true;
      _isStarted = true;
      _status = "Ride in Progress";
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideId =
        widget.rideData['rideId'] ??
        widget.rideData['id'] ??
        widget.rideData['_id'] ??
        "";

    print("DEBUG: ActiveRidePage computed rideId: '$rideId'");

    return BlocProvider(
      create: (context) =>
          sl<RideBloc>()..add(InitRideTrackingEvent(rideId: rideId)),
      child: BlocConsumer<RideBloc, RideState>(
        listener: (context, state) {
          if (state is RideLocationUpdate) {
            setState(() {
              _driverLocation = state.location;
            });
            if (_isConfirmed) {
              _mapController.move(state.location, 15.0);
            }
          } else if (state is RideArrived) {
            setState(() {
              _isArrived = true;
              _status = "Arrived at Pickup";
            });
          } else if (state is RideStarted) {
            setState(() {
              _isStarted = true;
              _status = "Ride in Progress";
            });
          } else if (state is RideCompleted) {
            setState(() {
              _isCompleted = true;
              _status = "Ride Completed";
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Ride Completed Successfully!"), backgroundColor: Color(0xff76eb07)),
            );
            final authState = context.read<goride_auth.AuthBloc>().state;
            if (authState.userId.isNotEmpty) {
              context.read<WalletBloc>().add(FetchWalletData(authState.userId));
            }
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is RideConfirmed) {
            setState(() {
              _isConfirmed = true;
              _status = "Heading to Pickup";
            });
          } else if (state is RideCancelled || state is DriverRejected) {
            print(
              "PAGE: Ride Cancelled/Rejected state received. Popping...",
            );
            String msg = (state is RideCancelled)
                ? state.message
                : (state as DriverRejected).message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                if (_isConfirmed)
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _pickupLocation,
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.goride.driver.goride_driver_app',
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [_pickupLocation, _dropLocation],
                            strokeWidth: 4.0,
                            color: const Color(
                              0xff76eb07,
                            ).withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _pickupLocation,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xff76eb07),
                              size: 40,
                            ),
                          ),
                          Marker(
                            point: _dropLocation,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.flag,
                              color: Colors.redAccent,
                              size: 40,
                            ),
                          ),
                          if (_driverLocation != null)
                            Marker(
                              point: _driverLocation!,
                              width: 60,
                              height: 60,
                              child: const Icon(
                                Icons.navigation_rounded,
                                color: Colors.blueAccent,
                                size: 40,
                              ),
                            ),
                        ],
                      ),
                    ],
                  )
                else
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xff000000), Color(0xff1a1a1a)],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_searching,
                            color: Color(0xff76eb07),
                            size: 80,
                          ),
                          const SizedBox(height: 30),
                          Text(
                            "AWAITING RIDER",
                            style: GoogleFonts.outfit(
                              color: const Color(0xff76eb07),
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "The user is reviewing your profile...",
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                Positioned(
                  top: 60,
                  left: 20,
                  right: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xff76eb07,
                                ).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isConfirmed
                                    ? Icons.directions_car
                                    : Icons.hourglass_empty,
                                color: const Color(0xff76eb07),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _status.toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xff76eb07),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Text(
                                    _isStarted 
                                        ? "Heading to Dropoff" 
                                        : (_isArrived ? "At Pickup Location" : "Heading to Pickup"),
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.white10,
                                  backgroundImage: widget.rideData['passengerProfilePic'] != null && widget.rideData['passengerProfilePic'].toString().isNotEmpty
                                      ? NetworkImage(widget.rideData['passengerProfilePic'])
                                      : null,
                                  child: widget.rideData['passengerProfilePic'] == null || widget.rideData['passengerProfilePic'].toString().isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Passenger",
                                        style: GoogleFonts.outfit(
                                          color: Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        widget.rideData['passengerName'] ??
                                            "Passenger",
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "EST. FARE",
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xff76eb07).withValues(alpha: 0.6),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      "RS. ${widget.rideData['fare'] ?? '0'}",
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xff76eb07),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  onPressed: () {
                                    final rideBloc = context.read<RideBloc>();
                                    final homeBloc = context.read<HomeBloc>();
                                    context.read<CallBloc>().add(StartCallEvent(
                                      widget.rideData['passengerId']?.toString() ?? "",
                                      name: widget.rideData['passengerName'] ?? "Passenger",
                                    ));
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MultiBlocProvider(
                                          providers: [
                                            BlocProvider.value(value: rideBloc),
                                            BlocProvider.value(value: homeBloc),
                                          ],
                                          child: const CallPage(),
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.call_rounded, color: Color(0xff76eb07)),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xff76eb07).withValues(alpha: 0.1),
                                    padding: const EdgeInsets.all(12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    final rideBloc = context.read<RideBloc>();
                                    final homeBloc = context.read<HomeBloc>();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MultiBlocProvider(
                                          providers: [
                                            BlocProvider.value(value: rideBloc),
                                            BlocProvider.value(value: homeBloc),
                                          ],
                                          child: ChatDetailPage(
                                            userName: widget.rideData['passengerName'] ?? "Passenger",
                                            tripId: rideId,
                                            userId: (widget.rideData['user_id'] ?? widget.rideData['userId'] ?? widget.rideData['passengerId'] ?? "").toString(),
                                            profilePic: widget.rideData['passengerProfilePic']?.toString(),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.message_rounded, color: Color(0xff76eb07)),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xff76eb07).withValues(alpha: 0.1),
                                    padding: const EdgeInsets.all(12),
                                  ),
                                ),
                              ],
                            ),


                            
                            const SizedBox(height: 20),
                            if (!_isArrived)
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.read<RideBloc>().add(
                                      DriverArrivedAtPickupEvent(
                                        rideId: rideId,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff76eb07),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    "I HAVE ARRIVED",
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),

                            if (_isArrived && !_isStarted)
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.read<RideBloc>().add(
                                      StartRideEvent(rideId: rideId),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff76eb07),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    "START RIDE",
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),

                            if (_isStarted && !_isCompleted)
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.read<RideBloc>().add(
                                      CompleteRideEvent(rideId: rideId),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    "COMPLETE RIDE",
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 15),

                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () {
                                  context.read<RideBloc>().add(
                                    CancelRideEvent(rideId: rideId),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.withValues(
                                    alpha: 0.1,
                                  ),
                                  foregroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: const BorderSide(
                                      color: Colors.redAccent,
                                      width: 1,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "CANCEL RIDE",
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
