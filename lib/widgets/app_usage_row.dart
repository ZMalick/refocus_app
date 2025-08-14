// Re-Focus - App_Usage_Row.dart
// Get individual app usage data and output it
// Zaid Malick

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppUsageRow extends StatelessWidget {
  final String appName;
  final String opens;
  final String timeUsed;
  final ImageProvider appIcon;

  const AppUsageRow({
    super.key,
    required this.appName,
    required this.opens,
    required this.timeUsed,
    required this.appIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: appIcon,
              radius: 12,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: Text(
                appName,
                maxLines: 1,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
        SizedBox(
          width: 30,
          child: Text(
            opens,
            maxLines: 1,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ),
        SizedBox(
          width: 90,
          child: Text(
            timeUsed,
            maxLines: 1,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
