import 'package:flutter/material.dart';
import 'package:goride_app/core/core.dart';

class AuthFooter extends StatelessWidget {
  const AuthFooter({super.key, required this.isLoginTab, this.onTap});

  final bool isLoginTab;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        text: TextSpan(
          text: isLoginTab
              ? "Don't have an account? "
              : "Already have an account? ",
          style: style(color: Colors.white38, size: 14),
          children: [
            TextSpan(
              text: isLoginTab ? 'Sign Up' : 'Login',
              style: style(color: primaryNeon, fw: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
