import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../injection_container.dart' as di;
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

  final Color primaryNeon = const Color(0xff76eb07);
  final Color backgroundColor = const Color(0xff0a0a0a);
  final Color surfaceColor = const Color(0xff121212);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
                    _buildHeader(),
                    const SizedBox(height: 50),
                    _buildTabSelector(),
                    const SizedBox(height: 40),
                    _buildForm(),
                    const SizedBox(height: 30),
                    _buildSubmitButton(),
                    const SizedBox(height: 30),
                    _buildDivider(),
                    const SizedBox(height: 30),
                    _buildSocialLogin(),
                    const SizedBox(height: 40),
                    _buildFooter(),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
           
          ),
          child: Image.asset('assets/background/logo.png', fit: BoxFit.fill,),
        ),
        const SizedBox(height: 10),
        Text(
          _isLoginTab ? 'Welcome Back' : 'Create Account',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _isLoginTab ? 'Sign in to your GoRide account' : 'Join the future of urban mobility',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white38,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabItem('Login', true)),
          Expanded(child: _buildTabItem('Sign Up', false)),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, bool isLogin) {
    bool isSelected = _isLoginTab == isLogin;
    return GestureDetector(
      onTap: () => setState(() => _isLoginTab = isLogin),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryNeon : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? [BoxShadow(color: primaryNeon.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1)]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.black : Colors.white38,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        if (!_isLoginTab) ...[
          _buildInputField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 20),
        ],
        _buildInputField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 20),
        _buildInputField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.white24,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        if (!_isLoginTab) ...[
          const SizedBox(height: 20),
          _buildInputField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            icon: Icons.lock_reset_rounded,
            isPassword: true,
            obscureText: _obscurePassword,
          ),
        ],
        const SizedBox(height: 20),
        _buildOptionsRow(),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.white24, fontSize: 14),
          prefixIcon: Icon(icon, color: primaryNeon.withValues(alpha: 0.7), size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildOptionsRow() {
    if (_isLoginTab) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => setState(() => _rememberMe = !_rememberMe),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _rememberMe ? primaryNeon : Colors.transparent,
                    border: Border.all(color: _rememberMe ? primaryNeon : Colors.white24),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _rememberMe ? const Icon(Icons.check, color: Colors.black, size: 14) : null,
                ),
                const SizedBox(width: 10),
                Text(
                  'Remember me',
                  style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            'Forgot Password?',
            style: GoogleFonts.poppins(color: primaryNeon, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      );
    } else {
      return GestureDetector(
        onTap: () => setState(() => _acceptTerms = !_acceptTerms),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _acceptTerms ? primaryNeon : Colors.transparent,
                border: Border.all(color: _acceptTerms ? primaryNeon : Colors.white24),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _acceptTerms ? const Icon(Icons.check, color: Colors.black, size: 14) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'I agree to the Terms of Service and Privacy Policy',
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        bool isLoading = state is AuthLoading;
        return Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryNeon.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : () {
              if (_isLoginTab) {
                context.read<AuthBloc>().add(LoginEvent(
                  email: _emailController.text,
                  password: _passwordController.text,
                ));
              } else {
                if (_passwordController.text != _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
                  );
                  return;
                }
                context.read<AuthBloc>().add(SignUpEvent(
                  email: _emailController.text,
                  password: _passwordController.text,
                  fullName: _nameController.text,
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryNeon,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : Text(
                    _isLoginTab ? 'Login' : 'Create Account',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.05))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR CONTINUE WITH',
            style: GoogleFonts.poppins(color: Colors.white12, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.05))),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      children: [
        Expanded(child: _buildSocialButton(Icons.g_mobiledata_rounded, 'Google')),
        const SizedBox(width: 16),
        Expanded(child: _buildSocialButton(Icons.apple_rounded, 'Apple')),
        const SizedBox(width: 16),
        Expanded(child: _buildSocialButton(Icons.facebook_rounded, 'Facebook')),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: Colors.white70, size: 28),
      ),
    );
  }

  Widget _buildFooter() {
    return GestureDetector(
      onTap: () => setState(() => _isLoginTab = !_isLoginTab),
      child: RichText(
        text: TextSpan(
          text: _isLoginTab ? "Don't have an account? " : "Already have an account? ",
          style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
          children: [
            TextSpan(
              text: _isLoginTab ? 'Sign Up' : 'Login',
              style: GoogleFonts.poppins(color: primaryNeon, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
