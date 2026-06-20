import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/app_user.dart';

class LocationSharingScreen extends StatefulWidget {
  const LocationSharingScreen({super.key});

  @override
  State<LocationSharingScreen> createState() => _LocationSharingScreenState();
}

class _LocationSharingScreenState extends State<LocationSharingScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  bool _isSharingEnabled = false;
  String _sharingMode = "While Using App"; // "While Using App" or "Always"
  final Set<String> _selectedContacts = {};
  bool _isInitialized = false;

  void _saveSettings() {
    if (_userId != null) {
      _firestoreService.updateLocationSharingSettings(
        _userId,
        _isSharingEnabled,
        _sharingMode,
        _selectedContacts.toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Location Sharing',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A1A2E),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _userId == null
            ? const Center(child: Text("Please sign in."))
            : StreamBuilder<AppUser?>(
                stream: _firestoreService.getUserData(_userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final user = snapshot.data;
                  final contacts = user?.emergencyContacts ?? [];

                  if (!_isInitialized && user != null) {
                    _isSharingEnabled = user.isLocationSharingEnabled;
                    _sharingMode = user.locationSharingMode;
                    _selectedContacts.clear();
                    _selectedContacts.addAll(user.sharedContacts);
                    
                    // Pre-select all contacts if none are selected yet and sharing is enabled
                    if (_selectedContacts.isEmpty && contacts.isNotEmpty && _isSharingEnabled) {
                      for (var c in contacts) {
                        _selectedContacts.add(c['phone'] ?? '');
                      }
                      _saveSettings();
                    }
                    _isInitialized = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() {});
                    });
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    children: [
                      // Header Map Icon/Animation
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: _isSharingEnabled
                                ? const Color(0xFFE0F7FA)
                                : const Color(0xFFF5F5F0),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.share_location,
                            size: 48,
                            color: _isSharingEnabled
                                ? const Color(0xFF4DD0E1)
                                : const Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Master Toggle
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Share Live Location",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isSharingEnabled ? "Active" : "Paused",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: _isSharingEnabled
                                        ? const Color(0xFF4DD0E1)
                                        : const Color(0xFF9E9E9E),
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _isSharingEnabled,
                              activeThumbColor: Colors.white,
                              activeTrackColor: const Color(0xFF4DD0E1),
                              onChanged: (val) {
                                setState(() {
                                  _isSharingEnabled = val;
                                });
                                _saveSettings();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sharing Mode Selection
                      if (_isSharingEnabled) ...[
                        Text(
                          "Sharing Mode",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
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
                            children: [
                              _buildModeOption(
                                "While Using App",
                                "Only shares when the app is open (battery friendly)",
                                Icons.phone_android,
                              ),
                              const Divider(height: 1, indent: 56, endIndent: 20),
                              _buildModeOption(
                                "Always",
                                "Shares in the background for maximum safety",
                                Icons.all_inclusive,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Contacts Selection
                        Text(
                          "Share With",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (contacts.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              "No emergency contacts added yet.",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF9E9E9E),
                              ),
                            ),
                          )
                        else
                          Container(
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
                              children: List.generate(contacts.length, (index) {
                                final c = contacts[index];
                                final name = c['name'] ?? 'Unknown';
                                final phone = c['phone'] ?? '';
                                final isSelected = _selectedContacts.contains(phone);
                                
                                return Column(
                                  children: [
                                    CheckboxListTile(
                                      value: isSelected,
                                      activeColor: const Color(0xFFB8A9D0),
                                      title: Text(
                                        name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1A1A2E),
                                        ),
                                      ),
                                      subtitle: Text(
                                        phone,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: const Color(0xFF9E9E9E),
                                        ),
                                      ),
                                      secondary: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF5F5F0),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.person, color: Color(0xFFB8A9D0), size: 18),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            _selectedContacts.add(phone);
                                          } else {
                                            _selectedContacts.remove(phone);
                                          }
                                        });
                                        _saveSettings();
                                      },
                                    ),
                                    if (index < contacts.length - 1)
                                      const Divider(height: 1, indent: 72, endIndent: 20),
                                  ],
                                );
                              }),
                            ),
                          ),
                      ],
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildModeOption(String title, String subtitle, IconData icon) {
    final isSelected = _sharingMode == title;
    return InkWell(
      onTap: () {
        setState(() {
          _sharingMode = title;
        });
        _saveSettings();
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE0F7FA) : const Color(0xFFF5F5F0),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? const Color(0xFF4DD0E1) : const Color(0xFF9E9E9E), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
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
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF4DD0E1), size: 24)
            else
              const Icon(Icons.circle_outlined, color: Color(0xFFE0E0E0), size: 24),
          ],
        ),
      ),
    );
  }
}
