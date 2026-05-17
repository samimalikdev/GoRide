import 'package:flutter/material.dart';

import 'input_field.dart';
import 'options_row.dart';

class FormWidget extends StatelessWidget {
  const FormWidget({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoginTab,
    required this.obscurePassword,
    this.onPressed,
    required this.rememberMe,
    required this.acceptTerms,
    required this.onAcceptTerms,
    required this.onRememberMe,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  final bool isLoginTab;
  final bool obscurePassword;
  final bool rememberMe;
  final bool acceptTerms;
  final VoidCallback? onPressed;
  final VoidCallback onAcceptTerms;
  final VoidCallback onRememberMe;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isLoginTab) ...[
          InputField(
            controller: nameController,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 20),
        ],
        InputField(
          controller: emailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 20),
        InputField(
          controller: passwordController,
          label: 'Password',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          obscureText: obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.white24,
              size: 20,
            ),
            onPressed: onPressed,
          ),
        ),
        if (!isLoginTab) ...[
          const SizedBox(height: 20),
          InputField(
            controller: confirmPasswordController,
            label: 'Confirm Password',
            icon: Icons.lock_reset_rounded,
            isPassword: true,
            obscureText: obscurePassword,
          ),
        ],
        const SizedBox(height: 20),
        OptionsRow(
          isLoginTab: isLoginTab,
          rememberMe: rememberMe,
          acceptTerms: acceptTerms,
          onAcceptTerms: onAcceptTerms,
          onRememberMe: onRememberMe,
        ),
      ],
    );
  }
}
