import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String title;
  final String description;
  final List<String> fixedDates;
  final bool isPrivateAvailable;
  final String meetingPoint;
  final List<String> placesIncluded;
  final String pricePlanned;
  final String pricePrivate;
  final String tripDuration;
  final String imageURL;
  final double rating;
  final String location;
  final List<String> whatToBring;
  final List<Map<String, String>> itinerary;

  const Trip({
    required this.id,
    required this.title,
    required this.description,
    required this.fixedDates,
    required this.isPrivateAvailable,
    required this.meetingPoint,
    required this.placesIncluded,
    required this.pricePlanned,
    required this.pricePrivate,
    required this.tripDuration,
    required this.imageURL,
    required this.rating,
    required this.location,
    required this.whatToBring,
    required this.itinerary,
  });

  static const Map<String, String> _fallbackTripImages = {
    'islamic cairo': 'https://images.unsplash.com/photo-1572252009286-268acec5ca0a?q=80&w=1000&auto=format&fit=crop',
    'pyramids': 'https://images.unsplash.com/photo-1600521605604-0b477bc2f664?q=80&w=1000&auto=format&fit=crop',
    'cairo city': 'https://images.unsplash.com/photo-1533157961806-03916dd5c33a?q=80&w=1000&auto=format&fit=crop',
  };

  static String getFallbackUrl(String title) {
    String lowerTitle = title.toLowerCase();
    for (var key in _fallbackTripImages.keys) {
      if (lowerTitle.contains(key)) return _fallbackTripImages[key]!;
    }
    return '';
  }

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    // Parse location — could be GeoPoint, String, or missing
    String parsedLocation;
    final locData = data['location'] ?? data['location '];
    if (locData is GeoPoint) {
      parsedLocation = '${locData.latitude}, ${locData.longitude}';
    } else {
      parsedLocation = locData?.toString() ?? data['meeting_point']?.toString() ?? '';
    }

    String title = data['title'] ?? data['name'] ?? '';
    String imgUrl = data['imageURL'] ?? data['image_url'] ?? data['imageUrl'] ?? data['image'] ?? data['cover_image'] ?? data['coverImage'] ?? (data['official_photos'] != null && (data['official_photos'] as List).isNotEmpty ? data['official_photos'][0] : '') ?? data['imageURL '] ?? '';

    if (imgUrl.trim().isEmpty || imgUrl == 'null' || !imgUrl.startsWith('http')) {
      String lowerTitle = title.toLowerCase();
      for (var key in _fallbackTripImages.keys) {
        if (lowerTitle.contains(key)) {
          imgUrl = _fallbackTripImages[key]!;
          break;
        }
      }
    }

    return Trip(
      id: doc.id,
      title: title,
      description: data['description'] ?? data['description '] ?? '',
      fixedDates: _parseStringList(data['fixed_dates'] ?? data['fixed_dates ']),
      isPrivateAvailable: data['is_private_available'] ?? false,
      meetingPoint: data['meeting_point'] ?? data['meeting_point '] ?? '',
      placesIncluded: _parseStringList(data['places_included'] ?? data['places_included ']),
      pricePlanned: data['price_planned']?.toString() ?? '',
      pricePrivate: data['price_private']?.toString() ?? '',
      tripDuration: [data['trip_duration'], data['duration'], data['hours']]
          .firstWhere((e) => e != null && e.toString().trim().isNotEmpty, orElse: () => '8 hours').toString(),
      imageURL: imgUrl,
      rating: (data['rating'] ?? 4.9).toDouble(),
      location: parsedLocation,
      whatToBring: _parseStringList(data['what_to_bring'] ?? data['what_to_bring '] ?? data['essentials']),
      itinerary: _parseItinerary(data['itinerary'] ?? data['itinerary ']),
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is Iterable) {
      return value.map((e) {
        if (e is Timestamp) {
          return e.toDate().toString().split(' ')[0]; // yyyy-mm-dd
        }
        return e.toString();
      }).toList();
    } else if (value is Timestamp) {
      return [value.toDate().toString().split(' ')[0]];
    } else {
      return [value.toString()];
    }
  }

  static List<Map<String, String>> _parseItinerary(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) {
        if (item is Map) {
          return {
            'time': item['time']?.toString() ?? '',
            'place': item['place']?.toString() ?? item['name']?.toString() ?? '',
          };
        }
        // If it's just a string, treat it as a place name with no time
        return {'time': '', 'place': item.toString()};
      }).toList();
    }
    return [];
  }

  // Compatibility getters for UI
  String get name => title;
  String get duration => tripDuration;
  String get imagePath => imageURL;
  // Expose planned price generally, private price if planned is missing
  String get price => pricePlanned.isNotEmpty ? pricePlanned : pricePrivate;
  bool get isPrivate => isPrivateAvailable;
}
