import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/explore_models.dart';

class PromoCard extends StatelessWidget {
  final PromoModel promo;

  const PromoCard({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff1a1a1a), Color(0xff252525)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xff76eb07).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo.title,
                  style: GoogleFonts.poppins(
                    color: const Color(0xff76eb07),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  promo.subtitle,
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xff76eb07).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xff76eb07).withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    promo.code,
                    style: GoogleFonts.poppins(
                      color: const Color(0xff76eb07),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.local_offer_rounded, color: Color(0xff76eb07), size: 50),
        ],
      ),
    );
  }
}
