import 'package:flutter/material.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';
import 'package:streaky/config/streak_categories.dart';
import 'package:streaky/models/streak_model.dart';

/// Bottom sheet for creating a new streak.
class AddStreakSheet extends StatefulWidget {
  final StreakModel? streak;
  final ValueChanged<StreakModel> onSave;

  const AddStreakSheet({
    super.key,
    this.streak,
    required this.onSave,
  });

  @override
  State<AddStreakSheet> createState() => _AddStreakSheetState();
}

class _AddStreakSheetState extends State<AddStreakSheet> {
  final _titleController = TextEditingController();
  String _selectedCategory = 'general';
  String _selectedEmoji = '🔥';
  String _frequency = 'daily';
  bool _reminderEnabled = false;
  String _reminderTime = '8:00 PM';

  @override
  void initState() {
    super.initState();
    if (widget.streak != null) {
      _titleController.text = widget.streak!.title;
      _selectedCategory = widget.streak!.category;
      _selectedEmoji = widget.streak!.emoji;
      _frequency = widget.streak!.frequency;
      _reminderEnabled = widget.streak!.reminderEnabled;
      _reminderTime = widget.streak!.reminderTime;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final category = StreakCategories.byId(_selectedCategory);
    final streak = widget.streak != null
        ? widget.streak!.copyWith(
            title: title,
            emoji: _selectedEmoji,
            category: _selectedCategory,
            color: '#${category.color.toARGB32().toRadixString(16).substring(2)}',
            frequency: _frequency,
            reminderEnabled: _reminderEnabled,
            reminderTime: _reminderTime,
          )
        : StreakModel(
            id: '',
            title: title,
            emoji: _selectedEmoji,
            category: _selectedCategory,
            color: '#${category.color.toARGB32().toRadixString(16).substring(2)}',
            frequency: _frequency,
            reminderEnabled: _reminderEnabled,
            reminderTime: _reminderTime,
          );

    widget.onSave(streak);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: Text(
                widget.streak != null ? 'Edit Streak 🔥' : 'New Streak 🔥',
                style: AppTextStyles.heading3,
              ),
            ),
            const SizedBox(height: 20),

            // Name input
            Text('Streak Name', style: AppTextStyles.label),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: AppTextStyles.body,
              decoration: const InputDecoration(
                hintText: 'e.g., Morning Coding',
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 20),

            // Category selection
            Text('Category', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: StreakCategories.all.map((cat) {
                final isSelected = _selectedCategory == cat.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat.id;
                      _selectedEmoji = cat.emoji;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cat.color.withAlpha(25)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? cat.color : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          cat.label,
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected
                                ? cat.color
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Frequency selector
            Text('Frequency', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Row(
              children: ['daily', 'weekdays', 'weekly'].map((freq) {
                final isSelected = _frequency == freq;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _frequency = freq),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentPurple.withAlpha(25)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accentPurple
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        freq[0].toUpperCase() + freq.substring(1),
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected
                              ? AppColors.accentPurple
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Reminder section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reminder', style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Text(
                      _reminderEnabled ? 'Set for $_reminderTime' : 'Off',
                      style: AppTextStyles.caption.copyWith(
                        color: _reminderEnabled
                            ? AppColors.primaryOrange
                            : AppColors.textSecondary,
                        fontWeight: _reminderEnabled ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _reminderEnabled,
                  onChanged: (val) {
                    setState(() {
                      _reminderEnabled = val;
                    });
                  },
                ),
              ],
            ),
            if (_reminderEnabled) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  TimeOfDay initialTime = const TimeOfDay(hour: 20, minute: 0);
                  try {
                    final parts = _reminderTime.split(' ');
                    final timeParts = parts[0].split(':');
                    int hour = int.parse(timeParts[0]);
                    int minute = int.parse(timeParts[1]);
                    if (parts.length > 1) {
                      if (parts[1].toUpperCase() == 'PM' && hour < 12) hour += 12;
                      if (parts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;
                    }
                    initialTime = TimeOfDay(hour: hour, minute: minute);
                  } catch (e) {
                    debugPrint('Error parsing reminder time: $e');
                  }

                  final time = await showTimePicker(
                    context: context,
                    initialTime: initialTime,
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppColors.primaryOrange,
                            onPrimary: Colors.white,
                            surface: AppColors.surface,
                            onSurface: AppColors.textPrimary,
                          ),
                          dialogTheme: const DialogThemeData(
                            backgroundColor: AppColors.surface,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() {
                      _reminderTime = time.format(context);
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.surfaceLight.withAlpha(80),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: AppColors.primaryOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _reminderTime,
                        style: AppTextStyles.bodyBold.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Create/Save button
            GestureDetector(
              onTap: _submit,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF8A00),
                      Color(0xFFFF6B6B),
                      Color(0xFFFF1493),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8A00).withAlpha(40),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.streak != null ? 'Save Changes' : 'Add Streak',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
