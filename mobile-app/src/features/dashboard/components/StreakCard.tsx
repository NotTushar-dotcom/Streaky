import { StyleSheet, Text, View } from 'react-native';

import { GradientCard } from '@/components/ui/GradientCard';
import { WeekDots } from '@/components/ui/WeekDots';
import { CheckInButton } from '@/components/ui/CheckInButton';
import { AppText } from '@/components/ui/AppText';
import { CategoryThemes, FontFamily, Spacing } from '@/theme';
import type { Streak } from '@/features/streaks/types';

interface StreakCardProps {
  streak: Streak;
  onCheckIn: () => void;
}

export function StreakCard({ streak, onCheckIn }: StreakCardProps) {
  const categoryTheme = CategoryThemes[streak.category];

  return (
    <GradientCard accentColor={categoryTheme.color}>
      {/* Header: Emoji + Name | Fire + Count */}
      <View style={styles.headerRow}>
        <View style={styles.nameContainer}>
          <Text style={styles.emoji}>{streak.emoji}</Text>
          <AppText variant="h2">{streak.name}</AppText>
        </View>
        <View style={styles.streakCount}>
          <Text style={styles.fireEmoji}>🔥</Text>
          <Text style={[styles.countText, { color: categoryTheme.color }]}>
            {streak.currentStreak}
          </Text>
        </View>
      </View>

      {/* Target description */}
      <AppText variant="caption" color="secondary" style={styles.targetText}>
        {streak.targetDescription}
      </AppText>

      {/* Weekly dots */}
      <View style={styles.weekDotsContainer}>
        <WeekDots
          weekHistory={streak.weekHistory}
          accentColor={categoryTheme.color}
        />
      </View>

      {/* Check-in button */}
      <View style={styles.checkInContainer}>
        <CheckInButton isCompleted={streak.isCompletedToday} onPress={onCheckIn} />
      </View>
    </GradientCard>
  );
}

const styles = StyleSheet.create({
  headerRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  nameContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.sm,
  },
  emoji: {
    fontSize: 24,
  },
  streakCount: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  fireEmoji: {
    fontSize: 18,
  },
  countText: {
    fontSize: 24,
    fontFamily: FontFamily.heading,
  },
  targetText: {
    marginTop: Spacing.xs,
  },
  weekDotsContainer: {
    marginTop: Spacing.lg,
    paddingHorizontal: Spacing.xs,
  },
  checkInContainer: {
    marginTop: Spacing.lg,
    alignItems: 'center',
  },
});
