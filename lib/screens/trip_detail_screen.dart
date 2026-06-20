import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/trip.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../widgets/vibe_check_widget.dart';
import '../widgets/vibe_list_widget.dart';
import '../widgets/review_input_widget.dart';
import '../widgets/review_list_widget.dart';
import '../widgets/guest_gate.dart';
import 'home_screen.dart';
import 'bookings_screen.dart';
import 'profile_screen.dart';
import 'select_spots_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;
  final bool isPrivate;

  const TripDetailScreen({
    super.key,
    required this.trip,
    this.isPrivate = false,
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  int _activeTab = 0;
  int _selectedPrivateIndex = 0;

  static const _navy = Color(0xFF1A1A2E);
  static const _lavender = Color(0xFFC7CEEA);
  // ignore: unused_field
  static const _bg = Color(0xFFFFF6FC);
  static const _cardBg = Color(0xFFF0EEFB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF6FC),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(child: _buildLocationRow()),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(child: _buildStatsBar()),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(child: _buildTabBar()),
              SliverToBoxAdapter(child: _buildTabContent()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBookingBar()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSliverAppBar() {
    final h = MediaQuery.of(context).size.height;
    return SliverAppBar(
      pinned: true,
      expandedHeight: h * 0.45,
      backgroundColor: _navy,
      elevation: 0,
      iconTheme: const IconThemeData(color: _lavender),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: _lavender),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: Text("Trippies", style: AppTheme.appBarTitle),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: StreamBuilder<List<String>>(
              stream: AuthService().currentUser?.uid != null 
                  ? FirestoreService().getWishlistStream(AuthService().currentUser!.uid) 
                  : const Stream.empty(),
              builder: (context, snapshot) {
                final isWishlisted = snapshot.data?.contains(widget.trip.id) ?? false;
                return IconButton(
                  icon: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? Colors.red : Colors.white,
                  ),
                  onPressed: () async {
                    if (GuestGate.check(context, featureName: 'Wishlist')) {
                      final uid = AuthService().currentUser?.uid;
                      if (uid != null) {
                        await FirestoreService().toggleFavorite(uid, widget.trip.id);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please log in to add to wishlist')),
                        );
                      }
                    }
                  },
                );
              },
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned.fill(
              child: Image(
                image: widget.trip.imagePath.trim().startsWith('http')
                    ? NetworkImage(widget.trip.imagePath.trim())
                    : AssetImage(widget.trip.imagePath.isNotEmpty
                        ? widget.trip.imagePath.trim()
                        : 'assets/images/placeholder.png') as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0, height: 150,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter, end: Alignment.topCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -1,
              left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  color: _navy.withValues(alpha: 0.85),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30), topRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(widget.trip.title,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(children: [
                        const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                        const SizedBox(width: 4),
                        Text(widget.trip.rating.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                                color: _navy,
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow() {
    final loc = widget.trip.location.isNotEmpty
        ? widget.trip.location
        : widget.trip.meetingPoint;
    if (loc.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: [
        const Icon(Icons.location_on, color: Colors.grey, size: 16),
        const SizedBox(width: 8),
        Expanded(
            child: Text(loc,
                style: GoogleFonts.poppins(
                    color: Colors.grey[600], fontSize: 13))),
      ]),
    );
  }

  // ── Stats Bar ──
  Widget _buildStatsBar() {
    final priceLabel = widget.isPrivate
        ? widget.trip.pricePrivate
        : widget.trip.pricePlanned;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _statCol(Icons.access_time_outlined, widget.trip.tripDuration),
            Container(width: 1, height: 30, color: Colors.grey[300]),
            _statCol(Icons.people_outline, "No Min"),
            Container(width: 1, height: 30, color: Colors.grey[300]),
            _statCol(Icons.account_balance_wallet_outlined,
                priceLabel.isNotEmpty ? priceLabel : widget.trip.price),
          ],
        ),
      ),
    );
  }

  Widget _statCol(IconData icon, String text) {
    return Expanded(
      child: Column(children: [
        Icon(icon, color: _navy, size: 24),
        const SizedBox(height: 4),
        Text(text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                color: _navy, fontSize: 11, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  // ── Tab Bar ──
  Widget _buildTabBar() {
    final tabs = ["Overview", "Itinerary", "Reviews", "What to bring"];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (i) {
            final active = _activeTab == i;
            return GestureDetector(
              onTap: () => setState(() => _activeTab = i),
              child: Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tabs[i],
                        style: GoogleFonts.poppins(
                          color: active ? _navy : Colors.grey[500],
                          fontSize: 15,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w400,
                        )),
                    const SizedBox(height: 4),
                    if (active)
                      Container(
                        height: 3, width: 24,
                        decoration: BoxDecoration(
                          color: _lavender,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 1:
        return _buildItinerary();
      case 2:
        return _buildReviews();
      case 3:
        return _buildWhatToBring();
      default:
        return widget.isPrivate ? _buildPrivateOverview() : _buildPlannedOverview();
    }
  }

  // ── Tab 0a: Planned Overview ──
  Widget _buildPlannedOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (widget.trip.fixedDates.isNotEmpty) ...[
          ...widget.trip.fixedDates.map((date) => _fixedDateCard(date)),
          const SizedBox(height: 24),
        ],
        Text("DESCRIPTION",
            style: GoogleFonts.poppins(
                color: _navy, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(widget.trip.description,
            style: GoogleFonts.poppins(
                color: const Color(0xFF6B6B6B), fontSize: 14, height: 1.6)),
      ]),
    );
  }

  Widget _fixedDateCard(String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg, borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("FIXED DATE",
            style: GoogleFonts.poppins(
                color: const Color(0xFF545D82),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Text(date,
            style: GoogleFonts.poppins(
                color: _navy, fontSize: 14, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  // ── Tab 0b: Private Overview ──
  Widget _buildPrivateOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Description
        Text(widget.trip.description,
            style: GoogleFonts.poppins(
                color: const Color(0xFF6B6B6B), fontSize: 14, height: 1.6)),
        const SizedBox(height: 24),
        // Places Included
        if (widget.trip.placesIncluded.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardBg, borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("PLACES INCLUDED",
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF545D82),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
                const SizedBox(height: 16),
                ...widget.trip.placesIncluded
                    .where((p) => p.trim().isNotEmpty)
                    .map((place) => _checkRow(place)),
              ],
            ),
          ),
        const SizedBox(height: 28),
        // Upcoming Private Trips
        Text("Upcoming Private Trips",
            style: GoogleFonts.poppins(
                color: _navy, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (widget.trip.fixedDates.isNotEmpty)
          ...List.generate(widget.trip.fixedDates.length, (i) {
            return _privateTripCard(widget.trip.fixedDates[i], i);
          })
        else
          Text("No upcoming private trips",
              style: GoogleFonts.poppins(
                  color: Colors.grey[500], fontSize: 14)),
      ]),
    );
  }

  Widget _privateTripCard(String dateStr, int index) {
    final selected = _selectedPrivateIndex == index;
    // Try to parse meaningful parts from the date string
    final parts = dateStr.split(RegExp(r'[-/\s]'));
    final month = parts.isNotEmpty ? parts[0] : '';
    final day = parts.length > 1 ? parts[1] : '';

    return GestureDetector(
      onTap: () => setState(() => _selectedPrivateIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _navy : Colors.grey[300]!,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          // Date box
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: _cardBg, borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(month,
                    style: GoogleFonts.poppins(
                        color: _navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                Text(day,
                    style: GoogleFonts.poppins(
                        color: _navy,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Time + availability
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr,
                    style: GoogleFonts.poppins(
                        color: _navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text("Only 2 spots left",
                    style: GoogleFonts.poppins(
                        color: const Color(0xFFE57373),
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          // Radio selector
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? _navy : Colors.grey[400]!,
                width: selected ? 3 : 1.5,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: _navy,
                      ),
                    ),
                  )
                : null,
          ),
        ]),
      ),
    );
  }

  // ── Tab 1: Itinerary ──
  Widget _buildItinerary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Itinerary",
            style: GoogleFonts.poppins(
                color: _navy, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text("check the itinerary of your trip",
            style: GoogleFonts.poppins(
                color: Colors.grey[500], fontSize: 13)),
        const SizedBox(height: 20),
        // Duration bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("DURATION",
                  style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              Text(widget.trip.tripDuration.isNotEmpty
                      ? widget.trip.tripDuration
                      : "Flexible",
                  style: GoogleFonts.poppins(
                      color: _navy,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text("PLACES INCLUDED",
            style: GoogleFonts.poppins(
                color: const Color(0xFF545D82),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5)),
        const SizedBox(height: 16),
        // Timeline
        if (widget.trip.itinerary.isNotEmpty)
          ...widget.trip.itinerary.map((item) => _timelineCard(
              item['time'] ?? '', item['place'] ?? ''))
        else if (widget.trip.placesIncluded.isNotEmpty)
          ...widget.trip.placesIncluded.asMap().entries.map((e) =>
              _timelineCard(_defaultTime(e.key), e.value))
        else
          Text("No itinerary available",
              style: GoogleFonts.poppins(
                  color: Colors.grey[500], fontSize: 14)),
      ]),
    );
  }

  String _defaultTime(int index) {
    final hour = 9 + index;
    return "${hour > 12 ? hour - 12 : hour}:00 ${hour >= 12 ? 'PM' : 'AM'}";
  }

  Widget _timelineCard(String time, String place) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        // Time column
        SizedBox(
          width: 60,
          child: Text(time,
              style: GoogleFonts.poppins(
                  color: _navy, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        // Dot + line
        Column(children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _lavender,
              border: Border.all(color: _navy, width: 2),
            ),
          ),
        ]),
        const SizedBox(width: 14),
        // Place card
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(place,
                style: GoogleFonts.poppins(
                    color: _navy, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ),
      ]),
    );
  }

  // ── Tab 2: Reviews ──
  Widget _buildReviews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReviewInputWidget(itemId: widget.trip.id),
          ReviewListWidget(itemId: widget.trip.id),
          const SizedBox(height: 32),
          Text(
            "Vibe Checks",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E2A47),
            ),
          ),
          const SizedBox(height: 16),
          VibeCheckWidget(itemId: widget.trip.id),
          VibeListWidget(itemId: widget.trip.id),
        ],
      ),
    );
  }

  // ── Tab 3: What to Bring ──
  Widget _buildWhatToBring() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("What to bring",
            style: GoogleFonts.poppins(
                color: _navy, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text("prepare everything you need for your trip",
            style: GoogleFonts.poppins(
                color: Colors.grey[500], fontSize: 13)),
        const SizedBox(height: 20),
        // Category pill
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text("ESSENTIALS & EXTRAS",
                style: GoogleFonts.poppins(
                    color: _navy,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
          ),
        ),
        const SizedBox(height: 20),
        // Checklist
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: (widget.trip.whatToBring.isNotEmpty
                    ? widget.trip.whatToBring
                    : ["Snacks", "Head scarf", "Comfortable shoes", "Water bottle", "Sunscreen"])
                .where((item) => item.trim().isNotEmpty)
                .map((item) => _checkRow(item))
                .toList(),
          ),
        ),
      ]),
    );
  }

  Widget _checkRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        const Icon(Icons.check_circle, color: _navy, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text.trim(),
              style: GoogleFonts.poppins(
                  color: const Color(0xFF4A4A4A),
                  fontSize: 13,
                  height: 1.4)),
        ),
      ]),
    );
  }

  // ── Sticky Booking Bar ──
  Widget _buildBookingBar() {
    final displayPrice = widget.isPrivate
        ? widget.trip.pricePrivate
        : widget.trip.pricePlanned;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("PRICE PER PERSON",
                  style: GoogleFonts.poppins(
                      color: Colors.grey[500],
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                (displayPrice.isNotEmpty ? displayPrice : widget.trip.price)
                    .replaceAll(RegExp(r'\s*(per person|/ person)', caseSensitive: false), '\nper person'),
                style: GoogleFonts.poppins(
                  color: _navy, 
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (GuestGate.check(context, featureName: 'Booking')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SelectSpotsScreen(
                    itemId: widget.trip.id,
                    itemType: 'trip',
                    title: widget.trip.title,
                    imageUrl: widget.trip.imageURL,
                    pricePerPerson: displayPrice.isNotEmpty ? displayPrice : widget.trip.price,
                    dateRange: widget.trip.fixedDates.isNotEmpty ? widget.trip.fixedDates[0] : 'Flexible',
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.pink,
            foregroundColor: AppTheme.darkBlue,
            elevation: 4,
            shadowColor: AppTheme.pink.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Reserve Spot",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Bottom Nav ──
  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF76767F),
      unselectedItemColor: const Color(0xFF76767F),
      showUnselectedLabels: true,
      elevation: 10,
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false);
        } else if (index == 1) {
          if (GuestGate.check(context, featureName: 'Bookings')) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const BookingsScreen()));
          }
        } else if (index == 2) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()));
        }
      },
      selectedLabelStyle:
          GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Booking'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile'),
      ],
    );
  }
}
