import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:goride_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:goride_app/features/auth/presentation/pages/auth_page.dart';
import 'package:goride_app/features/auth/presentation/pages/mfa_setup_page.dart';
import 'package:goride_app/features/profile/presentation/pages/mfa_settings_page.dart';
import 'package:goride_app/features/profile/presentation/pages/about_app_page.dart';
import 'package:goride_app/features/profile/presentation/pages/manage_profile_page.dart';
import 'package:goride_app/features/profile/presentation/pages/support_and_help_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthPage()),
            (route) => false,
          );
        } else if (state is AuthMfaSetupRequired) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MfaSetupPage(
                  qrCode: state.qrCode,
                  secret: state.secret,
                  factorId: state.factorId,
                  challengeId: state.challengeId,
                ),
              ),
            );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xff0a0a0a),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final user = state.currentUser;
                String name = user?.fullName ?? "User";
                String email = user?.email ?? "";
                String? profilePic = user?.profilePic;

                return Column(
                  children: [
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const ManageProfilePage()),
                        );
                      },
                      child: Center(
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xff76eb07), width: 3),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: const Color(0xff1a1a1a),
                                backgroundImage: profilePic != null && profilePic.isNotEmpty
                                    ? NetworkImage(profilePic)
                                    : null,
                                child: profilePic == null || profilePic.isEmpty
                                    ? Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                        style: GoogleFonts.poppins(color: const Color(0xff76eb07), fontSize: 40, fontWeight: FontWeight.w700),
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xff76eb07),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit_rounded, color: Colors.black, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      name,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      email,
                      style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
                    ),
                    const SizedBox(height: 30),
                    
                    _buildProfileOption(
                      Icons.person_outline_rounded, 
                      "Manage Profile",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const ManageProfilePage()),
                        );
                      },
                    ),
                    _buildProfileOption(
                      Icons.payment_rounded, 
                      "Payment Methods",
                      onTap: () => _showPaymentMethodsSheet(context),
                    ),
                    _buildProfileOption(
                      Icons.security_rounded, 
                      "Two-Factor Authentication",
                      subtitle: "Enhance account security",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const MfaSettingsPage()),
                        );
                      },
                    ),
                    _buildProfileOption(
                      Icons.help_outline_rounded, 
                      "Support & Help",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const SupportAndHelpPage()),
                        );
                      },
                    ),
                    _buildProfileOption(
                      Icons.info_outline_rounded, 
                      "About App",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const AboutAppPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildProfileOption(
                      Icons.logout_rounded, 
                      "Logout", 
                      color: Colors.redAccent, 
                      isLast: true,
                      onTap: () {
                        context.read<AuthBloc>().add(LogoutEvent());
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showManageProfileSheet(BuildContext context, String name, String email, String userId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff0a0a0a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Account Details",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 25),
            _detailRow("Full Name", name),
            _detailRow("Email Address", email.isEmpty ? "Not provided" : email),
            _detailRow("Rider ID", userId.length > 8 ? "#${userId.substring(0, 8).toUpperCase()}" : userId),
            _detailRow("Account Status", "Active & Verified", isGreen: true),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String val, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13)),
          Text(
            val, 
            style: GoogleFonts.poppins(
              color: isGreen ? const Color(0xff76eb07) : Colors.white, 
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {String? subtitle, Color color = Colors.white70, bool isLast = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xff1a1a1a),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isLast ? color.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(color: const Color(0xff76eb07).withValues(alpha: 0.6), fontSize: 11),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color.withValues(alpha: 0.3), size: 16),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff0a0a0a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Payment Options",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              _paymentChannelTile(Icons.account_balance_wallet_rounded, "GoRide Cash", "Balance: Rs. 0.00", isPrimary: true),
              _paymentChannelTile(Icons.credit_card_rounded, "Credit/Debit Card", "Link your card for instant payments"),
              _paymentChannelTile(Icons.phone_android_rounded, "Mobile Wallets", "JazzCash / EasyPaisa supported"),
              _paymentChannelTile(Icons.money_rounded, "Cash on Hand", "Default ride payment method"),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentChannelTile(IconData icon, String title, String subtitle, {bool isPrimary = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xff1a1a1a),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPrimary ? const Color(0xff76eb07).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: isPrimary ? const Color(0xff76eb07) : Colors.white70, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          if (isPrimary)
            const Icon(Icons.check_circle_rounded, color: Color(0xff76eb07), size: 18),
        ],
      ),
    );
  }

  void _showSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff0a0a0a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Support & Help Center",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              _supportActionTile(Icons.support_agent_rounded, "Live Chat Support", "Average response time: 2 mins", Colors.blueAccent),
              _supportActionTile(Icons.email_rounded, "Email Support", "support@goride.pk", const Color(0xff76eb07)),
              _supportActionTile(Icons.call_rounded, "24/7 Helpline", "0800-GORIDE", Colors.amber),
              _supportActionTile(Icons.help_center_rounded, "FAQs & Safety Guides", "Browse help articles", Colors.white70),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _supportActionTile(IconData icon, String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xff1a1a1a),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
        ],
      ),
    );
  }
}

