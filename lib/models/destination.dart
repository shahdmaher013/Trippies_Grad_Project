import 'package:cloud_firestore/cloud_firestore.dart';

class Destination {
  final String id;
  final String name; // from name
  final String location; // from location
  final String description; // from description
  final String knowBeforeYouGo; // from know_before_you_go
  final List<String> officialPhotos; // from official_photos
  final String duration; // Using a default since DB doesn't have it
  final String price; // from avg_cost
  final double rating;
  final String groupSize;

  const Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.knowBeforeYouGo,
    required this.officialPhotos,
    required this.duration,
    required this.price,
    required this.rating,
    required this.groupSize,
  });

  static const Map<String, String> _fallbackDestinationImages = {
    'khan el khalili': 'https://images.unsplash.com/photo-1582293888360-1a7f058098c4?q=80&w=1000&auto=format&fit=crop', // Market
  };

  static String getFallbackUrl(String title) {
    String lowerTitle = title.toLowerCase();
    for (var key in _fallbackDestinationImages.keys) {
      if (lowerTitle.contains(key)) return _fallbackDestinationImages[key]!;
    }
    return '';
  }

  factory Destination.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    String name = data['name'] ?? '';
    List<String> photos = _parseStringList(data['official_photos'] ?? data['official_photos '] ?? data['imageURL'] ?? data['image_url'] ?? data['imageUrl'] ?? data['image'] ?? data['cover_image'] ?? data['coverImage']);

    if (photos.isEmpty || photos.first.trim().isEmpty || photos.first == 'null' || !photos.first.startsWith('http')) {
      String lowerName = name.toLowerCase();
      for (var key in _fallbackDestinationImages.keys) {
        if (lowerName.contains(key)) {
          photos = [_fallbackDestinationImages[key]!];
          break;
        }
      }
    }

    return Destination(
      id: doc.id,
      name: name,
      location: data['location'] is GeoPoint
          ? '${(data['location'] as GeoPoint).latitude}, ${(data['location'] as GeoPoint).longitude}'
          : data['location']?.toString() ?? '',
      description: data['description'] ?? data['description '] ?? '',
      knowBeforeYouGo: _parseKnowBeforeYouGo(data['know_before_you_go'] ?? data['know_before_you_go '] ?? data['included_materials']),
      officialPhotos: photos,
      duration: [data['duration'], data['trip_duration'], data['hours']]
          .firstWhere((e) => e != null && e.toString().trim().isNotEmpty, orElse: () => 'Flexible').toString(),
      price: data['avg_cost']?.toString() ?? data['price_per_person']?.toString() ?? data['price_planned']?.toString() ?? '',
      rating: (data['rating'] ?? 4.9).toDouble(),
      groupSize: data['group_size']?.toString() ?? data['available_slots']?.toString() ?? 'No Min',
    );
  }

  // Getter to maintain compatibility with existing UI
  String get imagePath {
    if (officialPhotos.isNotEmpty) {
      return officialPhotos.first;
    }
    return '';
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is Iterable) {
      return value.map((e) {
        if (e is Timestamp) {
          return e.toDate().toString().split(' ')[0];
        }
        return e.toString();
      }).toList();
    } else if (value is Timestamp) {
      return [value.toDate().toString().split(' ')[0]];
    } else {
      return [value.toString()];
    }
  }

  static String _parseKnowBeforeYouGo(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      return value.join('\n\n');
    }
    return value.toString();
  }
}
