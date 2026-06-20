import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';

class VibeListWidget extends StatelessWidget {
  final String itemId;

  const VibeListWidget({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().getVibesForItem(itemId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          final errorStr = snapshot.error.toString();
          if (errorStr.contains('permission-denied')) {
             return Center(
               child: Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Text(
                   "Please log in to view vibes.",
                   style: GoogleFonts.poppins(color: Colors.grey[600]),
                 ),
               ),
             );
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Unable to load vibes right now.",
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
          );
        }

        final vibes = List<Map<String, dynamic>>.from(snapshot.data ?? []);

        if (vibes.isEmpty) {
          return const SizedBox.shrink();
        }

        // Sort locally to avoid requiring a composite index in Firestore
        vibes.sort((a, b) {
          final timeA = a['timestamp'];
          final timeB = b['timestamp'];
          if (timeA == null || timeB == null) return 0;
          return timeB.compareTo(timeA); // Descending order
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              "Recent Vibes",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: vibes.length,
                itemBuilder: (context, index) {
                  final vibe = vibes[index];
                  final imageUrl = vibe['image_url'] as String?;
                  final timestamp = vibe['created_at'] as String?;
                  
                  String formattedTime = '';
                  if (timestamp != null) {
                    final date = DateTime.tryParse(timestamp);
                    if (date != null) {
                      formattedTime = DateFormat('MMM d, yyyy - h:mm a').format(date);
                    }
                  }

                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.grey[300],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        formattedTime,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
