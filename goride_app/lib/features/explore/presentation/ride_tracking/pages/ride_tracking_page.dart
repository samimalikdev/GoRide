import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/explore_models.dart';
import '../bloc/ride_tracking_bloc.dart';
import '../bloc/ride_tracking_event.dart';
import '../bloc/ride_tracking_state.dart';
import '../../bloc/explore_bloc.dart';
import '../../bloc/explore_event.dart';
import 'package:goride_app/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:goride_app/features/call/presentation/bloc/call_bloc.dart';
import 'package:goride_app/features/call/presentation/pages/call_page.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:goride_app/injection_container.dart' as di;


class RideTrackingPage extends StatelessWidget {
  final String rideId;
  final DriverModel driver;
  final LatLng pickupLocation;
  final LatLng dropLocation;

  const RideTrackingPage({
    super.key,
    required this.rideId,
    required this.driver,
    required this.pickupLocation,
    required this.dropLocation,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<RideTrackingBloc>()
            ..add(StartTrackingEvent(rideId: rideId, driver: driver)),
      child: RideTrackingView(
        rideId: rideId,
        pickupLocation: pickupLocation,
        dropLocation: dropLocation,
        driver: driver,
      ),
    );
  }
}

class RideTrackingView extends StatefulWidget {
  final String rideId;
  final LatLng pickupLocation;
  final LatLng dropLocation;
  final DriverModel driver;

  const RideTrackingView({
    super.key,
    required this.rideId,
    required this.pickupLocation,
    required this.dropLocation,
    required this.driver,
  });

  @override
  State<RideTrackingView> createState() => _RideTrackingViewState();
}

class _RideTrackingViewState extends State<RideTrackingView> {
  final MapController _mapController = MapController();
  bool _isMapReady = false;

  void _fitMap(LatLng driverPos) {
    if (_isMapReady) {
      final bounds = LatLngBounds.fromPoints([
        widget.pickupLocation,
        widget.dropLocation,
        driverPos,
      ]);

      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(70)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RideTrackingBloc, RideTrackingState>(
      listener: (context, state) {
        if (state is RideTrackingActive) {
          _fitMap(state.driverPosition);
          if (state.hasArrived && !state.isStarted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Your driver is here!"),
                backgroundColor: Color(0xff76eb07),
              ),
            );
          }
          
          if (state.isCompleted) {
            Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == 'RideTrackingPage');
            _showCompletionDialog(context, state.fare);
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xff121212),
        body: Stack(
          children: [
            BlocBuilder<RideTrackingBloc, RideTrackingState>(
              builder: (context, state) {
                LatLng currentDriverPos = LatLng(
                  widget.driver.lat,
                  widget.driver.lng,
                );
                if (state is RideTrackingActive) {
                  currentDriverPos = state.driverPosition;
                }

                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: widget.pickupLocation,
                    initialZoom: 14.0,
                    onMapReady: () => _isMapReady = true,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.example.goride_app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [widget.pickupLocation, widget.dropLocation],
                          strokeWidth: 4.0,
                          color: const Color(0xff76eb07).withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: widget.pickupLocation,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Color(0xff76eb07),
                            size: 30,
                          ),
                        ),
                        Marker(
                          point: widget.dropLocation,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.flag,
                            color: Colors.redAccent,
                            size: 30,
                          ),
                        ),
                        Marker(
                          point: currentDriverPos,
                          width: 60,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xff76eb07),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.directions_car,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: BlocBuilder<RideTrackingBloc, RideTrackingState>(
                builder: (context, state) {
                  String message = "Waiting for driver...";
                  if (state is RideTrackingActive) {
                    message = state.statusMessage;
                  }

                  return Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xff1a1a1a),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Color(0xff76eb07),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          message,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Color(0xff1a1a1a),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xff252525),
                          backgroundImage: widget.driver.profilePic != null && widget.driver.profilePic!.isNotEmpty
                              ? NetworkImage(widget.driver.profilePic!)
                              : null,
                          child: widget.driver.profilePic == null || widget.driver.profilePic!.isEmpty
                              ? Text(
                                  widget.driver.name.isNotEmpty ? widget.driver.name[0].toUpperCase() : 'D',
                                  style: GoogleFonts.poppins(color: const Color(0xff76eb07), fontSize: 24, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.driver.name,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.driver.vehicle,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xff76eb07,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Color(0xff76eb07),
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "4.8",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: BlocBuilder<RideTrackingBloc, RideTrackingState>(
                            builder: (context, state) {
                              final isCompleted = state is RideTrackingActive && state.isCompleted;
                              return ElevatedButton.icon(
                                onPressed: isCompleted ? null : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MultiBlocProvider(
                                        providers: [
                                          BlocProvider.value(value: context.read<RideTrackingBloc>()),
                                          BlocProvider.value(value: context.read<ExploreBloc>()),
                                        ],
                                        child: ChatDetailPage(
                                          userName: widget.driver.name,
                                          vehicle: widget.driver.vehicle,
                                          receiverId: widget.driver.id.toString(),
                                          profilePic: widget.driver.profilePic,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat),
                                label: const Text("Message"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff252525),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: BlocBuilder<RideTrackingBloc, RideTrackingState>(
                            builder: (context, state) {
                              final isCompleted = state is RideTrackingActive && state.isCompleted;
                              return ElevatedButton.icon(
                                onPressed: isCompleted ? null : () {
                                  final authState = context.read<AuthBloc>().state;
                                  final userName = authState.currentUser?.fullName;
                                  context.read<CallBloc>().add(StartCallEvent(
                                    widget.driver.id.toString(), 
                                    name: userName,
                                  ));
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MultiBlocProvider(
                                        providers: [
                                          BlocProvider.value(value: context.read<RideTrackingBloc>()),
                                          BlocProvider.value(value: context.read<ExploreBloc>()),
                                        ],
                                        child: const CallPage(),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.phone),
                                label: const Text("Call"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff76eb07),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xff1a1a1a),
                              title: const Text(
                                "Cancel Ride",
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                "Are you sure you want to cancel this ride?",
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("NO"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context.read<ExploreBloc>().add(
                                      UserCancelRideEvent(
                                        rideId: widget.rideId,
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "YES, CANCEL",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          "CANCEL RIDE",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, double fare) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: const Color(0xff1a1a1a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xff76eb07), size: 80),
            const SizedBox(height: 20),
            Text(
              "RIDE COMPLETED!",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Fare: Rs. ${fare.toStringAsFixed(2)}",
              style: GoogleFonts.outfit(
                color: const Color(0xff76eb07),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Paid via Wallet",
              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Text(
              "We hope you enjoyed your ride with GoRide.",
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff76eb07),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "BACK TO HOME",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
