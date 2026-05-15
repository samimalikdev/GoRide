import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/explore_models.dart';

class CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryItem({super.key, required this.category, required this.onTap});

  IconData _getIcon(String icon) {
    switch (icon.toLowerCase()) {
      case 'car': return Icons.directions_car_filled_rounded;
      case 'ride': return Icons.directions_car_filled_rounded;
      case 'motorcycle': return Icons.two_wheeler_rounded;
      case 'bike': return Icons.two_wheeler_rounded;
      case 'stars': return Icons.auto_awesome_rounded;
      case 'box': return Icons.inventory_2_rounded;
      case 'courier': return Icons.local_shipping_rounded;
      default: return Icons.directions_car;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xff1a1a1a),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Icon(
              _getIcon(category.name),
              color: const Color(0xff76eb07),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
