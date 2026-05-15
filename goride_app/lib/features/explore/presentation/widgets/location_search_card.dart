import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationSearchCard extends StatelessWidget {
  final Function(double lat, double lng) onLocationSelected;

  const LocationSearchCard({super.key, required this.onLocationSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onLocationSelected(31.5691, 74.3824);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Colors.black54, size: 22),
            const SizedBox(width: 12),
            Text(
              "Where are you going?",
              style: GoogleFonts.poppins(
                color: Colors.black54,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
