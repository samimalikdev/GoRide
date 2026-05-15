import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:goride_app/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:goride_app/features/explore/presentation/bloc/explore_event.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/explore_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NearbyDriversPage extends StatelessWidget {
  final List<DriverModel> drivers;
  final LatLng pickupLocation;
  final String? rideId;

  const NearbyDriversPage({
    super.key,
    required this.drivers,
    required this.pickupLocation,
    this.rideId,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xff121212),
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: pickupLocation,
                initialZoom: 14.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: pickupLocation,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xff76eb07),
                        size: 40,
                      ),
                    ),
                    ...drivers.map((driver) => Marker(
                          point: LatLng(driver.lat, driver.lng),
                          width: 50,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xff76eb07), width: 2),
                            ),
                            child: const Icon(Icons.directions_car, color: Colors.white, size: 20),
                          ),
                        )),
                  ],
                ),
              ],
            ),
      
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xff1a1a1a),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xff1a1a1a),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "Searching for Ride",
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xff1a1a1a),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Finding your driver...", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text("Connecting to nearest drivers", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xff76eb07),
                              strokeWidth: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: drivers.length,
                        itemBuilder: (context, index) {
                          final driver = drivers[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xff252525),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: const Color(0xff333333),
                                  backgroundImage: driver.profilePic != null && driver.profilePic!.isNotEmpty
                                      ? NetworkImage(driver.profilePic!)
                                      : null,
                                  child: driver.profilePic == null || driver.profilePic!.isEmpty
                                      ? Text(
                                          driver.name.isNotEmpty ? driver.name[0].toUpperCase() : 'D',
                                          style: GoogleFonts.poppins(color: const Color(0xff76eb07), fontSize: 20, fontWeight: FontWeight.bold),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(driver.name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                                      Text(driver.vehicle, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text(
                                  "2 min away",
                                  style: GoogleFonts.poppins(color: const Color(0xff76eb07), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel Request",
                            style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
