import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { confirmed, pendingPayment, cancelled }

extension BookingStatusExtension on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.confirmed:
        return 'CONFIRMED';
      case BookingStatus.pendingPayment:
        return 'PENDING PAYMENT';
      case BookingStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.confirmed:
        return const Color(0xFFC7CEEA); // Lavender
      case BookingStatus.pendingPayment:
        return const Color(0xFFFFF3CD); // Soft yellow
      case BookingStatus.cancelled:
        return const Color(0xFFF8D7DA); // Muted rose
    }
  }

  Color get textColor {
    switch (this) {
      case BookingStatus.confirmed:
        return const Color(0xFF3B4371);
      case BookingStatus.pendingPayment:
        return const Color(0xFF856404);
      case BookingStatus.cancelled:
        return const Color(0xFF721C24);
    }
  }
}
class Booking {
  final String id;
  final String itemId;
  final String userId;
  final BookingStatus status;
  final String totalPrice;
  final String bookingDate;
  final String itemType;
  final int guestCount;
  final String guestLabel;
  final String bookingDisplayId;
  final String hostName;

  // Resolved fields from item
  String title;
  String location;
  String imagePath;
  List<String> tags;

  Booking({
    required this.id,
    required this.itemId,
    required this.userId,
    required this.status,
    required this.totalPrice,
    required this.bookingDate,
    this.itemType = 'trip',
    this.guestCount = 1,
    this.guestLabel = '1 Traveler',
    this.bookingDisplayId = '',
    this.hostName = '',
    this.title = 'Loading...',
    this.location = '',
    this.imagePath = '',
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'user_id': userId,
      'status': status.name,
      'total_price': totalPrice,
      'booking_date': bookingDate,
      'item_type': itemType,
      'guest_count': guestCount,
      'guest_label': guestLabel,
      'booking_display_id': bookingDisplayId,
      'host_name': hostName,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    String statusStr = data['status']?.toString().toLowerCase() ?? '';
    BookingStatus parsedStatus = BookingStatus.pendingPayment;
    if (statusStr == 'confirmed') parsedStatus = BookingStatus.confirmed;
    if (statusStr == 'cancelled') parsedStatus = BookingStatus.cancelled;

    String parsedDate = '';
    if (data['booking_date'] is Timestamp) {
      parsedDate = (data['booking_date'] as Timestamp).toDate().toString().split(' ')[0];
    } else {
      parsedDate = data['booking_date']?.toString() ?? '';
    }

    return Booking(
      id: doc.id,
      itemId: data['item_id'] ?? '',
      userId: data['user_id'] ?? '',
      status: parsedStatus,
      totalPrice: data['total_price']?.toString() ?? '',
      bookingDate: parsedDate,
      itemType: data['item_type']?.toString() ?? 'trip',
      guestCount: data['guest_count'] ?? 1,
      guestLabel: data['guest_label']?.toString() ?? '1 Traveler',
      bookingDisplayId: data['booking_display_id']?.toString() ?? doc.id.substring(0, 8).toUpperCase(),
      hostName: data['host_name']?.toString() ?? '',
    );
  }

  String get dateRange => bookingDate;
}
