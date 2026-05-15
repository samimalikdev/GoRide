import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:goride_driver_app/features/home/presentation/pages/active_ride_page.dart';
import 'package:goride_driver_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:goride_driver_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/home_event.dart';
import 'package:goride_driver_app/features/home/presentation/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:goride_driver_app/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:goride_driver_app/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:goride_driver_app/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:goride_driver_app/features/wallet/presentation/pages/wallet_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LatLng _currentLocation = const LatLng(31.5204, 74.3587); 
  bool _isRideRequestShowing = false;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(InitSocketEvent());
    context.read<HomeBloc>().add(CheckActiveRideEvent());
    
    final authState = context.read<AuthBloc>().state;
    if (authState.userId.isNotEmpty) {
      context.read<WalletBloc>().add(FetchWalletData(authState.userId));
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _toggleOnline(bool val) async {
    double? lat;
    double? lng;

    if (val) {
      final position = await _getCurrentLocation();
      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
        setState(() => _currentLocation = LatLng(lat!, lng!));
      }
    }

    if (!mounted) return;
    context.read<HomeBloc>().add(ToggleOnlineEvent(
      isOnline: val,
      lat: lat,
      lng: lng,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.read<HomeBloc>().add(InitSocketEvent());
              context.read<WalletBloc>().add(FetchWalletData(state.userId));
            }
          },
        ),
        BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeRideAccepted) {
              if (_isRideRequestShowing) {
                Navigator.pop(context); 
                _isRideRequestShowing = false;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActiveRidePage(rideData: state.rideData),
                ),
              );
            }
            if (state is HomeRideCancelled) {
              if (_isRideRequestShowing) {
                Navigator.pop(context); 
                _isRideRequestShowing = false;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is HomeNewRideRequest) {
              _showRideRequestPopup(state.rideData);
            } else if (state is HomeError) {
              if (_isRideRequestShowing) {
                Navigator.pop(context);
                _isRideRequestShowing = false;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          bool isOnline = state.isOnline;
          bool isLoading = state is HomeLoading;
          final walletState = context.watch<WalletBloc>().state;
          double balance = 0.0;
          if (walletState is WalletLoaded) {
            balance = walletState.balance;
          }

          return Scaffold(
            backgroundColor: const Color(0xff0a0a0a),
            body: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _currentLocation,
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.goride.driver.goride_driver_app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLocation,
                          width: 60,
                          height: 60,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xff76eb07).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Icon(
                                Icons.navigation_rounded,
                                color: Color(0xff76eb07),
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WalletPage()),
                        ),
                        child: _buildStatCard("Balance", "Rs. ${balance.toStringAsFixed(0)}", Icons.account_balance_wallet_rounded),
                      ),
                    ],
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    decoration: const BoxDecoration(
                      color: Color(0xff1a1a1a),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                      boxShadow: [
                        BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 25),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isOnline ? "YOU ARE ONLINE" : "YOU ARE OFFLINE",
                                  style: GoogleFonts.outfit(
                                    color: isOnline ? const Color(0xff76eb07) : Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isOnline ? "Waiting for requests..." : "Go online to start earning",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white38,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: isOnline,
                              onChanged: isLoading ? null : (val) => _toggleOnline(val),
                              activeColor: const Color(0xff76eb07),
                              activeTrackColor: const Color(0xff76eb07).withValues(alpha: 0.2),
                              inactiveThumbColor: Colors.grey,
                              inactiveTrackColor: Colors.white10,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        Row(
                          children: [
                            Expanded(child: _buildEarningItem("Today's Earnings", "Rs. ${balance.toStringAsFixed(0)}", Icons.payments_rounded)),
                          ],
                        ),
                        
                        const SizedBox(height: 25),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 65,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () => _toggleOnline(!isOnline),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isOnline ? Colors.red.withValues(alpha: 0.1) : const Color(0xff76eb07),
                              foregroundColor: isOnline ? Colors.redAccent : Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: isOnline ? const BorderSide(color: Colors.redAccent, width: 1) : null,
                              elevation: 0,
                            ),
                            child: isLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(
                              isOnline ? "STOP WORKING" : "GO ONLINE",
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 110),
                      ],
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

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xff1a1a1a),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff76eb07), size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff262626),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xff76eb07).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xff76eb07), size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w500)),
              Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  void _showRideRequestPopup(Map<String, dynamic> rideData) {
    if (_isRideRequestShowing) return;
    _isRideRequestShowing = true;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Ride Request",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 450,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xff1a1a1a),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: const Color(0xff76eb07).withValues(alpha: 0.3), width: 2),
                boxShadow: [
                  BoxShadow(color: const Color(0xff76eb07).withValues(alpha: 0.1), blurRadius: 30, spreadRadius: 10),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xff76eb07).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "NEW RIDE REQUEST",
                            style: GoogleFonts.outfit(color: const Color(0xff76eb07), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                        ),
                        Text(
                          "Within 5km",
                          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white10,
                          backgroundImage: (rideData['passengerProfilePic'] != null && rideData['passengerProfilePic'].toString().isNotEmpty)
                              ? NetworkImage(rideData['passengerProfilePic'])
                              : null,
                          child: (rideData['passengerProfilePic'] == null || rideData['passengerProfilePic'].toString().isEmpty)
                              ? const Icon(Icons.person, color: Colors.white, size: 20)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("RIDER", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900)),
                            Text(
                              rideData['passengerName'] ?? "Passenger",
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: Color(0xff76eb07), size: 30),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("PICKUP LOCATION", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900)),
                              Text(
                                rideData['pickupLocation'] ?? rideData['pickup_location'] ?? rideData['pickup'] ?? "Unknown Location",
                                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 25),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ESTIMATED FARE", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w900)),
                            Text(
                              "Rs. ${rideData['fare'] ?? 0}",
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle),
                          child: const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 30),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionBtn("DECLINE", Colors.transparent, Colors.white70, true, () {
                            if (context.read<HomeBloc>().state is HomeLoading) return;
                            _isRideRequestShowing = false;
                            Navigator.pop(context);
                          }),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: BlocBuilder<HomeBloc, HomeState>(
                            builder: (context, state) {
                              final isAccepting = state is HomeLoading;
                              final isWaiting = state is HomeWaitingForConfirmation;
                              
                              return _buildActionBtn(
                                isAccepting ? "ACCEPTING..." : (isWaiting ? "WAITING..." : "ACCEPT"), 
                                const Color(0xff76eb07), 
                                Colors.black, 
                                false, 
                                (isAccepting || isWaiting) ? () {} : () {
                                  final rId = rideData['rideId'] ?? rideData['id'] ?? rideData['_id'] ?? "";
                                  context.read<HomeBloc>().add(AcceptRideEvent(rideId: rId.toString()));
                                }
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionBtn(String label, Color bg, Color text, bool isOutline, VoidCallback onTap) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: text,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: isOutline ? BorderSide(color: Colors.white.withValues(alpha: 0.1)) : null,
        ),
        child: Text(label, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }
}
