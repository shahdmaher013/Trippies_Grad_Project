import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String itemId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.itemId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      itemId: data['item_id'] ?? data['trip_id'] ?? '',
      userId: data['user_id'] ?? '',
      userName: data['user_name'] ?? 'Anonymous',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? 
                 (data['timestamp'] as Timestamp?)?.toDate() ?? 
                 DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId, // Keep item_id for new ones
      'trip_id': itemId, // Write trip_id for backward compatibility
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'created_at': FieldValue.serverTimestamp(),
      'timestamp': FieldValue.serverTimestamp(), // Write timestamp for backward compatibility
    };
  }
}
