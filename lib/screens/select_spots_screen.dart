import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'checkout_screen.dart';

class SelectSpotsScreen extends StatefulWidget {
  final String itemId;
  final String itemType; // 'trip' or 'workshop'
  final String title;
  final String imageUrl;
  final String pricePerPerson;
  final String dateRange;
  final String? hostName;

  const SelectSpotsScreen({
    super.key,
    required this.itemId,
    required this.itemType,
    required this.title,
    required this.imageUrl,
    required this.pricePerPerson,
    required this.dateRange,
    this.hostName,
  });

  @override
  State<SelectSpotsScreen> createState() => _SelectSpotsScreenState();
}

class _SelectSpotsScreenState extends State<SelectSpotsScreen>
    with SingleTickerProviderStateMixin {
  int _spotCount = 1;
  static const int _maxSpots = 10;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  double? _parsePrice(String priceStr) {
    final cleaned = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned);
  }

  String _formatTotalPrice() {
    final unitPrice = _parsePrice(widget.pricePerPerson);
    if (unitPrice == null) return widget.pricePerPerson;

    final total = unitPrice * _spotCount;
    // Preserve original currency symbol
    final currencyMatch = RegExp(r'[^\d\s.]+').firstMatch(widget.pricePerPerson);
    final currency = currencyMatch?.group(0) ?? '';
    // Check if currency is at the end (e.g. "500 EGP") or start (e.g. "$500")
    if (widget.pricePerPerson.trim().startsWith(RegExp(r'[0-9]'))) {
      return '${total.toStringAsFixed(total == total.roundToDouble() ? 0 : 2)} $currency'.trim();
    }
    return '$currency${total.toStringAsFixed(total == total.roundToDouble() ? 0 : 2)}'.trim();
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
          "Select Spots",
          style: GoogleFonts.poppins(
            color: AppTheme.darkBlue,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Item Card
                      _buildItemCard(),
                      const SizedBox(height: 32),
                      // Spot Selector
                      _buildSpotSelector(),
                      const SizedBox(height: 28),
                      // Price Breakdown
                      _buildPriceBreakdown(),
                    ],
                  ),
                ),
              ),
              // Continue Button
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            ),
            child: SizedBox(
              width: 110,
              height: 110,
              child: widget.imageUrl.startsWith('http')
                  ? Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey[300]),
                    )
                  : Image.asset(
                      widget.imageUrl.isEmpty
                          ? 'assets/images/cairo_pyramids.png'
                          : widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey[300]),
                    ),
            ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EEFB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.itemType == 'workshop' ? 'Workshop' : 'Trip',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF545D82),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 13, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.dateRange,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotSelector() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "How many spots?",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkBlue,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Select the number of travelers",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 28),
          // Stepper
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minus Button
              _buildStepperButton(
                icon: Icons.remove,
                onTap: _spotCount > 1
                    ? () => setState(() => _spotCount--)
                    : null,
                enabled: _spotCount > 1,
              ),
              const SizedBox(width: 28),
              // Count Display
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Container(
                  key: ValueKey<int>(_spotCount),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EEFB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.babyBlue.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$_spotCount',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkBlue,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 28),
              // Plus Button
              _buildStepperButton(
                icon: Icons.add,
                onTap: _spotCount < _maxSpots
                    ? () => setState(() => _spotCount++)
                    : null,
                enabled: _spotCount < _maxSpots,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Traveler label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4EC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_outline, size: 16, color: Color(0xFFD81B60)),
                const SizedBox(width: 6),
                Text(
                  '$_spotCount Female ${_spotCount == 1 ? 'Traveler' : 'Travelers'}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFD81B60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    VoidCallback? onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: enabled ? AppTheme.darkBlue : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppTheme.darkBlue.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.grey[400],
          size: 24,
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    final unitPrice = _parsePrice(widget.pricePerPerson);
    final hasParsedPrice = unitPrice != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Price per person row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Price per person",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                widget.pricePerPerson.replaceAll(
                    RegExp(r'\s*(per person|/ person)', caseSensitive: false),
                    ''),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.darkBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Number of spots row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Number of spots",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'x $_spotCount',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.darkBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE0E0E0), height: 1),
          const SizedBox(height: 16),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkBlue,
                ),
              ),
              Text(
                hasParsedPrice ? _formatTotalPrice() : widget.pricePerPerson,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
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
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CheckoutScreen(
                itemId: widget.itemId,
                itemType: widget.itemType,
                title: widget.title,
                imageUrl: widget.imageUrl,
                price: _formatTotalPrice(),
                dateRange: widget.dateRange,
                hostName: widget.hostName,
                guestCount: _spotCount,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.pink,
          foregroundColor: AppTheme.darkBlue,
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
            Text(
              "Continue to Checkout",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }
}
