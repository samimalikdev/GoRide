import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goride_app/core/core.dart';

import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.isLoginTab,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nameController,
  });

  final bool isLoginTab;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        bool isLoading = state is AuthLoading;
        return Container(
          width: .infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: .circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryNeon.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (isLoginTab) {
                      context.read<AuthBloc>().add(
                        LoginEvent(
                          email: emailController.text,
                          password: passwordController.text,
                        ),
                      );
                    } else {
                      if (passwordController.text !=
                          confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Passwords do not match'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      context.read<AuthBloc>().add(
                        SignUpEvent(
                          email: emailController.text,
                          password: passwordController.text,
                          fullName: nameController.text,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryNeon,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: .circular(20)),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    isLoginTab ? 'Login' : 'Create Account',
                    style: style(size: 16, fw: .w700),
                  ),
          ),
        );
      },
    );
  }
}
