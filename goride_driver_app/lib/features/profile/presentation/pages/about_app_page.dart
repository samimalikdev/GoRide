import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

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
          "About GoRide",
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
            Center(
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  
                ),
                child: Image.asset('assets/background/logo.png', fit: BoxFit.fill),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "GoRide Driver Partner",
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                "Version 1.0.0 (Build 12)",
                style: GoogleFonts.outfit(color: const Color(0xff76eb07), fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Text(
                "Empowering safe, secure, and affordable everyday commuting across Pakistan with dynamic smart mobility solutions.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 35),

            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xff121212),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xff76eb07).withValues(alpha: 0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff76eb07).withValues(alpha: 0.03),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xff76eb07).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.developer_mode_rounded, color: Color(0xff76eb07), size: 24),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Developer Information",
                              style: GoogleFonts.outfit(color: const Color(0xff76eb07), fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                            Text(
                              "Sami Malik",
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "This app is created by Sami Malik",
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "About Me",
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "I'm a full-stack mobile & web developer with hands-on experience in building Android apps, iOS apps, Flutter apps, and powerful backend systems. I also work on WhatsApp automation, custom bots, and real-world API based solutions.",
                    style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Skills & Expertise",
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSkillChip("Flutter Dev (Android & iOS)"),
                      _buildSkillChip("Native Android (Kotlin)"),
                      _buildSkillChip("iOS App Development"),
                      _buildSkillChip("Backend (Node.js & Express)"),
                      _buildSkillChip("Databases (SQL & NoSQL)"),
                      _buildSkillChip("Full-Stack Development"),
                      _buildSkillChip("Cloud (AWS, Firebase, Vercel)"),
                      _buildSkillChip("Reverse Engineering"),
                      _buildSkillChip("WhatsApp Bot & Automation"),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Let's Connect",
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  _buildSocialLink(
                    context,
                    title: "WhatsApp",
                    url: "https://whatsapp.com/channel/0029Va9bWJa3QxS0N7sNcu00",
                    icon: Icons.chat_rounded,
                    color: const Color(0xff25D366),
                  ),
                  _buildSocialLink(
                    context,
                    title: "Instagram",
                    url: "https://www.instagram.com/iamsamimalik",
                    icon: Icons.camera_alt_rounded,
                    color: const Color(0xffE4405F),
                  ),
                  _buildSocialLink(
                    context,
                    title: "Telegram",
                    url: "https://t.me/SamiGaming",
                    icon: Icons.send_rounded,
                    color: const Color(0xff0088cc),
                  ),
                  _buildSocialLink(
                    context,
                    title: "LinkedIn",
                    url: "https://www.linkedin.com/in/samimalikdev",
                    icon: Icons.work_rounded,
                    color: const Color(0xff0A66C2),
                  ),
                  _buildSocialLink(
                    context,
                    title: "GitHub",
                    url: "https://github.com/samimalikdev",
                    icon: Icons.code_rounded,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            Text(
              "LEGAL & LICENSES",
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
            const SizedBox(height: 15),
            _buildAboutCard(
              context,
              icon: Icons.description_rounded,
              title: "Terms & Conditions",
              subtitle: "Read our commute agreement & usage guidelines",
              onTap: () => _showSimpleDialog(context, "Terms & Conditions", "1. Acceptance of Terms\nBy using GoRide, you agree to comply with local transportation regulations.\n\n2. Driver Responsibilities\nDriver partners must maintain lawful behavior, keep active safety documentation updated, and provide secure rides."),
            ),
            _buildAboutCard(
              context,
              icon: Icons.privacy_tip_rounded,
              title: "Privacy Policy",
              subtitle: "Learn how your location and personal data are protected",
              onTap: () => _showSimpleDialog(context, "Privacy Policy", "1. Data Security\nGoRide protects your personal information with enterprise encryption.\n\n2. Location Access\nBackground and foreground location permissions are strictly utilized for precise matchmaking and active safety tracking."),
            ),
            _buildAboutCard(
              context,
              icon: Icons.code_rounded,
              title: "Open Source Licenses",
              subtitle: "View third-party frameworks & libraries utilized",
              onTap: () => showLicensePage(
                context: context,
                applicationName: "GoRide Driver Partner",
                applicationVersion: "1.0.0",
                applicationIcon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.electric_car_rounded, color: Color(0xff76eb07), size: 40),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xff1a1a1a).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.copyright_rounded, color: Colors.white38, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    "2026 GoRide Inc. All rights reserved.",
                    style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xff1a1a1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xff76eb07).withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(color: const Color(0xff76eb07), fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildSocialLink(BuildContext context, {
    required String title,
    required String url,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: url));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Copied $title link to clipboard!"),
            backgroundColor: const Color(0xff76eb07),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            action: SnackBarAction(
              label: "OK",
              textColor: Colors.black,
              onPressed: () {},
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xff1a1a1a),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(url, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "COPY",
                style: GoogleFonts.outfit(color: const Color(0xff76eb07), fontSize: 10, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xff76eb07).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xff76eb07), size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }

  void _showSimpleDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1a1a1a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
        content: SingleChildScrollView(
          child: Text(content, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, height: 1.5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Close", style: GoogleFonts.outfit(color: const Color(0xff76eb07), fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
