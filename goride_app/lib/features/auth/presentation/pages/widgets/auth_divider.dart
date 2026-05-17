import 'package:flutter/material.dart';
import 'package:goride_app/core/constants/constants.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.05))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR CONTINUE WITH',
            style: style(
              color: Colors.white12,
              size: 10,
              fw: FontWeight.w800,
            ).copyWith(letterSpacing: 1),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.05))),
      ],
    );
  }
}
