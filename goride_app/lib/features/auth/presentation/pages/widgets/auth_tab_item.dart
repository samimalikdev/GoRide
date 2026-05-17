import 'package:flutter/material.dart';
import 'package:goride_app/core/core.dart';

class AuthTabItem extends StatelessWidget {
  const AuthTabItem({
    super.key,
    required this.title,
    this.isLogin = true,
    this.isLoginTab = true,
    required this.onTap,
  });

  final String title;
  final bool isLogin;
  final bool isLoginTab;
  final ValueChanged<bool> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = isLoginTab == isLogin;
    return GestureDetector(
      onTap: () => onTap(isLogin),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryNeon : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryNeon.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: style(
            color: isSelected ? Colors.black : Colors.white38,
            size: 15,
            fw: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
