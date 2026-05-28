import { StyleSheet, Text, View } from 'react-native';

import { BorderRadius, FontFamily, Palette } from '@/theme';

const DAY_LABELS = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

interface WeekDotsProps {
  /** 7 booleans for Mon–Sun completion */
  weekHistory: boolean[];
  /** Category accent color for completed dots */
  accentColor: string;
}

export function WeekDots({ weekHistory, accentColor }: WeekDotsProps) {
  // Convert JS day (0 = Sunday) to our Mon-first index (0 = Monday)
  const jsDay = new Date().getDay();
  const todayIndex = jsDay === 0 ? 6 : jsDay - 1;

  return (
    <View style={styles.container}>
      {DAY_LABELS.map((label, index) => {
        const isFuture = index > todayIndex;
        const isToday = index === todayIndex;
        const isCompleted = weekHistory[index];

        return (
          <View key={index} style={styles.dayColumn}>
            <Text
              style={[
                styles.label,
                isToday && styles.labelToday,
              ]}
            >
              {label}
            </Text>
            <View
              style={[
                styles.dot,
                // Future days — very dim
                isFuture && styles.dotFuture,
                // Past completed — filled with accent color
                !isFuture && isCompleted && {
                  backgroundColor: accentColor,
                },
                // Past missed — dim gray
                !isFuture && !isCompleted && !isToday && styles.dotMissed,
                // Today completed — accent with glow
                isToday && isCompleted && {
                  backgroundColor: accentColor,
                  shadowColor: accentColor,
                  shadowOffset: { width: 0, height: 0 },
                  shadowOpacity: 0.6,
                  shadowRadius: 4,
                  elevation: 4,
                },
                // Today not completed — ring outline
                isToday && !isCompleted && {
                  backgroundColor: 'transparent',
                  borderWidth: 2,
                  borderColor: accentColor,
                },
              ]}
            />
          </View>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  dayColumn: {
    alignItems: 'center',
    gap: 6,
  },
  label: {
    fontSize: 11,
    fontFamily: FontFamily.bodySemiBold,
    color: Palette.textSecondary,
    textTransform: 'uppercase',
  },
  labelToday: {
    color: Palette.textPrimary,
  },
  dot: {
    width: 10,
    height: 10,
    borderRadius: BorderRadius.full,
  },
  dotFuture: {
    backgroundColor: 'rgba(148, 163, 184, 0.15)',
  },
  dotMissed: {
    backgroundColor: 'rgba(148, 163, 184, 0.3)',
  },
});
