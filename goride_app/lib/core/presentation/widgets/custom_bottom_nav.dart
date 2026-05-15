import 'dart:ui';
import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 90,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xff121212).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(1, Icons.confirmation_number_rounded, "Bookings"),
                    _buildNavItem(2, Icons.chat_bubble_outline_rounded, "Chats"),
                    const SizedBox(width: 50),
                    _buildNavItem(3, Icons.account_balance_wallet_rounded, "Wallet"),
                    _buildNavItem(4, Icons.person_rounded, "Profile"),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                color: isActive ? const Color(0xff76eb07) : Colors.white24,
                size: 24,
                shadows: isActive
                    ? [
                        Shadow(
                          color: const Color(0xff76eb07).withValues(alpha: 0.5),
                          blurRadius: 15,
                        )
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            if (isActive)
              Container(
                height: 4,
                width: 4,
                decoration: const BoxDecoration(
                  color: Color(0xff76eb07),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0xff76eb07), blurRadius: 8, spreadRadius: 1)
                  ],
                ),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
