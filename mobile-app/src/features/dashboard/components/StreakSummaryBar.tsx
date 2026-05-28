import { StyleSheet, Text, View } from 'react-native';

import { GradientCard } from '@/components/ui/GradientCard';
import { FontFamily, Palette } from '@/theme';

interface StreakSummaryBarProps {
  bestStreak: number;
  completedToday: number;
  totalStreaks: number;
  overallScore: number;
}

interface StatItemProps {
  emoji: string;
  value: string;
  label: string;
  valueColor: string;
}

function StatItem({ emoji, value, label, valueColor }: StatItemProps) {
  return (
    <View style={styles.statItem}>
      <Text style={styles.emoji}>{emoji}</Text>
      <Text style={[styles.value, { color: valueColor }]}>{value}</Text>
      <Text style={styles.label}>{label}</Text>
    </View>
  );
}

export function StreakSummaryBar({
  bestStreak,
  completedToday,
  totalStreaks,
  overallScore,
}: StreakSummaryBarProps) {
  return (
    <GradientCard>
      <View style={styles.container}>
        <StatItem
          emoji="🔥"
          value={String(bestStreak)}
          label="Best"
          valueColor={Palette.orangeGlow}
        />
        <View style={styles.divider} />
        <StatItem
          emoji="✅"
          value={`${completedToday}/${totalStreaks}`}
          label="Today"
          valueColor={Palette.success}
        />
        <View style={styles.divider} />
        <StatItem
          emoji="⚡"
          value={`${overallScore}%`}
          label="Score"
          valueColor={Palette.cyan}
        />
      </View>
    </GradientCard>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
  },
  statItem: {
    alignItems: 'center',
    gap: 2,
    flex: 1,
  },
  emoji: {
    fontSize: 20,
    marginBottom: 2,
  },
  value: {
    fontSize: 22,
    fontFamily: FontFamily.heading,
  },
  label: {
    fontSize: 12,
    fontFamily: FontFamily.bodyRegular,
    color: Palette.textSecondary,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  divider: {
    width: 1,
    height: 40,
    backgroundColor: 'rgba(148, 163, 184, 0.15)',
  },
});
