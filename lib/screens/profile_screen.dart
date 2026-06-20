import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'bookings_screen.dart';
import 'auth_screen.dart';
import 'personal_info_screen.dart';
import 'legal_privacy_screen.dart';
import 'support_help_screen.dart';
import 'language_selection_screen.dart';
import 'notifications_screen.dart';
import 'password_security_screen.dart';
import 'emergency_contacts_screen.dart';
import 'location_sharing_screen.dart';
import '../widgets/guest_gate.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final displayName = FirebaseAuth.instance.currentUser?.displayName ?? 'Guest User';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'G';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // 1. Monogram Initial Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF3B6D1), Color(0xFFB8A9D0)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF3B6D1).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.poppins(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. User Info
              Text(
                displayName,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                GuestGate.isAuthenticated() ? "Solo Explorer since 2022" : "Browsing as Guest",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 28),

              // 4. Account Section
              _buildSectionHeader("Account"),
              const SizedBox(height: 12),
              _buildCard([
                _ProfileMenuItem(
                  icon: Icons.person_outline,
                  iconBg: const Color(0xFFE8F0FE),
                  iconColor: const Color(0xFF4A90D9),
                  title: "Personal Info",
                  subtitle: "Name, email, phone",
                  onTap: () {
                    if (GuestGate.check(context, featureName: 'Personal Info')) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalInfoScreen(),
                        ),
                      );
                    }
                  },
                ),
                _ProfileMenuItem(
                  icon: Icons.lock_outline,
                  iconBg: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFFFB74D),
                  title: "Password & Security",
                  subtitle: "Update your password",
                  onTap: () {
                    if (GuestGate.check(context, featureName: 'Password & Security')) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PasswordSecurityScreen(),
                        ),
                      );
                    }
                  },
                ),
              ]),
              const SizedBox(height: 24),

              // 5. Preferences Section
              _buildSectionHeader("Preferences"),
              const SizedBox(height: 12),
              _buildCard([
                _ProfileMenuItem(
                  icon: Icons.notifications_outlined,
                  iconBg: const Color(0xFFFCE4EC),
                  iconColor: const Color(0xFFF3B6D1),
                  title: "Notifications",
                  subtitle: "Alerts and reminders",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                _ProfileMenuItem(
                  icon: Icons.language,
                  iconBg: const Color(0xFFEDE7F6),
                  iconColor: const Color(0xFFB8A9D0),
                  title: "Language",
                  subtitle: "English (US)",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LanguageSelectionScreen(),
                      ),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 24),

              // 6. Safety Section
              _buildSectionHeader("Safety"),
              const SizedBox(height: 12),
              _buildCard([
                _ProfileMenuItem(
                  icon: Icons.sos_outlined,
                  iconBg: const Color(0xFFFFEBEE),
                  iconColor: const Color(0xFFEF5350),
                  title: "Emergency Contacts",
                  subtitle: "Manage trusted contacts",
                  onTap: () {
                    if (GuestGate.check(context, featureName: 'Emergency Contacts')) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmergencyContactsScreen(),
                        ),
                      );
                    }
                  },
                ),
                _ProfileMenuItem(
                  icon: Icons.share_location,
                  iconBg: const Color(0xFFE0F7FA),
                  iconColor: const Color(0xFF4DD0E1),
                  title: "Location Sharing",
                  subtitle: "Live location with contacts",
                  onTap: () {
                    if (GuestGate.check(context, featureName: 'Location Sharing')) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LocationSharingScreen(),
                        ),
                      );
                    }
                  },
                ),
              ]),
              const SizedBox(height: 24),

              // 7. More Section
              _buildSectionHeader("More"),
              const SizedBox(height: 12),
              _buildCard([
                _ProfileMenuItem(
                  icon: Icons.help_outline,
                  iconBg: const Color(0xFFF3E5F5),
                  iconColor: const Color(0xFFCE93D8),
                  title: "Help & Support",
                  subtitle: "FAQs and contact us",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SupportHelpScreen(),
                      ),
                    );
                  },
                ),
                _ProfileMenuItem(
                  icon: Icons.info_outline,
                  iconBg: const Color(0xFFE8EAF6),
                  iconColor: const Color(0xFF7986CB),
                  title: "About Trippies",
                  subtitle: "Version, terms, privacy",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LegalPrivacyScreen(),
                      ),
                    );
                  },
                ),
                _ProfileMenuItem(
                  icon: GuestGate.isAuthenticated() ? Icons.logout : Icons.login,
                  title: GuestGate.isAuthenticated() ? 'Log Out' : 'Sign Up / Log In',
                  subtitle: GuestGate.isAuthenticated() ? 'Sign out of your account' : 'Create an account to book',
                  iconBg: const Color(0xFFFFEBEE),
                  iconColor: const Color(0xFFE57373),
                  isDestructive: true,
                  showChevron: false,
                  onTap: () async {
                    try {
                      if (GuestGate.isAuthenticated()) {
                        await AuthService().signOut();
                      }
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                        (route) => false,
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                ),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<_ProfileMenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length * 2 - 1, (index) {
          if (index.isOdd) {
            return const Divider(
              height: 1,
              indent: 68,
              color: Color(0xFFF0F0F0),
            );
          }
          return items[index ~/ 2];
        }),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: AppTheme.pink,
      unselectedItemColor: const Color(0xFF76767F),
      showUnselectedLabels: true,
      elevation: 10,
      type: BottomNavigationBarType.fixed,
      currentIndex: 2,
      selectedLabelStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
        if (index == 1) {
          if (GuestGate.check(context, featureName: 'Bookings')) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BookingsScreen()),
            );
          }
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Booking',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDestructive;
  final bool showChevron;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.isDestructive = false,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDestructive
        ? const Color(0xFFE57373)
        : const Color(0xFF1A1A2E);
    final subtitleColor = isDestructive
        ? const Color(0xFFEF9A9A)
        : const Color(0xFF9E9E9E);

    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            if (showChevron)
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFBDBDBD),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
