enum WishlistCategory { trips, destinations, workshops }

extension WishlistCategoryExtension on WishlistCategory {
  String get label {
    switch (this) {
      case WishlistCategory.trips:
        return 'Trips';
      case WishlistCategory.destinations:
        return 'Destinations';
      case WishlistCategory.workshops:
        return 'Workshops';
    }
  }
}

class WishlistItem {
  final String id;
  final String title;
  final String location;
  final String imagePath;
  final double rating;
  final String description;
  final WishlistCategory category;
  final List<String> tags;

  const WishlistItem({
    required this.id,
    required this.title,
    required this.location,
    required this.imagePath,
    required this.rating,
    required this.description,
    required this.category,
    required this.tags,
  });
}
