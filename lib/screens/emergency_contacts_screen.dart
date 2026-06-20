// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/app_user.dart';
// ignore: unused_import
import '../theme/app_theme.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  List<Map<String, dynamic>> _contacts = [];
  bool _isInitialized = false;

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
          'Emergency Contacts',
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
            ? const Center(child: Text("Please sign in to manage contacts."))
            : StreamBuilder<AppUser?>(
                stream: _firestoreService.getUserData(_userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !_isInitialized) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Failed to load contacts."));
                  }

                  // SAFE PARSING LAYER: Handles both raw Strings and structured Maps from Firestore
                  if (snapshot.hasData && snapshot.data != null) {
                    final user = snapshot.data!;
                    final rawList = user.emergencyContacts;
                    
                    _contacts = rawList.map<Map<String, dynamic>>((element) {
                      return Map<String, dynamic>.from(element);
                                          // ignore: dead_code
                                          return {'name': 'Unknown Contact', 'phone': '', 'role': 'Notify on SOS'};
                    }).toList();

                    _isInitialized = true;
                  }

                  return _contacts.isEmpty ? _buildEmpty() : _buildList();
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFFB8A9D0),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFB8A9D0).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline, color: Color(0xFFB8A9D0), size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            "No emergency contacts yet",
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap + to add your first contact",
            style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final c = _contacts[index];
        final name = c['name'] ?? 'Unknown';
        final phone = c['phone'] ?? '';
        final role = c['role'] ?? 'Notify on SOS';
        
        final avatarBg = role == "Primary Contact" ? const Color(0xFFF3B6D1) : const Color(0xFFB8A9D0);
        final avatarIcon = role == "Primary Contact" ? Icons.star : Icons.person;

        return Dismissible(
          key: ValueKey('${name}_${index}_${_contacts.length}'),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(name),
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: const Color(0xFFEF5350), borderRadius: BorderRadius.circular(20)),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
          ),
          onDismissed: (_) async {
            final removedContact = _contacts.removeAt(index);
            try {
              await _firestoreService.updateEmergencyContacts(_userId!, _contacts);
            } catch (e) {
              setState(() {
                _contacts.insert(index, removedContact);
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Database operational error occurred.")),
                );
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
                  child: Icon(avatarIcon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                      const SizedBox(height: 2),
                      Text(phone, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF9E9E9E))),
                      Text(role, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFB8A9D0), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddEditDialog(editIndex: index),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F0), shape: BoxShape.circle),
                    child: const Icon(Icons.edit, color: Color(0xFF9E9E9E), size: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDelete(String name) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Remove $name?", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
        content: Text("This contact will no longer receive updates.", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Remove", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _showAddEditDialog({int? editIndex}) {
    if (_userId == null) return;
    
    final isEdit = editIndex != null;
    final nameCtrl = TextEditingController(text: isEdit ? _contacts[editIndex]['name'] : '');
    final phoneCtrl = TextEditingController(text: isEdit ? _contacts[editIndex]['phone'] : '');
    String role = isEdit ? (_contacts[editIndex]['role'] ?? 'Notify on SOS') : 'Notify on SOS';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _inputField("Name", nameCtrl, TextInputType.name),
                  const SizedBox(height: 14),
                  _inputField("Phone", phoneCtrl, TextInputType.phone),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    children: ["Primary Contact", "Notify on SOS"].map((r) {
                      final selected = role == r;
                      return ChoiceChip(
                        label: Text(r),
                        selected: selected,
                        onSelected: (_) => setModalState(() => role = r),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) return;

                      final contact = {'name': nameCtrl.text.trim(), 'phone': phoneCtrl.text.trim(), 'role': role};
                      final updatedList = List<Map<String, dynamic>>.from(_contacts);
                      
                      if (isEdit) {
                        updatedList[editIndex] = contact;
                      } else {
                        updatedList.add(contact);
                      }

                      Navigator.pop(ctx);
                      await _firestoreService.updateEmergencyContacts(_userId, updatedList);
                    },
                    child: Text(isEdit ? "Save Changes" : "Add Contact"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9F9F7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}