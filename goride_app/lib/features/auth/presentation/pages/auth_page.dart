import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goride_app/core/constants/app_colors.dart';
import 'widgets/widgets.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'mfa_page.dart';
import 'mfa_setup_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoginTab = true;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _acceptTerms = false;


  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else if (state is AuthMfaRequired) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MfaPage(
                factorId: state.factorId,
                challengeId: state.challengeId,
              ),
            ),
          );
        } else if (state is AuthMfaSetupRequired) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MfaSetupPage(
                qrCode: state.qrCode,
                secret: state.secret,
                factorId: state.factorId,
                challengeId: state.challengeId,
              ),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryNeon.withValues(alpha: 0.05),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    AuthHeader(isLoginTab: _isLoginTab),
                    const SizedBox(height: 50),
                    AuthTabSelector(
                      isLoginTab: _isLoginTab,
                      onTap: (value) => setState(() => _isLoginTab = value),
                    ),
                    const SizedBox(height: 40),
                    FormWidget(
                      nameController: _nameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      isLoginTab: _isLoginTab,
                      obscurePassword: _obscurePassword,
                      rememberMe: _rememberMe,
                      acceptTerms: _acceptTerms,
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onAcceptTerms: () =>
                          setState(() => _acceptTerms = !_acceptTerms),
                      onRememberMe: () =>
                          setState(() => _rememberMe = !_rememberMe),
                    ),
                    const SizedBox(height: 30),
                    AuthSubmitButton(
                      isLoginTab: _isLoginTab,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      nameController: _nameController,
                    ),
                    const SizedBox(height: 30),
                    const AuthDivider(),
                    const SizedBox(height: 30),
                    const SocialLoginWidget(),
                    const SizedBox(height: 40),
                    AuthFooter(
                      isLoginTab: _isLoginTab,
                      onTap: () => setState(() => _isLoginTab = !_isLoginTab),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
