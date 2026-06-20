import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/booking.dart';
import '../widgets/booking_card.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'booking_detail_screen.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _activeTabIndex = 0; // 0 = Upcoming, 1 = Past, 2 = Cancelled
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6FC), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Bookings",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
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
                  
                if (_activeTabIndex != 2) ...[
                    const SizedBox(height: 4),
                    Text(
                      _activeTabIndex == 0
                          ? "Manage your upcoming adventures across Egypt."
                          : "Check your past adventure across Egypt.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Segmented Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildTabSegment("Upcoming", 0),
                    _buildTabSegment("Past", 1),
                    _buildTabSegment("Cancelled", 2),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Feed
            Expanded(
              child: userId == null
                  ? Center(
                      child: Text(
                        "Please sign in to see your bookings.",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF9E9E9E),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : StreamBuilder<List<Booking>>(
                      stream: _firestoreService.getUserBookings(userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "Error loading bookings.",
                              style: GoogleFonts.poppins(color: Colors.red),
                            ),
                          );
                        }

                        final allBookings = snapshot.data ?? [];
                        
                        // Filter
                        List<Booking> filteredBookings = [];
                        switch (_activeTabIndex) {
                          case 0:
                            filteredBookings = allBookings
                                .where((b) =>
                                    b.status == BookingStatus.confirmed ||
                                    b.status == BookingStatus.pendingPayment)
                                .toList();
                            break;
                          case 1:
                            // We don't have past logic implemented deeply, just return empty for now
                            filteredBookings = [];
                            break;
                          case 2:
                            filteredBookings = allBookings
                                .where((b) => b.status == BookingStatus.cancelled)
                                .toList();
                            break;
                        }

                        if (filteredBookings.isEmpty) {
                          return Center(
                            child: Text(
                              "No bookings found in this category.",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF9E9E9E),
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: filteredBookings.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return BookingCard(
                              booking: filteredBookings[index],
                              onViewDetails: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookingDetailScreen(
                                      booking: filteredBookings[index],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTabSegment(String title, int index) {
    final isActive = _activeTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFC7CEEA)
                : Colors.transparent, // Lavender if active
            borderRadius: BorderRadius.circular(26),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? const Color(0xFF1A1A2E)
                    : const Color(0xFF9E9E9E),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(
        0xFFF3B6D1,
      ), // Keeping consistency across screens
      unselectedItemColor: const Color(0xFF76767F),
      showUnselectedLabels: true,
      elevation: 10,
      type: BottomNavigationBarType.fixed,
      currentIndex: 1, // Booking is index 1
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
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
