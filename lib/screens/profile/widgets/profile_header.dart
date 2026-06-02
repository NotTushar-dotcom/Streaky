import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';
import 'package:streaky/providers/auth_provider.dart';
import 'package:streaky/providers/user_provider.dart';
import 'package:streaky/widgets/animated_counter.dart';

/// Profile header with cartoon avatar, name, Edit badge, and stat cards.
class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final int currentStreak;
  final int bestStreak;
  final int totalCheckins;
  final int mascotLevel;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalCheckins,
    this.mascotLevel = 1,
  });

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: name);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Edit Profile Name', style: AppTextStyles.heading4),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Name cannot be empty';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Enter name',
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final newName = nameController.text.trim();
              Navigator.pop(dialogContext);

              try {
                final authProvider = context.read<AuthProvider>();
                final userProvider = context.read<UserProvider>();
                if (authProvider.isLoggedIn) {
                  await userProvider.updateProfile(authProvider.uid, {'name': newName});
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating name: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required int value,
    required String label,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted
                ? AppColors.cyanHighlight.withAlpha(120)
                : AppColors.surfaceLight,
            width: isHighlighted ? 1.5 : 1,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: AppColors.cyanHighlight.withAlpha(20),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedCounter(
              value: value,
              style: AppTextStyles.statNumber.copyWith(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isHighlighted ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Avatar (cartoon character with glow)
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPurple.withAlpha(80),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: AppColors.accentPurple.withAlpha(120),
              width: 2.5,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile_avatar.png',
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Name with green Edit badge
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name, style: AppTextStyles.heading2),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showEditProfileDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.limeSuccess.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.limeSuccess.withAlpha(80),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '✏',
                      style: TextStyle(fontSize: 10),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Edit',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.limeSuccess,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Bio tagline
        Text(
          'Building my best self 🚀',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textHint,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 24),

        // Stats row (bordered cards)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                value: currentStreak,
                label: 'Current Streak',
                color: AppColors.primaryOrange,
              ),
              _buildStatCard(
                value: bestStreak,
                label: 'Best Streak',
                color: AppColors.accentPurple,
              ),
              _buildStatCard(
                value: totalCheckins,
                label: 'Total Checkins',
                color: AppColors.cyanHighlight,
                isHighlighted: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
