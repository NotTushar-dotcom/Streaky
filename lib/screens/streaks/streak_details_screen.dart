import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';
import 'package:streaky/config/streak_categories.dart';
import 'package:streaky/models/streak_model.dart';
import 'package:streaky/models/checkin_model.dart';
import 'package:streaky/providers/auth_provider.dart';
import 'package:streaky/providers/streak_provider.dart';
import 'package:streaky/providers/user_provider.dart';
import 'package:streaky/services/firestore_service.dart';
import 'package:streaky/screens/streaks/widgets/add_streak_sheet.dart';

/// Screen showing detailed progress, statistics, weekly view,
/// check-in actions, and a full calendar history for a specific streak.
class StreakDetailsScreen extends StatefulWidget {
  final StreakModel streak;

  const StreakDetailsScreen({
    super.key,
    required this.streak,
  });

  @override
  State<StreakDetailsScreen> createState() => _StreakDetailsScreenState();
}

class _StreakDetailsScreenState extends State<StreakDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  String _getStreakSubtitle(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'coding':
        return 'Code daily. Build the future.';
      case 'gym':
        return 'Train hard. Build the body.';
      case 'learning':
        return 'Keep learning. Expand your mind.';
      case 'reading':
        return 'Read books. Grow your knowledge.';
      case 'meditation':
        return 'Find peace. Stay mindful.';
      case 'content_creation':
      case 'content creation':
        return 'Create things. Express yourself.';
      case 'journaling':
        return 'Write daily. Reflect on life.';
      case 'social_media':
      case 'social media':
        return 'Connect. Share your journey.';
      case 'self_improvement':
      case 'self improvement':
        return 'Improve daily. Level up.';
      default:
        return 'Stay consistent. Keep moving.';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  void _showEditStreak(BuildContext context, StreakModel currentStreak) {
    final authProvider = context.read<AuthProvider>();
    final streakProvider = context.read<StreakProvider>();
    
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddStreakSheet(
          streak: currentStreak,
          onSave: (updatedStreak) {
            streakProvider.updateStreak(
              authProvider.uid,
              currentStreak.id,
              updatedStreak.toMap(),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final streakProvider = context.watch<StreakProvider>();

    // Watch the provider list to get real-time state of the streak
    final streak = streakProvider.streaks.firstWhere(
      (s) => s.id == widget.streak.id,
      orElse: () => widget.streak,
    );

    final category = StreakCategories.byId(streak.category);
    final themeColor = category.color;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: AppColors.textPrimary,
            size: 32,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Streak Details',
          style: AppTextStyles.heading3.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surfaceLight.withAlpha(120),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            onPressed: () => _showEditStreak(context, streak),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: StreamBuilder<List<CheckinModel>>(
        stream: _firestoreService.streamCheckins(authProvider.uid, streak.id),
        builder: (context, snapshot) {
          final checkins = snapshot.data ?? [];
          final checkinDates = checkins.map((c) => c.date).toSet();

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. MAIN CARD (Emoji, Title, Description, Stats)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: themeColor.withAlpha(30),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withAlpha(15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Row for Emoji & Title info
                        Row(
                          children: [
                            // Emoji block with glow
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: themeColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: themeColor.withAlpha(40),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: themeColor.withAlpha(20),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                streak.emoji,
                                style: const TextStyle(fontSize: 30),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Title and Subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    streak.title,
                                    style: AppTextStyles.heading2.copyWith(
                                      fontSize: 22,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getStreakSubtitle(streak.category),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.surfaceLight, height: 1),
                        const SizedBox(height: 20),

                        // Stats Row (Current streak & Best streak)
                        Row(
                          children: [
                            // Current Streak
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '${streak.currentStreak}',
                                        style: AppTextStyles.streakNumber.copyWith(
                                          fontSize: 44,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'days',
                                        style: AppTextStyles.bodyBold.copyWith(
                                          color: AppColors.primaryOrange,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Current Streak',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Best Streak Chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.warning.withAlpha(20),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Best',
                                    style: AppTextStyles.label.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${streak.bestStreak} days',
                                    style: AppTextStyles.bodyBold.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w700,
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
                  
                  const SizedBox(height: 28),

                  // 2. THIS WEEK SECTION
                  Text(
                    'This Week',
                    style: AppTextStyles.heading4.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Weekday Circles Row
                  _buildWeeklyProgress(checkinDates, themeColor),

                  const SizedBox(height: 24),

                  // 3. CHECK-IN CTA BUTTON
                  _buildCheckInButton(context, authProvider, userProvider, streakProvider, streak),

                  const SizedBox(height: 32),

                  // 4. STREAK HISTORY (Calendar Grid)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Streak History',
                        style: AppTextStyles.heading4.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'View all',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.cyanHighlight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Monthly Calendar Widget
                  _buildCalendarCard(checkinDates, themeColor),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper widget to construct the weekly Mon-Sun progress dots
  Widget _buildWeeklyProgress(Set<String> checkinDates, Color themeColor) {
    final now = DateTime.now();
    final mondayOffset = now.weekday - 1;
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: mondayOffset));
    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final dateStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        final isCompleted = checkinDates.contains(dateStr);
        final isFuture = day.isAfter(now);
        final isToday = _isSameDay(day, now);

        return Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? themeColor.withAlpha(35)
                : isFuture
                    ? Colors.black.withAlpha(100)
                    : AppColors.surfaceLight,
            border: Border.all(
              color: isToday
                  ? AppColors.cyanHighlight
                  : isCompleted
                      ? themeColor.withAlpha(80)
                      : AppColors.surfaceLight.withAlpha(120),
              width: isToday ? 2.0 : 1.0,
            ),
            boxShadow: isCompleted
                ? [
                    BoxShadow(
                      color: themeColor.withAlpha(40),
                      blurRadius: 12,
                      spreadRadius: 0,
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            weekdays[i],
            style: GoogleFonts.outfit(
              color: isCompleted
                  ? themeColor
                  : isFuture
                      ? AppColors.textHint
                      : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );
      }),
    );
  }

  // Helper widget to build the premium Check In button
  Widget _buildCheckInButton(
    BuildContext context,
    AuthProvider authProvider,
    UserProvider userProvider,
    StreakProvider streakProvider,
    StreakModel streak,
  ) {
    final isCompleted = streak.completedToday;

    return GestureDetector(
      onTap: isCompleted
          ? null
          : () {
              streakProvider.checkIn(authProvider.uid, streak.id);
              userProvider.addXP(authProvider.uid, UserProvider.xpPerCheckin);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: isCompleted
              ? const LinearGradient(
                  colors: [
                    Color(0xFF1E3A2F),
                    Color(0xFF0F2D21),
                  ],
                )
              : const LinearGradient(
                  colors: [
                    Color(0xFFFF8A00),
                    Color(0xFFFF4D6A),
                    Color(0xFFFF1493),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? AppColors.limeSuccess.withAlpha(100) : Colors.transparent,
            width: isCompleted ? 1.0 : 0.0,
          ),
          boxShadow: isCompleted
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFFFF4D6A).withAlpha(50),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: isCompleted
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.limeSuccess,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Checked In for Today! 🎉',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.limeSuccess,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              )
            : Text(
                'Check In for Today 🔥',
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }

  // Helper widget to construct the history calendar card
  Widget _buildCalendarCard(Set<String> checkinDates, Color themeColor) {
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final totalDays = _daysInMonth(_selectedMonth);
    // Adjust weekday (Monday=1, Sunday=7)
    final firstWeekday = firstDayOfMonth.weekday;
    final paddingCells = firstWeekday - 1;

    final monthName = _getMonthName(_selectedMonth.month);
    final yearStr = '${_selectedMonth.year}';

    final weekLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.surfaceLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Month Header navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$monthName $yearStr',
                style: AppTextStyles.heading4.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.textPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // Prevent navigating to future months
                      final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                      final now = DateTime.now();
                      if (nextMonth.isBefore(DateTime(now.year, now.month + 1, 1))) {
                        setState(() {
                          _selectedMonth = nextMonth;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: _canGoForward()
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          
          const SizedBox(height: 16),

          // Weekday Labels M, T, W...
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekLabels.map((lbl) {
              return SizedBox(
                width: 32,
                child: Text(
                  lbl,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),
          const Divider(color: AppColors.surfaceLight, height: 1),
          const SizedBox(height: 12),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: paddingCells + totalDays,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              if (index < paddingCells) {
                return const SizedBox.shrink();
              }

              final dayNum = index - paddingCells + 1;
              final dayDate = DateTime(_selectedMonth.year, _selectedMonth.month, dayNum);
              final dateStr = '${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}';
              
              final isCompleted = checkinDates.contains(dateStr);
              final isFuture = dayDate.isAfter(DateTime.now());
              final isToday = _isSameDay(dayDate, DateTime.now());

              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? themeColor.withAlpha(35)
                      : isFuture
                          ? Colors.transparent
                          : AppColors.surfaceLight.withAlpha(120),
                  border: Border.all(
                    color: isToday
                        ? AppColors.cyanHighlight
                        : isCompleted
                            ? themeColor.withAlpha(80)
                            : Colors.transparent,
                    width: isToday ? 2.0 : 1.0,
                  ),
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: themeColor.withAlpha(30),
                            blurRadius: 10,
                            spreadRadius: 0,
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$dayNum',
                  style: GoogleFonts.outfit(
                    color: isCompleted
                        ? themeColor
                        : isFuture
                            ? AppColors.textHint
                            : AppColors.textSecondary,
                    fontWeight: isCompleted || isToday ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _canGoForward() {
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    final now = DateTime.now();
    return nextMonth.isBefore(DateTime(now.year, now.month + 1, 1));
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
