import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // Required for Clipboard functionality
import '../theme/app_theme.dart';

class LegalPrivacyScreen extends StatelessWidget {
  const LegalPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Standardized app background color
    // ignore: unused_local_variable
    const Color background = Color(0xFFFFF6FC);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB8A9D0)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Legal & Privacy',
          style: AppTheme.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                children: [
                  // Hero Section
                  Text(
                    "Legal Information",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "We are committed to protecting your privacy and ensuring transparency. Review our policies below to understand how we handle your data and your rights as a Trippies user.",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF757575),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Privacy Policy Card
                  _PolicyCard(
                    icon: Icons.privacy_tip_outlined,
                    iconBg: const Color(0xFFE8F0FE),
                    iconColor: const Color(0xFF4A90D9),
                    title: "Privacy Policy",
                    lastUpdated: "OCT 2023",
                    body:
                        "Our privacy policy explains what data we collect, how we use it, and who we share it with. We prioritize the security of your personal information.",
                    cardBg:  Colors.white,
                    footnotes: const [
                      "End-to-end data encryption",
                      "GDPR compliant practices",
                      "Transparent data collection",
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Terms of Service Card
                  _PolicyCard(
                    icon: Icons.description_outlined,
                    iconBg: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFFB74D),
                    title: "Terms of Service",
                    lastUpdated: "SEP 2023",
                    body:
                        "The Terms of Service govern your use of the Trippies application, including user behavior guidelines, content ownership, and dispute resolution.",
                    cardBg: Colors.white,
                    footnotes: const [
                      "Fair usage guidelines",
                      "User responsibilities",
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Data Protection Card
                  _PolicyCard(
                    icon: Icons.shield_outlined,
                    iconBg: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF66BB6A),
                    title: "Data Protection",
                    lastUpdated: "NOV 2023",
                    body:
                        "Learn about the technical and organizational measures we have in place to safeguard your data against unauthorized access or breaches.",
                    cardBg: Colors.white,
                    footnotes: const [
                      "Secure cloud storage",
                      "Regular security audits",
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Community Guidelines Card
                  _PolicyCard(
                    icon: Icons.group_outlined,
                    iconBg: const Color(0xFFFCE4EC),
                    iconColor: const Color(0xFFF3B6D1),
                    title: "Community Guidelines",
                    lastUpdated: "DEC 2023",
                    body:
                        "Our community guidelines ensure a safe, respectful, and inclusive environment for all Trippies users. Please review our expectations for interacting with others.",
                    cardBg: Colors.white,
                    footnotes: const [
                      "Respectful communication",
                      "Zero tolerance for harassment",
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Support Footer
            Container(
              width: double.infinity,
              color: const Color(0xFFFFF6FC),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                children: [
                  Text(
                    "Have questions about our legal policies?",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF757575),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Copy the support email to clipboards
                        await Clipboard.setData(
                          const ClipboardData(text: "support@trippies.com"),
                        );

                        if (!context.mounted) return;

                        // Pop up the confirmation message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Email copied",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.darkBlue,
                              ),
                            ),
                            backgroundColor: AppTheme.pink,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.only(
                              bottom: 24,
                              left: 64,
                              right: 64,
                            ),
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.babyBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                        shadowColor: AppTheme.babyBlue.withValues(alpha: 0.25),
                      ),
                      icon: const Icon(
                        Icons.mail_outline,
                        color: AppTheme.darkBlue,
                      ),
                      label: Text(
                        "CONTACT SUPPORT TEAM",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkBlue,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String lastUpdated;
  final String body;
  final Color cardBg;
  final List<String> footnotes;

  const _PolicyCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.lastUpdated,
    required this.body,
    required this.cardBg,
    required this.footnotes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkBlue,
                  ),
                ),
              ),
              Text(
                "LAST UPDATED\n$lastUpdated",
                textAlign: TextAlign.right,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFBDBDBD),
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Body
          Text(
            body,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF4A4A4A),
              height: 1.5,
            ),
          ),

          // Footnotes
          if (footnotes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF0EEFB), height: 1),
            const SizedBox(height: 16),
            ...footnotes.map(
              (note) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppTheme.pink,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF757575),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}