// Re-Focus - Progress_Bar.dart
// Calculate Total Screen Time and Update Progress Bar
// Zaid Malick

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressSection extends StatelessWidget {
  final Duration goalTime;
  final Duration totalScreenTime;

  const ProgressSection({
    super.key,
    required this.goalTime,
    required this.totalScreenTime,
  });

  @override
  Widget build(BuildContext context) {
    final totalHours = totalScreenTime.inHours;
    final totalMin = totalScreenTime.inMinutes.remainder(60);

    final goalHours = goalTime.inHours;
    final goalMin = goalTime.inMinutes.remainder(60);

    final remaining = goalTime - totalScreenTime;
    final hoursRemaining = remaining.inHours;
    final minRemaining = remaining.inMinutes.remainder(60);

    final progress = totalScreenTime.inSeconds / goalTime.inSeconds;
    final isOverLimit = progress >= 1.0;

    return Column(
      children: [
        Text(
          ' Total Screen Time: $totalHours''h $totalMin''m',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 40,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(
                      isOverLimit ? Colors.red : Colors.blue,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(),
                child: Center(
                  child: Text(
                    isOverLimit ?
                    'OVER THE GOAL' : '$hoursRemaining' 'h $minRemaining''m Remaining',
                    style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text(
              'Goal: $goalHours''h $goalMin''m',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ),
        ),
        const Divider(thickness: 2, indent: 20, endIndent: 20),
      ],
    );
  }
}
