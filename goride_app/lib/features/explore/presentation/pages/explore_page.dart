import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:goride_app/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:goride_app/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:goride_app/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'location_picker_page.dart';
import 'nearby_drivers_page.dart';
import '../widgets/home_top_curve_clipper.dart';
import '../widgets/vector_map_painter.dart';
import '../widgets/route_painter.dart';
import '../widgets/map_marker.dart';
import '../bloc/explore_bloc.dart';
import '../bloc/explore_event.dart';
import '../bloc/explore_state.dart';
import '../bloc/explore_models.dart';
import '../ride_tracking/pages/ride_tracking_page.dart';


class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  int _selectedRideIndex = 0;
  String _pickupAddress = "Select Pickup Location";
  String _dropAddress = "Select Drop Destination";
  double? _pickupLat;
  double? _pickupLng;
  double? _dropLat;
  double? _dropLng;
  bool _isProposedDialogShowing = false;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    context.read<ExploreBloc>().add(const GetExploreDataEvent());
    context.read<ExploreBloc>().add(const CheckActiveRideEvent());
    final userId = context.read<AuthBloc>().state.currentUser?.id;
    if (userId != null) {
      context.read<WalletBloc>().add(FetchWalletData(userId: userId));
    }
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isLoadingLocation = false;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _pickupLat = position.latitude;
          _pickupLng = position.longitude;
        });
        context.read<ExploreBloc>().add(GetExploreDataEvent(
          lat: position.latitude,
          lng: position.longitude,
        ));
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks[0];
        String addr = "${place.street}, ${place.subLocality ?? ''}, ${place.locality}";
        addr = addr.replaceAll(", ,", ",").replaceAll(RegExp(r'^,\s*'), '');
        setState(() {
          if (_pickupAddress == "Select Pickup Location") {
            _pickupAddress = addr;
          }
        });
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExploreBloc, ExploreState>(
      listener: (context, state) {
        if (state is RideRequestSuccess) {
          if (Navigator.canPop(context)) Navigator.pop(context);
          if (state.drivers.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No drivers available in your area")),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NearbyDriversPage(
                  drivers: state.drivers,
                  pickupLocation: LatLng(_pickupLat ?? 0, _pickupLng ?? 0),
                  rideId: state.rideId,
                ),
              ),
            );
          }
        } else if (state is RideProposed) {
          _showDriverConfirmationDialog(context, state.driver, state.rideId);
        } else if (state is RideAccepted) {
          if (_isProposedDialogShowing) {
            Navigator.pop(context);
            _isProposedDialogShowing = false;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RideTrackingPage(
                rideId: state.rideId,
                driver: state.driver,
                pickupLocation: state.pickupLocation,
                dropLocation: state.dropLocation,
              ),
            ),
          );
        } else if (state is RideRequestError) {
          if (Navigator.canPop(context)) Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is RideCancelled) {
          print("EXPLORE_PAGE: RideCancelled state received in listener!");
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
          context.read<ExploreBloc>().add(const GetExploreDataEvent());
        }
      },
      child: BlocBuilder<ExploreBloc, ExploreState>(
        buildWhen: (previous, current) =>
            current is ExploreLoading ||
            current is ExploreLoaded ||
            current is ExploreError,
        builder: (context, state) {
          if (state is ExploreLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xff76eb07)));
          } else if (state is ExploreError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
          } else if (state is ExploreLoaded) {
            final data = state.data;
            return Stack(
              children: [
                _buildTopBackground(context),
                SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<ExploreBloc>().add(GetExploreDataEvent(
                        lat: _pickupLat,
                        lng: _pickupLng,
                      ));
                    },
                    color: const Color(0xff76eb07),
                    backgroundColor: const Color(0xff1a1a1a),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(data),
                          const SizedBox(height: 25),
                          _buildLocationPill(),
                          const SizedBox(height: 30),
                          _buildMainBookingCard(data),
                          const SizedBox(height: 30),
                          _buildRideOptions(data.categories),
                          const SizedBox(height: 25),
                          _buildMapPreview(),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildTopBackground(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height * 0.45,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff76eb07),
              ),
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/background/IMg.png',
                  fit: BoxFit.cover,
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: HomeTopCurveClipper(),
              child: Container(
                height: 120,
                color: const Color(0xff0a0a0a),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ExploreData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  String balance = "Rs. 0";
                  if (state is WalletLoaded) {
                    balance = "Rs. ${state.balance.toStringAsFixed(0)}";
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet_rounded, color: Colors.black, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          balance,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Row(
                children: [
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final user = state.currentUser;
                      final profilePic = user?.profilePic;
                      final name = user?.fullName ?? "User";
                      return Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey,
                          backgroundImage: profilePic != null && profilePic.isNotEmpty
                              ? NetworkImage(profilePic)
                              : null,
                          child: profilePic == null || profilePic.isEmpty
                              ? Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            "${data.greeting}, ${data.userName}",
            style: GoogleFonts.poppins(
              color: Colors.black.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "Where are you going?",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPill() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.my_location_rounded, color: Colors.black, size: 18),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              _isLoadingLocation
                  ? "Fetching current location..."
                  : (_pickupAddress == "Select Pickup Location"
                      ? "Current Location"
                      : _pickupAddress),
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainBookingCard(ExploreData data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LocationPickerPage(title: "Select Pickup")),
                    );
                    if (result != null) {
                      setState(() {
                        _pickupAddress = result['address'];
                        final latLng = result['location'] as LatLng;
                        _pickupLat = latLng.latitude;
                        _pickupLng = latLng.longitude;
                      });
                    }
                  },
                  child: _buildInputRow(
                    icon: Icons.circle,
                    iconColor: const Color(0xff76eb07),
                    hint: _pickupAddress,
                    rightIcon: Icons.gps_fixed_rounded,
                    isPlaceholder: _pickupAddress == "Select Pickup Location",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 30,
                      width: 1.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [const Color(0xff76eb07), Colors.white.withValues(alpha: 0.2)],
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LocationPickerPage(title: "Select Destination")),
                    );
                    if (result != null) {
                      setState(() {
                        _dropAddress = result['address'];
                        final latLng = result['location'] as LatLng;
                        _dropLat = latLng.latitude;
                        _dropLng = latLng.longitude;
                      });
                    }
                  },
                  child: _buildInputRow(
                    icon: Icons.panorama_fish_eye_rounded,
                    iconColor: Colors.white38,
                    hint: _dropAddress,
                    rightIcon: Icons.add_rounded,
                    isPlaceholder: _dropAddress == "Select Drop Destination",
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff76eb07),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: const Color(0xff76eb07).withValues(alpha: 0.5),
                    ),
                    onPressed: () {
                      final authState = context.read<AuthBloc>().state;
                      final userId = authState.currentUser?.id;

                      if (userId != null) {
                        context.read<ExploreBloc>().add(
                          RequestRideEvent(
                            userId: userId,
                            pickupLocation: _pickupAddress,
                            dropLocation: _dropAddress,
                            category: data.categories[_selectedRideIndex].name,
                            fare: 250.0,
                            pickupLatitude: _pickupLat,
                            pickupLongitude: _pickupLng,
                            dropLatitude: _dropLat,
                            dropLongitude: _dropLng,
                          ),
                        );
                        _showSearchingSheet(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please login to request a ride")),
                        );
                      }
                    },
                    child: Text(
                      "Find Ride",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSearchingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Color(0xff0a0a0a),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(25),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Searching for Rides",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Connecting you to the nearest drivers...",
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              const Center(
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xff76eb07),
                        strokeWidth: 2,
                      ),
                      Icon(Icons.directions_car_filled_rounded, color: Color(0xff76eb07), size: 50),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text(
                    "Cancel Request",
                    style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputRow({
    required IconData icon,
    required Color iconColor,
    required String hint,
    required IconData rightIcon,
    bool isPlaceholder = true,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            hint,
            style: GoogleFonts.poppins(
              color: isPlaceholder ? Colors.white38 : Colors.white,
              fontSize: 15,
              fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(rightIcon, color: Colors.white38, size: 22),
      ],
    );
  }

  Widget _buildRideOptions(List<CategoryModel> categories) {
    return SizedBox(
      height: 125,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedRideIndex == index;
          final category = categories[index];

          IconData getIcon(String name) {
            switch (name.toLowerCase()) {
              case 'ride': return Icons.directions_car_filled_rounded;
              case 'bike': return Icons.two_wheeler_rounded;
              case 'luxury': return Icons.electric_car_rounded;
              case 'courier': return Icons.local_shipping_rounded;
              default: return Icons.directions_car_rounded;
            }
          }

          return GestureDetector(
            onTap: () => setState(() => _selectedRideIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 105,
              margin: const EdgeInsets.only(right: 15, bottom: 5),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xff76eb07).withValues(alpha: 0.1) : const Color(0xff1a1a1a),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xff76eb07) : Colors.white.withValues(alpha: 0.05),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? const Color(0xff76eb07).withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2),
                    blurRadius: isSelected ? 15 : 5,
                    spreadRadius: isSelected ? 2 : 0,
                  )
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      getIcon(category.name),
                      color: isSelected ? const Color(0xff76eb07) : Colors.white70,
                      size: 32,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      category.name,
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildMapPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xff0d0d0d),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xff76eb07).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff76eb07).withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: VectorMapPainter()),
            ),
            Positioned.fill(
              child: CustomPaint(painter: RoutePainter()),
            ),
            _buildLandmark(top: 40, left: 120, label: "Downtown"),
            _buildLandmark(bottom: 60, right: 40, label: "Airport"),
            const Positioned(
              top: 45,
              left: 55,
              child: MapMarker(color: Colors.blue, isStart: true),
            ),
            const Positioned(
              bottom: 45,
              right: 75,
              child: MapMarker(color: Color(0xff76eb07), isStart: false),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.5, 1],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandmark({double? top, double? left, double? right, double? bottom, required String label}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          color: Colors.white12,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }

  void _showDriverConfirmationDialog(BuildContext context, DriverModel driver, String rideId) {
    if (_isProposedDialogShowing) return;
    _isProposedDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1a1a1a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Driver Found", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40, 
              backgroundColor: const Color(0xff252525), 
              backgroundImage: driver.profilePic != null && driver.profilePic!.isNotEmpty
                  ? NetworkImage(driver.profilePic!)
                  : null,
              child: driver.profilePic == null || driver.profilePic!.isEmpty
                  ? Text(
                      driver.name.isNotEmpty ? driver.name[0].toUpperCase() : 'D',
                      style: GoogleFonts.poppins(color: const Color(0xff76eb07), fontSize: 32, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(height: 15),
            Text(driver.name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(driver.vehicle, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 20),
            Text("Do you want to accept this ride?", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _isProposedDialogShowing = false;
              Navigator.pop(context);
              context.read<ExploreBloc>().add(RejectDriverEvent(rideId: rideId));
            },
            child: Text("REJECT", style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              _isProposedDialogShowing = false;
              Navigator.pop(context);
              context.read<ExploreBloc>().add(ConfirmRideEvent(rideId: rideId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff76eb07), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text("ACCEPT", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
