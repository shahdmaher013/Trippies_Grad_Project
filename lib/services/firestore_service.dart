import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/destination.dart';
import '../models/trip.dart';
import '../models/workshop.dart';
import '../models/app_user.dart';
import '../models/booking.dart';
import '../models/review.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Destinations
  Stream<List<Destination>> getDestinations() {
    return _db
        .collection('destinations')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Destination.fromFirestore(doc))
              .toList(),
        );
  }

  // Planned Trips
  Stream<List<Trip>> getPlannedTrips() {
    return _db
        .collection('trips')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList(),
        );
  }

  // Private Trips
  Stream<List<Trip>> getPrivateTrips() {
    return _db
        .collection('trips')
        .where(
          'is_private_available',
          isEqualTo: true,
        ) // Or whatever logic distinguishes private
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList(),
        );
  }

  // Workshops
  Stream<List<Workshop>> getWorkshops() {
    return _db
        .collection('workshops')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Workshop.fromFirestore(doc)).toList(),
        );
  }

  // User Data
  Stream<AppUser?> getUserData(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);
  }

  // --- Wishlist (dedicated collection) ---

  /// Returns a real-time stream of item IDs wishlisted by this user.
  Stream<List<String>> getWishlistStream(String userId) {
    return _db
        .collection('wishlist')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data()['item_id'] as String)
            .toList());
  }

  Future<void> toggleFavorite(String userId, String itemId) async {
    final query = await _db
        .collection('wishlist')
        .where('user_id', isEqualTo: userId)
        .where('item_id', isEqualTo: itemId)
        .get();

    if (query.docs.isNotEmpty) {
      // Already wishlisted → remove it
      for (final doc in query.docs) {
        await doc.reference.delete();
      }
    } else {
      // Not wishlisted → add it
      await _db.collection('wishlist').add({
        'user_id': userId,
        'item_id': itemId,
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> removeFromFavorites(String userId, String itemId) async {
    final query = await _db
        .collection('wishlist')
        .where('user_id', isEqualTo: userId)
        .where('item_id', isEqualTo: itemId)
        .get();

    for (final doc in query.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> updateEmergencyContacts(String userId, List<Map<String, dynamic>> contacts) async {
    final userRef = _db.collection('users').doc(userId);
    final doc = await userRef.get();
    if (doc.exists) {
      await userRef.update({
        'emergency_contacts': contacts,
      });
    } else {
      await userRef.set({
        'emergency_contacts': contacts,
      }, SetOptions(merge: true));
    }
  }

  // Bookings
  Stream<List<Booking>> getUserBookings(String userId) {
    return _db
        .collection('bookings')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList(),
        );
  }

  Future<String> createBooking(Booking booking) async {
    // 1. Create a reference to generate a unique doc ID without saving it yet
    final docRef = _db.collection('bookings').doc();
    
    // 2. Generate the human-readable display ID
    final prefix = booking.itemType == 'trip' ? 'TRP' : (booking.itemType == 'destination' ? 'DST' : 'WKS');
    final shortId = docRef.id.substring(0, 6).toUpperCase();
    final displayId = '$prefix-${DateTime.now().year}-$shortId';
    
    // 3. Prepare all the data to save
    final data = booking.toMap();
    data['booking_display_id'] = displayId;
    
    // 4. Save everything at once! This triggers a 'create' rule, NOT an 'update' rule.
    await docRef.set(data);
    
    return displayId;
  }

  // --- Location Sharing Settings ---
  Future<void> updateLocationSharingSettings(String userId, bool isEnabled, String mode, List<String> sharedContacts) async {
    await _db.collection('users').doc(userId).update({
      'is_location_sharing_enabled': isEnabled,
      'location_sharing_mode': mode,
      'shared_contacts': sharedContacts,
    });
  }

  // Helper to fetch item details for Booking or Wishlist
  Future<dynamic> getItemById(String itemId) async {
    // Check trips
    final tripDoc = await _db.collection('trips').doc(itemId).get();
    if (tripDoc.exists) return Trip.fromFirestore(tripDoc);

    // Check destinations
    final destDoc = await _db.collection('destinations').doc(itemId).get();
    if (destDoc.exists) return Destination.fromFirestore(destDoc);

    // Check workshops
    final workDoc = await _db.collection('workshops').doc(itemId).get();
    if (workDoc.exists) return Workshop.fromFirestore(workDoc);

    return null;
  }

  // --- Vibe Check Methods ---

  Future<void> uploadVibe(String itemId, String userId, File imageFile) async {
    final timestamp = DateTime.now();
    final fileName = '${userId}_${timestamp.millisecondsSinceEpoch}.jpg';
    
    // 1. Upload to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child('vibes/$fileName');
    final uploadTask = await storageRef.putFile(imageFile);
    final imageUrl = await uploadTask.ref.getDownloadURL();

    // 2. Save record to Firestore
    await _db.collection('vibe_checks').add({
      'item_id': itemId,
      'user_id': userId,
      'image_url': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'created_at': timestamp.toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> getVibesForItem(String itemId) {
    return _db
        .collection('vibe_checks')
        .where('item_id', isEqualTo: itemId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // --- Reviews ---

  Future<void> submitReview(Review review) async {
    await _db.collection('reviews').add(review.toMap());
  }

  Stream<List<Review>> getReviewsForItem(String itemId) {
    // We use Filter.or to match either 'item_id' or 'trip_id' for backward compatibility
    return _db
        .collection('reviews')
        .where(Filter.or(
          Filter('item_id', isEqualTo: itemId),
          Filter('trip_id', isEqualTo: itemId),
        ))
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
          // Sort locally since we used an OR query (can't orderBy easily without composite index)
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs;
        });
  }

  // --- Save Phone Number ---

  Future<void> saveUserPhoneNumber(String userId, String phoneNumber) async {
    final userRef = _db.collection('users').doc(userId);
    final doc = await userRef.get();
    if (doc.exists) {
      await userRef.update({'phone_number': phoneNumber});
    } else {
      await userRef.set({'phone_number': phoneNumber}, SetOptions(merge: true));
    }
  }

  // --- Identity Verification ---

  Future<void> submitVerificationPhoto(String userId, File imageFile) async {
    // 1. Upload to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child('verfication_photo/$userId.jpg');
    final uploadTask = await storageRef.putFile(imageFile);
    final photoUrl = await uploadTask.ref.getDownloadURL();

    // 2. Update user profile in Firestore
    final userRef = _db.collection('users').doc(userId);
    final doc = await userRef.get();
    if (doc.exists) {
      await userRef.update({
        'verified': true,
        'verfication_photo': photoUrl,
      });
    } else {
      await userRef.set({
        'verified': true,
        'verfication_photo': photoUrl,
      }, SetOptions(merge: true));
    }
  }
}
