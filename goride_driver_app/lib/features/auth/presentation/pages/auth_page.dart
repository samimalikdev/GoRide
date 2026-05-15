import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:goride_driver_app/features/documents/presentation/pages/document_submission_page.dart';
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
  final Color surfaceColor = const Color(0xff1a1a1a);

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
            MaterialPageRoute(builder: (_) => const DocumentSubmissionPage()),
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
            SnackBar(
              content: Text(state.message, style: GoogleFonts.outfit()),
              backgroundColor: Colors.redAccent,
            ),
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
                physics: const BouncingScrollPhysics(),
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
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: Image.asset('assets/background/logo.png', fit: BoxFit.fill),
        ),
        const SizedBox(height: 20),
        Text(
          _isLoginTab ? 'WELCOME BACK' : 'JOIN THE FLEET',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _isLoginTab
              ? 'Sign in to your driver portal'
              : 'Start your journey with GoRide today',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: Colors.white38,
            fontSize: 15,
            fontWeight: FontWeight.w500,
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
          Expanded(child: _buildTabItem('LOGIN', true)),
          Expanded(child: _buildTabItem('REGISTER', false)),
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? primaryNeon : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.black : Colors.white38,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
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
            label: 'FULL NAME',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 20),
        ],
        _buildInputField(
          controller: _emailController,
          label: 'EMAIL ADDRESS',
          icon: Icons.alternate_email_rounded,
        ),
        const SizedBox(height: 20),
        _buildInputField(
          controller: _passwordController,
          label: 'PASSWORD',
          icon: Icons.lock_rounded,
          isPassword: true,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: Colors.white24,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(
            color: Colors.white24,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
          prefixIcon: Icon(icon, color: primaryNeon, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => setState(() {
            if (_isLoginTab)
              _rememberMe = !_rememberMe;
            else
              _acceptTerms = !_acceptTerms;
          }),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: (_isLoginTab ? _rememberMe : _acceptTerms)
                      ? primaryNeon
                      : Colors.transparent,
                  border: Border.all(
                    color: (_isLoginTab ? _rememberMe : _acceptTerms)
                        ? primaryNeon
                        : Colors.white24,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: (_isLoginTab ? _rememberMe : _acceptTerms)
                    ? const Icon(
                        Icons.check,
                        color: Colors.black,
                        size: 14,
                        fontWeight: FontWeight.bold,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                _isLoginTab ? 'REMEMBER ME' : 'I ACCEPT TERMS',
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        if (_isLoginTab)
          Text(
            'FORGOT?',
            style: GoogleFonts.outfit(
              color: primaryNeon,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        bool isLoading = state is AuthLoading;
        return SizedBox(
          width: double.infinity,
          height: 65,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (_isLoginTab) {
                      context.read<AuthBloc>().add(
                        LoginEvent(
                          email: _emailController.text,
                          password: _passwordController.text,
                        ),
                      );
                    } else {
                      context.read<AuthBloc>().add(
                        SignUpEvent(
                          email: _emailController.text,
                          password: _passwordController.text,
                          fullName: _nameController.text,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryNeon,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    _isLoginTab ? 'LOGIN' : 'CREATE ACCOUNT',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
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
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            'OR CONNECT WITH',
            style: GoogleFonts.outfit(
              color: Colors.white12,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.05))),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      children: [
        Expanded(child: _buildSocialButton(Icons.g_mobiledata_rounded)),
        const SizedBox(width: 15),
        Expanded(child: _buildSocialButton(Icons.apple_rounded)),
        const SizedBox(width: 15),
        Expanded(child: _buildSocialButton(Icons.facebook_rounded)),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Icon(icon, color: Colors.white70, size: 30),
    );
  }

  Widget _buildFooter() {
    return GestureDetector(
      onTap: () => setState(() => _isLoginTab = !_isLoginTab),
      child: RichText(
        text: TextSpan(
          text: _isLoginTab ? "NEW TO GORIDE? " : "ALREADY A PARTNER? ",
          style: GoogleFonts.outfit(
            color: Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          children: [
            TextSpan(
              text: _isLoginTab ? 'REGISTER' : 'LOGIN',
              style: GoogleFonts.outfit(
                color: primaryNeon,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
