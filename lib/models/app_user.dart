import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String profilePic;
  final List<Map<String, dynamic>> emergencyContacts;
  final List<String> bookedTrips;
  final bool isLocationSharingEnabled;
  final String locationSharingMode;
  final List<String> sharedContacts;
  final bool verified;

  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.profilePic,
    required this.emergencyContacts,
    required this.bookedTrips,
    required this.isLocationSharingEnabled,
    required this.locationSharingMode,
    required this.sharedContacts,
    this.verified = false,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      fullName: data['full_name'] ?? '',
      phoneNumber: data['phone_number'] ?? '',
      profilePic: data['profile_pic'] ?? '',
      emergencyContacts: data['emergency_contacts'] != null 
          ? List<Map<String, dynamic>>.from(data['emergency_contacts'])
          : [],
      bookedTrips: data['booked_trips'] != null ? List<String>.from(data['booked_trips']) : [],
      isLocationSharingEnabled: data['is_location_sharing_enabled'] ?? false,
      locationSharingMode: data['location_sharing_mode'] ?? 'While Using App',
      sharedContacts: data['shared_contacts'] != null ? List<String>.from(data['shared_contacts']) : [],
      verified: data['verified'] ?? false,
    );
  }
}
