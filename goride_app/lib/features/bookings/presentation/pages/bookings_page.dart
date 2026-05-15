import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';
import '../bloc/bookings_state.dart';
import '../../../explore/presentation/ride_tracking/pages/ride_tracking_page.dart';
import '../../data/models/booking_model.dart';

import 'package:latlong2/latlong.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookingsBloc>().add(FetchBookingsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0a0a0a),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "My Bookings",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              BlocBuilder<BookingsBloc, BookingsState>(
                builder: (context, state) {
                  String activeTab = 'Active';
                  if (state is BookingsLoaded) activeTab = state.activeTab;
                  return _buildBookingTabs(activeTab);
                },
              ),
              const SizedBox(height: 25),
              Expanded(
                child: BlocBuilder<BookingsBloc, BookingsState>(
                  builder: (context, state) {
                    if (state is BookingsLoading) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xff76eb07)));
                    } else if (state is BookingsError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                            const SizedBox(height: 16),
                            Text(state.message, style: GoogleFonts.poppins(color: Colors.white70)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<BookingsBloc>().add(FetchBookingsEvent()),
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      );
                    } else if (state is BookingsLoaded) {
                      if (state.filteredBookings.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.history_rounded, color: Colors.white10, size: 80),
                              const SizedBox(height: 20),
                              Text(
                                "No ${state.activeTab} bookings found",
                                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<BookingsBloc>().add(FetchBookingsEvent());
                        },
                        color: const Color(0xff76eb07),
                        backgroundColor: const Color(0xff1a1a1a),
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: state.filteredBookings.length,
                          itemBuilder: (context, index) {
                            final booking = state.filteredBookings[index];
                            return _buildBookingCard(booking);
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingTabs(String activeTab) {
    return Row(
      children: [
        _buildTab("Active", activeTab == "Active"),
        const SizedBox(width: 15),
        _buildTab("Completed", activeTab == "Completed"),
        const SizedBox(width: 15),
        _buildTab("Cancelled", activeTab == "Cancelled"),
      ],
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => context.read<BookingsBloc>().add(ChangeBookingTabEvent(label)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff76eb07) : const Color(0xff1a1a1a),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.black : Colors.white60,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    bool isActive = ['pending', 'driver_assigned', 'accepted', 'driver_arrived', 'started'].contains(booking.status);
    
    Color statusColor;
    String statusText = booking.status.toUpperCase().replaceAll('_', ' ');
    
    switch (booking.status) {
      case 'completed':
        statusColor = Colors.white38;
        break;
      case 'cancelled':
        statusColor = Colors.redAccent;
        break;
      case 'pending':
        statusColor = Colors.amber;
        break;
      default:
        statusColor = const Color(0xff76eb07);
    }

    IconData getIcon(String category) {
      switch (category.toLowerCase()) {
        case 'ride': return Icons.directions_car_filled_rounded;
        case 'bike': return Icons.two_wheeler_rounded;
        case 'luxury': return Icons.electric_car_rounded;
        case 'courier': return Icons.local_shipping_rounded;
        default: return Icons.directions_car_rounded;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1a1a1a),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isActive ? const Color(0xff76eb07).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(getIcon(booking.category), color: const Color(0xff76eb07), size: 24),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.category,
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      Text(
                        booking.formattedDate,
                        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.poppins(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, color: Color(0xff76eb07), size: 8),
                  Container(height: 20, width: 1, color: Colors.white10),
                  const Icon(Icons.location_on, color: Colors.white38, size: 10),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.pickupLocation, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),
                    Text(booking.dropLocation, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Text(
                "Rs. ${booking.fare.toInt()}",
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
          if (isActive && booking.driver != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff76eb07),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RideTrackingPage(
                        rideId: booking.id,
                        driver: booking.driver!,
                        pickupLocation: LatLng(booking.pickupLat, booking.pickupLng),
                        dropLocation: LatLng(booking.dropLat, booking.dropLng),
                      ),
                    ),
                  );
                },
                child: Text("Track Ride", style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }

}
