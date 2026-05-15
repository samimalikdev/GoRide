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
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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
                borderRadius: BorderRadius.circular(25),
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
                          "Driver Partner Support",
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Our specialized driver support team is available 24/7 to assist you on the road.",
                          style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            Text(
              "DIRECT CHANNELS",
              style: GoogleFonts.outfit(color: const Color(0xff76eb07), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
            const SizedBox(height: 15),
            _supportCard(
              context,
              icon: Icons.chat_rounded,
              title: "Live Chat Support",
              subtitle: "Connect instantly with a driver care agent",
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
              onTap: () => _showDialog(context, "Email Support", "You can write to us anytime at support@goride.pk. We typically respond to driver partners within 1 to 3 hours."),
            ),
            _supportCard(
              context,
              icon: Icons.phone_in_talk_rounded,
              title: "24/7 Driver Helpline",
              subtitle: "0800-GORIDE (Toll Free)",
              color: Colors.amber,
              onTap: () => _showDialog(context, "Helpline", "Call our toll-free 24/7 driver support line at 0800-GORIDE for emergency dispatch, ride disputes, or immediate assistance."),
            ),

            const SizedBox(height: 35),
            Text(
              "FREQUENTLY ASKED QUESTIONS",
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
            const SizedBox(height: 15),
            _faqTile(
              context,
              question: "How do I update my vehicle documents?",
              answer: "Go to Documents & Verification from your profile menu. You can upload updated images of your CNIC, Driving License, and Vehicle Registration.",
            ),
            _faqTile(
              context,
              question: "When are my earnings disbursed?",
              answer: "Earnings from wallet and card payments are automatically transferred to your registered bank account or mobile wallet on a weekly basis, or instantly via cash-out request.",
            ),
            _faqTile(
              context,
              question: "What should I do in case of an accident?",
              answer: "Ensure your safety first, then contact emergency services. Once safe, report the incident immediately via our 24/7 Helpline so our dispatch team can support you.",
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
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xff1a1a1a),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      if (badgeText != null) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.outfit(color: color, fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _faqTile(BuildContext context, {required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xff121212),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: const Color(0xff76eb07),
          collapsedIconColor: Colors.white38,
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          title: Text(
            question,
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18, right: 18, bottom: 18),
              child: Text(
                answer,
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
        content: Text(content, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Close", style: GoogleFonts.outfit(color: const Color(0xff76eb07), fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
