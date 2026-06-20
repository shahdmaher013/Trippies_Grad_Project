import 'package:flutter/material.dart';
import 'sos_screen.dart';
import 'chat_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/feature_card.dart';
import '../widgets/section_header.dart';
import 'profile_screen.dart';
import 'bookings_screen.dart';
import 'wishlist_screen.dart';
import 'trips_screen.dart';
import 'destinations_screen.dart';
import 'workshops_screen.dart';
import '../models/trip.dart';
import '../models/destination.dart';
import '../models/workshop.dart';
import '../services/firestore_service.dart';
import 'trip_detail_screen.dart';
import 'destination_detail_screen.dart';
import 'workshop_detail_screen.dart';
import '../widgets/guest_gate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF6FC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Trippies",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBlue,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (GuestGate.check(context, featureName: 'Wishlist')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WishlistScreen()),
                );
              }
            },
            icon: const Icon(Icons.favorite_border, color: AppTheme.darkBlue),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              StreamBuilder<List<Trip>>(
                stream: FirestoreService().getPlannedTrips(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Error loading trips: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data!.take(3).toList();
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        '0 Trips found in database. Please check your Firebase collection.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  final cards = items
                      .map(
                        (t) => {
                          "title": t.title,
                          "imagePath": t.imageURL,
                          "onTap": () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TripDetailScreen(trip: t, isPrivate: false),
                            ),
                          ),
                        },
                      )
                      .toList();
                  return _buildSection(context, "Trips", cards);
                },
              ),
              StreamBuilder<List<Destination>>(
                stream: FirestoreService().getDestinations(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Error loading destinations: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data!.take(3).toList();
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        '0 Destinations found in database. Please check your Firebase collection.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  final cards = items
                      .map(
                        (d) => {
                          "title": d.name,
                          "imagePath": d.imagePath,
                          "onTap": () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DestinationDetailScreen(destination: d),
                            ),
                          ),
                        },
                      )
                      .toList();
                  return _buildSection(context, "Destinations", cards);
                },
              ),
              StreamBuilder<List<Workshop>>(
                stream: FirestoreService().getWorkshops(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Error loading workshops: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data!.take(3).toList();
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        '0 Workshops found in database. Please check your Firebase collection.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  final cards = items
                      .map(
                        (w) => {
                          "title": w.name,
                          "imagePath": w.imagePath,
                          "onTap": () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkshopDetailScreen(workshop: w),
                            ),
                          ),
                        },
                      )
                      .toList();
                  return _buildSection(context, "Workshops", cards);
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "chat_fab",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              );
            },
            backgroundColor: AppTheme.babyBlue,
            elevation: 4,
            mini: true,
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "sos_fab",
            onPressed: () {
              if (GuestGate.check(context, featureName: 'SOS Emergency')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SosScreen()),
                );
              }
            },
            backgroundColor: AppTheme.pink,
            elevation: 6,
            child: const Icon(Icons.sos, color: Colors.white, size: 28),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDADDFE), Color(0xFFF3E7E9)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF232946).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            right: 0,
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                SizedBox(width: 4),
                Icon(Icons.auto_awesome, color: Colors.white, size: 14),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back,",
                style: GoogleFonts.notoSerif(
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Good morning, ${FirebaseAuth.instance.currentUser?.displayName ?? 'User'} 👋",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: AppTheme.darkBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Search bar removed per user request

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Map<String, dynamic>> cards,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          onSeeAll: () {
            if (title == "Trips") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TripsScreen()),
              );
            } else if (title == "Destinations") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DestinationsScreen()),
              );
            } else if (title == "Workshops") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WorkshopsScreen()),
              );
            }
          },
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return FeatureCard(
                title: card["title"],
                imagePath: card["imagePath"],
                onTap: card["onTap"],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: AppTheme.pink,
      unselectedItemColor: const Color(0xFF76767F),
      showUnselectedLabels: true,
      elevation: 10,
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          if (GuestGate.check(context, featureName: 'Bookings')) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BookingsScreen()),
            );
          }
        }
        if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }
      },
      selectedLabelStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
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
