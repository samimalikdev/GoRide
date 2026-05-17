import 'package:flutter/material.dart';
import 'package:goride_app/core/core.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.isLoginTab});

  final bool isLoginTab;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: Image.asset(Assets.logo, fit: BoxFit.fill),
        ),
        const SizedBox(height: 10),
        Text(
          isLoginTab ? 'Welcome Back' : 'Create Account',
          style: style(
            color: Colors.white,
            size: 32,
            fw: FontWeight.w800,
          ).copyWith(letterSpacing: -1),
        ),
        const SizedBox(height: 10),
        Text(
          isLoginTab
              ? 'Sign in to your GoRide account'
              : 'Join the future of urban mobility',
          textAlign: TextAlign.center,
          style: style(color: Colors.white38, size: 15, fw: FontWeight.w400),
        ),
      ],
    );
  }
}
