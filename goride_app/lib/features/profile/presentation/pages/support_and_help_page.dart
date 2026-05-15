import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportAndHelpPage extends StatelessWidget {
  const SupportAndHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0a0a0a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Support & Help",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xff1a1a1a), const Color(0xff76eb07).withValues(alpha: 0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xff76eb07).withValues(alpha: 0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff76eb07).withValues(alpha: 0.05),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xff76eb07).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.support_agent_rounded, color: Color(0xff76eb07), size: 35),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "How can we help?",
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Our dedicated support team is available around the clock to assist you.",
                          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Text(
              "DIRECT CHANNELS",
              style: GoogleFonts.poppins(color: const Color(0xff76eb07), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            _supportCard(
              context,
              icon: Icons.chat_rounded,
              title: "Live Chat Support",
              subtitle: "Connect instantly with a customer care agent",
              badgeText: "Fastest",
              color: Colors.blueAccent,
              onTap: () => _showDialog(context, "Live Chat", "Our Live Chat support agents are currently routing your request. Please hold on while we connect you to the next available representative."),
            ),
            _supportCard(
              context,
              icon: Icons.email_rounded,
              title: "Email Support",
              subtitle: "support@goride.pk",
              color: const Color(0xff76eb07),
              onTap: () => _showDialog(context, "Email Support", "You can write to us anytime at support@goride.pk. We typically respond within 2 to 4 hours."),
            ),
            _supportCard(
              context,
              icon: Icons.phone_in_talk_rounded,
              title: "24/7 Helpline",
              subtitle: "0800-GORIDE (Toll Free)",
              color: Colors.amber,
              onTap: () => _showDialog(context, "Helpline", "Call our toll-free 24/7 support line at 0800-GORIDE for emergency dispatch or immediate assistance."),
            ),

            const SizedBox(height: 30),
            Text(
              "FREQUENTLY ASKED QUESTIONS",
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            _faqTile(
              context,
              question: "How do I update my profile details?",
              answer: "Go to Manage Profile from the main account menu. You can tap your avatar to select a new premium picture or edit your full name directly.",
            ),
            _faqTile(
              context,
              question: "What payment methods are supported?",
              answer: "GoRide accepts Cash on Hand, mobile wallets (JazzCash / EasyPaisa), integrated credit/debit cards, and GoRide Cash wallet balance.",
            ),
            _faqTile(
              context,
              question: "Is Two-Factor Authentication required?",
              answer: "You can optionally configure highly secure time-based OTP (TOTP) two-factor authentication via Google Authenticator from your security profile settings.",
            ),
            _faqTile(
              context,
              question: "How do lost items get recovered?",
              answer: "If you left an item in a vehicle, immediately contact our 24/7 helpline with your Ride ID. Our dispatch unit will coordinate directly with the driver.",
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _supportCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff1a1a1a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.poppins(color: color, fontSize: 9, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _faqTile(BuildContext context, {required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xff121212),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: const Color(0xff76eb07),
          collapsedIconColor: Colors.white38,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            question,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                answer,
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1a1a1a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
        content: Text(content, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Close", style: GoogleFonts.poppins(color: const Color(0xff76eb07), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
