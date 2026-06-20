import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/booking.dart';
import '../models/trip.dart';
import '../models/destination.dart';
import '../models/workshop.dart';
import '../services/firestore_service.dart';

class BookingCard extends StatefulWidget {
  final Booking booking;
  final VoidCallback onViewDetails;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onViewDetails,
  });

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItemDetails();
  }

  Future<void> _loadItemDetails() async {
    // If already loaded, skip
    if (widget.booking.title != 'Loading...') {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final item = await FirestoreService().getItemById(widget.booking.itemId);
      if (item != null) {
        if (item is Trip) {
          widget.booking.title = item.title;
          widget.booking.location = item.meetingPoint;
          widget.booking.imagePath = item.imageURL;
          widget.booking.tags = ['Trip'];
        } else if (item is Destination) {
          widget.booking.title = item.name;
          widget.booking.location = item.location;
          widget.booking.imagePath = item.imagePath;
          widget.booking.tags = ['Destination'];
        } else if (item is Workshop) {
          widget.booking.title = item.title;
          widget.booking.location = item.location;
          widget.booking.imagePath = item.imageURL;
          widget.booking.tags = [item.category.isNotEmpty ? item.category : 'Workshop'];
        }
      } else {
        widget.booking.title = 'Unknown Item';
      }
    } catch (e) {
      widget.booking.title = 'Error loading item';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header with Status Badge
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: widget.booking.imagePath.startsWith('http')
                      ? Image.network(
                          widget.booking.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFDADDFE),
                            child: const Icon(
                              Icons.landscape,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                        )
                      : Image.asset(
                          widget.booking.imagePath.isEmpty
                              ? 'assets/images/cairo_pyramids.png' // default fallback
                              : widget.booking.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFDADDFE),
                            child: const Icon(
                              Icons.landscape,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                        ),
                ),
                // Status Badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.booking.status.color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.booking.status.label,
                      style: GoogleFonts.poppins(
                        color: widget.booking.status.textColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                _isLoading
                    ? Container(
                        height: 20,
                        width: 150,
                        color: Colors.grey[200],
                      )
                    : Text(
                        widget.booking.title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                const SizedBox(height: 12),

                // Metadata Row
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Color(0xFF9E9E9E),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.booking.dateRange,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF9E9E9E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFF9E9E9E),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _isLoading
                                ? Container(
                                    height: 12,
                                    width: 80,
                                    color: Colors.grey[200],
                                  )
                                : Text(
                                    widget.booking.location,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF9E9E9E),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons & Tags
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Tags
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.booking.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFCE4EC), // Light pink
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFD81B60),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Primary Button (Right aligned, hidden for cancelled)
                    if (widget.booking.status == BookingStatus.confirmed ||
                        widget.booking.status == BookingStatus.pendingPayment)
                      ElevatedButton(
                        onPressed: widget.onViewDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFF4C2D7,
                          ), // Coral/Pink
                          foregroundColor: const Color(0xFF1A1A2E),
                          elevation: 0,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'View details',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
