import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';
import 'package:streaky/providers/auth_provider.dart';
import 'package:streaky/providers/streak_provider.dart';
import 'package:streaky/services/notification_service.dart';
import 'package:streaky/widgets/glow_card.dart';
import 'widgets/reminder_card.dart';
import 'widgets/tone_selector.dart';

/// Screen 6 — Reminder & Voice Center
///
/// UI for reminders, custom schedules, AI motivation,
/// and voice streak creation (placeholder for future integration).
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  String _selectedTone = 'energetic';
  bool _smartNotifications = true;

  @override
  Widget build(BuildContext context) {
    final streakProvider = context.watch<StreakProvider>();
    final activeStreaks = streakProvider.activeStreaks;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Reminders & Voice', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Smart notifications toggle
            GlowCard(
              glowColor: AppColors.cyanHighlight,
              showGlow: _smartNotifications,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.cyanHighlight),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Smart Notifications',
                            style: AppTextStyles.bodyBold),
                        Text(
                          'AI-powered reminders at the right time',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _smartNotifications,
                    onChanged: (v) =>
                        setState(() => _smartNotifications = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Voice streak creation (placeholder)
            Text('Voice Controls', style: AppTextStyles.heading4),
            const SizedBox(height: 8),
            GlowCard(
              glowColor: AppColors.primaryOrange,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppColors.subtleGlow(AppColors.primaryOrange),
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to create a streak by voice',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Say: "Create a gym streak for every morning"',
                    style: AppTextStyles.caption.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Motivation tone
            Text('Motivation Tone', style: AppTextStyles.heading4),
            const SizedBox(height: 8),
            ToneSelector(
              selectedTone: _selectedTone,
              onSelected: (tone) =>
                  setState(() => _selectedTone = tone),
            ),

            const SizedBox(height: 24),

            // Streak reminders
            Text('Streak Reminders', style: AppTextStyles.heading4),
            const SizedBox(height: 8),

            if (activeStreaks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Create streaks to set up reminders.',
                  style: AppTextStyles.bodySmall,
                ),
              )
            else
              ...activeStreaks.map((streak) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ReminderCard(
                    emoji: streak.emoji,
                    title: streak.title,
                    time: streak.reminderTime,
                    isEnabled: streak.reminderEnabled,
                    onToggle: (enabled) async {
                      if (enabled) {
                        final granted = await NotificationService().requestPermissions();
                        if (!granted && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enable notifications in device settings to receive reminders.'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                      }
                      
                      if (context.mounted) {
                        final authProvider = context.read<AuthProvider>();
                        await streakProvider.updateStreak(
                          authProvider.uid,
                          streak.id,
                          {'reminderEnabled': enabled},
                        );
                      }
                    },
                  ),
                );
              }),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
