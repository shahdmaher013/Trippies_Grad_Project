import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  // Track the currently selected language code
  String _selectedLanguageCode = 'EN';

  @override
  Widget build(BuildContext context) {
    const Color customBg = Color(0xFFFFF6FC);

    return Scaffold(
      backgroundColor: customBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB8A9D0)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Language',
          style: AppTheme.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "languages",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 32),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _LanguageTile(
                    code: 'EN',
                    title: 'English',
                    subtitle: 'System Default',
                    tileColor: Colors.white,
                    isSelected: _selectedLanguageCode == 'EN',
                    onTap: () {
                      setState(() {
                        _selectedLanguageCode = 'EN';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _LanguageTile(
                    code: 'FR',
                    title: 'français',
                    subtitle: 'French',
                    tileColor: Colors.white,
                    isSelected: _selectedLanguageCode == 'FR',
                    onTap: () {
                      _showComingSoon(context);
                    },
                  ),
                  const SizedBox(height: 16),
                  _LanguageTile(
                    code: 'ES',
                    title: 'Español',
                    subtitle: 'Spanish',
                    tileColor: Colors.white,
                    isSelected: _selectedLanguageCode == 'ES',
                    onTap: () {
                      _showComingSoon(context);
                    },
                  ),
                  const SizedBox(height: 16),
                  _LanguageTile(
                    code: 'IT',
                    title: 'italiano',
                    subtitle: 'Italian',
                    tileColor: Colors.white,
                    isSelected: _selectedLanguageCode == 'IT',
                    onTap: () {
                      _showComingSoon(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, customBg),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF6FC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.translate, color: AppTheme.babyBlue),
            const SizedBox(width: 12),
            Text(
              "Coming Soon!",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.darkBlue,
              ),
            ),
          ],
        ),
        content: Text(
          "This language will be available in a future update. Stay tuned!",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Got it",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.babyBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, Color navBgColor) {
    return BottomNavigationBar(
      backgroundColor: navBgColor,
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
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Booking',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFFFCE4EC),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person),
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String code;
  final String title;
  final String subtitle;
  final Color tileColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const _LanguageTile({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.tileColor,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(24),
          // Highlight active choice using a soft colored border
          border: Border.all(
            color: isSelected ? AppTheme.pink : Colors.transparent,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Leading Circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                // Give the active selection circle a tinted theme background
                color: isSelected ? const Color(0xFFFFF1F9) : const Color(0xFFF0F4FF),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                code,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppTheme.pink : const Color(0xFF1A1A2E),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            
            // Add a check icon for the active language item
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.pink,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}