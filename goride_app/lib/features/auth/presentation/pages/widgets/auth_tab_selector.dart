import 'package:flutter/material.dart';
import 'package:goride_app/core/constances/app_colors.dart';

import 'auth_tab_item.dart';

class AuthTabSelector extends StatelessWidget {
  const AuthTabSelector({
    super.key,
    this.isLoginTab = true,
    required this.onTap,
  });

  final bool isLoginTab;
  final ValueChanged<bool> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AuthTabItem(
              title: 'Login',
              isLoginTab: isLoginTab,
              onTap: onTap,
            ),
          ),
          Expanded(
            child: AuthTabItem(
              title: 'Sign Up',
              isLogin: false,
              isLoginTab: isLoginTab,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
