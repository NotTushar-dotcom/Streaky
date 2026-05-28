import { StyleSheet, View } from 'react-native';

import { AppText } from '@/components/ui/AppText';
import { Spacing } from '@/theme';

function getGreeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

function getMotivationalSubtitle(completedCount: number, totalCount: number): string {
  if (completedCount === 0) return "Let's get those streaks going! 💪";
  if (completedCount === totalCount) return 'You crushed it today! 🏆';
  if (completedCount >= totalCount / 2) return "You're on fire, keep going! 🔥";
  return 'Great start, keep the momentum! ⚡';
}

interface GreetingHeaderProps {
  userName: string;
  completedCount: number;
  totalCount: number;
}

export function GreetingHeader({ userName, completedCount, totalCount }: GreetingHeaderProps) {
  const greeting = getGreeting();
  const subtitle = getMotivationalSubtitle(completedCount, totalCount);

  return (
    <View style={styles.container}>
      <AppText variant="hero">
        {greeting}, {userName}! 🔥
      </AppText>
      <AppText variant="body" color="secondary">
        {subtitle}
      </AppText>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    gap: Spacing.xs,
    paddingVertical: Spacing.sm,
  },
});
