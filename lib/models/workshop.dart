import 'package:cloud_firestore/cloud_firestore.dart';

class Workshop {
  final String id;
  final String title;
  final String availableSlots;
  final String category;
  final String description;
  final String duration;
  final String hostName;
  final List<String> includedMaterials;
  final String location;
  final String pricePerPerson;
  final String imageURL;
  final double rating;

  const Workshop({
    required this.id,
    required this.title,
    required this.availableSlots,
    required this.category,
    required this.description,
    required this.duration,
    required this.hostName,
    required this.includedMaterials,
    required this.location,
    required this.pricePerPerson,
    required this.imageURL,
    required this.rating,
  });

  static const Map<String, String> _fallbackWorkshopImages = {
    'egyptian pottery': 'https://images.unsplash.com/photo-1610701596007-11502861dcfa?q=80&w=1000&auto=format&fit=crop', // Pottery making
  };

  static String getFallbackUrl(String title) {
    String lowerTitle = title.toLowerCase();
    for (var key in _fallbackWorkshopImages.keys) {
      if (lowerTitle.contains(key)) return _fallbackWorkshopImages[key]!;
    }
    return '';
  }

  factory Workshop.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    String title = data['title'] ?? data['name'] ?? '';
    String imgUrl = data['imageURL'] ?? data['image_url'] ?? data['imageUrl'] ?? data['image'] ?? data['cover_image'] ?? data['coverImage'] ?? (data['official_photos'] != null && (data['official_photos'] as List).isNotEmpty ? data['official_photos'][0] : '');

    if (imgUrl.trim().isEmpty || imgUrl == 'null' || !imgUrl.startsWith('http')) {
      String lowerTitle = title.toLowerCase();
      for (var key in _fallbackWorkshopImages.keys) {
        if (lowerTitle.contains(key)) {
          imgUrl = _fallbackWorkshopImages[key]!;
          break;
        }
      }
    }

    return Workshop(
      id: doc.id,
      title: title,
      availableSlots: data['available_slots']?.toString() ?? data['group_size']?.toString() ?? '',
      category: data['category'] ?? data['category '] ?? '',
      description: data['description'] ?? data['description '] ?? '',
      duration: [data['duration'], data['workshop_duration'], data['trip_duration'], data['hours']]
          .firstWhere((e) => e != null && e.toString().trim().isNotEmpty, orElse: () => '2 hours').toString(),
      hostName: data['host_name'] ?? '',
      includedMaterials: _parseStringList(data['included_materials'] ?? data['know_before_you_go']),
      location: data['location'] is GeoPoint
          ? '${(data['location'] as GeoPoint).latitude}, ${(data['location'] as GeoPoint).longitude}'
          : data['location']?.toString() ?? '',
      pricePerPerson: data['price_per_person']?.toString() ?? data['avg_cost']?.toString() ?? data['price_planned']?.toString() ?? '',
      imageURL: imgUrl,
      rating: (data['rating'] ?? 4.9).toDouble(),
    );
  }

  // UI compatibility getters
  String get name => title;
  String get price => pricePerPerson;
  String get imagePath => imageURL;

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
}
