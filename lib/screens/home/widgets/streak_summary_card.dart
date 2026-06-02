import 'package:flutter/material.dart';
import 'package:streaky/widgets/animated_counter.dart';

/// Summary card showing total streak with mascot overlay.
class StreakSummaryCard extends StatelessWidget {
  final int totalStreaks;
  final int bestStreak;
  final int totalCheckins;

  const StreakSummaryCard({
    super.key,
    required this.totalStreaks,
    required this.bestStreak,
    required this.totalCheckins,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF5A2219), // Glowing orange/copper at bottom-left
                  Color(0xFF1B112D), // Deep dark purple
                  Color(0xFF110D23), // Near-black dark blue
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                stops: [0.0, 0.55, 1.0],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF35244F).withAlpha(120),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFA5E03).withAlpha(15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                // Left Column: Total Streak
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFFFA5E03),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Current Streak',
                            style: TextStyle(
                              color: Colors.white.withAlpha(220),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          AnimatedCounter(
                            value: totalStreaks,
                            style: const TextStyle(
                              color: Color(0xFFFA5E03),
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'days',
                            style: TextStyle(
                              color: Color(0xFFFA5E03),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Vertical Divider
                Container(
                  width: 1.5,
                  height: 52,
                  color: Colors.white.withAlpha(25),
                ),
                const SizedBox(width: 20),

                // Right Column: Best Streak & Trophy
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFFB5A9F8), // Silver/light purple
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Best Streak',
                            style: TextStyle(
                              color: Colors.white.withAlpha(160),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$bestStreak',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                  text: 'days',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(140),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Space for Mascot on the right
                const SizedBox(width: 80),
              ],
            ),
          ),
          
          // Mascot overlapping top-right
          Positioned(
            top: -26,
            right: 0,
            child: Image.asset(
              'assets/images/fire_mascot.gif',
              width: 96,
              height: 96,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
