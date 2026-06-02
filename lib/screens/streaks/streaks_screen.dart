import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';
import 'package:streaky/providers/auth_provider.dart';
import 'package:streaky/providers/streak_provider.dart';
import 'package:streaky/models/streak_model.dart';
import 'widgets/streak_card.dart';
import 'widgets/category_chips.dart';
import 'widgets/add_streak_sheet.dart';

/// Screen 3 — My Streaks
///
/// All streaks with search, category filters, grid view, and add button.
class StreaksScreen extends StatefulWidget {
  const StreaksScreen({super.key});

  @override
  State<StreaksScreen> createState() => _StreaksScreenState();
}

class _StreaksScreenState extends State<StreaksScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final streakProvider = context.watch<StreakProvider>();

    var filteredStreaks = streakProvider.activeStreaks;

    // Filter by category
    if (_selectedCategory != 'all') {
      filteredStreaks = filteredStreaks
          .where((s) => s.category == _selectedCategory)
          .toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filteredStreaks = filteredStreaks
          .where((s) =>
              s.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text('My Streaks', style: AppTextStyles.heading2),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${streakProvider.activeStreaks.length}',
                      style: AppTextStyles.bodyBold.copyWith(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Search streaks...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textHint,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Category chips
            CategoryChips(
              selectedCategory: _selectedCategory,
              onSelected: (cat) => setState(() => _selectedCategory = cat),
            ),

            const SizedBox(height: 16),

            // Grid
            Expanded(
              child: filteredStreaks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🔍', style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No streaks found'
                                : 'No streaks in this category',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: filteredStreaks.length,
                      itemBuilder: (context, index) {
                        final streak = filteredStreaks[index];
                        return StreakCard(
                          streak: streak,
                          onTap: () {
                            _showAddStreak(
                              context,
                              authProvider,
                              streakProvider,
                              streak: streak,
                            );
                          },
                          onDelete: () {
                            _confirmDelete(context, streak.title, () {
                              streakProvider.deleteStreak(
                                authProvider.uid,
                                streak.id,
                              );
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStreak(context, authProvider, streakProvider),
        backgroundColor: AppColors.primaryOrange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        label: Text('Add Streak', style: AppTextStyles.button),
      ),
    );
  }

  void _showAddStreak(
    BuildContext context,
    AuthProvider authProvider,
    StreakProvider streakProvider, {
    StreakModel? streak,
  }) {
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
          streak: streak,
          onSave: (updatedStreak) {
            if (streak == null) {
              streakProvider.addStreak(authProvider.uid, updatedStreak);
            } else {
              streakProvider.updateStreak(
                authProvider.uid,
                streak.id,
                updatedStreak.toMap(),
              );
            }
          },
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    String title,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Delete Streak', style: AppTextStyles.heading4),
        content: Text(
          'Are you sure you want to delete "$title"? This action cannot be undone.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
