import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/booking.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'payment_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String itemId;
  final String itemType; // 'trip', 'destination', 'workshop'
  final String title;
  final String imageUrl;
  final String price;
  final String dateRange;
  final String? hostName;
  final int guestCount;

  const CheckoutScreen({
    super.key,
    required this.itemId,
    required this.itemType,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.dateRange,
    this.hostName,
    this.guestCount = 1,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false;

  void _processPayment() async {
    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to book this item.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // In a real app, integrate Stripe or similar here.
      // We simulate successful payment directly.
      
      final booking = Booking(
        id: '', // Will be set by Firestore
        itemId: widget.itemId,
        userId: user.uid,
        status: BookingStatus.confirmed,
        totalPrice: widget.price,
        bookingDate: widget.dateRange,
        itemType: widget.itemType,
        guestCount: widget.guestCount,
        guestLabel: '${widget.guestCount} Female ${widget.guestCount == 1 ? "Traveler" : "Travelers"}',
        hostName: widget.hostName ?? '',
      );

      final displayId = await _firestoreService.createBooking(booking);
      
      // Update booking object with generated ID to pass to success screen
      final completedBooking = Booking(
        id: displayId, // We'll use displayId temporarily as ID for UI purposes
        itemId: booking.itemId,
        userId: booking.userId,
        status: booking.status,
        totalPrice: booking.totalPrice,
        bookingDate: booking.bookingDate,
        itemType: booking.itemType,
        guestCount: booking.guestCount,
        guestLabel: booking.guestLabel,
        bookingDisplayId: displayId,
        hostName: booking.hostName,
        title: widget.title,
        imagePath: widget.imageUrl,
        location: '', // Can be passed later if needed
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(booking: completedBooking),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process payment: $e')),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Checkout",
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A1A2E),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBookingSummaryCard(),
                    const SizedBox(height: 32),
                    _buildPaymentMethodSection(),
                  ],
                ),
              ),
            ),
            _buildBottomCTA(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummaryCard() {
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
          // Image Header
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: widget.imageUrl.startsWith('http')
                      ? Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                        )
                      : Image.asset(
                          widget.imageUrl.isEmpty ? 'assets/images/cairo_pyramids.png' : widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                        ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, color: Color(0xFF4CAF50), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Safety Verified",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF1A1A2E),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 8),
                    Text(
                      widget.dateRange,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 16, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.guestCount} Female ${widget.guestCount == 1 ? "Traveler" : "Travelers"}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE4EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Solo Traveler Friendly",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFD81B60),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFE0E0E0), height: 1),
                const SizedBox(height: 20),
                
                // Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Amount",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF1A1A2E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.price,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: const Color(0xFF8E7AB5),
                        fontWeight: FontWeight.bold,
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

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Payment Method",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "+ Add New Card",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC7CEEA),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Card Selection
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC7CEEA), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EEFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.credit_card, color: Color(0xFFC7CEEA)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Credit / Debit Card",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      "**** **** **** 4242",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.radio_button_checked, color: Color(0xFFC7CEEA)),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Encryption Notice
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EEFB).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, color: Color(0xFF9E9E9E), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Payments are securely processed and protected by industry standard encryption.",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF76767F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCTA() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 20,
          ),
        ],
      ),
      child: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2B5D3), // AppTheme.pink
                foregroundColor: const Color(0xFF1A1A2E), // Navy text
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Confirm & Pay ${widget.price}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
