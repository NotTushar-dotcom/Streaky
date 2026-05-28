import { useMemo, useState } from 'react';
import { StyleSheet, View } from 'react-native';

import { Screen } from '@/components/layout/Screen';
import { AppText } from '@/components/ui/AppText';
import { GreetingHeader } from '@/features/dashboard/components/GreetingHeader';
import { StreakSummaryBar } from '@/features/dashboard/components/StreakSummaryBar';
import { StreakCard } from '@/features/dashboard/components/StreakCard';
import { mockStreaks } from '@/features/streaks/data/mock';
import { Spacing } from '@/theme';

export default function TodayScreen() {
  const [streaks, setStreaks] = useState(mockStreaks);

  const handleCheckIn = (streakId: string) => {
    setStreaks((prev) =>
      prev.map((s) =>
        s.id === streakId
          ? { ...s, isCompletedToday: !s.isCompletedToday }
          : s,
      ),
    );
  };

  const completedCount = useMemo(
    () => streaks.filter((s) => s.isCompletedToday).length,
    [streaks],
  );

  const bestStreak = useMemo(
    () => Math.max(...streaks.map((s) => s.bestStreak)),
    [streaks],
  );

  const overallScore = useMemo(
    () => Math.round((completedCount / streaks.length) * 100),
    [completedCount, streaks.length],
  );

  return (
    <Screen scrollable>
      <GreetingHeader
        userName="Tushar"
        completedCount={completedCount}
        totalCount={streaks.length}
      />

      <StreakSummaryBar
        bestStreak={bestStreak}
        completedToday={completedCount}
        totalStreaks={streaks.length}
        overallScore={overallScore}
      />

      {/* Section Header */}
      <View style={styles.sectionHeader}>
        <AppText variant="h1">Today&apos;s Streaks 🎯</AppText>
        <AppText variant="caption" color="secondary">
          {completedCount}/{streaks.length} completed
        </AppText>
      </View>

      {/* Streak Cards */}
      {streaks.map((streak) => (
        <StreakCard
          key={streak.id}
          streak={streak}
          onCheckIn={() => handleCheckIn(streak.id)}
        />
      ))}

      {/* Motivational Footer */}
      <View style={styles.footer}>
        <AppText variant="body" color="secondary" style={styles.footerText}>
          {completedCount === streaks.length
            ? 'You crushed every streak today! 🏆✨'
            : `${streaks.length - completedCount} more to go — you got this! 💪`}
        </AppText>
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  footer: {
    alignItems: 'center',
    paddingVertical: Spacing.lg,
  },
  footerText: {
    textAlign: 'center',
  },
});
