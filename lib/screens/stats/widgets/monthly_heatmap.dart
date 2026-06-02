import 'package:flutter/material.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';

/// Monthly activity heatmap grid.
class MonthlyHeatmap extends StatelessWidget {
  /// Map of 'YYYY-MM-DD' → check-in count for the month.
  final Map<String, int> activityData;
  final DateTime month;

  const MonthlyHeatmap({
    super.key,
    required this.activityData,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday =
        DateTime(month.year, month.month, 1).weekday; // 1=Mon, 7=Sun

    // Build grid cells: blanks for offset + days of month
    final cells = <Widget>[];

    // Day labels
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    for (final label in dayLabels) {
      cells.add(Center(
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(fontSize: 10),
        ),
      ));
    }

    // Blank cells for offset (Monday=1 means 0 blanks, Sunday=7 means 6)
    final offset = firstWeekday - 1;
    for (int i = 0; i < offset; i++) {
      cells.add(const SizedBox());
    }

    // Day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final dateStr =
          '${month.year}-${month.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final count = activityData[dateStr] ?? 0;
      final isToday = DateTime.now().year == month.year &&
          DateTime.now().month == month.month &&
          DateTime.now().day == day;

      cells.add(_HeatmapCell(
        count: count,
        isToday: isToday,
        day: day,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month label
        Text(
          _monthName(month.month),
          style: AppTextStyles.label,
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: cells,
        ),
      ],
    );
  }

  String _monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[month];
  }
}

class _HeatmapCell extends StatelessWidget {
  final int count;
  final bool isToday;
  final int day;

  const _HeatmapCell({
    required this.count,
    required this.isToday,
    required this.day,
  });

  Color get _cellColor {
    if (count == 0) return AppColors.surfaceLight;
    if (count == 1) return AppColors.limeSuccess.withAlpha(80);
    if (count == 2) return AppColors.limeSuccess.withAlpha(140);
    return AppColors.limeSuccess;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cellColor,
        borderRadius: BorderRadius.circular(4),
        border: isToday
            ? Border.all(color: AppColors.primaryOrange, width: 1.5)
            : null,
        boxShadow: count > 0
            ? [
                BoxShadow(
                  color: AppColors.limeSuccess.withAlpha(20),
                  blurRadius: 4,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          '$day',
          style: AppTextStyles.caption.copyWith(
            fontSize: 9,
            color: count > 0 ? AppColors.background : AppColors.textHint,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
