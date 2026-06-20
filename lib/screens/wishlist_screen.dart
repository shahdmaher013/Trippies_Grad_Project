import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wishlist_item.dart';
import '../widgets/wishlist_card.dart';
import '../models/trip.dart';
import '../models/destination.dart';
import '../models/workshop.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'trip_detail_screen.dart';
import 'destination_detail_screen.dart';
import 'workshop_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  WishlistCategory _selectedCategory = WishlistCategory.trips;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  Widget _buildList(List<WishlistItem> items, String? userId) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          "No items found in this category.",
          style: GoogleFonts.poppins(
            color: const Color(0xFF9E9E9E),
            fontSize: 16,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        return WishlistCard(
          item: item,
          onViewDetails: () async {
            final fullItem = await _firestoreService.getItemById(item.id);
            if (!context.mounted || fullItem == null) return;

            if (fullItem is Trip) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TripDetailScreen(trip: fullItem)),
              );
            } else if (fullItem is Destination) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: fullItem)),
              );
            } else if (fullItem is Workshop) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WorkshopDetailScreen(workshop: fullItem)),
              );
            }
          },
          onRemove: () async {
            if (userId != null) {
              try {
                await _firestoreService.removeFromFavorites(userId, item.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${item.title} removed from wishlist."),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to remove item.")),
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6FC), // Warm off-white
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
       leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black), // Changed arrow to black
        onPressed: () => Navigator.of(context).pop(),
      ), // IconButton
      title: Text(
        "Wishlist", // Changed title text from "Trippies" to "Wishlist"
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: Colors.black, // Changed text color to black
        ),
      ), // Text
      centerTitle: true, // Changed from false to true to center it!
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    "Curated escapes and soulful experiences across Egypt.",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filter Chips (Horizontal Scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: WishlistCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category.label),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        }
                      },
                      labelStyle: GoogleFonts.poppins(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF1A1A2E)
                            : const Color(0xFF9E9E9E),
                        fontSize: 14,
                      ),
                      backgroundColor: const Color(0xFFF0F0F0),
                      selectedColor: const Color(0xFFC7CEEA),
                      shape: const StadiumBorder(
                        side: BorderSide(color: Colors.transparent),
                      ),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Feed
            Expanded(
              child: userId == null
                  ? Center(
                      child: Text(
                        "Please sign in to view wishlist.",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF9E9E9E),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : StreamBuilder<List<String>>(
                      stream: _firestoreService.getWishlistStream(userId),
                      builder: (context, wishlistSnapshot) {
                        if (wishlistSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (wishlistSnapshot.hasError) {
                          return const Center(
                            child: Text("Error loading wishlist data."),
                          );
                        }

                        final favorites = wishlistSnapshot.data ?? [];

                        if (favorites.isEmpty) {
                          return Center(
                            child: Text(
                              "Your wishlist is empty.",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF9E9E9E),
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        if (_selectedCategory == WishlistCategory.trips) {
                          return StreamBuilder<List<Trip>>(
                            stream: _firestoreService.getPlannedTrips(),
                            builder: (context, tripSnapshot) {
                              if (!tripSnapshot.hasData) {
                                return const SizedBox();
                              }
                              final trips = tripSnapshot.data!
                                  .where((t) => favorites.contains(t.id))
                                  .toList();

                              final mappedItems = trips
                                  .map(
                                    (t) => WishlistItem(
                                      id: t.id,
                                      title: t.title,
                                      location: t.meetingPoint,
                                      imagePath: t.imageURL,
                                      rating: t.rating,
                                      description: t.description,
                                      category: WishlistCategory.trips,
                                      tags: ['Trip'],
                                    ),
                                  )
                                  .toList();

                              return _buildList(mappedItems, userId);
                            },
                          );
                        } else if (_selectedCategory ==
                            WishlistCategory.destinations) {
                          return StreamBuilder<List<Destination>>(
                            stream: _firestoreService.getDestinations(),
                            builder: (context, destSnapshot) {
                              if (!destSnapshot.hasData) {
                                return const SizedBox();
                              }
                              final dests = destSnapshot.data!
                                  .where((d) => favorites.contains(d.id))
                                  .toList();

                              final mappedItems = dests
                                  .map(
                                    (d) => WishlistItem(
                                      id: d.id,
                                      title: d.name,
                                      location: d.location,
                                      imagePath: d.imagePath,
                                      rating: d.rating,
                                      description: d.description,
                                      category: WishlistCategory.destinations,
                                      tags: ['Destination'],
                                    ),
                                  )
                                  .toList();

                              return _buildList(mappedItems, userId);
                            },
                          );
                        } else if (_selectedCategory ==
                            WishlistCategory.workshops) {
                          return StreamBuilder<List<Workshop>>(
                            stream: _firestoreService.getWorkshops(),
                            builder: (context, workSnapshot) {
                              if (!workSnapshot.hasData) {
                                return const SizedBox();
                              }
                              final works = workSnapshot.data!
                                  .where((w) => favorites.contains(w.id))
                                  .toList();

                              final mappedItems = works
                                  .map(
                                    (w) => WishlistItem(
                                      id: w.id,
                                      title: w.title,
                                      location: w.location,
                                      imagePath: w.imageURL,
                                      rating: w.rating,
                                      description: w.description,
                                      category: WishlistCategory.workshops,
                                      tags: [
                                        w.category.isNotEmpty
                                            ? w.category
                                            : 'Workshop',
                                      ],
                                    ),
                                  )
                                  .toList();

                              return _buildList(mappedItems, userId);
                            },
                          );
                        }

                        return const SizedBox();
                      },
                    ),
            ),
          ],
        ),
      ),
      // Empty bottom nav to maintain layout consistency if pushed,
      // but usually pushed screens don't have bottom navs unless desired.
      // The design requested to keep the icons for Home, Booking, Profile minimal.
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(
        0xFF76767F,
      ), // None highlighted, match unselected
      unselectedItemColor: const Color(0xFF76767F),
      showUnselectedLabels: true,
      elevation: 10,
      type: BottomNavigationBarType.fixed,
      currentIndex: 0, // Default to home since we came from there
      onTap: (index) {
        // Since this is pushed on top of Home, we can pop back to Home if index 0 is tapped.
        if (index == 0) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          // Provide basic routing for other tabs if they want to switch directly
          Navigator.of(context).popUntil((route) => route.isFirst);
          // Home screen would then need to handle tab switching,
          // but for simplicity we'll just pop for now or ignore.
        }
      },
      selectedLabelStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Booking',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
