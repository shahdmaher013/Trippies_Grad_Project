import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trip.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'guest_gate.dart';

class TripCard extends StatefulWidget {
  final Trip trip;
  final VoidCallback onViewDetails;

  const TripCard({super.key, required this.trip, required this.onViewDetails});

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {

  Widget _buildImage(String imagePath) {
    if (imagePath.isEmpty) {
      return _buildFallback();
    }
    if (imagePath.trim().startsWith('http')) {
      return Image.network(
        imagePath.trim(),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFFDADDFE),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFA5B4FC)),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: const Color(0xFFDADDFE),
      child: const Icon(
        Icons.landscape,
        color: Colors.white54,
        size: 40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Base Image Layer
            _buildImage(widget.trip.imagePath),

            // Gradient Overlay for Text Legibility (Bottom 40%)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
              ),
            ),

            // Heart Icon (Top Right)
            Positioned(
              top: 16,
              right: 16,
              child: StreamBuilder<List<String>>(
                stream: AuthService().currentUser?.uid != null
                    ? FirestoreService().getWishlistStream(AuthService().currentUser!.uid)
                    : const Stream.empty(),
                builder: (context, snapshot) {
                  final isWishlisted = snapshot.data?.contains(widget.trip.id) ?? false;
                  return GestureDetector(
                    onTap: () async {
                      if (GuestGate.check(context, featureName: 'Wishlist')) {
                        final uid = AuthService().currentUser?.uid;
                        if (uid != null) {
                          await FirestoreService().toggleFavorite(uid, widget.trip.id);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Information (Bottom Left)
            Positioned(
              bottom: 16,
              left: 16,
              right: 110, // Leave room for button
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.trip.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${widget.trip.duration} • ${widget.trip.price}'.replaceAll(RegExp(r'\s*(per person|/ person)', caseSensitive: false), '\nper person'),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Button (Bottom Right)
            Positioned(
              bottom: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: widget.onViewDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2B5D3),
                  foregroundColor: const Color(0xFF70425B),
                  elevation: 0,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'View Details',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
