import 'package:flutter/material.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';

/// Settings list for the profile screen.
class SettingsList extends StatelessWidget {
  final VoidCallback onReminders;
  final VoidCallback onExportData;
  final VoidCallback onAbout;

  const SettingsList({
    super.key,
    required this.onReminders,
    required this.onExportData,
    required this.onAbout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SettingsItem(
          icon: Icons.notifications_rounded,
          label: 'Reminders',
          color: AppColors.cyanHighlight,
          onTap: onReminders,
        ),
        _SettingsItem(
          icon: Icons.download_rounded,
          label: 'Export Data',
          color: AppColors.limeSuccess,
          onTap: onExportData,
        ),
        _SettingsItem(
          icon: Icons.info_outline_rounded,
          label: 'About Streaky',
          color: AppColors.accentPurple,
          onTap: onAbout,
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.surfaceLight.withAlpha(40),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
