import 'package:flutter/material.dart';
import 'package:goride_app/core/core.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.suffixIcon,
    this.isPassword = false,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: style(color: Colors.white, size: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: style(color: Colors.white24, size: 14),
          prefixIcon: Icon(
            icon,
            color: primaryNeon.withValues(alpha: 0.7),
            size: 20,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
