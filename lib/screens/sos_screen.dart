import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/app_user.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _rippleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color:  Color(0xFFB8A9D0)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Trippies',
          style: AppTheme.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildSosTrigger(),
              const SizedBox(height: 32),
              _buildEmergencyContacts(),
              const SizedBox(height: 28),
              _buildQuickServices(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSosTrigger() {
    return Column(
      children: [
        GestureDetector(
          onTap: _onSosTapped,
          child: AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              final scale = _rippleAnimation.value;
              return SizedBox(
                width: 260, height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(scale: scale, child: _ring(260, 0.08)),
                    Transform.scale(scale: scale, child: _ring(220, 0.12)),
                    Transform.scale(scale: scale * 0.98, child: _ring(180, 0.18)),
                    _ring(150, 0.25),
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.lavender,
                        boxShadow: [BoxShadow(color: AppTheme.lavender.withValues(alpha: 0.35), blurRadius: 24, spreadRadius: 4)],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Stack(alignment: Alignment.center, children: [
                            Padding(padding: EdgeInsets.only(bottom: 8), child: Icon(Icons.sensors, color: Colors.white, size: 22)),
                            Padding(padding: EdgeInsets.only(top: 10), child: Icon(Icons.location_on, color: Colors.white, size: 28)),
                          ]),
                          const SizedBox(height: 4),
                          Text("Send Live\nLocation", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white, height: 1.2)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text("Tap to instantly notify your emergency contacts and share your real-time path", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
        ),
      ],
    );
  }

  Widget _ring(double size, double alpha) {
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.lavender.withValues(alpha: alpha)));
  }

  Widget _buildEmergencyContacts() {
    if (_userId == null) {
      return _buildEmptyContacts();
    }

    return StreamBuilder<AppUser?>(
      stream: _firestoreService.getUserData(_userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        final contacts = user?.emergencyContacts ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My Emergency Contacts", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.navyLegacy)),
            const SizedBox(height: 14),
            if (contacts.isEmpty)
              _buildEmptyContacts()
            else
              ...contacts.map((c) => _buildContactCard(c)),
          ],
        );
      },
    );
  }

  Widget _buildEmptyContacts() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, color: AppTheme.textTertiary, size: 40),
          const SizedBox(height: 12),
          Text(
            "No emergency contacts added yet",
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            "Add contacts in your Profile > Safety settings",
            style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    final name = contact['name']?.toString() ?? 'Unknown';
    final phone = contact['phone']?.toString() ?? '';

    // Cycle through accent colors for avatars
    final colors = [AppTheme.pink, AppTheme.lavender, AppTheme.babyBlue];
    final colorIndex = name.hashCode.abs() % colors.length;
    final avatarBg = colors[colorIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.navyLegacy)),
            const SizedBox(height: 2),
            Text(phone.isNotEmpty ? phone : 'No phone number', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textTertiary)),
          ])),
          GestureDetector(
            onTap: () => _showCallingDialog(name),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: const Color(0xFFF5F5F0), shape: BoxShape.circle, border: Border.all(color: AppTheme.divider, width: 0.5)),
              child: const Icon(Icons.phone, color: AppTheme.textTertiary, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickServices() {
    return Row(
      children: [
        Expanded(child: _serviceBtn("Local Police", AppTheme.pink, Icons.shield, true)),
        const SizedBox(width: 16),
        Expanded(child: _serviceBtn("Ambulance", AppTheme.lavender, Icons.medical_services, false)),
      ],
    );
  }

  Widget _serviceBtn(String label, Color bg, IconData icon, bool isPolice) {
    return GestureDetector(
      onTap: () => _showCallingDialog(label),
      child: Container(
        height: 88,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: bg.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isPolice
                ? const Stack(alignment: Alignment.center, children: [Icon(Icons.shield, color: Colors.white, size: 28), Padding(padding: EdgeInsets.only(bottom: 2), child: Icon(Icons.star, color: AppTheme.pink, size: 12))])
                : Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _onSosTapped() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Text('Live location sent to contacts!', style: GoogleFonts.poppins(color: Colors.white)),
      ]),
      backgroundColor: AppTheme.navyLegacy,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showCallingDialog(String name) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        Future.delayed(const Duration(seconds: 3), () {
          if (ctx.mounted) Navigator.of(ctx).pop();
        });
        return _CallingDialog(serviceName: name);
      },
    );
  }
}

class _CallingDialog extends StatefulWidget {
  final String serviceName;
  const _CallingDialog({required this.serviceName});
  @override
  State<_CallingDialog> createState() => _CallingDialogState();
}

class _CallingDialogState extends State<_CallingDialog> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _anim = Tween<double>(begin: -0.05, end: 0.05).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final color = widget.serviceName == "Local Police" ? AppTheme.pink : AppTheme.lavender;
    final icon = widget.serviceName == "Ambulance" ? Icons.medical_services : Icons.phone;
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15)),
            child: Center(child: AnimatedBuilder(animation: _anim, builder: (context, _) {
              return Transform.rotate(angle: _anim.value, child: Container(width: 56, height: 56, decoration: BoxDecoration(shape: BoxShape.circle, color: color), child: Icon(icon, color: Colors.white, size: 28)));
            })),
          ),
          const SizedBox(height: 20),
          Text("Calling now...", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.navyLegacy)),
          const SizedBox(height: 8),
          Text(widget.serviceName, style: GoogleFonts.poppins(fontSize: 15, color: AppTheme.textTertiary)),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) => TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.3, end: 1.0), duration: Duration(milliseconds: 400 + (i * 200)), curve: Curves.easeInOut,
            builder: (context, v, child) => Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: v))),
          ))),
          const SizedBox(height: 24),
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textTertiary))),
        ]),
      ),
    );
  }
}
